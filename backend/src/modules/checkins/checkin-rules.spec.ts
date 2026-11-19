import {
  DEFAULT_CHECKIN_COOLDOWN_MINUTES,
  DEFAULT_INSIDE_WINDOW_MINUTES,
  insideSince,
  isDuplicateCheckin,
} from './checkin-rules';

const at = (iso: string) => new Date(iso);

describe('[R-19] duplicate protection', () => {
  const now = at('2026-11-19T22:00:00Z');

  it('[R-19] the default cooldown is 3 hours', () => {
    expect(DEFAULT_CHECKIN_COOLDOWN_MINUTES).toBe(180);
  });

  it('[R-19] a check-in within the last 3 hours makes the scan a duplicate', () => {
    expect(isDuplicateCheckin(at('2026-11-19T21:59:00Z'), now, 180)).toBe(true);
    expect(isDuplicateCheckin(at('2026-11-19T19:00:01Z'), now, 180)).toBe(true);
  });

  it('[R-19] exactly 3 hours later (or more) is a new check-in', () => {
    expect(isDuplicateCheckin(at('2026-11-19T19:00:00Z'), now, 180)).toBe(false);
    expect(isDuplicateCheckin(at('2026-11-18T22:00:00Z'), now, 180)).toBe(false);
  });

  it('[R-19] no previous check-in is never a duplicate', () => {
    expect(isDuplicateCheckin(null, now, 180)).toBe(false);
    expect(isDuplicateCheckin(undefined, now, 180)).toBe(false);
  });

  it('[R-19] uses the configured cooldown', () => {
    expect(isDuplicateCheckin(at('2026-11-19T21:30:00Z'), now, 20)).toBe(false);
    expect(isDuplicateCheckin(at('2026-11-19T21:50:00Z'), now, 20)).toBe(true);
  });
});

describe('[R-23] currently inside', () => {
  it('[R-23] the default window is 2 hours', () => {
    expect(DEFAULT_INSIDE_WINDOW_MINUTES).toBe(120);
  });

  it('[R-23] "inside" starts window minutes before now', () => {
    expect(insideSince(at('2026-11-19T22:00:00Z'), 120)).toEqual(at('2026-11-19T20:00:00Z'));
  });
});
