/**
 * The ONLY place where calendar dates of the gym are computed (docs/PLAN.md section 6,
 * "Date handling rule"). Business rules [R-01]–[R-05].
 *
 * Representation: a "local date" is a JS `Date` at 00:00:00.000 UTC of that calendar day.
 * That is exactly what Prisma reads/writes for `@db.Date` columns, so values round-trip
 * without conversion. All arithmetic here is done in UTC, so results do not depend on the
 * server's own timezone.
 *
 * "Today" always comes from an injected clock (ClockService) plus the gym timezone,
 * never from `new Date()` in business code.
 */
import { UTCDate } from '@date-fns/utc';
import { addMonths } from 'date-fns';
import { formatInTimeZone } from 'date-fns-tz';

/** A calendar date, stored as UTC midnight. Alias for readability. */
export type LocalDate = Date;

const MS_PER_DAY = 24 * 60 * 60 * 1000;
const LOCAL_DATE_RE = /^(\d{4})-(\d{2})-(\d{2})$/;

/** [R-05] Allowed start date range for a new member, relative to today. */
export const START_DATE_MIN_OFFSET_DAYS = -7;
export const START_DATE_MAX_OFFSET_DAYS = 30;

/** True when `d` is a valid Date exactly at UTC midnight. */
export function isLocalDate(d: unknown): d is LocalDate {
  return d instanceof Date && !Number.isNaN(d.getTime()) && d.getTime() % MS_PER_DAY === 0;
}

function assertLocalDate(d: Date, name = 'date'): void {
  if (!isLocalDate(d)) {
    throw new RangeError(`${name} must be a local date (UTC midnight), got ${String(d)}`);
  }
}

/** Parses `YYYY-MM-DD` (API format). Throws RangeError for malformed or impossible dates. */
export function parseLocalDate(value: string): LocalDate {
  const m = LOCAL_DATE_RE.exec(value);
  if (!m) throw new RangeError(`Invalid local date "${value}", expected YYYY-MM-DD`);
  const [year, month, day] = [Number(m[1]), Number(m[2]), Number(m[3])];
  const d = new Date(Date.UTC(year, month - 1, day));
  if (d.getUTCFullYear() !== year || d.getUTCMonth() !== month - 1 || d.getUTCDate() !== day) {
    throw new RangeError(`Invalid local date "${value}"`);
  }
  return d;
}

/** Formats a local date as `YYYY-MM-DD` (API format). */
export function formatLocalDate(d: LocalDate): string {
  assertLocalDate(d);
  return d.toISOString().slice(0, 10);
}

/** The calendar date of `instant` as seen in `timeZone`. */
export function toLocalDate(instant: Date, timeZone: string): LocalDate {
  if (Number.isNaN(instant.getTime())) throw new RangeError('Invalid instant');
  return parseLocalDate(formatInTimeZone(instant, timeZone, 'yyyy-MM-dd'));
}

/** "Today" in the gym timezone. `now` must come from ClockService. */
export function todayLocal(now: Date, timeZone: string): LocalDate {
  return toLocalDate(now, timeZone);
}

/** Adds (or subtracts, when negative) whole calendar days. */
export function addDays(d: LocalDate, days: number): LocalDate {
  assertLocalDate(d);
  if (!Number.isInteger(days)) throw new RangeError('days must be an integer');
  return new Date(d.getTime() + days * MS_PER_DAY);
}

/** Whole calendar days from `from` to `to` (positive when `to` is later). */
export function diffInDays(to: LocalDate, from: LocalDate): number {
  assertLocalDate(to, 'to');
  assertLocalDate(from, 'from');
  return Math.round((to.getTime() - from.getTime()) / MS_PER_DAY);
}

/**
 * [R-04] End date (inclusive) of a period of `months` calendar months starting on `start`:
 * `addMonths(start, months) − 1 day`. date-fns clamps to the last day of shorter months,
 * e.g. 2026-01-31 + 1 month = 2026-02-28, so the end date is 2026-02-27.
 */
export function addMonthsInclusive(start: LocalDate, months: number): LocalDate {
  assertLocalDate(start, 'start');
  if (!Number.isInteger(months) || months < 1) {
    throw new RangeError('months must be an integer >= 1');
  }
  const plusMonths = addMonths(new UTCDate(start.getTime()), months);
  return addDays(new Date(plusMonths.getTime()), -1);
}

/** [R-03] Expired when today > endDate. */
export function isExpired(endDate: LocalDate, today: LocalDate): boolean {
  return diffInDays(today, endDate) > 0;
}

/** [R-01] Active when today <= endDate (inclusive) AND the member account is active. */
export function isMembershipActive(
  endDate: LocalDate,
  today: LocalDate,
  accountActive: boolean,
): boolean {
  return accountActive && !isExpired(endDate, today);
}

/** [R-02] (endDate − today) + 1 while not expired (1 on the last day); 0 once expired. */
export function daysLeft(endDate: LocalDate, today: LocalDate): number {
  return isExpired(endDate, today) ? 0 : diffInDays(endDate, today) + 1;
}

/** [R-05] Earliest and latest start date the admin may pick for a new member. */
export function allowedStartDateRange(today: LocalDate): { min: LocalDate; max: LocalDate } {
  return {
    min: addDays(today, START_DATE_MIN_OFFSET_DAYS),
    max: addDays(today, START_DATE_MAX_OFFSET_DAYS),
  };
}

/** [R-05] Start date is today unless the admin picks one in [today − 7, today + 30]. */
export function resolveStartDate(today: LocalDate, requested?: LocalDate): LocalDate {
  if (requested === undefined) return today;
  assertLocalDate(requested, 'startDate');
  const { min, max } = allowedStartDateRange(today);
  if (diffInDays(requested, min) < 0 || diffInDays(max, requested) < 0) {
    throw new RangeError(
      `startDate must be between ${formatLocalDate(min)} and ${formatLocalDate(max)}`,
    );
  }
  return requested;
}

/** [R-05] True when `requested` is inside the allowed start date range. */
export function isStartDateAllowed(today: LocalDate, requested: LocalDate): boolean {
  try {
    resolveStartDate(today, requested);
    return true;
  } catch {
    return false;
  }
}
