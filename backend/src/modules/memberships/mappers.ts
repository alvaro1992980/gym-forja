import { Payment, User } from '@prisma/client';
import { formatLocalDate } from '../../common/date/gym-date';
import { MyPaymentDto, PaymentDto, PersonRefDto } from './dto';
import { formatMoney } from './membership-rules';

export type PaymentWithRefs = Payment & {
  recordedBy: Pick<User, 'id' | 'firstName' | 'lastName'>;
  membership: { memberId: string };
};

export const PAYMENT_INCLUDE = {
  recordedBy: { select: { id: true, firstName: true, lastName: true } },
  membership: { select: { memberId: true } },
} as const;

const dateOrNull = (d: Date | null) => (d ? formatLocalDate(d) : null);

export function personRef(u: Pick<User, 'id' | 'firstName' | 'lastName'>): PersonRefDto {
  return { id: u.id, firstName: u.firstName, lastName: u.lastName };
}

/** Admin view of a payment (includes notes and void details). */
export function toPaymentDto(p: PaymentWithRefs): PaymentDto {
  return {
    id: p.id,
    memberId: p.membership.memberId,
    kind: p.kind,
    tier: p.tier,
    months: p.months,
    periodStart: dateOrNull(p.periodStart),
    periodEnd: dateOrNull(p.periodEnd),
    amount: formatMoney(p.amount),
    suggestedAmount: formatMoney(p.suggestedAmount),
    currency: p.currency,
    method: p.method,
    note: p.note,
    recordedBy: personRef(p.recordedBy),
    paidAt: p.paidAt,
    voidedAt: p.voidedAt,
    voidedById: p.voidedById,
    voidReason: p.voidReason,
  };
}

/** Member view: no notes, no internal fields (section 8.3 `/me/payments`). */
export function toMyPaymentDto(p: Payment): MyPaymentDto {
  return {
    id: p.id,
    kind: p.kind,
    tier: p.tier,
    months: p.months,
    periodStart: dateOrNull(p.periodStart),
    periodEnd: dateOrNull(p.periodEnd),
    amount: formatMoney(p.amount),
    currency: p.currency,
    method: p.method,
    paidAt: p.paidAt,
  };
}
