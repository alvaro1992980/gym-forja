import { HttpStatus, Injectable } from '@nestjs/common';
import { PaymentKind, Prisma, Role, User } from '@prisma/client';
import { ClockService } from '../../common/clock/clock.service';
import {
  addDays,
  addMonthsInclusive,
  formatLocalDate,
  isExpired,
  daysLeft as computeDaysLeft,
  parseLocalDate,
  resolveStartDate,
} from '../../common/date/gym-date';
import { AppException } from '../../common/errors/app.exception';
import { ErrorCode } from '../../common/errors/error-codes';
import { mapUserUniqueViolation } from '../../common/errors/prisma-errors';
import { Paginated, paginated, skipTake } from '../../common/pagination/pagination';
import { PrismaService } from '../../prisma/prisma.service';
import { PricingService } from '../pricing/pricing.service';
import { UsersService } from '../users/users.service';
import {
  CreatedMemberDto,
  CreateMemberDto,
  ListMembersQueryDto,
  MemberDetailDto,
  MemberListItemDto,
  NewMemberPreviewQueryDto,
  PaymentPreviewDto,
  TemporaryPasswordDto,
  UpdateMemberDto,
} from './dto';
import { PAYMENT_INCLUDE, personRef, toPaymentDto } from './mappers';
import { formatMoney, hasNote, isNoteRequired, money, suggestedAmount } from './membership-rules';
import { toMembershipSummary } from './membership-view';
import { MembershipsService } from './memberships.service';

const DEFAULT_EXPIRING_DAYS = 7;
const RECENT_CHECKINS = 10;

@Injectable()
export class MembersService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly clock: ClockService,
    private readonly users: UsersService,
    private readonly memberships: MembershipsService,
    private readonly pricing: PricingService,
  ) {}

  /** [R-05] start date, mapped to an API error. */
  private startDate(today: Date, requested?: string): Date {
    try {
      return resolveStartDate(today, requested ? parseLocalDate(requested) : undefined);
    } catch {
      throw new AppException(HttpStatus.BAD_REQUEST, ErrorCode.START_DATE_OUT_OF_RANGE, undefined, {
        min: formatLocalDate(addDays(today, -7)),
        max: formatLocalDate(addDays(today, 30)),
      });
    }
  }

  /** Period and suggested amount for a new member (used by the "new member" stepper). */
  async previewNew(q: NewMemberPreviewQueryDto): Promise<PaymentPreviewDto> {
    const start = this.startDate(this.clock.today(), q.startDate);
    const price = await this.pricing.get(q.tier);
    return {
      periodStart: formatLocalDate(start),
      periodEnd: formatLocalDate(addMonthsInclusive(start, q.months)),
      suggestedAmount: formatMoney(suggestedAmount(price.monthlyPrice, q.months)),
      currency: price.currency,
      tierApplies: 'now',
    };
  }

  /**
   * POST /admin/members: user + membership + NEW payment in one transaction (section 8.2).
   * [R-04] [R-05] [R-06] [R-10] [R-41]
   */
  async create(adminId: string, dto: CreateMemberDto): Promise<CreatedMemberDto> {
    const today = this.clock.today();
    const now = this.clock.now();
    const start = this.startDate(today, dto.startDate);
    const end = addMonthsInclusive(start, dto.months);
    const price = await this.pricing.get(dto.tier);
    const suggested = suggestedAmount(price.monthlyPrice, dto.months);
    if (isNoteRequired(dto.amount, suggested) && !hasNote(dto.note)) {
      throw new AppException(HttpStatus.BAD_REQUEST, ErrorCode.AMOUNT_NOTE_REQUIRED);
    }
    await this.users.assertPhoneAndEmailFree(dto.phone, dto.email);

    const { userId, temporaryPassword } = await this.prisma.$transaction(async (tx) => {
      const { user, temporaryPassword } = await this.users.createWithTemporaryPassword(
        {
          role: Role.MEMBER,
          firstName: dto.firstName,
          lastName: dto.lastName,
          phone: dto.phone,
          email: dto.email,
          birthDate: dto.birthDate ? parseLocalDate(dto.birthDate) : null,
          gender: dto.gender ?? null,
          emergencyContact: dto.emergencyContact ?? null,
          medicalNotes: dto.medicalNotes ?? null,
        },
        tx,
      );
      const membership = await tx.membership.create({
        data: { memberId: user.id, tier: dto.tier, startDate: start, endDate: end },
      });
      await tx.payment.create({
        data: {
          membershipId: membership.id,
          kind: PaymentKind.NEW,
          tier: dto.tier,
          months: dto.months,
          periodStart: start,
          periodEnd: end,
          amount: money(dto.amount),
          suggestedAmount: suggested,
          currency: price.currency,
          method: dto.method,
          note: dto.note ?? null,
          recordedById: adminId,
          paidAt: now,
        },
      });
      return { userId: user.id, temporaryPassword };
    });
    return { ...(await this.detail(userId)), temporaryPassword };
  }

  /** GET /admin/members with filters, sorting and pagination (section 8.2). */
  async list(q: ListMembersQueryDto): Promise<Paginated<MemberListItemDto>> {
    await this.memberships.applyAllDueScheduledTiers();
    const today = this.clock.today();
    const and: Prisma.UserWhereInput[] = [{ role: Role.MEMBER }];

    if (q.q) {
      const digits = q.q.replace(/\D/g, '');
      const words = q.q.split(/\s+/).filter((w) => w.length > 0);
      const or: Prisma.UserWhereInput[] = [
        {
          AND: words.map((w) => ({
            OR: [
              { firstName: { contains: w, mode: 'insensitive' as const } },
              { lastName: { contains: w, mode: 'insensitive' as const } },
            ],
          })),
        },
      ];
      if (digits.length >= 3) or.push({ phone: { contains: digits } });
      and.push({ OR: or });
    }

    const membership: Prisma.MembershipWhereInput = {};
    if (q.tier) membership.tier = q.tier;
    if (q.trainerId) membership.trainerId = q.trainerId;

    const status = q.status ?? (q.expiringWithinDays ? 'expiring' : undefined);
    switch (status) {
      case 'inactive':
        and.push({ isActive: false });
        break;
      case 'active':
        and.push({ isActive: true });
        membership.endDate = { gte: today };
        break;
      case 'expired':
        and.push({ isActive: true });
        membership.endDate = { lt: today };
        break;
      case 'expiring': {
        const n = q.expiringWithinDays ?? DEFAULT_EXPIRING_DAYS;
        and.push({ isActive: true });
        // daysLeft in 1..n  ⇔  today ≤ endDate ≤ today + n − 1   [R-02]
        membership.endDate = { gte: today, lte: addDays(today, n - 1) };
        break;
      }
      default:
        and.push({ isActive: true }); // [R-43] inactive hidden by default
    }
    and.push({ membership: { is: membership } });

    const where: Prisma.UserWhereInput = { AND: and };
    const orderBy: Prisma.UserOrderByWithRelationInput[] =
      q.sort === 'endDate'
        ? [{ membership: { endDate: 'asc' } }, { firstName: 'asc' }]
        : q.sort === 'createdAt'
          ? [{ createdAt: 'desc' }]
          : [{ firstName: 'asc' }, { lastName: 'asc' }];

    const [rows, total] = await this.prisma.$transaction([
      this.prisma.user.findMany({
        where,
        orderBy,
        include: {
          membership: true,
          checkins: { orderBy: { createdAt: 'desc' }, take: 1, select: { createdAt: true } },
        },
        ...skipTake(q),
      }),
      this.prisma.user.count({ where }),
    ]);

    return paginated(
      rows.map((u) => {
        const m = u.membership!;
        return {
          id: u.id,
          firstName: u.firstName,
          lastName: u.lastName,
          phone: u.phone,
          isActive: u.isActive,
          tier: m.tier,
          endDate: formatLocalDate(m.endDate),
          daysLeft: computeDaysLeft(m.endDate, today),
          status: !u.isActive ? 'inactive' : isExpired(m.endDate, today) ? 'expired' : 'active',
          trainerId: m.trainerId,
          lastCheckinAt: u.checkins[0]?.createdAt ?? null,
        };
      }),
      total,
      q,
    );
  }

  private async requireMember(id: string): Promise<User> {
    const user = await this.prisma.user.findUnique({ where: { id } });
    if (!user || user.role !== Role.MEMBER) {
      throw new AppException(HttpStatus.NOT_FOUND, ErrorCode.NOT_FOUND);
    }
    return user;
  }

  /** GET /admin/members/:id */
  async detail(id: string): Promise<MemberDetailDto> {
    const user = await this.requireMember(id);
    const membership = await this.memberships.getCurrentByMember(id);
    if (!membership) throw new AppException(HttpStatus.NOT_FOUND, ErrorCode.NOT_FOUND);
    const today = this.clock.today();
    const [trainer, checkins, payments] = await Promise.all([
      membership.trainerId
        ? this.prisma.user.findUnique({ where: { id: membership.trainerId } })
        : Promise.resolve(null),
      this.prisma.checkin.findMany({
        where: { memberId: id },
        orderBy: { createdAt: 'desc' },
        take: RECENT_CHECKINS,
      }),
      this.prisma.payment.findMany({
        where: { membershipId: membership.id },
        include: PAYMENT_INCLUDE,
        orderBy: { paidAt: 'desc' },
      }),
    ]);
    return {
      id: user.id,
      firstName: user.firstName,
      lastName: user.lastName,
      phone: user.phone,
      email: user.email,
      birthDate: user.birthDate ? formatLocalDate(user.birthDate) : null,
      gender: user.gender,
      emergencyContact: user.emergencyContact,
      medicalNotes: user.medicalNotes,
      isActive: user.isActive,
      mustChangePassword: user.mustChangePassword,
      createdAt: user.createdAt,
      membership: toMembershipSummary(membership, today),
      trainer: trainer ? personRef(trainer) : null,
      recentCheckins: checkins.map((c) => ({
        id: c.id,
        createdAt: c.createdAt,
        tier: c.tier,
        daysLeft: c.daysLeft,
      })),
      payments: payments.map(toPaymentDto),
      assignment: null,
    };
  }

  /** PATCH /admin/members/:id — profile fields only (not tier/dates). */
  async update(id: string, dto: UpdateMemberDto): Promise<MemberDetailDto> {
    await this.requireMember(id);
    const data: Prisma.UserUpdateInput = {};
    if (dto.firstName !== undefined) data.firstName = dto.firstName;
    if (dto.lastName !== undefined) data.lastName = dto.lastName;
    if (dto.phone !== undefined) data.phone = dto.phone;
    if (dto.email !== undefined) data.email = dto.email ? dto.email.toLowerCase() : null;
    if (dto.birthDate !== undefined) {
      data.birthDate = dto.birthDate ? parseLocalDate(dto.birthDate) : null;
    }
    if (dto.gender !== undefined) data.gender = dto.gender;
    if (dto.emergencyContact !== undefined) data.emergencyContact = dto.emergencyContact;
    if (dto.medicalNotes !== undefined) data.medicalNotes = dto.medicalNotes;
    try {
      await this.prisma.user.update({ where: { id }, data });
    } catch (error) {
      mapUserUniqueViolation(error);
    }
    return this.detail(id);
  }

  /** [R-43] */
  async deactivate(id: string): Promise<MemberDetailDto> {
    await this.requireMember(id);
    await this.users.deactivate(id);
    return this.detail(id);
  }

  async reactivate(id: string): Promise<MemberDetailDto> {
    await this.requireMember(id);
    await this.users.reactivate(id);
    return this.detail(id);
  }

  /** [R-44] */
  async resetPassword(id: string): Promise<TemporaryPasswordDto> {
    await this.requireMember(id);
    const { temporaryPassword } = await this.users.resetPassword(id);
    return { temporaryPassword };
  }
}
