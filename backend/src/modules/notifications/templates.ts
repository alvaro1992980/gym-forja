import { NotificationType, Tier } from '@prisma/client';

/**
 * Notification texts (PLAN section 7). Spanish only in v1; English variants can be keyed by
 * the user's language later.
 */
export interface NotificationMessage {
  type: NotificationType;
  title: string;
  body: string;
  /** Routing data for the app: `screen` and/or `memberId` (section 9.8). */
  data: Record<string, string>;
}

export const TIER_NAMES: Record<Tier, string> = {
  BASIC: 'Mensual',
  PLUS: 'Mensual +',
  PREMIUM: 'Mensual ++',
};

/** `2026-11-21` → `21/11/2026`. */
export function displayDate(localDate: string): string {
  const [y, m, d] = localDate.split('-');
  return `${d}/${m}/${y}`;
}

const days = (n: number) => (n === 1 ? '1 día' : `${n} días`);

interface MemberRef {
  id: string;
  firstName: string;
  lastName: string;
}

export function checkinAdmin(
  member: MemberRef,
  tier: Tier,
  daysLeft: number,
  checkinId: string,
): NotificationMessage {
  return {
    type: NotificationType.CHECKIN_ADMIN,
    title: 'Ingreso',
    body: `${member.firstName} ${member.lastName} · ${TIER_NAMES[tier]} · ${days(daysLeft)} restantes`,
    data: { memberId: member.id, checkinId },
  };
}

export function checkinMember(firstName: string, daysLeft: number): NotificationMessage {
  return {
    type: NotificationType.CHECKIN_MEMBER,
    title: `¡Bienvenido, ${firstName}!`,
    body:
      daysLeft === 1
        ? 'Hoy es el último día de tu membresía.'
        : `Te quedan ${days(daysLeft)} de membresía.`,
    data: { screen: 'checkin_result' },
  };
}

export function checkinDeniedAdmin(member: MemberRef, endDate: string): NotificationMessage {
  return {
    type: NotificationType.CHECKIN_DENIED_ADMIN,
    title: 'Ingreso rechazado',
    body: `${member.firstName} ${member.lastName} intentó ingresar: membresía vencida el ${displayDate(endDate)}`,
    data: { memberId: member.id },
  };
}

export function checkinDeniedMember(endDate: string): NotificationMessage {
  return {
    type: NotificationType.CHECKIN_DENIED_MEMBER,
    title: 'Membresía vencida',
    body: `Tu membresía venció el ${displayDate(endDate)}. Acércate a recepción para renovar.`,
    data: { screen: 'home' },
  };
}

export type ExpiringType =
  | typeof NotificationType.EXPIRING_7
  | typeof NotificationType.EXPIRING_3
  | typeof NotificationType.EXPIRING_1;

export function expiring(type: ExpiringType, endDate: string): NotificationMessage {
  const left = { EXPIRING_7: 7, EXPIRING_3: 3, EXPIRING_1: 1 }[type];
  return {
    type,
    title: 'Tu membresía vence pronto',
    body:
      left === 1
        ? `Hoy es tu último día (vence el ${displayDate(endDate)}).`
        : `Te quedan ${days(left)} (vence el ${displayDate(endDate)}).`,
    data: { screen: 'home' },
  };
}

export function expiredMember(): NotificationMessage {
  return {
    type: NotificationType.EXPIRED_MEMBER,
    title: 'Tu membresía venció',
    body: 'Venció ayer. Renueva en recepción para seguir entrenando.',
    data: { screen: 'home' },
  };
}

export interface DailySummaryCounts {
  EXPIRING_7: number;
  EXPIRING_3: number;
  EXPIRING_1: number;
  EXPIRED_MEMBER: number;
}

/** [R-24] Admin summary, or null when there is nothing to report. */
export function adminDailySummary(c: DailySummaryCounts): NotificationMessage | null {
  const parts: string[] = [];
  if (c.EXPIRING_7)
    parts.push(`${c.EXPIRING_7} ${c.EXPIRING_7 === 1 ? 'vence' : 'vencen'} en 7 días`);
  if (c.EXPIRING_3) parts.push(`${c.EXPIRING_3} en 3 días`);
  if (c.EXPIRING_1) parts.push(`${c.EXPIRING_1} hoy (último día)`);
  if (c.EXPIRED_MEMBER) {
    parts.push(`${c.EXPIRED_MEMBER} ${c.EXPIRED_MEMBER === 1 ? 'venció' : 'vencieron'} ayer`);
  }
  if (parts.length === 0) return null;
  return {
    type: NotificationType.ADMIN_DAILY_SUMMARY,
    title: 'Resumen de membresías',
    body: parts.join(' · '),
    data: { screen: 'admin_expiring' },
  };
}

export function paymentRecorded(tier: Tier, endDate: string): NotificationMessage {
  return {
    type: NotificationType.PAYMENT_RECORDED,
    title: 'Pago registrado',
    body: `Renovaste ${TIER_NAMES[tier]} hasta el ${displayDate(endDate)}. ¡Gracias!`,
    data: { screen: 'home' },
  };
}

export function tierChanged(tier: Tier): NotificationMessage {
  return {
    type: NotificationType.TIER_CHANGED,
    title: 'Tu plan cambió',
    body: `Ahora tienes ${TIER_NAMES[tier]}.`,
    data: { screen: 'home' },
  };
}
