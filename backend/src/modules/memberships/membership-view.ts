import { Membership, Tier } from '@prisma/client';
import { daysLeft, formatLocalDate, isExpired, LocalDate } from '../../common/date/gym-date';

export type MembershipStatus = 'active' | 'expired';

export interface MembershipSummary {
  tier: Tier;
  startDate: string;
  endDate: string;
  daysLeft: number;
  status: MembershipStatus;
  /** [R-09] Tier already paid for a future period, and when it starts. */
  nextTier: Tier | null;
  nextTierStartDate: string | null;
}

/** Date-derived view of a membership for API responses ([R-01]–[R-03]). */
export function toMembershipSummary(m: Membership, today: LocalDate): MembershipSummary {
  return {
    tier: m.tier,
    startDate: formatLocalDate(m.startDate),
    endDate: formatLocalDate(m.endDate),
    daysLeft: daysLeft(m.endDate, today),
    status: isExpired(m.endDate, today) ? 'expired' : 'active',
    nextTier: m.nextTier,
    nextTierStartDate: m.nextTierStartDate ? formatLocalDate(m.nextTierStartDate) : null,
  };
}
