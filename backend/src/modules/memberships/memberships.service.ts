import { HttpStatus, Injectable } from '@nestjs/common';
import { Membership, Prisma, Tier } from '@prisma/client';
import { ClockService } from '../../common/clock/clock.service';
import { addDays, diffInDays, LocalDate } from '../../common/date/gym-date';
import { AppException } from '../../common/errors/app.exception';
import { ErrorCode } from '../../common/errors/error-codes';
import { PrismaService } from '../../prisma/prisma.service';
import { replayPayments } from './membership-rules';

type Tx = Prisma.TransactionClient;

/**
 * Membership state changes shared by members, payments and tier changes.
 * Every method takes a transaction client; callers own the transaction.
 */
@Injectable()
export class MembershipsService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly clock: ClockService,
  ) {}

  /**
   * Locks the member's membership row for the rest of the transaction, so concurrent
   * payments/voids/tier changes on the same member are serialized.
   */
  async lockByMember(tx: Tx, memberId: string): Promise<Membership> {
    await tx.$queryRaw`SELECT id FROM "Membership" WHERE "memberId" = ${memberId} FOR UPDATE`;
    const m = await tx.membership.findUnique({ where: { memberId } });
    if (!m) throw new AppException(HttpStatus.NOT_FOUND, ErrorCode.NOT_FOUND);
    return m;
  }

  async lockById(tx: Tx, membershipId: string): Promise<Membership> {
    await tx.$queryRaw`SELECT id FROM "Membership" WHERE id = ${membershipId} FOR UPDATE`;
    return tx.membership.findUniqueOrThrow({ where: { id: membershipId } });
  }

  /**
   * Changes the tier now and records a TierChange.
   * [R-16] Leaving PREMIUM unassigns the trainer. [R-15] Nothing else is touched, so all
   * history (payments, check-ins, later workouts, measurements, notes) is kept.
   */
  async setTier(tx: Tx, m: Membership, toTier: Tier, changedById: string): Promise<Membership> {
    if (m.tier === toTier) return m;
    const updated = await tx.membership.update({
      where: { id: m.id },
      data: {
        tier: toTier,
        ...(m.tier === Tier.PREMIUM && toTier !== Tier.PREMIUM ? { trainerId: null } : {}),
      },
    });
    await tx.tierChange.create({
      data: { membershipId: m.id, fromTier: m.tier, toTier, changedById },
    });
    return updated;
  }

  /**
   * [R-09] Recomputes the scheduled tier: the first future period (start > today) whose
   * payment tier differs from the current tier. Only one switch is pending at a time; any
   * later one is found again after it is applied.
   */
  async refreshNextTier(tx: Tx, m: Membership, today: LocalDate): Promise<Membership> {
    const future = await tx.payment.findMany({
      where: {
        membershipId: m.id,
        voidedAt: null,
        months: { gt: 0 },
        periodStart: { gt: today },
      },
      orderBy: { periodStart: 'asc' },
    });
    const next = future.find((p) => p.tier !== m.tier);
    const nextTier = next?.tier ?? null;
    const nextTierStartDate = next?.periodStart ?? null;
    if (
      m.nextTier === nextTier &&
      (m.nextTierStartDate?.getTime() ?? null) === (nextTierStartDate?.getTime() ?? null)
    ) {
      return m;
    }
    return tx.membership.update({ where: { id: m.id }, data: { nextTier, nextTierStartDate } });
  }

  /**
   * [R-09] Applies a scheduled tier whose period has started. Called on every read/write
   * of a membership (and by the daily job from D8), so the stored tier is always current.
   */
  async applyScheduledTier(tx: Tx, m: Membership, today: LocalDate): Promise<Membership> {
    let current = m;
    while (
      current.nextTier &&
      current.nextTierStartDate &&
      diffInDays(today, current.nextTierStartDate) >= 0
    ) {
      const source = await tx.payment.findFirst({
        where: {
          membershipId: current.id,
          voidedAt: null,
          tier: current.nextTier,
          periodStart: current.nextTierStartDate,
        },
        orderBy: { paidAt: 'desc' },
      });
      current = await this.setTier(
        tx,
        current,
        current.nextTier,
        source?.recordedById ?? current.memberId,
      );
      current = await this.refreshNextTier(tx, current, today);
    }
    return current;
  }

  /** Reads a member's membership with any due scheduled tier applied. */
  async getCurrentByMember(memberId: string): Promise<Membership | null> {
    const today = this.clock.today();
    const m = await this.prisma.membership.findUnique({ where: { memberId } });
    if (!m) return null;
    if (!m.nextTierStartDate || diffInDays(today, m.nextTierStartDate) < 0) return m;
    return this.prisma.$transaction(async (tx) =>
      this.applyScheduledTier(tx, await this.lockByMember(tx, memberId), today),
    );
  }

  /** Applies every due scheduled tier (used before list queries and by the daily job). */
  async applyAllDueScheduledTiers(): Promise<number> {
    const today = this.clock.today();
    const due = await this.prisma.membership.findMany({
      where: { nextTierStartDate: { lte: today } },
      select: { memberId: true },
    });
    for (const { memberId } of due) {
      await this.prisma.$transaction(async (tx) =>
        this.applyScheduledTier(tx, await this.lockByMember(tx, memberId), today),
      );
    }
    return due.length;
  }

  /**
   * [R-12] Recalculates periods and dates from the non-voided payments (PLAN section 8.3)
   * and stores periodStart/periodEnd on each payment. With no period left, the membership
   * keeps its start date and ends the day before (expired, 0 days left).
   * Tier is not reverted (docs/DECISIONS.md); the scheduled tier is recomputed.
   */
  async recalculate(tx: Tx, m: Membership, today: LocalDate): Promise<Membership> {
    const payments = await tx.payment.findMany({ where: { membershipId: m.id } });
    const result = replayPayments(
      payments.map((p) => ({
        id: p.id,
        kind: p.kind,
        months: p.months,
        paidAt: p.paidAt,
        periodStart: p.periodStart,
        voidedAt: p.voidedAt,
      })),
      this.clock.timeZone,
    );
    for (const p of payments) {
      const period = result.periods.get(p.id);
      if (!period) continue;
      if (
        p.periodStart?.getTime() !== period.start.getTime() ||
        p.periodEnd?.getTime() !== period.end.getTime()
      ) {
        await tx.payment.update({
          where: { id: p.id },
          data: { periodStart: period.start, periodEnd: period.end },
        });
      }
    }
    const startDate = result.startDate ?? m.startDate;
    const endDate = result.endDate ?? addDays(m.startDate, -1);
    const updated = await tx.membership.update({
      where: { id: m.id },
      data: { startDate, endDate },
    });
    return this.refreshNextTier(tx, updated, today);
  }
}
