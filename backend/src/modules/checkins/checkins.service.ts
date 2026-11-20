import { HttpStatus, Injectable, Logger } from '@nestjs/common';
import { CheckinResult, Membership, Prisma } from '@prisma/client';
import { AuthUser } from '../../common/auth/auth-user';
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
import { AppConfigService } from '../../config/app-config.service';
import { PrismaService } from '../../prisma/prisma.service';
import { personRef } from '../memberships/mappers';
import { MembershipsService } from '../memberships/memberships.service';
import { QrTokenError, QrTokenService } from '../kiosk/qr-token.service';
import { NotificationsService } from '../notifications/notifications.service';
import {
  checkinAdmin,
  checkinDeniedAdmin,
  checkinDeniedMember,
  checkinMember,
} from '../notifications/templates';
import { RealtimeGateway } from '../realtime/realtime.gateway';
import { SettingsService } from '../settings/settings.controller';
import { insideSince, isDuplicateCheckin } from './checkin-rules';
import {
  AttemptItemDto,
  CheckinItemDto,
  CheckinResponseDto,
  DateRangeQueryDto,
  DENIED_RESULTS,
  InsideNowDto,
  ListAttemptsQueryDto,
  ListCheckinsQueryDto,
  MyCheckinDto,
} from './dto';

type Tx = Prisma.TransactionClient;

type Outcome =
  | { kind: 'expired'; membership: Membership }
  | {
      kind: 'success' | 'duplicate';
      membership: Membership;
      checkin: { id: string; createdAt: Date };
    };

const MEMBER_REF = { select: { id: true, firstName: true, lastName: true } } as const;

/** Check-in flow [R-17]–[R-23] and check-in history. */
@Injectable()
export class CheckinsService {
  private readonly logger = new Logger(CheckinsService.name);

  constructor(
    private readonly prisma: PrismaService,
    private readonly clock: ClockService,
    private readonly config: AppConfigService,
    private readonly qr: QrTokenService,
    private readonly memberships: MembershipsService,
    private readonly settings: SettingsService,
    private readonly realtime: RealtimeGateway,
    private readonly notifications: NotificationsService,
  ) {}

  /**
   * POST /checkins. Every scan stores a CheckinAttempt [R-22]; only a valid, non-duplicate
   * scan by an active member with an active membership creates a Checkin [R-17].
   */
  async checkIn(user: AuthUser, qrToken: string): Promise<CheckinResponseDto> {
    // [R-17]/[R-18] Valid, unexpired kiosk token from an active kiosk.
    let kioskId: string;
    try {
      kioskId = (await this.verifyKioskToken(qrToken)).kid;
    } catch (e) {
      const reason = e instanceof QrTokenError ? e.reason : 'invalid';
      await this.recordAttempt(this.prisma, user.id, CheckinResult.INVALID_TOKEN, null, reason);
      throw new AppException(
        HttpStatus.BAD_REQUEST,
        reason === 'expired' ? ErrorCode.QR_TOKEN_EXPIRED : ErrorCode.QR_TOKEN_INVALID,
      );
    }

    // [R-21] Deactivated account with a still-valid access token.
    if (!user.isActive) {
      await this.recordAttempt(this.prisma, user.id, CheckinResult.DENIED_INACTIVE, kioskId, null);
      this.realtime.checkinDenied({
        member: { id: user.id, firstName: user.firstName, lastName: user.lastName },
        reason: 'INACTIVE',
        endDate: null,
        createdAt: this.clock.now(),
      });
      throw new AppException(HttpStatus.FORBIDDEN, ErrorCode.ACCOUNT_INACTIVE);
    }

    const { checkinCooldownMinutes } = await this.settings.get();
    const now = this.clock.now();
    const today = this.clock.today();

    const outcome = await this.prisma.$transaction(async (tx): Promise<Outcome> => {
      // The membership row lock serializes simultaneous scans of the same member [R-19].
      let membership = await this.memberships.lockByMember(tx, user.id);
      membership = await this.memberships.applyScheduledTier(tx, membership, today);

      // [R-20] Expired membership: no check-in.
      if (isExpired(membership.endDate, today)) {
        await this.recordAttempt(
          tx,
          user.id,
          CheckinResult.DENIED_EXPIRED,
          kioskId,
          `endDate=${formatLocalDate(membership.endDate)}`,
        );
        return { kind: 'expired', membership };
      }

      // [R-19] Duplicate within the cooldown: no new check-in, no admin event.
      const last = await tx.checkin.findFirst({
        where: { memberId: user.id },
        orderBy: { createdAt: 'desc' },
        select: { id: true, createdAt: true },
      });
      if (last && isDuplicateCheckin(last.createdAt, now, checkinCooldownMinutes)) {
        await this.recordAttempt(tx, user.id, CheckinResult.DUPLICATE, kioskId, last.id);
        return { kind: 'duplicate', membership, checkin: last };
      }

      const checkin = await tx.checkin.create({
        data: {
          memberId: user.id,
          tier: membership.tier,
          daysLeft: daysLeft(membership.endDate, today),
          kioskId,
          createdAt: now,
        },
        select: { id: true, createdAt: true },
      });
      await this.recordAttempt(tx, user.id, CheckinResult.SUCCESS, kioskId, checkin.id);
      return { kind: 'success', membership, checkin };
    });

    const m = outcome.membership;
    const endDate = formatLocalDate(m.endDate);
    const member = { id: user.id, firstName: user.firstName, lastName: user.lastName };

    if (outcome.kind === 'expired') {
      this.realtime.checkinDenied({ member, reason: 'EXPIRED', endDate, createdAt: now });
      // [R-20] Both the admins and the member are notified (section 7).
      this.notifications.notifyAdmins(checkinDeniedAdmin(member, endDate));
      this.notifications.notify([user.id], checkinDeniedMember(endDate));
      throw new AppException(HttpStatus.FORBIDDEN, ErrorCode.MEMBERSHIP_EXPIRED, undefined, {
        endDate,
      });
    }

    const left = daysLeft(m.endDate, today);
    if (outcome.kind === 'success') {
      this.realtime.checkinCreated({
        checkinId: outcome.checkin.id,
        member,
        tier: m.tier,
        daysLeft: left,
        createdAt: outcome.checkin.createdAt,
      });
      // Not for duplicates [R-19].
      this.notifications.notifyAdmins(checkinAdmin(member, m.tier, left, outcome.checkin.id));
      this.notifications.notify([user.id], checkinMember(user.firstName, left));
    }
    return {
      result: outcome.kind === 'success' ? 'SUCCESS' : 'DUPLICATE',
      duplicate: outcome.kind === 'duplicate',
      checkinId: outcome.checkin.id,
      checkedInAt: outcome.checkin.createdAt,
      member: { firstName: user.firstName },
      membership: { tier: m.tier, endDate, daysLeft: left },
      todayWorkout: null,
    };
  }

  /** GET /admin/checkins */
  async list(q: ListCheckinsQueryDto): Promise<Paginated<CheckinItemDto>> {
    const where: Prisma.CheckinWhereInput = {
      memberId: q.memberId,
      createdAt: this.range(q),
    };
    const [rows, total] = await this.prisma.$transaction([
      this.prisma.checkin.findMany({
        where,
        include: { member: MEMBER_REF },
        orderBy: { createdAt: 'desc' },
        ...skipTake(q),
      }),
      this.prisma.checkin.count({ where }),
    ]);
    return paginated(rows.map(toCheckinItem), total, q);
  }

  /** GET /admin/checkins/inside [R-23] */
  async inside(): Promise<InsideNowDto> {
    const { insideWindowMinutes } = await this.settings.get();
    const rows = await this.prisma.checkin.findMany({
      where: { createdAt: { gte: insideSince(this.clock.now(), insideWindowMinutes) } },
      include: { member: MEMBER_REF },
      orderBy: { createdAt: 'desc' },
      distinct: ['memberId'],
    });
    return {
      count: rows.length,
      windowMinutes: insideWindowMinutes,
      items: rows.map(toCheckinItem),
    };
  }

  /** GET /admin/checkins/attempts */
  async attempts(q: ListAttemptsQueryDto): Promise<Paginated<AttemptItemDto>> {
    const where: Prisma.CheckinAttemptWhereInput = {
      memberId: q.memberId,
      result: q.result ?? { in: [...DENIED_RESULTS] },
      createdAt: this.range(q),
    };
    const [rows, total] = await this.prisma.$transaction([
      this.prisma.checkinAttempt.findMany({
        where,
        include: { member: MEMBER_REF },
        orderBy: { createdAt: 'desc' },
        ...skipTake(q),
      }),
      this.prisma.checkinAttempt.count({ where }),
    ]);
    return paginated(
      rows.map((a) => ({
        id: a.id,
        result: a.result,
        member: a.member ? personRef(a.member) : null,
        kioskId: a.kioskId,
        detail: a.detail,
        createdAt: a.createdAt,
      })),
      total,
      q,
    );
  }

  /** GET /me/checkins */
  async mine(memberId: string, q: DateRangeQueryDto): Promise<Paginated<MyCheckinDto>> {
    const where: Prisma.CheckinWhereInput = { memberId, createdAt: this.range(q) };
    const [rows, total] = await this.prisma.$transaction([
      this.prisma.checkin.findMany({
        where,
        select: { id: true, tier: true, createdAt: true },
        orderBy: { createdAt: 'desc' },
        ...skipTake(q),
      }),
      this.prisma.checkin.count({ where }),
    ]);
    return paginated(rows, total, q);
  }

  /** Signature + expiry, then the kiosk must exist, be a KIOSK and be active. */
  private async verifyKioskToken(token: string) {
    const claims = this.qr.verify(token);
    const kiosk = await this.prisma.user.findUnique({
      where: { id: claims.kid },
      select: { role: true, isActive: true },
    });
    if (!kiosk || kiosk.role !== 'KIOSK' || !kiosk.isActive) {
      throw new QrTokenError('invalid');
    }
    return claims;
  }

  /** `from`/`to` are gym-local dates, both inclusive. */
  private range(q: DateRangeQueryDto): Prisma.DateTimeFilter | undefined {
    if (!q.from && !q.to) return undefined;
    const tz = this.config.gymTimezone;
    return {
      gte: q.from ? startOfLocalDayUtc(parseLocalDate(q.from), tz) : undefined,
      lt: q.to ? startOfLocalDayUtc(addDays(parseLocalDate(q.to), 1), tz) : undefined,
    };
  }

  private async recordAttempt(
    db: Tx | PrismaService,
    memberId: string,
    result: CheckinResult,
    kioskId: string | null,
    detail: string | null,
  ): Promise<void> {
    await db.checkinAttempt.create({
      data: { memberId, result, kioskId, detail, createdAt: this.clock.now() },
    });
    if (result !== CheckinResult.SUCCESS) {
      this.logger.log(`Check-in attempt ${result} by member ${memberId}`);
    }
  }
}

function toCheckinItem(c: {
  id: string;
  tier: CheckinItemDto['tier'];
  daysLeft: number;
  kioskId: string;
  createdAt: Date;
  member: { id: string; firstName: string; lastName: string };
}): CheckinItemDto {
  return {
    id: c.id,
    member: personRef(c.member),
    tier: c.tier,
    daysLeft: c.daysLeft,
    kioskId: c.kioskId,
    createdAt: c.createdAt,
  };
}
