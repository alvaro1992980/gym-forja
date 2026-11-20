import { NotificationType } from '@prisma/client';
import { addDays, diffInDays, LocalDate } from '../../common/date/gym-date';

export type ExpiryType =
  | typeof NotificationType.EXPIRING_7
  | typeof NotificationType.EXPIRING_3
  | typeof NotificationType.EXPIRING_1
  | typeof NotificationType.EXPIRED_MEMBER;

/**
 * [R-24] Reminder for `daysLeft` 7, 3 or 1 ([R-02]: daysLeft = endDate − today + 1, so
 * endDate = today + 6, + 2, + 0) and the expired notice the day after endDate.
 * Key = days from today to endDate.
 */
const BY_OFFSET = new Map<number, ExpiryType>([
  [6, NotificationType.EXPIRING_7],
  [2, NotificationType.EXPIRING_3],
  [0, NotificationType.EXPIRING_1],
  [-1, NotificationType.EXPIRED_MEMBER],
]);

/** The daily job's notification for a membership ending on [endDate], or null. */
export function expiryNotificationFor(endDate: LocalDate, today: LocalDate): ExpiryType | null {
  return BY_OFFSET.get(diffInDays(endDate, today)) ?? null;
}

/** The end dates the daily job looks for on [today]. */
export function expiryTargetDates(today: LocalDate): LocalDate[] {
  return [...BY_OFFSET.keys()].map((offset) => addDays(today, offset));
}
