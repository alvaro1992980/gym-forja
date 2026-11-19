import { Role } from '@prisma/client';
import request from 'supertest';
import { TestApp, createTestApp } from './support/app';
import { resetDatabase } from './support/database';
import { bearer, createAndLogin, login, Session, uniquePhone } from './support/fixtures';

describe('Admin staff (e2e)', () => {
  let t: TestApp;
  let admin: Session;
  let adminId: string;
  const http = () => request(t.app.getHttpServer());

  beforeAll(async () => {
    t = await createTestApp({ now: '2026-11-19T16:00:00Z' });
    await resetDatabase(t.prisma);
    const a = await createAndLogin(t.app, t.prisma, Role.ADMIN);
    admin = a.session;
    adminId = a.user.id;
  });

  afterAll(async () => {
    await t.app.close();
  });

  describe('POST /admin/staff', () => {
    it('[R-41] creates a TRAINER with an 8-character temporary password that works for login', async () => {
      const res = await http()
        .post('/api/v1/admin/staff')
        .set(...bearer(admin.accessToken))
        .send({ role: 'TRAINER', firstName: ' Carlos ', lastName: 'Rojas', phone: '7555 1234' })
        .expect(201);
      expect(res.body).toMatchObject({
        role: 'TRAINER',
        firstName: 'Carlos',
        phone: '+59175551234', // [R-40]
        isActive: true,
        mustChangePassword: true,
      });
      expect(res.body.temporaryPassword).toMatch(/^[A-HJ-NP-Za-km-np-z2-9]{8}$/);
      expect(res.body).not.toHaveProperty('passwordHash');

      const s = await login(t.app, '+59175551234', res.body.temporaryPassword as string);
      expect(s.user).toMatchObject({ role: 'TRAINER', mustChangePassword: true });
    });

    it.each(['ADMIN', 'KIOSK'])('creates a %s account', async (role) => {
      const res = await http()
        .post('/api/v1/admin/staff')
        .set(...bearer(admin.accessToken))
        .send({ role, firstName: 'X', lastName: role, phone: uniquePhone() })
        .expect(201);
      expect(res.body.role).toBe(role);
    });

    it('rejects role MEMBER (members are created with a membership in D3)', async () => {
      const res = await http()
        .post('/api/v1/admin/staff')
        .set(...bearer(admin.accessToken))
        .send({ role: 'MEMBER', firstName: 'X', lastName: 'Y', phone: uniquePhone() })
        .expect(400);
      expect(res.body.code).toBe('VALIDATION_ERROR');
    });

    it('rejects a duplicate phone in any format → 409 PHONE_ALREADY_EXISTS', async () => {
      const res = await http()
        .post('/api/v1/admin/staff')
        .set(...bearer(admin.accessToken))
        .send({ role: 'TRAINER', firstName: 'X', lastName: 'Y', phone: '+591 7555-1234' })
        .expect(409);
      expect(res.body.code).toBe('PHONE_ALREADY_EXISTS');
    });

    it('rejects a duplicate email (case-insensitive) → 409 EMAIL_ALREADY_EXISTS', async () => {
      await http()
        .post('/api/v1/admin/staff')
        .set(...bearer(admin.accessToken))
        .send({
          role: 'TRAINER',
          firstName: 'A',
          lastName: 'B',
          phone: uniquePhone(),
          email: 'coach@gym.bo',
        })
        .expect(201);
      const res = await http()
        .post('/api/v1/admin/staff')
        .set(...bearer(admin.accessToken))
        .send({
          role: 'TRAINER',
          firstName: 'C',
          lastName: 'D',
          phone: uniquePhone(),
          email: 'Coach@Gym.bo',
        })
        .expect(409);
      expect(res.body.code).toBe('EMAIL_ALREADY_EXISTS');
    });

    it('validates the body', async () => {
      const res = await http()
        .post('/api/v1/admin/staff')
        .set(...bearer(admin.accessToken))
        .send({ role: 'TRAINER', firstName: '', lastName: 'Y', phone: '12', email: 'nope' })
        .expect(400);
      const fields = (res.body.details.fields as { field: string }[]).map((f) => f.field);
      expect(fields).toEqual(expect.arrayContaining(['firstName', 'phone', 'email']));
    });
  });

  describe('GET /admin/staff', () => {
    it('lists staff paginated, without members', async () => {
      await createAndLogin(t.app, t.prisma, Role.MEMBER);
      const res = await http()
        .get('/api/v1/admin/staff?page=1&pageSize=2')
        .set(...bearer(admin.accessToken))
        .expect(200);
      expect(res.body).toMatchObject({ page: 1, pageSize: 2 });
      expect(res.body.items).toHaveLength(2);
      expect(res.body.total).toBeGreaterThanOrEqual(5);
      const all = await http()
        .get('/api/v1/admin/staff?pageSize=100')
        .set(...bearer(admin.accessToken))
        .expect(200);
      expect((all.body.items as { role: string }[]).every((u) => u.role !== 'MEMBER')).toBe(true);
    });

    it('filters by role', async () => {
      const res = await http()
        .get('/api/v1/admin/staff?role=KIOSK')
        .set(...bearer(admin.accessToken))
        .expect(200);
      expect(res.body.total).toBe(1);
      expect(res.body.items[0].role).toBe('KIOSK');
    });
  });

  describe('deactivate / reactivate', () => {
    it('[R-43] deactivating a trainer revokes their sessions and hides them from the default list', async () => {
      const { user, session } = await createAndLogin(t.app, t.prisma, Role.TRAINER);
      const res = await http()
        .post(`/api/v1/admin/staff/${user.id}/deactivate`)
        .set(...bearer(admin.accessToken))
        .expect(200);
      expect(res.body.isActive).toBe(false);
      await http()
        .post('/api/v1/auth/refresh')
        .send({ refreshToken: session.refreshToken })
        .expect(401);
      await http()
        .get('/api/v1/me')
        .set(...bearer(session.accessToken))
        .expect(401);

      const list = await http()
        .get('/api/v1/admin/staff?pageSize=100')
        .set(...bearer(admin.accessToken))
        .expect(200);
      expect((list.body.items as { id: string }[]).some((u) => u.id === user.id)).toBe(false);
      const withInactive = await http()
        .get('/api/v1/admin/staff?pageSize=100&includeInactive=true')
        .set(...bearer(admin.accessToken))
        .expect(200);
      expect((withInactive.body.items as { id: string }[]).some((u) => u.id === user.id)).toBe(
        true,
      );

      const re = await http()
        .post(`/api/v1/admin/staff/${user.id}/reactivate`)
        .set(...bearer(admin.accessToken))
        .expect(200);
      expect(re.body.isActive).toBe(true);
    });

    it('[R-45] deactivating the last active admin is rejected', async () => {
      // Deactivate every other admin first, so `adminId` is the only active one.
      const others = await t.prisma.user.findMany({
        where: { role: 'ADMIN', isActive: true, id: { not: adminId } },
      });
      for (const o of others) {
        await http()
          .post(`/api/v1/admin/staff/${o.id}/deactivate`)
          .set(...bearer(admin.accessToken))
          .expect(200);
      }
      const res = await http()
        .post(`/api/v1/admin/staff/${adminId}/deactivate`)
        .set(...bearer(admin.accessToken))
        .expect(409);
      expect(res.body.code).toBe('LAST_ACTIVE_ADMIN');
      expect(await t.prisma.user.count({ where: { role: 'ADMIN', isActive: true } })).toBe(1);
    });

    it('[R-45] an admin can be deactivated while another active admin exists', async () => {
      const second = await createAndLogin(t.app, t.prisma, Role.ADMIN);
      await http()
        .post(`/api/v1/admin/staff/${second.user.id}/deactivate`)
        .set(...bearer(admin.accessToken))
        .expect(200);
    });

    it('returns 404 for a member id or an unknown id', async () => {
      const { user } = await createAndLogin(t.app, t.prisma, Role.MEMBER);
      await http()
        .post(`/api/v1/admin/staff/${user.id}/deactivate`)
        .set(...bearer(admin.accessToken))
        .expect(404);
      await http()
        .post('/api/v1/admin/staff/00000000-0000-4000-8000-000000000000/deactivate')
        .set(...bearer(admin.accessToken))
        .expect(404);
    });
  });

  describe('permissions', () => {
    it.each([Role.TRAINER, Role.MEMBER, Role.KIOSK])(
      'non-admin %s gets 403 on /admin/*',
      async (role) => {
        const { session } = await createAndLogin(t.app, t.prisma, role);
        const auth = bearer(session.accessToken);
        const list = await http()
          .get('/api/v1/admin/staff')
          .set(...auth)
          .expect(403);
        expect(list.body.code).toBe('FORBIDDEN');
        await http()
          .post('/api/v1/admin/staff')
          .set(...auth)
          .send({ role: 'TRAINER', firstName: 'X', lastName: 'Y', phone: uniquePhone() })
          .expect(403);
        await http()
          .post(`/api/v1/admin/staff/${adminId}/deactivate`)
          .set(...auth)
          .expect(403);
      },
    );

    it('anonymous gets 401 on /admin/*', async () => {
      await http().get('/api/v1/admin/staff').expect(401);
    });
  });
});
