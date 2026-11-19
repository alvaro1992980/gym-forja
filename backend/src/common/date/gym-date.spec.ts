import {
  addDays,
  addMonthsInclusive,
  allowedStartDateRange,
  daysLeft,
  diffInDays,
  formatLocalDate,
  isExpired,
  isLocalDate,
  isMembershipActive,
  isStartDateAllowed,
  parseLocalDate,
  resolveStartDate,
  todayLocal,
  toLocalDate,
} from './gym-date';

const d = parseLocalDate;
const fmt = formatLocalDate;
const LA_PAZ = 'America/La_Paz'; // UTC-4, no DST

describe('gym-date', () => {
  describe('parseLocalDate / formatLocalDate', () => {
    it('round-trips YYYY-MM-DD as UTC midnight', () => {
      const date = d('2026-11-19');
      expect(date.toISOString()).toBe('2026-11-19T00:00:00.000Z');
      expect(fmt(date)).toBe('2026-11-19');
      expect(isLocalDate(date)).toBe(true);
    });

    it.each(['2026-02-30', '2026-13-01', '2026-00-10', '2026-1-5', '19-11-2026', '', 'abc'])(
      'rejects invalid input %p',
      (value) => {
        expect(() => d(value)).toThrow(RangeError);
      },
    );

    it('accepts Feb 29 only in leap years', () => {
      expect(fmt(d('2028-02-29'))).toBe('2028-02-29');
      expect(() => d('2026-02-29')).toThrow(RangeError);
    });

    it('refuses to format a Date that is not at UTC midnight', () => {
      expect(() => fmt(new Date('2026-11-19T10:00:00Z'))).toThrow(RangeError);
    });
  });

  describe('toLocalDate / todayLocal (gym timezone)', () => {
    it('uses the gym timezone, not UTC: 03:59Z is still the previous day in La Paz', () => {
      expect(fmt(toLocalDate(new Date('2026-11-20T03:59:59.999Z'), LA_PAZ))).toBe('2026-11-19');
    });

    it('switches day at local midnight (04:00Z in La Paz)', () => {
      expect(fmt(toLocalDate(new Date('2026-11-20T04:00:00.000Z'), LA_PAZ))).toBe('2026-11-20');
    });

    it('handles year boundaries', () => {
      expect(fmt(todayLocal(new Date('2027-01-01T02:00:00Z'), LA_PAZ))).toBe('2026-12-31');
    });

    it('works for other timezones (configurable GYM_TIMEZONE)', () => {
      const instant = new Date('2026-11-19T23:30:00Z');
      expect(fmt(toLocalDate(instant, 'Europe/Madrid'))).toBe('2026-11-20');
      expect(fmt(toLocalDate(instant, 'UTC'))).toBe('2026-11-19');
    });

    it('rejects invalid instants', () => {
      expect(() => toLocalDate(new Date('nope'), LA_PAZ)).toThrow(RangeError);
    });
  });

  describe('addDays / diffInDays', () => {
    it('adds and subtracts across month and year ends', () => {
      expect(fmt(addDays(d('2026-12-31'), 1))).toBe('2027-01-01');
      expect(fmt(addDays(d('2026-03-01'), -1))).toBe('2026-02-28');
      expect(fmt(addDays(d('2028-03-01'), -1))).toBe('2028-02-29');
    });

    it('counts whole days', () => {
      expect(diffInDays(d('2026-12-14'), d('2026-12-02'))).toBe(12);
      expect(diffInDays(d('2026-12-02'), d('2026-12-14'))).toBe(-12);
      expect(diffInDays(d('2027-01-01'), d('2026-01-01'))).toBe(365);
    });

    it('rejects non-integer days', () => {
      expect(() => addDays(d('2026-01-01'), 1.5)).toThrow(RangeError);
    });
  });

  describe('[R-04] addMonthsInclusive', () => {
    it('[R-04] S = 2026-01-15, N = 1 → endDate = 2026-02-14', () => {
      expect(fmt(addMonthsInclusive(d('2026-01-15'), 1))).toBe('2026-02-14');
    });

    it('[R-04] S = 2026-01-31, N = 1 → addMonths gives 2026-02-28 → endDate = 2026-02-27', () => {
      expect(fmt(addMonthsInclusive(d('2026-01-31'), 1))).toBe('2026-02-27');
    });

    it('[R-04] S = 2026-03-01, N = 3 → endDate = 2026-05-31', () => {
      expect(fmt(addMonthsInclusive(d('2026-03-01'), 3))).toBe('2026-05-31');
    });

    it.each([
      // month-end clamping
      ['2028-01-31', 1, '2028-02-28'], // leap year: addMonths → 2028-02-29
      ['2026-03-31', 1, '2026-04-29'], // addMonths → 2026-04-30
      ['2026-08-31', 6, '2027-02-27'], // addMonths → 2027-02-28
      ['2026-05-31', 1, '2026-06-29'],
      // ordinary cases
      ['2026-01-01', 1, '2026-01-31'],
      ['2026-02-01', 1, '2026-02-28'],
      ['2028-02-01', 1, '2028-02-29'],
      ['2026-12-15', 1, '2027-01-14'], // crosses the year
      ['2026-11-19', 12, '2027-11-18'],
      ['2028-02-29', 12, '2029-02-27'], // addMonths → 2029-02-28
    ])('[R-04] S = %s, N = %i → endDate = %s', (start, months, expected) => {
      expect(fmt(addMonthsInclusive(d(start), months))).toBe(expected);
    });

    it('[R-04] consecutive periods never overlap or leave gaps', () => {
      // A renewal starting on endDate + 1 [R-07] continues exactly where the previous ended.
      let start = d('2026-01-31');
      for (let i = 0; i < 24; i++) {
        const end = addMonthsInclusive(start, 1);
        expect(diffInDays(end, start)).toBeGreaterThanOrEqual(27);
        start = addDays(end, 1);
      }
    });

    it.each([0, -1, 1.5, Number.NaN])('[R-04] rejects months = %p', (months) => {
      expect(() => addMonthsInclusive(d('2026-01-15'), months)).toThrow(RangeError);
    });
  });

  describe('[R-01] / [R-03] active and expired', () => {
    const end = d('2026-12-14');

    it('[R-01] is active on the last day (endDate is inclusive)', () => {
      expect(isMembershipActive(end, d('2026-12-14'), true)).toBe(true);
    });

    it('[R-01] is active before endDate', () => {
      expect(isMembershipActive(end, d('2026-11-19'), true)).toBe(true);
    });

    it('[R-01] is not active when the member account is inactive, even with days left', () => {
      expect(isMembershipActive(end, d('2026-11-19'), false)).toBe(false);
    });

    it('[R-01] is not active the day after endDate', () => {
      expect(isMembershipActive(end, d('2026-12-15'), true)).toBe(false);
    });

    it('[R-03] is expired only when today > endDate', () => {
      expect(isExpired(end, d('2026-12-13'))).toBe(false);
      expect(isExpired(end, d('2026-12-14'))).toBe(false);
      expect(isExpired(end, d('2026-12-15'))).toBe(true);
      expect(isExpired(end, d('2027-03-01'))).toBe(true);
    });

    it('[R-03] uses the gym-local date: 23:30 local on endDate is not expired yet', () => {
      // 2026-12-14 23:30 in La Paz = 2026-12-15T03:30Z
      const today = todayLocal(new Date('2026-12-15T03:30:00Z'), LA_PAZ);
      expect(isExpired(end, today)).toBe(false);
      const tomorrow = todayLocal(new Date('2026-12-15T04:00:00Z'), LA_PAZ);
      expect(isExpired(end, tomorrow)).toBe(true);
    });
  });

  describe('[R-02] daysLeft', () => {
    const end = d('2026-12-14');

    it('[R-02] daysLeft = (endDate − today) + 1 when active', () => {
      expect(daysLeft(end, d('2026-12-03'))).toBe(12);
    });

    it('[R-02] is 1 on the last day', () => {
      expect(daysLeft(end, d('2026-12-14'))).toBe(1);
    });

    it('[R-02] is 2 the day before the last day', () => {
      expect(daysLeft(end, d('2026-12-13'))).toBe(2);
    });

    it('[R-02] is 0 once expired', () => {
      expect(daysLeft(end, d('2026-12-15'))).toBe(0);
      expect(daysLeft(end, d('2027-06-01'))).toBe(0);
    });

    it('[R-02] equals the period length on the start day of a 1-month period', () => {
      const start = d('2026-01-15');
      expect(daysLeft(addMonthsInclusive(start, 1), start)).toBe(31);
    });

    it('[R-02] counts across a month boundary', () => {
      expect(daysLeft(d('2026-03-02'), d('2026-02-27'))).toBe(4);
    });
  });

  describe('[R-05] new member start date', () => {
    const today = d('2026-11-19');

    it('[R-05] defaults to today', () => {
      expect(fmt(resolveStartDate(today))).toBe('2026-11-19');
    });

    it('[R-05] allows today − 7 days to today + 30 days (inclusive)', () => {
      const { min, max } = allowedStartDateRange(today);
      expect(fmt(min)).toBe('2026-11-12');
      expect(fmt(max)).toBe('2026-12-19');
      expect(fmt(resolveStartDate(today, d('2026-11-12')))).toBe('2026-11-12');
      expect(fmt(resolveStartDate(today, d('2026-12-19')))).toBe('2026-12-19');
      expect(isStartDateAllowed(today, d('2026-11-25'))).toBe(true);
    });

    it('[R-05] rejects dates outside the range', () => {
      expect(isStartDateAllowed(today, d('2026-11-11'))).toBe(false);
      expect(isStartDateAllowed(today, d('2026-12-20'))).toBe(false);
      expect(() => resolveStartDate(today, d('2026-12-20'))).toThrow(
        'startDate must be between 2026-11-12 and 2026-12-19',
      );
    });
  });
});
