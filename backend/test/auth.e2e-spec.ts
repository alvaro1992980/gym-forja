import { Role, Tier } from '@prisma/client';
import request from 'supertest';
import { parseLocalDate } from '../src/common/date/gym-date';
import { TestApp, createTestApp } from './support/app';
import { resetDatabase } from './support/database';
import {
  bearer,
  createAndLogin,
  createUser,
  login,
  SEED_ADMIN,
  seedTestBase,
  Session,
} from './support/fixtures';

// 2026-11-19 12:00 in La Paz.
const NOW = '2026-11-19T16:00:00Z';

describe('Auth (e2e)', () => {
  let t: TestApp;
  const http = () => request(t.app.getHttpServer());

  beforeAll(async () => {
    t = await createTestApp({ now: NOW });
    await resetDatabase(t.prisma);
    await seedTestBase(t.prisma);
  });

  afterAll(async () => {
    await t.app.close();
  });

  describe('seeded admin, first login', () => {
    let session: Session;

    it('logs in with the seeded phone and password and must change the password', async () => {
      session = await login(t.app, SEED_ADMIN.phone, SEED_ADMIN.password);
      expect(session.accessToken).toEqual(expect.any(String));
      expect(session.refreshToken).toEqual(expect.any(String));
      expect(session.user).toMatchObject({ role: 'ADMIN', mustChangePassword: true });
    });

    it('[R-40] accepts the phone in local format with separators', async () => {
      const s = await login(t.app, '7000-0000', SEED_ADMIN.password);
      expect(s.user.id).toBe(session.user.id);
    });

    it('GET /me works while the password change is pending', async () => {
      const res = await http()
        .get('/api/v1/me')
        .set(...bearer(session.accessToken))
        .expect(200);
      expect(res.body).toMatchObject({
        role: 'ADMIN',
        phone: SEED_ADMIN.phone,
        mustChangePassword: true,
        membership: null,
      });
    });

    it('other endpoints return 403 PASSWORD_CHANGE_REQUIRED', async () => {
      const res = await http()
        .get('/api/v1/admin/staff')
        .set(...bearer(session.accessToken))
        .expect(403);
      expect(res.body.code).toBe('PASSWORD_CHANGE_REQUIRED');
    });

    it('rejects a wrong current password', async () => {
      const res = await http()
        .post('/api/v1/auth/change-password')
        .set(...bearer(session.accessToken))
        .send({ currentPassword: 'nope-nope', newPassword: 'NewPass123' })
        .expect(400);
      expect(res.body.code).toBe('WRONG_CURRENT_PASSWORD');
    });

    it('[R-42] rejects a new password shorter than 8 characters', async () => {
      const res = await http()
        .post('/api/v1/auth/change-password')
        .set(...bearer(session.accessToken))
        .send({ currentPassword: SEED_ADMIN.password, newPassword: 'Short7!' })
        .expect(400);
      expect(res.body.code).toBe('VALIDATION_ERROR');
      expect(JSON.stringify(res.body.details)).toContain('newPassword');
    });

    it('rejects reusing the current password', async () => {
      const res = await http()
        .post('/api/v1/auth/change-password')
        .set(...bearer(session.accessToken))
        .send({ currentPassword: SEED_ADMIN.password, newPassword: SEED_ADMIN.password })
        .expect(400);
      expect(res.body.code).toBe('PASSWORD_UNCHANGED');
    });

    it('changes the password, which unlocks the other endpoints immediately', async () => {
      await http()
        .post('/api/v1/auth/change-password')
        .set(...bearer(session.accessToken))
        .send({ currentPassword: SEED_ADMIN.password, newPassword: 'NewAdminPass1' })
        .expect(204);
      await http()
        .get('/api/v1/admin/staff')
        .set(...bearer(session.accessToken))
        .expect(200);
    });

    it('the new password works and the old one does not', async () => {
      const s = await login(t.app, SEED_ADMIN.phone, 'NewAdminPass1');
      expect(s.user.mustChangePassword).toBe(false);
      const res = await http()
        .post('/api/v1/auth/login')
        .send({ phone: SEED_ADMIN.phone, password: SEED_ADMIN.password })
        .expect(401);
      expect(res.body.code).toBe('INVALID_CREDENTIALS');
    });
  });

  describe('login errors', () => {
    it('unknown phone → 401 INVALID_CREDENTIALS', async () => {
      const res = await http()
        .post('/api/v1/auth/login')
        .send({ phone: '+59179999999', password: 'whatever1' })
        .expect(401);
      expect(res.body.code).toBe('INVALID_CREDENTIALS');
    });

    it('[R-43] deactivated account → 403 ACCOUNT_INACTIVE (only with the right password)', async () => {
      const user = await createUser(t.prisma, { role: Role.MEMBER, isActive: false });
      const ok = await http()
        .post('/api/v1/auth/login')
        .send({ phone: user.phone, password: user.password })
        .expect(403);
      expect(ok.body.code).toBe('ACCOUNT_INACTIVE');
      const wrong = await http()
        .post('/api/v1/auth/login')
        .send({ phone: user.phone, password: 'wrong-password' })
        .expect(401);
      expect(wrong.body.code).toBe('INVALID_CREDENTIALS');
    });

    it('invalid body → 400 VALIDATION_ERROR, unknown fields rejected', async () => {
      const res = await http()
        .post('/api/v1/auth/login')
        .send({ phone: '+59170000000', password: 'x', extra: true })
        .expect(400);
      expect(res.body.code).toBe('VALIDATION_ERROR');
      await http().post('/api/v1/auth/login').send({ phone: 'abc', password: 'x' }).expect(400);
    });

    it('login is rate limited to 5 attempts per minute per IP + phone', async () => {
      const user = await createUser(t.prisma, { role: Role.MEMBER });
      for (let i = 0; i < 5; i++) {
        await http()
          .post('/api/v1/auth/login')
          .send({ phone: user.phone, password: 'wrong-password' })
          .expect(401);
      }
      const blocked = await http()
        .post('/api/v1/auth/login')
        .send({ phone: user.phone, password: user.password })
        .expect(429);
      expect(blocked.body.code).toBe('TOO_MANY_REQUESTS');
      // Another phone from the same IP is not blocked.
      const other = await createUser(t.prisma, { role: Role.MEMBER });
      await login(t.app, other.phone, other.password);
    });
  });

  describe('access tokens', () => {
    it('no token → 401 UNAUTHORIZED', async () => {
      const res = await http().get('/api/v1/me').expect(401);
      expect(res.body.code).toBe('UNAUTHORIZED');
    });

    it('malformed or forged token → 401', async () => {
      await http().get('/api/v1/me').set('Authorization', 'Bearer abc.def.ghi').expect(401);
      const { session } = await createAndLogin(t.app, t.prisma, Role.MEMBER);
      const [h, p] = session.accessToken.split('.');
      await http()
        .get('/api/v1/me')
        .set('Authorization', `Bearer ${h}.${p}.invalidsignature`)
        .expect(401);
    });

    it('[R-43] a deactivated user cannot use a still-valid access token', async () => {
      const { user, session } = await createAndLogin(t.app, t.prisma, Role.TRAINER);
      await t.prisma.user.update({ where: { id: user.id }, data: { isActive: false } });
      await http()
        .get('/api/v1/me')
        .set(...bearer(session.accessToken))
        .expect(401);
    });
  });

  describe('refresh tokens', () => {
    it('a refresh token works once and returns a new pair', async () => {
      const { session } = await createAndLogin(t.app, t.prisma, Role.MEMBER);
      const res = await http()
        .post('/api/v1/auth/refresh')
        .send({ refreshToken: session.refreshToken })
        .expect(200);
      const next = res.body as Session;
      expect(next.refreshToken).not.toBe(session.refreshToken);
      await http()
        .get('/api/v1/me')
        .set(...bearer(next.accessToken))
        .expect(200);
    });

    it('reusing a refresh token revokes ALL of that user’s tokens', async () => {
      const { user, session: s1 } = await createAndLogin(t.app, t.prisma, Role.MEMBER);
      const s2 = await login(t.app, user.phone, user.password); // a second device

      const rotated = (
        await http()
          .post('/api/v1/auth/refresh')
          .send({ refreshToken: s1.refreshToken })
          .expect(200)
      ).body as Session;

      // The old token is presented again (stolen copy) → rejected...
      const reuse = await http()
        .post('/api/v1/auth/refresh')
        .send({ refreshToken: s1.refreshToken })
        .expect(401);
      expect(reuse.body.code).toBe('INVALID_REFRESH_TOKEN');

      // ...and every session of the user is gone, including the legitimate rotated one.
      await http()
        .post('/api/v1/auth/refresh')
        .send({ refreshToken: rotated.refreshToken })
        .expect(401);
      await http().post('/api/v1/auth/refresh').send({ refreshToken: s2.refreshToken }).expect(401);
      const active = await t.prisma.refreshToken.count({
        where: { userId: user.id, revokedAt: null },
      });
      expect(active).toBe(0);
    });

    it('an unknown refresh token → 401 INVALID_REFRESH_TOKEN', async () => {
      const res = await http()
        .post('/api/v1/auth/refresh')
        .send({ refreshToken: 'not-a-real-token' })
        .expect(401);
      expect(res.body.code).toBe('INVALID_REFRESH_TOKEN');
    });

    it('an expired refresh token → 401', async () => {
      const { session } = await createAndLogin(t.app, t.prisma, Role.MEMBER);
      t.clock!.advanceMs(31 * 24 * 60 * 60 * 1000);
      try {
        await http()
          .post('/api/v1/auth/refresh')
          .send({ refreshToken: session.refreshToken })
          .expect(401);
      } finally {
        t.clock!.set(NOW);
      }
    });

    it('stores only a hash of the refresh token', async () => {
      const { session } = await createAndLogin(t.app, t.prisma, Role.MEMBER);
      const leaked = await t.prisma.refreshToken.findFirst({
        where: { tokenHash: session.refreshToken },
      });
      expect(leaked).toBeNull();
    });
  });

  describe('logout', () => {
    it('revokes the refresh token and removes the device FCM token', async () => {
      const { user, session } = await createAndLogin(t.app, t.prisma, Role.MEMBER);
      await t.prisma.device.create({
        data: { userId: user.id, fcmToken: `fcm-${user.id}`, platform: 'android' },
      });
      await http()
        .post('/api/v1/auth/logout')
        .set(...bearer(session.accessToken))
        .send({ refreshToken: session.refreshToken, fcmToken: `fcm-${user.id}` })
        .expect(204);
      await http()
        .post('/api/v1/auth/refresh')
        .send({ refreshToken: session.refreshToken })
        .expect(401);
      expect(await t.prisma.device.count({ where: { userId: user.id } })).toBe(0);
    });

    it('cannot revoke another user’s refresh token', async () => {
      const a = await createAndLogin(t.app, t.prisma, Role.MEMBER);
      const b = await createAndLogin(t.app, t.prisma, Role.MEMBER);
      await http()
        .post('/api/v1/auth/logout')
        .set(...bearer(a.session.accessToken))
        .send({ refreshToken: b.session.refreshToken })
        .expect(204);
      await http()
        .post('/api/v1/auth/refresh')
        .send({ refreshToken: b.session.refreshToken })
        .expect(200);
    });
  });

  describe('GET /me', () => {
    it('returns the member profile with a membership summary and no medical notes', async () => {
      const { user, session } = await createAndLogin(t.app, t.prisma, Role.MEMBER, {
        medicalNotes: 'Asma',
      });
      await t.prisma.membership.create({
        data: {
          memberId: user.id,
          tier: Tier.PLUS,
          startDate: parseLocalDate('2026-11-15'),
          endDate: parseLocalDate('2026-12-14'),
        },
      });
      const res = await http()
        .get('/api/v1/me')
        .set(...bearer(session.accessToken))
        .expect(200);
      expect(res.body.membership).toEqual({
        tier: 'PLUS',
        startDate: '2026-11-15',
        endDate: '2026-12-14',
        daysLeft: 26, // [R-02] (2026-12-14 − 2026-11-19) + 1
        status: 'active',
        nextTier: null,
        nextTierStartDate: null,
      });
      expect(res.body).not.toHaveProperty('medicalNotes');
      expect(res.body).not.toHaveProperty('passwordHash');
    });
  });
});
