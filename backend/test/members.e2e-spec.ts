import { Role } from '@prisma/client';
import request from 'supertest';
import { parseLocalDate } from '../src/common/date/gym-date';
import { TestApp, createTestApp } from './support/app';
import { resetDatabase } from './support/database';
import {
  activateMember,
  bearer,
  createAndLogin,
  createMemberViaApi,
  login,
  seedTestBase,
  Session,
  uniquePhone,
} from './support/fixtures';

// 2026-11-19 12:00 in La Paz → today = 2026-11-19
const NOW = '2026-11-19T16:00:00Z';

describe('Admin members (e2e)', () => {
  let t: TestApp;
  let admin: Session;
  let adminId: string;
  const http = () => request(t.app.getHttpServer());
  const auth = () => bearer(admin.accessToken);

  beforeAll(async () => {
    t = await createTestApp({ now: NOW });
    await resetDatabase(t.prisma);
    await seedTestBase(t.prisma);
    const a = await createAndLogin(t.app, t.prisma, Role.ADMIN);
    admin = a.session;
    adminId = a.user.id;
  });

  beforeEach(() => t.clock!.set(NOW));

  afterAll(async () => {
    await t.app.close();
  });

  describe('POST /admin/members', () => {
    it('[R-41] creates user + membership + NEW payment and returns a temporary password that works for login', async () => {
      const res = await http()
        .post('/api/v1/admin/members')
        .set(...auth())
        .send({
          firstName: 'Ana',
          lastName: 'Rojas',
          phone: '7111 2222',
          email: 'Ana@Mail.com',
          birthDate: '1995-03-10',
          medicalNotes: 'Lesión de rodilla',
          tier: 'BASIC',
          months: 1,
          amount: 150,
          method: 'CASH',
        })
        .expect(201);

      expect(res.body).toMatchObject({
        firstName: 'Ana',
        phone: '+59171112222',
        email: 'ana@mail.com',
        birthDate: '1995-03-10',
        medicalNotes: 'Lesión de rodilla',
        isActive: true,
        mustChangePassword: true,
        trainer: null,
        assignment: null,
        recentCheckins: [],
        membership: {
          tier: 'BASIC',
          startDate: '2026-11-19', // [R-05] default today
          endDate: '2026-12-18', // [R-04]
          daysLeft: 30, // [R-02]
          status: 'active', // [R-01]
        },
      });
      expect(res.body.temporaryPassword).toMatch(/^[A-HJ-NP-Za-km-np-z2-9]{8}$/);
      expect(res.body.payments).toHaveLength(1);
      // [R-06] every payment field
      expect(res.body.payments[0]).toMatchObject({
        kind: 'NEW',
        tier: 'BASIC',
        months: 1,
        periodStart: '2026-11-19',
        periodEnd: '2026-12-18',
        amount: '150.00',
        suggestedAmount: '150.00',
        currency: 'BOB',
        method: 'CASH',
        note: null,
        recordedBy: { id: adminId },
        paidAt: NOW.replace('Z', '.000Z'),
        voidedAt: null,
      });

      const s = await login(t.app, '71112222', res.body.temporaryPassword as string);
      expect(s.user).toMatchObject({ role: 'MEMBER', mustChangePassword: true });
    });

    it('[R-04] month-end start date: 2026-01-31 + 1 month ends 2026-02-27', async () => {
      t.clock!.set('2026-01-31T16:00:00Z');
      const m = await createMemberViaApi(t.app, admin.accessToken);
      expect(m.membership).toMatchObject({ startDate: '2026-01-31', endDate: '2026-02-27' });
    });

    it('[R-05] accepts a start date from today − 7 to today + 30', async () => {
      const past = await createMemberViaApi(t.app, admin.accessToken, { startDate: '2026-11-12' });
      expect(past.membership).toMatchObject({ startDate: '2026-11-12', endDate: '2026-12-11' });
      const future = await createMemberViaApi(t.app, admin.accessToken, {
        startDate: '2026-12-19',
      });
      expect(future.membership).toMatchObject({ startDate: '2026-12-19', endDate: '2027-01-18' });
    });

    it.each(['2026-11-11', '2026-12-20'])(
      '[R-05] rejects start date %s (outside the range)',
      async (startDate) => {
        const res = await http()
          .post('/api/v1/admin/members')
          .set(...auth())
          .send({
            firstName: 'X',
            lastName: 'Y',
            phone: uniquePhone(),
            tier: 'BASIC',
            months: 1,
            amount: 150,
            method: 'CASH',
            startDate,
          })
          .expect(400);
        expect(res.body).toMatchObject({
          code: 'START_DATE_OUT_OF_RANGE',
          details: { min: '2026-11-12', max: '2026-12-19' },
        });
      },
    );

    it('[R-10] an amount different from the suggestion requires a note', async () => {
      const body = {
        firstName: 'X',
        lastName: 'Y',
        phone: uniquePhone(),
        tier: 'PLUS',
        months: 3,
        amount: 700,
        method: 'TRANSFER',
      };
      const res = await http()
        .post('/api/v1/admin/members')
        .set(...auth())
        .send(body)
        .expect(400);
      expect(res.body.code).toBe('AMOUNT_NOTE_REQUIRED');

      const ok = await createMemberViaApi(t.app, admin.accessToken, {
        ...body,
        note: 'Promo amigos',
      });
      expect(ok.payments[0]).toMatchObject({ amount: '700.00' });
      const stored = await t.prisma.payment.findUniqueOrThrow({ where: { id: ok.payments[0].id } });
      expect(stored.suggestedAmount.toFixed(2)).toBe('750.00');
      expect(stored.note).toBe('Promo amigos');
    });

    it('rejects a duplicate phone and creates nothing', async () => {
      const m = await createMemberViaApi(t.app, admin.accessToken);
      const users = await t.prisma.user.count();
      const memberships = await t.prisma.membership.count();
      const res = await http()
        .post('/api/v1/admin/members')
        .set(...auth())
        .send({
          firstName: 'X',
          lastName: 'Y',
          phone: m.phone,
          tier: 'BASIC',
          months: 1,
          amount: 150,
          method: 'CASH',
        })
        .expect(409);
      expect(res.body.code).toBe('PHONE_ALREADY_EXISTS');
      expect(await t.prisma.user.count()).toBe(users);
      expect(await t.prisma.membership.count()).toBe(memberships);
    });

    it('validates the body ([R-06] months 1–12, method, amount)', async () => {
      const res = await http()
        .post('/api/v1/admin/members')
        .set(...auth())
        .send({
          firstName: 'X',
          lastName: 'Y',
          phone: uniquePhone(),
          tier: 'GOLD',
          months: 13,
          amount: -1,
          method: 'BITCOIN',
        })
        .expect(400);
      const fields = (res.body.details.fields as { field: string }[]).map((f) => f.field);
      expect(fields).toEqual(expect.arrayContaining(['tier', 'months', 'amount', 'method']));
    });

    it('GET /admin/members/preview gives the period and suggested amount for a new member', async () => {
      const res = await http()
        .get('/api/v1/admin/members/preview?tier=PLUS&months=3')
        .set(...auth())
        .expect(200);
      expect(res.body).toMatchObject({
        periodStart: '2026-11-19',
        periodEnd: '2027-02-18',
        suggestedAmount: '750.00',
        currency: 'BOB',
      });
    });
  });

  describe('GET /admin/members', () => {
    let ids: Record<string, string>;

    beforeAll(async () => {
      await resetDatabase(t.prisma);
      await seedTestBase(t.prisma);
      const a = await createAndLogin(t.app, t.prisma, Role.ADMIN);
      admin = a.session;
      t.clock!.set(NOW);
      const mk = async (firstName: string, tier: string, endDate: string, isActive = true) => {
        const m = await createMemberViaApi(t.app, admin.accessToken, {
          firstName,
          lastName: 'Lista',
          tier,
          amount: { BASIC: 150, PLUS: 250, PREMIUM: 400 }[tier],
        });
        await t.prisma.membership.update({
          where: { memberId: m.id },
          data: { endDate: parseLocalDate(endDate) },
        });
        if (!isActive) await t.prisma.user.update({ where: { id: m.id }, data: { isActive } });
        return m.id;
      };
      ids = {
        active: await mk('Activo', 'BASIC', '2026-12-30'), // 42 days left
        expiring: await mk('Porvencer', 'PLUS', '2026-11-25'), // 7 days left
        lastDay: await mk('Ultimo', 'PREMIUM', '2026-11-19'), // 1 day left
        expired: await mk('Vencido', 'BASIC', '2026-11-18'), // expired yesterday
        inactive: await mk('Inactivo', 'BASIC', '2026-12-30', false),
      };
    });

    const names = (body: { items: { firstName: string }[] }) =>
      body.items.map((i) => i.firstName).sort();

    it('hides inactive members by default [R-43]', async () => {
      const res = await http()
        .get('/api/v1/admin/members')
        .set(...auth())
        .expect(200);
      expect(names(res.body)).toEqual(['Activo', 'Porvencer', 'Ultimo', 'Vencido']);
      const vencido = (
        res.body.items as { firstName: string; status: string; daysLeft: number }[]
      ).find((i) => i.firstName === 'Vencido');
      expect(vencido).toMatchObject({ status: 'expired', daysLeft: 0 });
    });

    it.each([
      ['active', ['Activo', 'Porvencer', 'Ultimo']],
      ['expiring', ['Porvencer', 'Ultimo']],
      ['expired', ['Vencido']],
      ['inactive', ['Inactivo']],
    ])('status=%s', async (status, expected) => {
      const res = await http()
        .get(`/api/v1/admin/members?status=${status}`)
        .set(...auth())
        .expect(200);
      expect(names(res.body)).toEqual(expected);
    });

    it('expiringWithinDays narrows the window', async () => {
      const res = await http()
        .get('/api/v1/admin/members?expiringWithinDays=1')
        .set(...auth())
        .expect(200);
      expect(names(res.body)).toEqual(['Ultimo']);
    });

    it('filters by tier', async () => {
      const res = await http()
        .get('/api/v1/admin/members?tier=PLUS')
        .set(...auth())
        .expect(200);
      expect(names(res.body)).toEqual(['Porvencer']);
    });

    it('searches by name (case-insensitive, several words) and by phone digits', async () => {
      const byName = await http()
        .get('/api/v1/admin/members?q=vencido%20LISTA')
        .set(...auth())
        .expect(200);
      expect(names(byName.body)).toEqual(['Vencido']);
      const member = await t.prisma.user.findUniqueOrThrow({ where: { id: ids.active } });
      const byPhone = await http()
        .get(`/api/v1/admin/members?q=${member.phone.slice(-6)}`)
        .set(...auth())
        .expect(200);
      expect(names(byPhone.body)).toEqual(['Activo']);
    });

    it('sorts by endDate and paginates', async () => {
      const res = await http()
        .get('/api/v1/admin/members?sort=endDate&pageSize=2&page=1')
        .set(...auth())
        .expect(200);
      expect(res.body).toMatchObject({ page: 1, pageSize: 2, total: 4 });
      expect((res.body.items as { firstName: string }[]).map((i) => i.firstName)).toEqual([
        'Vencido',
        'Ultimo',
      ]);
    });

    it('filters by trainer', async () => {
      const trainer = await createAndLogin(t.app, t.prisma, Role.TRAINER);
      await t.prisma.membership.update({
        where: { memberId: ids.lastDay },
        data: { trainerId: trainer.user.id },
      });
      const res = await http()
        .get(`/api/v1/admin/members?trainerId=${trainer.user.id}`)
        .set(...auth())
        .expect(200);
      expect(names(res.body)).toEqual(['Ultimo']);
    });
  });

  describe('detail, edit, deactivate, reset password', () => {
    it('GET /admin/members/:id returns 404 for staff or unknown ids', async () => {
      await http()
        .get(`/api/v1/admin/members/${adminId}`)
        .set(...auth())
        .expect(404);
      await http()
        .get('/api/v1/admin/members/00000000-0000-4000-8000-000000000000')
        .set(...auth())
        .expect(404);
      await http()
        .get('/api/v1/admin/members/not-a-uuid')
        .set(...auth())
        .expect(400);
    });

    it('PATCH edits profile fields and clears optional ones with null', async () => {
      const m = await createMemberViaApi(t.app, admin.accessToken, { email: 'a@b.com' });
      const res = await http()
        .patch(`/api/v1/admin/members/${m.id}`)
        .set(...auth())
        .send({ firstName: 'Juana', email: null, emergencyContact: 'Mamá 70000001' })
        .expect(200);
      expect(res.body).toMatchObject({
        firstName: 'Juana',
        email: null,
        emergencyContact: 'Mamá 70000001',
      });
    });

    it('PATCH cannot change tier or dates', async () => {
      const m = await createMemberViaApi(t.app, admin.accessToken);
      await http()
        .patch(`/api/v1/admin/members/${m.id}`)
        .set(...auth())
        .send({ tier: 'PREMIUM' })
        .expect(400);
      await http()
        .patch(`/api/v1/admin/members/${m.id}`)
        .set(...auth())
        .send({ endDate: '2030-01-01' })
        .expect(400);
    });

    it('PATCH rejects a phone that belongs to someone else', async () => {
      const a = await createMemberViaApi(t.app, admin.accessToken);
      const b = await createMemberViaApi(t.app, admin.accessToken);
      const res = await http()
        .patch(`/api/v1/admin/members/${b.id}`)
        .set(...auth())
        .send({ phone: a.phone })
        .expect(409);
      expect(res.body.code).toBe('PHONE_ALREADY_EXISTS');
    });

    it('[R-43] deactivate: isActive = false, sessions revoked, login refused; reactivate restores', async () => {
      const m = await createMemberViaApi(t.app, admin.accessToken);
      const session = await activateMember(t.app, m);
      const res = await http()
        .post(`/api/v1/admin/members/${m.id}/deactivate`)
        .set(...auth())
        .expect(200);
      expect(res.body.isActive).toBe(false);
      await http()
        .post('/api/v1/auth/refresh')
        .send({ refreshToken: session.refreshToken })
        .expect(401);
      await http()
        .post('/api/v1/auth/login')
        .send({ phone: m.phone, password: 'Password123' })
        .expect(403);
      await http()
        .post(`/api/v1/admin/members/${m.id}/reactivate`)
        .set(...auth())
        .expect(200);
      await login(t.app, m.phone, 'Password123');
    });

    it('[R-44] reset password: new temporary password, old one rejected, sessions revoked', async () => {
      const m = await createMemberViaApi(t.app, admin.accessToken);
      const session = await activateMember(t.app, m);
      const res = await http()
        .post(`/api/v1/admin/members/${m.id}/reset-password`)
        .set(...auth())
        .expect(200);
      const temp = res.body.temporaryPassword as string;
      expect(temp).toMatch(/^[A-HJ-NP-Za-km-np-z2-9]{8}$/);
      await http()
        .post('/api/v1/auth/refresh')
        .send({ refreshToken: session.refreshToken })
        .expect(401);
      await http()
        .post('/api/v1/auth/login')
        .send({ phone: m.phone, password: 'Password123' })
        .expect(401);
      const s = await login(t.app, m.phone, temp);
      expect(s.user.mustChangePassword).toBe(true);
    });
  });

  describe('pricing and settings', () => {
    it('GET/PUT /admin/pricing', async () => {
      const res = await http()
        .get('/api/v1/admin/pricing')
        .set(...auth())
        .expect(200);
      expect(res.body).toEqual([
        { tier: 'BASIC', monthlyPrice: '150.00', currency: 'BOB' },
        { tier: 'PLUS', monthlyPrice: '250.00', currency: 'BOB' },
        { tier: 'PREMIUM', monthlyPrice: '400.00', currency: 'BOB' },
      ]);
      const put = await http()
        .put('/api/v1/admin/pricing')
        .set(...auth())
        .send({ prices: [{ tier: 'PLUS', monthlyPrice: 260.5 }] })
        .expect(200);
      expect(put.body[1]).toEqual({ tier: 'PLUS', monthlyPrice: '260.50', currency: 'BOB' });
      await http()
        .put('/api/v1/admin/pricing')
        .set(...auth())
        .send({ prices: [{ tier: 'PLUS', monthlyPrice: 0 }] })
        .expect(400);
      await http()
        .put('/api/v1/admin/pricing')
        .set(...auth())
        .send({ prices: [{ tier: 'PLUS', monthlyPrice: 250 }] })
        .expect(200);
    });

    it('GET/PUT /admin/settings (timezone is read-only)', async () => {
      const res = await http()
        .get('/api/v1/admin/settings')
        .set(...auth())
        .expect(200);
      expect(res.body).toEqual({
        gymName: 'Mi Gimnasio',
        timezone: 'America/La_Paz',
        checkinCooldownMinutes: 180,
        insideWindowMinutes: 120,
        defaultCountryCode: '+591',
      });
      const put = await http()
        .put('/api/v1/admin/settings')
        .set(...auth())
        .send({ gymName: 'Forja Gym', checkinCooldownMinutes: 120 })
        .expect(200);
      expect(put.body).toMatchObject({ gymName: 'Forja Gym', checkinCooldownMinutes: 120 });
      await http()
        .put('/api/v1/admin/settings')
        .set(...auth())
        .send({ timezone: 'UTC' })
        .expect(400);
      await http()
        .put('/api/v1/admin/settings')
        .set(...auth())
        .send({ insideWindowMinutes: 0 })
        .expect(400);
    });
  });

  describe('permissions', () => {
    it.each([Role.TRAINER, Role.MEMBER, Role.KIOSK])(
      '%s gets 403 on admin member endpoints',
      async (role) => {
        const { session } = await createAndLogin(t.app, t.prisma, role);
        const h = bearer(session.accessToken);
        for (const path of [
          '/api/v1/admin/members',
          '/api/v1/admin/payments',
          '/api/v1/admin/pricing',
          '/api/v1/admin/settings',
        ]) {
          await http()
            .get(path)
            .set(...h)
            .expect(403);
        }
        await http()
          .post('/api/v1/admin/members')
          .set(...h)
          .send({})
          .expect(403);
      },
    );
  });
});
