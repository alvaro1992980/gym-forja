import { addDays, parseLocalDate } from '../../common/date/gym-date';
import { expiryNotificationFor, expiryTargetDates } from './expiry-rules';

const today = parseLocalDate('2026-11-19');
const ending = (offset: number) => expiryNotificationFor(addDays(today, offset), today);

describe('[R-24] daily expiry notifications', () => {
  it('[R-24] reminds members with 7, 3 and 1 days left ([R-02] daysLeft = endDate − today + 1)', () => {
    expect(ending(6)).toBe('EXPIRING_7'); // endDate 2026-11-25
    expect(ending(2)).toBe('EXPIRING_3');
    expect(ending(0)).toBe('EXPIRING_1'); // last day
  });

  it('[R-24] notifies members whose membership expired yesterday (today = endDate + 1)', () => {
    expect(ending(-1)).toBe('EXPIRED_MEMBER');
  });

  it('[R-24] nothing for other days', () => {
    for (const offset of [-30, -2, 1, 3, 4, 5, 7, 8, 30]) expect(ending(offset)).toBeNull();
  });

  it('[R-24] looks for exactly those four end dates', () => {
    expect(expiryTargetDates(today).map((d) => d.toISOString().slice(0, 10))).toEqual([
      '2026-11-25',
      '2026-11-21',
      '2026-11-19',
      '2026-11-18',
    ]);
  });
});
