/**
 * Pure check-in rules (docs/PLAN.md section 3.4). Times are instants; the windows are
 * configurable in GymSettings (defaults: cooldown 180 min, inside 120 min).
 */

export const DEFAULT_CHECKIN_COOLDOWN_MINUTES = 180;
export const DEFAULT_INSIDE_WINDOW_MINUTES = 120;

/** [R-18] Kiosks fetch a new QR token every 30 s; each is valid for QR_TOKEN_TTL_SECONDS (45). */
export const QR_REFRESH_SECONDS = 30;

const MINUTE_MS = 60_000;

/**
 * [R-19] A scan is a duplicate when the member already has a successful check-in within the
 * last `cooldownMinutes` (the boundary itself is outside the window).
 */
export function isDuplicateCheckin(
  lastSuccessAt: Date | null | undefined,
  now: Date,
  cooldownMinutes: number,
): boolean {
  if (!lastSuccessAt) return false;
  const elapsed = now.getTime() - lastSuccessAt.getTime();
  return elapsed >= 0 && elapsed < cooldownMinutes * MINUTE_MS;
}

/** [R-23] Members with a successful check-in at or after this instant are "inside". */
export function insideSince(now: Date, windowMinutes: number): Date {
  return new Date(now.getTime() - windowMinutes * MINUTE_MS);
}
