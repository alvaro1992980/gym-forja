import { HttpStatus, Injectable } from '@nestjs/common';
import { Membership, PaymentKind, PaymentMethod, Prisma, Tier } from '@prisma/client';
import { ClockService } from '../../common/clock/clock.service';
import {
  addDays,
  daysLeft,
  formatLocalDate,
  isExpired,
  parseLocalDate,
  startOfLocalDayUtc,
} from '../../common/date/gym-date';
import { AppException } from '../../common/errors/app.exception';
import { ErrorCode } from '../../common/errors/error-codes';
import { Paginated, paginated, skipTake } from '../../common/pagination/pagination';
import { PrismaService } from '../../prisma/prisma.service';
import { PricingService } from '../pricing/pricing.service';
import {
  CreatePaymentDto,
  ListPaymentsQueryDto,
  PaymentDto,
  PaymentPreviewDto,
  PaymentPreviewQueryDto,
  PaymentResultDto,
  PaymentTotalsDto,
  TierChangeDto,
  TierChangePreviewResultDto,
  TierChangeResultDto,
  VoidPaymentDto,
} from './dto';
import { PAYMENT_INCLUDE, PaymentWithRefs, toPaymentDto } from './mappers';
import {
  DEFAULT_CURRENCY,
  Decimal,
  formatMoney,
  hasNote,
  isNoteRequired,
  isUpgrade,
  money,
  previewTierChange,
  renewalPeriod,
  renewalTierTiming,
  suggestedAmount,
} from './membership-rules';
import { toMembershipSummary } from './membership-view';
import { MembershipsService } from './memberships.service';

function noteRequired(): AppException {
  return new AppException(HttpStatus.BAD_REQUEST, ErrorCode.AMOUNT_NOTE_REQUIRED);
}

@Injectable()
export class PaymentsService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly clock: ClockService,
    private readonly memberships: MembershipsService,
    private readonly pricing: PricingService,
  ) {}

  private async requireMembership(memberId: string) {
    const m = await this.memberships.getCurrentByMember(memberId);
    if (!m) throw new AppException(HttpStatus.NOT_FOUND, ErrorCode.NOT_FOUND);
    return m;
  }

  // ------------------------------------------------------------- renewals

  /** [R-07]/[R-08]/[R-10] What a renewal would buy, before the admin confirms. */
  async previewRenewal(memberId: string, q: PaymentPreviewQueryDto): Promise<PaymentPreviewDto> {
    const m = await this.requireMembership(memberId);
    const today = this.clock.today();
    const period = renewalPeriod(m.endDate, today, q.months);
    const price = await this.pricing.get(q.tier);
    return {
      periodStart: formatLocalDate(period.start),
      periodEnd: formatLocalDate(period.end),
      suggestedAmount: formatMoney(suggestedAmount(price.monthlyPrice, q.months)),
      currency: price.currency,
      tierApplies: renewalTierTiming({
        currentTier: m.tier,
        newTier: q.tier,
        wasExpired: isExpired(m.endDate, today),
        applyTierNow: false,
      }),
    };
  }

  /** [R-06]–[R-10] Records a RENEWAL and extends the membership, in one transaction. */
  async createRenewal(
    adminId: string,
    memberId: string,
    dto: CreatePaymentDto,
  ): Promise<PaymentResultDto> {
    const today = this.clock.today();
    const now = this.clock.now();
    const { payment, membership } = await this.prisma.$transaction(async (tx) => {
      let m = await this.memberships.lockByMember(tx, memberId);
      m = await this.memberships.applyScheduledTier(tx, m, today);

      const wasExpired = isExpired(m.endDate, today);
      const period = renewalPeriod(m.endDate, today, dto.months);
      const price = await this.pricing.get(dto.tier, tx);
      const suggested = suggestedAmount(price.monthlyPrice, dto.months);
      if (isNoteRequired(dto.amount, suggested) && !hasNote(dto.note)) throw noteRequired();

      const payment = await tx.payment.create({
        data: {
          membershipId: m.id,
          kind: PaymentKind.RENEWAL,
          tier: dto.tier,
          months: dto.months,
          periodStart: period.start,
          periodEnd: period.end,
          amount: money(dto.amount),
          suggestedAmount: suggested,
          currency: price.currency,
          method: dto.method,
          note: dto.note ?? null,
          recordedById: adminId,
          paidAt: now,
        },
        include: PAYMENT_INCLUDE,
      });

      m = await tx.membership.update({
        where: { id: m.id },
        data: {
          endDate: period.end,
          // A renewal after expiry opens a new continuous period [R-08].
          ...(wasExpired ? { startDate: period.start } : {}),
        },
      });

      const timing = renewalTierTiming({
        currentTier: m.tier,
        newTier: dto.tier,
        wasExpired,
        applyTierNow: dto.applyTierNow ?? false,
      });
      if (timing === 'now') m = await this.memberships.setTier(tx, m, dto.tier, adminId);
      // 'scheduled' → becomes nextTier here [R-09].
      m = await this.memberships.refreshNextTier(tx, m, today);
      return { payment, membership: m };
    });
    return { payment: toPaymentDto(payment), membership: toMembershipSummary(membership, today) };
  }

  // ---------------------------------------------------------- tier change

  private async tierChangePreviewFor(m: Membership, toTier: Tier) {
    const today = this.clock.today();
    if (isExpired(m.endDate, today)) {
      // An expired membership changes tier with a renewal instead [R-09].
      throw new AppException(HttpStatus.CONFLICT, ErrorCode.MEMBERSHIP_EXPIRED, undefined, {
        endDate: formatLocalDate(m.endDate),
      });
    }
    if (m.tier === toTier) throw new AppException(HttpStatus.BAD_REQUEST, ErrorCode.TIER_UNCHANGED);
    const prices = await this.pricing.getAll();
    const left = daysLeft(m.endDate, today);
    const preview = previewTierChange({
      fromTier: m.tier,
      toTier,
      prices: {
        BASIC: prices.BASIC.monthlyPrice,
        PLUS: prices.PLUS.monthlyPrice,
        PREMIUM: prices.PREMIUM.monthlyPrice,
      },
      daysLeft: left,
    });
    return { ...preview, daysLeft: left, currency: prices[toTier].currency };
  }

  /** [R-13] upgrade suggestion / [R-14] downgrade warning. */
  async previewTierChange(memberId: string, toTier: Tier): Promise<TierChangePreviewResultDto> {
    const m = await this.requireMembership(memberId);
    const p = await this.tierChangePreviewFor(m, toTier);
    return {
      fromTier: m.tier,
      toTier,
      isUpgrade: p.isUpgrade,
      daysLeft: p.daysLeft,
      suggestedAmount: formatMoney(p.suggestedAmount),
      currency: p.currency,
      warning: p.warning,
    };
  }

  /**
   * [R-13] Upgrade: applies now; the charge is recorded as an UPGRADE payment (months = 0).
   * A waived charge (amount 0) needs a note and is also recorded, so the decision is auditable.
   * [R-14] Downgrade: applies now, no charge, no refund. [R-15]/[R-16] via setTier().
   */
  async applyTierChange(
    adminId: string,
    memberId: string,
    dto: TierChangeDto,
  ): Promise<TierChangeResultDto> {
    const today = this.clock.today();
    const now = this.clock.now();
    const result = await this.prisma.$transaction(async (tx) => {
      let m = await this.memberships.lockByMember(tx, memberId);
      m = await this.memberships.applyScheduledTier(tx, m, today);
      const preview = await this.tierChangePreviewFor(m, dto.toTier);
      let payment: PaymentWithRefs | null = null;

      if (isUpgrade(m.tier, dto.toTier)) {
        const amount = money(dto.amount ?? preview.suggestedAmount);
        if (isNoteRequired(amount, preview.suggestedAmount) && !hasNote(dto.note)) {
          throw noteRequired();
        }
        if (amount.gt(0) && !dto.method) {
          throw new AppException(HttpStatus.BAD_REQUEST, ErrorCode.PAYMENT_METHOD_REQUIRED);
        }
        if (amount.gt(0) || preview.suggestedAmount.gt(0)) {
          payment = await tx.payment.create({
            data: {
              membershipId: m.id,
              kind: PaymentKind.UPGRADE,
              tier: dto.toTier,
              months: 0,
              amount,
              suggestedAmount: preview.suggestedAmount,
              currency: preview.currency,
              method: dto.method ?? PaymentMethod.OTHER,
              note: dto.note ?? null,
              recordedById: adminId,
              paidAt: now,
            },
            include: PAYMENT_INCLUDE,
          });
        }
      } else if (dto.amount !== undefined && new Decimal(dto.amount).gt(0)) {
        throw new AppException(HttpStatus.BAD_REQUEST, ErrorCode.DOWNGRADE_HAS_NO_CHARGE);
      }

      m = await this.memberships.setTier(tx, m, dto.toTier, adminId);
      m = await this.memberships.refreshNextTier(tx, m, today);
      return { m, payment };
    });
    return {
      membership: toMembershipSummary(result.m, today),
      payment: result.payment ? toPaymentDto(result.payment) : null,
    };
  }

  // ----------------------------------------------------------------- void

  /** [R-12] Never deleted: voided with a reason, then dates are recalculated. */
  async voidPayment(
    adminId: string,
    paymentId: string,
    dto: VoidPaymentDto,
  ): Promise<PaymentResultDto> {
    const today = this.clock.today();
    const now = this.clock.now();
    const { payment, membership } = await this.prisma.$transaction(async (tx) => {
      const existing = await tx.payment.findUnique({ where: { id: paymentId } });
      if (!existing) throw new AppException(HttpStatus.NOT_FOUND, ErrorCode.NOT_FOUND);
      let m = await this.memberships.lockById(tx, existing.membershipId);
      // Re-read under the lock to avoid voiding twice concurrently.
      const locked = await tx.payment.findUniqueOrThrow({ where: { id: paymentId } });
      if (locked.voidedAt) {
        throw new AppException(HttpStatus.CONFLICT, ErrorCode.PAYMENT_ALREADY_VOIDED);
      }
      await tx.payment.update({
        where: { id: paymentId },
        data: { voidedAt: now, voidedById: adminId, voidReason: dto.reason },
      });
      m = await this.memberships.recalculate(tx, m, today);
      m = await this.memberships.applyScheduledTier(tx, m, today);
      const payment = await tx.payment.findUniqueOrThrow({
        where: { id: paymentId },
        include: PAYMENT_INCLUDE,
      });
      return { payment, membership: m };
    });
    return { payment: toPaymentDto(payment), membership: toMembershipSummary(membership, today) };
  }

  // ----------------------------------------------------------------- list

  /** Admin payment list with totals of non-voided payments (section 8.3). */
  async list(
    q: ListPaymentsQueryDto,
  ): Promise<Paginated<PaymentDto> & { totals: PaymentTotalsDto }> {
    const tz = this.clock.timeZone;
    const paidAt: Prisma.DateTimeFilter = {};
    if (q.from) paidAt.gte = startOfLocalDayUtc(parseLocalDate(q.from), tz);
    if (q.to) paidAt.lt = startOfLocalDayUtc(addDays(parseLocalDate(q.to), 1), tz);
    const base: Prisma.PaymentWhereInput = {
      ...(q.from || q.to ? { paidAt } : {}),
      ...(q.method ? { method: q.method } : {}),
      ...(q.memberId ? { membership: { memberId: q.memberId } } : {}),
    };
    const where: Prisma.PaymentWhereInput = q.includeVoided ? base : { ...base, voidedAt: null };
    const [items, total, sums] = await this.prisma.$transaction([
      this.prisma.payment.findMany({
        where,
        include: PAYMENT_INCLUDE,
        orderBy: { paidAt: 'desc' },
        ...skipTake(q),
      }),
      this.prisma.payment.count({ where }),
      this.prisma.payment.aggregate({
        where: { ...base, voidedAt: null },
        _sum: { amount: true },
        _count: { _all: true },
      }),
    ]);
    return {
      ...paginated(items.map(toPaymentDto), total, q),
      totals: {
        count: sums._count._all,
        amount: formatMoney(sums._sum.amount ?? 0),
        currency: DEFAULT_CURRENCY,
      },
    };
  }
}
