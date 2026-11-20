import {
  adminDailySummary,
  checkinAdmin,
  checkinDeniedAdmin,
  checkinDeniedMember,
  checkinMember,
  expiredMember,
  expiring,
  paymentRecorded,
  tierChanged,
} from './templates';

const juan = { id: 'm1', firstName: 'Juan', lastName: 'Pérez' };

describe('notification templates (PLAN section 7)', () => {
  it('check-in for admins and the member', () => {
    expect(checkinAdmin(juan, 'PREMIUM', 12, 'c1')).toEqual({
      type: 'CHECKIN_ADMIN',
      title: 'Ingreso',
      body: 'Juan Pérez · Mensual ++ · 12 días restantes',
      data: { memberId: 'm1', checkinId: 'c1' },
    });
    expect(checkinMember('Juan', 12)).toMatchObject({
      title: '¡Bienvenido, Juan!',
      body: 'Te quedan 12 días de membresía.',
      data: { screen: 'checkin_result' },
    });
  });

  it('[R-20] denied check-in for admins and the member', () => {
    expect(checkinDeniedAdmin(juan, '2026-11-10')).toMatchObject({
      title: 'Ingreso rechazado',
      body: 'Juan Pérez intentó ingresar: membresía vencida el 10/11/2026',
      data: { memberId: 'm1' },
    });
    expect(checkinDeniedMember('2026-11-10').body).toBe(
      'Tu membresía venció el 10/11/2026. Acércate a recepción para renovar.',
    );
  });

  it('[R-24] expiry reminders and the expired notice', () => {
    expect(expiring('EXPIRING_7', '2026-11-21')).toMatchObject({
      title: 'Tu membresía vence pronto',
      body: 'Te quedan 7 días (vence el 21/11/2026).',
      data: { screen: 'home' },
    });
    expect(expiring('EXPIRING_1', '2026-11-19').body).toBe(
      'Hoy es tu último día (vence el 19/11/2026).',
    );
    expect(expiredMember().body).toBe('Venció ayer. Renueva en recepción para seguir entrenando.');
  });

  it('[R-24] admin summary only when there is something to report', () => {
    expect(
      adminDailySummary({ EXPIRING_7: 3, EXPIRING_3: 2, EXPIRING_1: 1, EXPIRED_MEMBER: 1 }),
    ).toMatchObject({
      type: 'ADMIN_DAILY_SUMMARY',
      body: '3 vencen en 7 días · 2 en 3 días · 1 hoy (último día) · 1 venció ayer',
      data: { screen: 'admin_expiring' },
    });
    expect(
      adminDailySummary({ EXPIRING_7: 0, EXPIRING_3: 0, EXPIRING_1: 0, EXPIRED_MEMBER: 0 }),
    ).toBeNull();
  });

  it('payment and tier change', () => {
    expect(paymentRecorded('PLUS', '2026-12-14').body).toBe(
      'Renovaste Mensual + hasta el 14/12/2026. ¡Gracias!',
    );
    expect(tierChanged('PREMIUM').body).toBe('Ahora tienes Mensual ++.');
  });
});
