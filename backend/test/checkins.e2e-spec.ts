import { CheckinResult, Role } from '@prisma/client';
import type { Server } from 'node:http';
import type { AddressInfo } from 'node:net';
import { io, Socket } from 'socket.io-client';
import request from 'supertest';
import { TestApp, createTestApp } from './support/app';
import { resetDatabase } from './support/database';
import {
  activateMember,
  bearer,
  createAndLogin,
  createMemberViaApi,
  CreatedMember,
  seedTestBase,
  Session,
} from './support/fixtures';

/** 12:00 in La Paz (UTC−4) on 2026-11-19. */
const NOON = '2026-11-19T16:00:00.000Z';
const MINUTE = 60_000;

interface Member {
  created: CreatedMember;
  session: Session;
}

describe('Check-in, kiosk QR and realtime (e2e)', () => {
  let t: TestApp;
  let admin: Session;
  let kiosk: Session;
  let kioskId: string;
  let baseUrl: string;
  const sockets: Socket[] = [];
  const http = () => request(t.app.getHttpServer());

  /** A BASIC member created today for 1 month (2026-11-19 .. 2026-12-18), logged in. */
  async function newMember(): Promise<Member> {
    const created = await createMemberViaApi(t.app, admin.accessToken, { firstName: 'Juan' });
    return { created, session: await activateMember(t.app, created) };
  }

  async function qrToken(session = kiosk): Promise<string> {
    const res = await http()
      .get('/api/v1/kiosk/qr-token')
      .set(...bearer(session.accessToken))
      .expect(200);
    return (res.body as { token: string }).token;
  }

  const scan = (m: Member, token: string) =>
    http()
      .post('/api/v1/checkins')
      .set(...bearer(m.session.accessToken))
      .send({ qrToken: token });

  const attempts = (memberId: string) =>
    t.prisma.checkinAttempt.findMany({ where: { memberId }, orderBy: { createdAt: 'asc' } });

  const checkins = (memberId: string) => t.prisma.checkin.count({ where: { memberId } });

  /** Connects to /realtime and resolves once the server says which rooms it joined. */
  function connect(token: string): Promise<{ socket: Socket; rooms: string[] }> {
    const socket = io(`${baseUrl}/realtime`, {
      auth: { token },
      transports: ['websocket'],
      reconnection: false,
    });
    sockets.push(socket);
    return new Promise((resolve, reject) => {
      socket.on('ready', (data: { rooms: string[] }) => resolve({ socket, rooms: data.rooms }));
      socket.on('unauthorized', () => reject(new Error('unauthorized')));
      socket.on('connect_error', reject);
    });
  }

  function nextEvent<T>(socket: Socket, event: string, ms = 3000): Promise<T> {
    return new Promise((resolve, reject) => {
      const timer = setTimeout(() => reject(new Error(`no ${event}`)), ms);
      socket.once(event, (payload: T) => {
        clearTimeout(timer);
        resolve(payload);
      });
    });
  }

  /** Collects every `event` received while `fn` runs, plus a short grace period. */
  async function collect(socket: Socket, event: string, fn: () => Promise<unknown>) {
    const got: unknown[] = [];
    const listener = (p: unknown) => got.push(p);
    socket.on(event, listener);
    await fn();
    await new Promise((r) => setTimeout(r, 300));
    socket.off(event, listener);
    return got;
  }

  beforeAll(async () => {
    t = await createTestApp({ now: NOON });
    await resetDatabase(t.prisma);
    await seedTestBase(t.prisma);
    admin = (await createAndLogin(t.app, t.prisma, Role.ADMIN)).session;
    const k = await createAndLogin(t.app, t.prisma, Role.KIOSK);
    kiosk = k.session;
    kioskId = k.user.id;
    await t.app.listen(0, '127.0.0.1');
    const server = t.app.getHttpServer() as unknown as Server;
    const { port } = server.address() as AddressInfo;
    baseUrl = `http://127.0.0.1:${port}`;
  });

  beforeEach(() => t.clock!.set(NOON));

  afterAll(async () => {
    sockets.forEach((s) => s.disconnect());
    await t.app.close();
  });

  describe('GET /kiosk/qr-token', () => {
    it('[R-18] returns a token valid for 45 s, refreshed every 30 s (KIOSK only)', async () => {
      const res = await http()
        .get('/api/v1/kiosk/qr-token')
        .set(...bearer(kiosk.accessToken))
        .expect(200);
      expect(res.body).toEqual({
        token: expect.any(String),
        expiresAt: '2026-11-19T16:00:45.000Z',
        refreshInSeconds: 30,
        gymName: expect.any(String),
      });
    });

    it('other roles get 403, anonymous 401', async () => {
      const m = await newMember();
      const trainer = (await createAndLogin(t.app, t.prisma, Role.TRAINER)).session;
      for (const s of [admin, trainer, m.session]) {
        await http()
          .get('/api/v1/kiosk/qr-token')
          .set(...bearer(s.accessToken))
          .expect(403);
      }
      await http().get('/api/v1/kiosk/qr-token').expect(401);
    });
  });

  describe('POST /checkins', () => {
    it('[R-17] [R-22] a valid scan creates a check-in and a SUCCESS attempt', async () => {
      const m = await newMember();
      const res = await scan(m, await qrToken()).expect(200);
      expect(res.body).toEqual({
        result: 'SUCCESS',
        duplicate: false,
        checkinId: expect.any(String),
        checkedInAt: NOON,
        member: { firstName: 'Juan' },
        membership: { tier: 'BASIC', endDate: '2026-12-18', daysLeft: 30 },
        todayWorkout: null,
      });
      const row = await t.prisma.checkin.findUniqueOrThrow({
        where: { id: (res.body as { checkinId: string }).checkinId },
      });
      expect(row).toMatchObject({ memberId: m.created.id, tier: 'BASIC', daysLeft: 30, kioskId });
      expect((await attempts(m.created.id)).map((a) => a.result)).toEqual([CheckinResult.SUCCESS]);
    });

    it('[R-19] a second scan within 3 h is a DUPLICATE: same data, no new check-in', async () => {
      const m = await newMember();
      const first = (await scan(m, await qrToken()).expect(200)).body as { checkinId: string };

      t.clock!.advanceMs(179 * MINUTE);
      const dup = await scan(m, await qrToken()).expect(200);
      expect(dup.body).toMatchObject({
        result: 'DUPLICATE',
        duplicate: true,
        checkinId: first.checkinId,
        checkedInAt: NOON,
        membership: { tier: 'BASIC', endDate: '2026-12-18', daysLeft: 30 },
      });
      expect(await checkins(m.created.id)).toBe(1);

      // After the cooldown, it counts again.
      t.clock!.advanceMs(1 * MINUTE);
      const again = await scan(m, await qrToken()).expect(200);
      expect(again.body).toMatchObject({ result: 'SUCCESS', duplicate: false });
      expect(await checkins(m.created.id)).toBe(2);
      expect((await attempts(m.created.id)).map((a) => a.result)).toEqual([
        CheckinResult.SUCCESS,
        CheckinResult.DUPLICATE,
        CheckinResult.SUCCESS,
      ]);
    });

    it('[R-18] a token is still accepted 40 s later but expired after 45 s', async () => {
      const m = await newMember();
      const token = await qrToken();
      t.clock!.advanceMs(46_000);
      const res = await scan(m, token).expect(400);
      expect(res.body).toMatchObject({ code: 'QR_TOKEN_EXPIRED' });

      t.clock!.set(NOON);
      const fresh = await qrToken();
      t.clock!.advanceMs(40_000);
      await scan(m, fresh).expect(200);

      const rows = await attempts(m.created.id);
      expect(rows.map((a) => [a.result, a.detail]).sort()).toEqual([
        [CheckinResult.INVALID_TOKEN, 'expired'],
        [CheckinResult.SUCCESS, expect.any(String)],
      ]);
      expect(await checkins(m.created.id)).toBe(1);
    });

    it('[R-17] [R-22] a tampered token is rejected as INVALID_TOKEN', async () => {
      const m = await newMember();
      const [h, p, s] = (await qrToken()).split('.');
      const claims = JSON.parse(Buffer.from(p, 'base64url').toString()) as object;
      const forged = Buffer.from(JSON.stringify({ ...claims, exp: 9999999999 })).toString(
        'base64url',
      );
      const res = await scan(m, `${h}.${forged}.${s}`).expect(400);
      expect(res.body).toMatchObject({ code: 'QR_TOKEN_INVALID' });
      await scan(m, 'garbage').expect(400);
      expect((await attempts(m.created.id)).map((a) => [a.result, a.detail])).toEqual([
        [CheckinResult.INVALID_TOKEN, 'invalid'],
        [CheckinResult.INVALID_TOKEN, 'invalid'],
      ]);
      expect(await checkins(m.created.id)).toBe(0);
    });

    it("[R-17] another role's token used as the QR is invalid", async () => {
      const m = await newMember();
      for (const token of [admin.accessToken, kiosk.accessToken, m.session.accessToken]) {
        const res = await scan(m, token).expect(400);
        expect(res.body).toMatchObject({ code: 'QR_TOKEN_INVALID' });
      }
      expect(await checkins(m.created.id)).toBe(0);
    });

    it('[R-17] a QR from a deactivated kiosk is invalid', async () => {
      const m = await newMember();
      const other = await createAndLogin(t.app, t.prisma, Role.KIOSK);
      const token = await qrToken(other.session);
      await t.prisma.user.update({ where: { id: other.user.id }, data: { isActive: false } });
      const res = await scan(m, token).expect(400);
      expect(res.body).toMatchObject({ code: 'QR_TOKEN_INVALID' });
    });

    it('[R-20] [R-22] an expired membership is denied and stored as DENIED_EXPIRED', async () => {
      const m = await newMember();
      await t.prisma.membership.update({
        where: { memberId: m.created.id },
        data: { endDate: new Date('2026-11-10T00:00:00Z') },
      });
      const res = await scan(m, await qrToken()).expect(403);
      expect(res.body).toMatchObject({
        code: 'MEMBERSHIP_EXPIRED',
        details: { endDate: '2026-11-10' },
      });
      expect(await checkins(m.created.id)).toBe(0);
      expect((await attempts(m.created.id))[0]).toMatchObject({
        result: CheckinResult.DENIED_EXPIRED,
        detail: 'endDate=2026-11-10',
        kioskId,
      });
    });

    it('[R-01] the last day of the membership is still active', async () => {
      const m = await newMember();
      t.clock!.set('2026-12-18T23:30:00.000Z'); // 19:30 in La Paz on the end date
      const res = await scan(m, await qrToken()).expect(200);
      expect(res.body).toMatchObject({ membership: { daysLeft: 1 } });
    });

    it('[R-21] [R-22] a deactivated account with a stale session is DENIED_INACTIVE', async () => {
      const m = await newMember();
      await http()
        .post(`/api/v1/admin/members/${m.created.id}/deactivate`)
        .set(...bearer(admin.accessToken))
        .expect(200);
      const res = await scan(m, await qrToken()).expect(403);
      expect(res.body).toMatchObject({ code: 'ACCOUNT_INACTIVE' });
      expect((await attempts(m.created.id))[0].result).toBe(CheckinResult.DENIED_INACTIVE);
      expect(await checkins(m.created.id)).toBe(0);
      // [R-43] Every other route still rejects the stale token.
      await http()
        .get('/api/v1/me')
        .set(...bearer(m.session.accessToken))
        .expect(401);
    });

    it('[R-17] only members can check in (403), anonymous gets 401', async () => {
      const token = await qrToken();
      const trainer = (await createAndLogin(t.app, t.prisma, Role.TRAINER)).session;
      for (const s of [admin, kiosk, trainer]) {
        const res = await http()
          .post('/api/v1/checkins')
          .set(...bearer(s.accessToken))
          .send({ qrToken: token })
          .expect(403);
        expect(res.body).toMatchObject({ code: 'FORBIDDEN' });
      }
      await http().post('/api/v1/checkins').send({ qrToken: token }).expect(401);
    });

    it('validates the body', async () => {
      const m = await newMember();
      const res = await http()
        .post('/api/v1/checkins')
        .set(...bearer(m.session.accessToken))
        .send({})
        .expect(400);
      expect(res.body).toMatchObject({ code: 'VALIDATION_ERROR' });
    });

    it('is limited to 10 scans per minute per member (429)', async () => {
      const m = await newMember();
      const token = await qrToken();
      for (let i = 0; i < 10; i++) await scan(m, token).expect(200);
      const res = await scan(m, token).expect(429);
      expect(res.body).toMatchObject({ code: 'TOO_MANY_REQUESTS' });
      // Another member is not affected.
      const other = await newMember();
      await scan(other, token).expect(200);
    });
  });

  describe('admin check-in lists', () => {
    it('[R-23] "inside now" = latest successful check-in in the last 2 hours', async () => {
      await t.prisma.checkin.deleteMany();
      const a = await newMember();
      const b = await newMember();
      await scan(a, await qrToken()).expect(200);
      t.clock!.advanceMs(90 * MINUTE);
      await scan(b, await qrToken()).expect(200);

      const now = await http()
        .get('/api/v1/admin/checkins/inside')
        .set(...bearer(admin.accessToken))
        .expect(200);
      expect(now.body).toMatchObject({ count: 2, windowMinutes: 120 });

      t.clock!.advanceMs(31 * MINUTE); // a: 121 min ago, b: 31 min ago
      const later = await http()
        .get('/api/v1/admin/checkins/inside')
        .set(...bearer(admin.accessToken))
        .expect(200);
      const body = later.body as { count: number; items: { member: { id: string } }[] };
      expect(body.count).toBe(1);
      expect(body.items[0].member.id).toBe(b.created.id);
    });

    it('lists check-ins (by member and gym date) and denied attempts', async () => {
      const m = await newMember();
      await scan(m, await qrToken()).expect(200);
      await scan(m, 'garbage').expect(400);

      const list = await http()
        .get(`/api/v1/admin/checkins?memberId=${m.created.id}&from=2026-11-19&to=2026-11-19`)
        .set(...bearer(admin.accessToken))
        .expect(200);
      expect(list.body).toMatchObject({
        total: 1,
        items: [{ member: { id: m.created.id, firstName: 'Juan' }, tier: 'BASIC' }],
      });
      const otherDay = await http()
        .get(`/api/v1/admin/checkins?memberId=${m.created.id}&from=2026-11-20`)
        .set(...bearer(admin.accessToken))
        .expect(200);
      expect(otherDay.body).toMatchObject({ total: 0 });

      const denied = await http()
        .get(`/api/v1/admin/checkins/attempts?memberId=${m.created.id}`)
        .set(...bearer(admin.accessToken))
        .expect(200);
      expect(denied.body).toMatchObject({ total: 1, items: [{ result: 'INVALID_TOKEN' }] });
      const successes = await http()
        .get(`/api/v1/admin/checkins/attempts?memberId=${m.created.id}&result=SUCCESS`)
        .set(...bearer(admin.accessToken))
        .expect(200);
      expect(successes.body).toMatchObject({ total: 1 });
    });

    it('admin lists are ADMIN only', async () => {
      const m = await newMember();
      for (const path of ['', '/inside', '/attempts']) {
        await http()
          .get(`/api/v1/admin/checkins${path}`)
          .set(...bearer(m.session.accessToken))
          .expect(403);
        await http()
          .get(`/api/v1/admin/checkins${path}`)
          .set(...bearer(kiosk.accessToken))
          .expect(403);
      }
    });

    it('GET /me/checkins returns only my own history', async () => {
      const a = await newMember();
      const b = await newMember();
      await scan(a, await qrToken()).expect(200);
      await scan(b, await qrToken()).expect(200);
      const res = await http()
        .get('/api/v1/me/checkins')
        .set(...bearer(a.session.accessToken))
        .expect(200);
      expect(res.body).toMatchObject({ total: 1, items: [{ tier: 'BASIC', createdAt: NOON }] });
      await http()
        .get('/api/v1/me/checkins')
        .set(...bearer(admin.accessToken))
        .expect(403);
    });
  });

  describe('realtime /realtime', () => {
    it('an admin socket receives checkin.created (not for duplicates)', async () => {
      const { socket, rooms } = await connect(admin.accessToken);
      expect(rooms).toEqual(['admins']);
      const m = await newMember();

      const created = nextEvent<Record<string, unknown>>(socket, 'checkin.created');
      const res = await scan(m, await qrToken()).expect(200);
      expect(await created).toEqual({
        checkinId: (res.body as { checkinId: string }).checkinId,
        member: { id: m.created.id, firstName: 'Juan', lastName: 'Pérez' },
        tier: 'BASIC',
        daysLeft: 30,
        createdAt: NOON,
      });

      const token = await qrToken();
      const events = await collect(socket, 'checkin.created', () => scan(m, token).expect(200));
      expect(events).toEqual([]);
    });

    it('[R-20] an admin socket receives checkin.denied for an expired membership', async () => {
      const { socket } = await connect(admin.accessToken);
      const m = await newMember();
      await t.prisma.membership.update({
        where: { memberId: m.created.id },
        data: { endDate: new Date('2026-11-10T00:00:00Z') },
      });
      const denied = nextEvent<Record<string, unknown>>(socket, 'checkin.denied');
      await scan(m, await qrToken()).expect(403);
      expect(await denied).toMatchObject({
        member: { id: m.created.id, firstName: 'Juan' },
        reason: 'EXPIRED',
        endDate: '2026-11-10',
      });
    });

    it('non-admin sockets join no room and get no admin events', async () => {
      const m = await newMember();
      const { socket, rooms } = await connect(m.session.accessToken);
      expect(rooms).toEqual([]);
      const events = await collect(socket, 'checkin.created', async () =>
        scan(m, await qrToken()).expect(200),
      );
      expect(events).toEqual([]);
    });

    it('a missing or invalid token is refused', async () => {
      await expect(connect('nope')).rejects.toThrow('unauthorized');
      await expect(connect(kiosk.accessToken.slice(0, -2) + 'xx')).rejects.toThrow('unauthorized');
    });
  });
});
