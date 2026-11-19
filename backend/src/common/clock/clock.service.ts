import { Injectable } from '@nestjs/common';
import { AppConfigService } from '../../config/app-config.service';
import { LocalDate, todayLocal } from '../date/gym-date';

/**
 * The single source of "now" for the whole API (docs/PLAN.md section 11).
 * Tests replace it with FixedClockService so nothing depends on the real date.
 */
@Injectable()
export class ClockService {
  constructor(private readonly config: AppConfigService) {}

  /** Current instant (UTC). */
  now(): Date {
    return new Date();
  }

  /** Today's calendar date in the gym timezone. */
  today(): LocalDate {
    return todayLocal(this.now(), this.config.gymTimezone);
  }

  get timeZone(): string {
    return this.config.gymTimezone;
  }
}

/** Test double: a clock frozen at a given instant that can be moved explicitly. */
export class FixedClockService extends ClockService {
  private current: Date;

  constructor(config: AppConfigService, instant: Date | string) {
    super(config);
    this.current = new Date(instant);
  }

  override now(): Date {
    return new Date(this.current.getTime());
  }

  set(instant: Date | string): void {
    this.current = new Date(instant);
  }

  advanceMs(ms: number): void {
    this.current = new Date(this.current.getTime() + ms);
  }
}
