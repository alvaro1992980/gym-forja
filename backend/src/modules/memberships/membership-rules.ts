/**
 * Pure business rules for memberships and payments ([R-06]–[R-16]).
 * No database, no clock: callers pass "today" and data. Heavily unit-tested.
 */
import { PaymentKind, Tier } from '@prisma/client';
import { Decimal } from '@prisma/client/runtime/library';
import {
  addDays,
  addMonthsInclusive,
  diffInDays,
  isExpired,
  LocalDate,
  toLocalDate,
} from '../../common/date/gym-date';

/** Prisma's Decimal (decimal.js), the same class Prisma returns for `@db.Decimal` columns. */
export { Decimal };

/** [R-06] */
export const MIN_MONTHS = 1;
export const MAX_MONTHS = 12;
export const DEFAULT_CURRENCY = 'BOB';

/** Tier order for upgrade/downgrade decisions. */
export const TIER_RANK: Record<Tier, number> = { BASIC: 0, PLUS: 1, PREMIUM: 2 };

export function isUpgrade(from: Tier, to: Tier): boolean {
  return TIER_RANK[to] > TIER_RANK[from];
}

export function isDowngrade(from: Tier, to: Tier): boolean {
  return TIER_RANK[to] < TIER_RANK[from];
}

/** Money normalized to 2 decimals. */
export function money(value: Decimal.Value): Decimal {
  return new Decimal(value).toDecimalPlaces(2, Decimal.ROUND_HALF_UP);
}

/** "150.00" — how money is returned by the API (never a float). */
export function formatMoney(value: Decimal.Value): string {
  return money(value).toFixed(2);
}

/**
 * [R-07] Renewal while active starts the day after endDate (no paid day is lost).
 * [R-08] Renewal while expired (or without any period yet) starts today.
 */
export function nextPeriodStart(currentEnd: LocalDate | null, today: LocalDate): LocalDate {
  if (currentEnd === null || isExpired(currentEnd, today)) return today;
  return addDays(currentEnd, 1);
}

export interface Period {
  start: LocalDate;
  end: LocalDate;
}

/** [R-04] + [R-07]/[R-08]: the period a payment of `months` buys. */
export function renewalPeriod(
  currentEnd: LocalDate | null,
  today: LocalDate,
  months: number,
): Period {
  const start = nextPeriodStart(currentEnd, today);
  return { start, end: addMonthsInclusive(start, months) };
}

/** [R-10] Suggested amount = monthly price × months. */
export function suggestedAmount(monthlyPrice: Decimal.Value, months: number): Decimal {
  return money(new Decimal(monthlyPrice).times(months));
}

/** [R-10] A note is required when the amount differs from the suggestion. */
export function isNoteRequired(amount: Decimal.Value, suggested: Decimal.Value): boolean {
  return !money(amount).equals(money(suggested));
}

export function hasNote(note: string | null | undefined): boolean {
  return typeof note === 'string' && note.trim().length > 0;
}

/**
 * [R-13] Suggested prorated charge for an upgrade during an active period:
 * round((newMonthlyPrice − oldMonthlyPrice) / 30 × daysLeft), never negative.
 * Rounded to whole currency units (half up).
 */
export function proratedUpgradeCharge(
  oldMonthlyPrice: Decimal.Value,
  newMonthlyPrice: Decimal.Value,
  daysLeft: number,
): Decimal {
  const diff = new Decimal(newMonthlyPrice).minus(oldMonthlyPrice);
  if (diff.lte(0) || daysLeft <= 0) return money(0);
  return money(diff.div(30).times(daysLeft).toDecimalPlaces(0, Decimal.ROUND_HALF_UP));
}

export const DOWNGRADE_WARNING =
  'El cambio a un plan inferior se aplica de inmediato y no tiene reembolso.';

export interface TierChangePreview {
  isUpgrade: boolean;
  suggestedAmount: Decimal;
  warning: string | null;
}

/** [R-13] upgrade → prorated suggestion; [R-14] downgrade → no charge + warning. */
export function previewTierChange(input: {
  fromTier: Tier;
  toTier: Tier;
  prices: Record<Tier, Decimal.Value>;
  daysLeft: number;
}): TierChangePreview {
  if (isUpgrade(input.fromTier, input.toTier)) {
    return {
      isUpgrade: true,
      suggestedAmount: proratedUpgradeCharge(
        input.prices[input.fromTier],
        input.prices[input.toTier],
        input.daysLeft,
      ),
      warning: null,
    };
  }
  return { isUpgrade: false, suggestedAmount: money(0), warning: DOWNGRADE_WARNING };
}

/**
 * [R-09] When does the tier of a renewal apply?
 *  - expired membership → immediately (the new period starts today);
 *  - active + "apply tier now" → immediately;
 *  - active otherwise → scheduled for the start of the new period.
 */
export function renewalTierTiming(input: {
  currentTier: Tier;
  newTier: Tier;
  wasExpired: boolean;
  applyTierNow: boolean;
}): 'unchanged' | 'now' | 'scheduled' {
  if (input.currentTier === input.newTier) return 'unchanged';
  if (input.wasExpired || input.applyTierNow) return 'now';
  return 'scheduled';
}

// ---------------------------------------------------------------------------
// [R-12] Recalculation (docs/PLAN.md section 8.3)
// ---------------------------------------------------------------------------

export interface ReplayPayment {
  id: string;
  kind: PaymentKind;
  months: number;
  paidAt: Date;
  /** Only used for the NEW payment, whose start the admin may have chosen [R-05]. */
  periodStart: LocalDate | null;
  voidedAt: Date | null;
}

export interface ReplayResult {
  /** periodStart/periodEnd for every non-voided payment with months > 0. */
  periods: Map<string, Period>;
  /** Start of the current continuous period, or null when no period remains. */
  startDate: LocalDate | null;
  endDate: LocalDate | null;
}

/**
 * Replays non-voided payments with months > 0 in `paidAt` order, using each payment's
 * paidAt local date as "today" for [R-07]/[R-08]. The NEW payment keeps the start date
 * chosen at creation [R-05]. `startDate` is the first day of the last unbroken chain of
 * periods.
 */
export function replayPayments(payments: ReplayPayment[], timeZone: string): ReplayResult {
  const active = payments
    .filter((p) => p.voidedAt === null && p.months > 0)
    .sort((a, b) => a.paidAt.getTime() - b.paidAt.getTime() || a.id.localeCompare(b.id));

  const periods = new Map<string, Period>();
  let endDate: LocalDate | null = null;
  let startDate: LocalDate | null = null;

  for (const p of active) {
    const today = toLocalDate(p.paidAt, timeZone);
    const start: LocalDate =
      endDate === null && p.kind === PaymentKind.NEW && p.periodStart
        ? p.periodStart
        : nextPeriodStart(endDate, today);
    const end = addMonthsInclusive(start, p.months);
    const continues = endDate !== null && diffInDays(start, endDate) === 1;
    if (!continues) startDate = start;
    periods.set(p.id, { start, end });
    endDate = end;
  }

  return { periods, startDate, endDate };
}
