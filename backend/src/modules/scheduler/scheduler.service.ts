import { Injectable, Logger, OnApplicationShutdown, OnModuleInit } from '@nestjs/common';
import { NotificationType, Role } from '@prisma/client';
import { CronJob } from 'cron';
import { ClockService } from '../../common/clock/clock.service';
import { formatLocalDate } from '../../common/date/gym-date';
import { isUniqueViolation } from '../../common/errors/prisma-errors';
import { AppConfigService } from '../../config/app-config.service';
import { NodeEnv } from '../../config/env.validation';
import { PrismaService } from '../../prisma/prisma.service';
import { NotificationsService } from '../notifications/notifications.service';
import {
  adminDailySummary,
  DailySummaryCounts,
  expiredMember,
  expiring,
} from '../notifications/templates';
import { expiryNotificationFor, expiryTargetDates } from './expiry-rules';

export const JOB_NAMES = ['daily-expiry', 'nightly-sessions'] as const;
export type JobName = (typeof JOB_NAMES)[number];

export interface DailyExpiryResult {
  date: string;
  sent: DailySummaryCounts;
  /** Already sent for this membership period earlier [R-25]. */
  skipped: number;
  adminSummary: boolean;
}

/**
 * Scheduled jobs in the gym timezone (PLAN D8): the daily expiry notifications at 08:00
 * [R-24]–[R-26] and the nightly session close at 23:59 [R-30] (a no-op until D12).
 * Not started under NODE_ENV=test; tests call the jobs directly.
 */
@Injectable()
export class SchedulerService implements OnModuleInit, OnApplicationShutdown {
  private readonly jobs: CronJob[] = [];

  private readonly logger = new Logger(SchedulerService.name);
  constructor(
    private readonly prisma: PrismaService,
    private readonly clock: ClockService,
    private readonly config: AppConfigService,
    private readonly notifications: NotificationsService,
  ) {}

  onModuleInit(): void {
    if (this.config.nodeEnv === NodeEnv.Test) return;
    const timeZone = this.config.gymTimezone;
    const schedule = (name: JobName, cronTime: string) => {
      this.jobs.push(
        CronJob.from({ cronTime, timeZone, start: true, onTick: () => void this.safely(name) }),
      );
    };
    schedule('daily-expiry', '0 0 8 * * *');
    schedule('nightly-sessions', '0 59 23 * * *');
    this.logger.log(`Jobs scheduled (${timeZone}): daily-expiry 08:00, nightly-sessions 23:59`);
  }

  onApplicationShutdown(): void {
    this.jobs.forEach((job) => void job.stop());
  }

  run(name: JobName): Promise<unknown> {
    return name === 'daily-expiry' ? this.dailyExpiry() : this.nightlySessions();
  }

  private async safely(name: JobName): Promise<void> {
    try {
      const result = await this.run(name);
      this.logger.log(`Job ${name} done: ${JSON.stringify(result)}`);
    } catch (e) {
      this.logger.error(`Job ${name} failed: ${String(e)}`);
    }
  }

  /**
   * [R-24] Reminders (7/3/1 days left), the expired notice (expired yesterday) and one admin
   * summary when there is something to report. [R-25] Each `(membershipId, type, endDate)` is
   * sent at most once: running twice the same day sends nothing new. [R-26] A renewal changes
   * endDate, so the old period's reminders no longer match.
   */
  async dailyExpiry(): Promise<DailyExpiryResult> {
    const today = this.clock.today();
    const memberships = await this.prisma.membership.findMany({
      where: {
        endDate: { in: expiryTargetDates(today) },
        member: { role: Role.MEMBER, isActive: true },
      },
      select: { id: true, memberId: true, endDate: true },
    });

    const sent: DailySummaryCounts = {
      EXPIRING_7: 0,
      EXPIRING_3: 0,
      EXPIRING_1: 0,
      EXPIRED_MEMBER: 0,
    };
    let skipped = 0;
    for (const m of memberships) {
      const type = expiryNotificationFor(m.endDate, today);
      if (!type) continue;
      try {
        await this.prisma.notificationLog.create({
          data: { membershipId: m.id, type, endDate: m.endDate, sentAt: this.clock.now() },
        });
      } catch (e) {
        if (isUniqueViolation(e)) {
          skipped++;
          continue;
        }
        throw e;
      }
      const message =
        type === NotificationType.EXPIRED_MEMBER
          ? expiredMember()
          : expiring(type, formatLocalDate(m.endDate));
      await this.notifications.deliver([m.memberId], message);
      sent[type]++;
    }

    const summary = adminDailySummary(sent);
    if (summary) {
      const admins = await this.prisma.user.findMany({
        where: { role: Role.ADMIN, isActive: true },
        select: { id: true },
      });
      await this.notifications.deliver(
        admins.map((a) => a.id),
        summary,
      );
    }
    return { date: formatLocalDate(today), sent, skipped, adminSummary: summary !== null };
  }

  /** [R-30] Auto-finish or delete open workout sessions. Workouts arrive in D12. */
  nightlySessions(): Promise<{ finished: number; deleted: number }> {
    return Promise.resolve({ finished: 0, deleted: 0 });
  }
}
