import { NotificationType, Role } from '@prisma/client';
import request from 'supertest';
import { addDays, parseLocalDate } from '../src/common/date/gym-date';
import { NotificationsService } from '../src/modules/notifications/notifications.service';
import { PushMessage, PushResult, PushSender } from '../src/modules/notifications/push.sender';
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

/** 08:00 in La Paz (UTC−4) on 2026-11-19. */
const MORNING = '2026-11-19T12:00:00.000Z';
const TODAY = parseLocalDate('2026-11-19');

/** Records pushes; tokens starting with `dead-` are reported invalid by "FCM". */
class RecordingPush extends PushSender {
  sent: { tokens: string[]; message: PushMessage }[] = [];
  failNext = false;

  send(tokens: string[], message: PushMessage): Promise<PushResult> {
    if (this.failNext) {
      this.failNext = false;
      return Promise.reject(new Error('FCM down'));
    }
    this.sent.push({ tokens, message });
    return Promise.resolve({ invalidTokens: tokens.filter((t) => t.startsWith('dead-')) });
  }
}

interface Member {
  created: CreatedMember;
  session: Session;
}

describe('Notifications, devices, inbox and the daily job (e2e)', () => {
  let t: TestApp;
  let push: RecordingPush;
  let notifications: NotificationsService;
  let admin: Session;
  let adminId: string;
  let kiosk: Session;
  const http = () => request(t.app.getHttpServer());

  async function newMember(firstName = 'Juan'): Promise<Member> {
    const created = await createMemberViaApi(t.app, admin.accessToken, { firstName });
    return { created, session: await activateMember(t.app, created) };
  }

  const registerDevice = (s: Session, fcmToken: string) =>
    http()
      .post('/api/v1/me/devices')
      .set(...bearer(s.accessToken))
      .send({ fcmToken, platform: 'android' });

  async function scan(m: Member) {
    const qr = await http()
      .get('/api/v1/kiosk/qr-token')
      .set(...bearer(kiosk.accessToken))
      .expect(200);
    const res = await http()
      .post('/api/v1/checkins')
      .set(...bearer(m.session.accessToken))
      .send({ qrToken: (qr.body as { token: string }).token });
    await notifications.flush();
    return res;
  }

  const stored = (userId: string, type?: NotificationType) =>
    t.prisma.notification.findMany({ where: { userId, type }, orderBy: { createdAt: 'asc' } });

  const setEndDate = (memberId: string, endDate: Date) =>
    t.prisma.membership.update({ where: { memberId }, data: { endDate } });

  const runDaily = (s = admin) =>
    http()
      .post('/api/v1/admin/jobs/daily-expiry/run')
      .set(...bearer(s.accessToken));

  beforeAll(async () => {
    push = new RecordingPush();
    t = await createTestApp({ now: MORNING, push });
    notifications = t.app.get(NotificationsService);
    await resetDatabase(t.prisma);
    await seedTestBase(t.prisma);
    // The seeded admin must change the password: deactivate it so only this admin is "all admins".
    await t.prisma.user.updateMany({ where: { role: Role.ADMIN }, data: { isActive: false } });
    const a = await createAndLogin(t.app, t.prisma, Role.ADMIN);
    admin = a.session;
    adminId = a.user.id;
    kiosk = (await createAndLogin(t.app, t.prisma, Role.KIOSK)).session;
  });

  beforeEach(async () => {
    t.clock!.set(MORNING);
    push.sent = [];
    await t.prisma.notification.deleteMany();
    await t.prisma.checkin.deleteMany();
    await t.prisma.device.deleteMany();
  });

  afterAll(async () => {
    await t.app.close();
  });

  describe('devices (8.6)', () => {
    it('upserts by token, moves a token to the new user, deletes only your own', async () => {
      const m = await newMember();
      await registerDevice(m.session, 'token-aaaaaaaaaa').expect(204);
      await registerDevice(m.session, 'token-aaaaaaaaaa').expect(204);
      expect(await t.prisma.device.count({ where: { fcmToken: 'token-aaaaaaaaaa' } })).toBe(1);

      // Same phone, another account signs in.
      await registerDevice(admin, 'token-aaaaaaaaaa').expect(204);
      const device = await t.prisma.device.findUniqueOrThrow({
        where: { fcmToken: 'token-aaaaaaaaaa' },
      });
      expect(device.userId).toBe(adminId);

      await http()
        .delete('/api/v1/me/devices/token-aaaaaaaaaa')
        .set(...bearer(m.session.accessToken))
        .expect(204);
      expect(await t.prisma.device.count()).toBe(1); // not the member's anymore
      await http()
        .delete('/api/v1/me/devices/token-aaaaaaaaaa')
        .set(...bearer(admin.accessToken))
        .expect(204);
      expect(await t.prisma.device.count()).toBe(0);
    });

    it('logout with fcmToken deletes the device', async () => {
      const m = await newMember();
      await registerDevice(m.session, 'token-logout-1').expect(204);
      await http()
        .post('/api/v1/auth/logout')
        .set(...bearer(m.session.accessToken))
        .send({ refreshToken: m.session.refreshToken, fcmToken: 'token-logout-1' })
        .expect(204);
      expect(await t.prisma.device.count()).toBe(0);
    });

    it('validates the body and needs a session', async () => {
      const m = await newMember();
      await http()
        .post('/api/v1/me/devices')
        .set(...bearer(m.session.accessToken))
        .send({ fcmToken: 'token-bbbbbbbbbb', platform: 'windows' })
        .expect(400);
      await http()
        .post('/api/v1/me/devices')
        .send({ fcmToken: 'token-bbbbbbbbbb', platform: 'ios' })
        .expect(401);
    });
  });

  describe('check-in notifications (section 7)', () => {
    it('a check-in stores and pushes CHECKIN_ADMIN and CHECKIN_MEMBER', async () => {
      const m = await newMember('Ana');
      await registerDevice(m.session, 'token-member-1').expect(204);
      await registerDevice(admin, 'token-admin-1').expect(204);
      const res = await scan(m);
      expect(res.status).toBe(200);

      const [toAdmin] = await stored(adminId, 'CHECKIN_ADMIN');
      expect(toAdmin).toMatchObject({
        title: 'Ingreso',
        body: 'Ana Pérez · Mensual · 30 días restantes',
        data: { memberId: m.created.id, checkinId: (res.body as { checkinId: string }).checkinId },
      });
      const [toMember] = await stored(m.created.id, 'CHECKIN_MEMBER');
      expect(toMember.title).toBe('¡Bienvenido, Ana!');

      expect(push.sent.map((p) => [p.tokens, p.message.title])).toEqual(
        expect.arrayContaining([
          [['token-admin-1'], 'Ingreso'],
          [['token-member-1'], '¡Bienvenido, Ana!'],
        ]),
      );
      const adminPush = push.sent.find((p) => p.tokens[0] === 'token-admin-1')!;
      expect(adminPush.message.data).toEqual({
        memberId: m.created.id,
        checkinId: expect.any(String),
        type: 'CHECKIN_ADMIN',
        notificationId: toAdmin.id,
      });
    });

    it('[R-19] a duplicate check-in notifies nobody', async () => {
      const m = await newMember();
      await scan(m);
      await t.prisma.notification.deleteMany();
      t.clock!.advanceMs(10 * 60_000);
      const res = await scan(m);
      expect((res.body as { duplicate: boolean }).duplicate).toBe(true);
      expect(await t.prisma.notification.count()).toBe(0);
    });

    it('[R-20] an expired scan notifies both the admins and the member', async () => {
      const m = await newMember('Eva');
      await setEndDate(m.created.id, addDays(TODAY, -9));
      const res = await scan(m);
      expect(res.status).toBe(403);
      expect((await stored(adminId, 'CHECKIN_DENIED_ADMIN'))[0].body).toBe(
        'Eva Pérez intentó ingresar: membresía vencida el 10/11/2026',
      );
      expect((await stored(m.created.id, 'CHECKIN_DENIED_MEMBER'))[0].data).toEqual({
        screen: 'home',
      });
    });

    it('deletes devices whose token FCM rejects', async () => {
      const m = await newMember();
      await registerDevice(m.session, 'dead-token-123').expect(204);
      await registerDevice(m.session, 'live-token-123').expect(204);
      await scan(m);
      const left = await t.prisma.device.findMany({ where: { userId: m.created.id } });
      expect(left.map((d) => d.fcmToken)).toEqual(['live-token-123']);
    });

    it('a push failure never fails the check-in; the inbox still has it', async () => {
      const m = await newMember();
      await registerDevice(m.session, 'token-member-2').expect(204);
      push.failNext = true;
      const res = await scan(m);
      expect(res.status).toBe(200);
      expect(await stored(m.created.id, 'CHECKIN_MEMBER')).toHaveLength(1);
    });
  });

  describe('payment and tier notifications', () => {
    it('a renewal sends PAYMENT_RECORDED; a tier change sends TIER_CHANGED', async () => {
      const m = await newMember();
      await http()
        .post(`/api/v1/admin/members/${m.created.id}/payments`)
        .set(...bearer(admin.accessToken))
        .send({ tier: 'BASIC', months: 1, amount: 150, method: 'CASH' })
        .expect(201);
      await http()
        .post(`/api/v1/admin/members/${m.created.id}/tier-change`)
        .set(...bearer(admin.accessToken))
        .send({ toTier: 'PLUS', method: 'CASH' })
        .expect(200);
      await notifications.flush();
      expect((await stored(m.created.id, 'PAYMENT_RECORDED'))[0].body).toBe(
        'Renovaste Mensual hasta el 18/01/2027. ¡Gracias!',
      );
      expect((await stored(m.created.id, 'TIER_CHANGED'))[0].body).toBe('Ahora tienes Mensual +.');
    });
  });

  describe('inbox (8.6)', () => {
    it('lists newest first with unreadCount; read one, read all; only your own', async () => {
      const m = await newMember();
      await scan(m); // CHECKIN_MEMBER
      t.clock!.advanceMs(60_000);
      await http()
        .post(`/api/v1/admin/members/${m.created.id}/payments`)
        .set(...bearer(admin.accessToken))
        .send({ tier: 'BASIC', months: 1, amount: 150, method: 'CASH' })
        .expect(201);
      await notifications.flush();

      const inbox = () =>
        http()
          .get('/api/v1/me/notifications')
          .set(...bearer(m.session.accessToken))
          .expect(200)
          .then(
            (r) =>
              r.body as {
                items: { id: string; type: string; readAt: string | null }[];
                total: number;
                unreadCount: number;
              },
          );
      let body = await inbox();
      expect(body.items.map((i) => i.type)).toEqual(['PAYMENT_RECORDED', 'CHECKIN_MEMBER']);
      expect(body).toMatchObject({ total: 2, unreadCount: 2, page: 1, pageSize: 20 });

      await http()
        .post(`/api/v1/me/notifications/${body.items[1].id}/read`)
        .set(...bearer(m.session.accessToken))
        .expect(204);
      body = await inbox();
      expect(body.unreadCount).toBe(1);
      expect(body.items[1].readAt).not.toBeNull();

      // Someone else's notification looks like it does not exist.
      const [adminNote] = await stored(adminId);
      await http()
        .post(`/api/v1/me/notifications/${adminNote.id}/read`)
        .set(...bearer(m.session.accessToken))
        .expect(404);

      await http()
        .post('/api/v1/me/notifications/read-all')
        .set(...bearer(m.session.accessToken))
        .expect(204);
      expect((await inbox()).unreadCount).toBe(0);
      expect((await stored(adminId)).every((n) => n.readAt === null)).toBe(true);
    });
  });

  describe('daily job [R-24]–[R-26]', () => {
    let in7: Member;
    let in3: Member;
    let lastDay: Member;
    let expiredYesterday: Member;

    beforeEach(async () => {
      await t.prisma.notificationLog.deleteMany();
      // Park every existing membership far away so only these four are due.
      await t.prisma.membership.updateMany({ data: { endDate: addDays(TODAY, 100) } });
      in7 = await newMember('Siete');
      in3 = await newMember('Tres');
      lastDay = await newMember('Uno');
      expiredYesterday = await newMember('Ayer');
      await setEndDate(in7.created.id, addDays(TODAY, 6));
      await setEndDate(in3.created.id, addDays(TODAY, 2));
      await setEndDate(lastDay.created.id, TODAY);
      await setEndDate(expiredYesterday.created.id, addDays(TODAY, -1));
    });

    it('[R-24] reminds 7/3/1 days left, notifies yesterday’s expiries and sends one summary', async () => {
      const res = await runDaily().expect(200);
      expect(res.body).toEqual({
        date: '2026-11-19',
        sent: { EXPIRING_7: 1, EXPIRING_3: 1, EXPIRING_1: 1, EXPIRED_MEMBER: 1 },
        skipped: 0,
        adminSummary: true,
      });
      expect((await stored(in7.created.id, 'EXPIRING_7'))[0].body).toBe(
        'Te quedan 7 días (vence el 25/11/2026).',
      );
      expect(await stored(in3.created.id, 'EXPIRING_3')).toHaveLength(1);
      expect(await stored(lastDay.created.id, 'EXPIRING_1')).toHaveLength(1);
      expect(await stored(expiredYesterday.created.id, 'EXPIRED_MEMBER')).toHaveLength(1);
      const summaries = await stored(adminId, 'ADMIN_DAILY_SUMMARY');
      expect(summaries).toHaveLength(1);
      expect(summaries[0].body).toBe(
        '1 vence en 7 días · 1 en 3 días · 1 hoy (último día) · 1 venció ayer',
      );
    });

    it('[R-25] running the job twice the same day sends each reminder once', async () => {
      await runDaily().expect(200);
      t.clock!.advanceMs(3 * 3600_000); // 11:00, same day
      const second = await runDaily().expect(200);
      expect(second.body).toMatchObject({
        sent: { EXPIRING_7: 0, EXPIRING_3: 0, EXPIRING_1: 0, EXPIRED_MEMBER: 0 },
        skipped: 4,
        adminSummary: false,
      });
      expect(await t.prisma.notification.count({ where: { type: 'EXPIRING_7' } })).toBe(1);
      expect(await stored(adminId, 'ADMIN_DAILY_SUMMARY')).toHaveLength(1);
    });

    it('[R-26] after a renewal, the new endDate gets its own reminders', async () => {
      await runDaily().expect(200);
      // in7 renews: endDate moves one month; a week before the new endDate the reminder is new.
      await http()
        .post(`/api/v1/admin/members/${in7.created.id}/payments`)
        .set(...bearer(admin.accessToken))
        .send({ tier: 'BASIC', months: 1, amount: 150, method: 'CASH' })
        .expect(201);
      const renewed = await t.prisma.membership.findUniqueOrThrow({
        where: { memberId: in7.created.id },
      });
      expect(renewed.endDate.toISOString().slice(0, 10)).toBe('2026-12-25');
      t.clock!.set('2026-12-19T12:00:00.000Z'); // 7 days left of the new period
      await t.prisma.membership.updateMany({
        where: { memberId: { not: in7.created.id } },
        data: { endDate: addDays(TODAY, 100) },
      });
      const res = await runDaily().expect(200);
      expect(res.body).toMatchObject({ sent: { EXPIRING_7: 1 }, skipped: 0 });
      expect(await stored(in7.created.id, 'EXPIRING_7')).toHaveLength(2);
    });

    it('[R-24] deactivated members get nothing; nothing to report → no summary', async () => {
      await t.prisma.user.updateMany({
        where: {
          id: {
            in: [in7, in3, lastDay, expiredYesterday].map((m) => m.created.id),
          },
        },
        data: { isActive: false },
      });
      const res = await runDaily().expect(200);
      expect(res.body).toMatchObject({ adminSummary: false, skipped: 0 });
      expect(await t.prisma.notification.count()).toBe(0);
    });

    it('jobs: ADMIN only; unknown job → 404; nightly job is a no-op until D12', async () => {
      await runDaily(in7.session).expect(403);
      await http()
        .post('/api/v1/admin/jobs/nope/run')
        .set(...bearer(admin.accessToken))
        .expect(404);
      const nightly = await http()
        .post('/api/v1/admin/jobs/nightly-sessions/run')
        .set(...bearer(admin.accessToken))
        .expect(200);
      expect(nightly.body).toEqual({ finished: 0, deleted: 0 });
    });
  });
});
