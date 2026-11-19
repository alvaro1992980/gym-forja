import { AppConfigService } from '../../config/app-config.service';
import { formatLocalDate } from '../date/gym-date';
import { ClockService, FixedClockService } from './clock.service';

function configWithTz(tz: string): AppConfigService {
  return { gymTimezone: tz } as AppConfigService;
}

describe('ClockService', () => {
  it('now() returns the current instant', () => {
    const clock = new ClockService(configWithTz('America/La_Paz'));
    const before = Date.now();
    const now = clock.now().getTime();
    expect(now).toBeGreaterThanOrEqual(before);
    expect(now).toBeLessThanOrEqual(Date.now());
  });

  it('today() uses the configured gym timezone', () => {
    const laPaz = new FixedClockService(configWithTz('America/La_Paz'), '2026-11-20T02:00:00Z');
    const utc = new FixedClockService(configWithTz('UTC'), '2026-11-20T02:00:00Z');
    expect(formatLocalDate(laPaz.today())).toBe('2026-11-19');
    expect(formatLocalDate(utc.today())).toBe('2026-11-20');
  });

  it('FixedClockService can be set and advanced', () => {
    const clock = new FixedClockService(configWithTz('America/La_Paz'), '2026-11-19T12:00:00Z');
    clock.advanceMs(24 * 60 * 60 * 1000);
    expect(formatLocalDate(clock.today())).toBe('2026-11-20');
    clock.set('2027-01-01T12:00:00Z');
    expect(clock.now().toISOString()).toBe('2027-01-01T12:00:00.000Z');
  });

  it('FixedClockService returns copies, so callers cannot mutate the clock', () => {
    const clock = new FixedClockService(configWithTz('UTC'), '2026-11-19T12:00:00Z');
    clock.now().setUTCFullYear(2000);
    expect(clock.now().getUTCFullYear()).toBe(2026);
  });
});
