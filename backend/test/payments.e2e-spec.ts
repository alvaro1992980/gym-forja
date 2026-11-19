import { Role, Tier } from '@prisma/client';
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

/** Noon in La Paz on a local date. */
const at = (date: string) => `${date}T16:00:00Z`;
const TODAY = '2026-11-19';

describe('Payments, renewals and tier changes (e2e)', () => {
  let t: TestApp;
  let admin: Session;
  const http = () => request(t.app.getHttpServer());
  const auth = () => bearer(admin.accessToken);

  /** A BASIC member created today for 1 month: 2026-11-19 .. 2026-12-18. */
  const newBasic = (body: Record<string, unknown> = {}) =>
    createMemberViaApi(t.app, admin.accessToken, body);

  const detail = async (id: string) =>
    (
      await http()
        .get(`/api/v1/admin/members/${id}`)
        .set(...auth())
        .expect(200)
    ).body as {
      membership: Record<string, unknown>;
      payments: Record<string, unknown>[];
      trainer: unknown;
    };

  const renew = (id: string, body: Record<string, unknown>, status = 201) =>
    http()
      .post(`/api/v1/admin/members/${id}/payments`)
      .set(...auth())
      .send({ method: 'CASH', ...body })
      .expect(status);

  beforeAll(async () => {
    t = await createTestApp({ now: at(TODAY) });
    await resetDatabase(t.prisma);
    await seedTestBase(t.prisma);
    admin = (await createAndLogin(t.app, t.prisma, Role.ADMIN)).session;
  });

  beforeEach(() => t.clock!.set(at(TODAY)));

  afterAll(async () => {
    await t.app.close();
  });

  describe('[R-01] / [R-02] / [R-03] through the API', () => {
    it('[R-02] daysLeft is 1 on the last day; [R-01] still active', async () => {
      const m = await newBasic();
      t.clock!.set(at('2026-12-18'));
      expect((await detail(m.id)).membership).toMatchObject({ daysLeft: 1, status: 'active' });
    });

    it('[R-03] expired the day after endDate with daysLeft 0', async () => {
      const m = await newBasic();
      t.clock!.set(at('2026-12-19'));
      expect((await detail(m.id)).membership).toMatchObject({ daysLeft: 0, status: 'expired' });
    });

    it('[R-03] uses the gym-local date: 23:30 in La Paz on the last day is not expired', async () => {
      const m = await newBasic();
      t.clock!.set('2026-12-19T03:30:00Z'); // 2026-12-18 23:30 in La Paz
      expect((await detail(m.id)).membership).toMatchObject({ daysLeft: 1, status: 'active' });
    });
  });

  describe('renewals', () => {
    it('[R-07] renewal while active starts on endDate + 1 (preview, then create)', async () => {
      const m = await newBasic();
      t.clock!.set(at('2026-12-10'));
      const preview = await http()
        .get(`/api/v1/admin/members/${m.id}/payments/preview?tier=BASIC&months=1`)
        .set(...auth())
        .expect(200);
      expect(preview.body).toEqual({
        periodStart: '2026-12-19',
        periodEnd: '2027-01-18',
        suggestedAmount: '150.00',
        currency: 'BOB',
        tierApplies: 'unchanged',
      });
      const res = await renew(m.id, { tier: 'BASIC', months: 1, amount: 150 });
      expect(res.body.payment).toMatchObject({
        kind: 'RENEWAL',
        periodStart: '2026-12-19',
        periodEnd: '2027-01-18',
      });
      expect(res.body.membership).toMatchObject({
        startDate: '2026-11-19', // continuous period unchanged
        endDate: '2027-01-18',
        daysLeft: 40,
      });
    });

    it('[R-08] renewal while expired starts today and opens a new period', async () => {
      const m = await newBasic();
      t.clock!.set(at('2026-12-25'));
      const res = await renew(m.id, { tier: 'BASIC', months: 2, amount: 300 });
      expect(res.body.membership).toMatchObject({
        startDate: '2026-12-25',
        endDate: '2027-02-24',
        status: 'active',
      });
    });

    it('[R-10] a renewal with a different amount needs a note', async () => {
      const m = await newBasic();
      const res = await renew(m.id, { tier: 'BASIC', months: 1, amount: 100 }, 400);
      expect(res.body.code).toBe('AMOUNT_NOTE_REQUIRED');
      const ok = await renew(m.id, { tier: 'BASIC', months: 1, amount: 100, note: 'Descuento' });
      expect(ok.body.payment).toMatchObject({ amount: '100.00', suggestedAmount: '150.00' });
    });

    it('[R-06] stores who recorded the payment and when', async () => {
      const m = await newBasic();
      t.clock!.set('2026-11-20T21:15:00Z');
      const res = await renew(m.id, { tier: 'BASIC', months: 1, amount: 150, method: 'QR' });
      const p = await t.prisma.payment.findUniqueOrThrow({ where: { id: res.body.payment.id } });
      expect(p.recordedById).toBeTruthy();
      expect(p.paidAt.toISOString()).toBe('2026-11-20T21:15:00.000Z');
      expect(p.method).toBe('QR');
      expect(p.currency).toBe('BOB');
    });
  });

  describe('[R-09] tier of a renewal', () => {
    it('[R-09] active membership: the new tier is scheduled for the new period, then applied', async () => {
      const m = await newBasic();
      const preview = await http()
        .get(`/api/v1/admin/members/${m.id}/payments/preview?tier=PLUS&months=1`)
        .set(...auth())
        .expect(200);
      expect(preview.body.tierApplies).toBe('scheduled');

      const res = await renew(m.id, { tier: 'PLUS', months: 1, amount: 250 });
      expect(res.body.membership).toMatchObject({
        tier: 'BASIC',
        nextTier: 'PLUS',
        nextTierStartDate: '2026-12-19',
      });

      t.clock!.set(at('2026-12-18'));
      expect((await detail(m.id)).membership).toMatchObject({ tier: 'BASIC', nextTier: 'PLUS' });

      t.clock!.set(at('2026-12-19'));
      expect((await detail(m.id)).membership).toMatchObject({
        tier: 'PLUS',
        nextTier: null,
        nextTierStartDate: null,
      });
      const changes = await t.prisma.tierChange.findMany({
        where: { membership: { memberId: m.id } },
      });
      expect(changes).toHaveLength(1);
      expect(changes[0]).toMatchObject({ fromTier: 'BASIC', toTier: 'PLUS' });
    });

    it('[R-09] the scheduled tier is applied in the member list too', async () => {
      const m = await newBasic({ firstName: 'Programado' });
      await renew(m.id, { tier: 'PREMIUM', months: 1, amount: 400 });
      t.clock!.set(at('2026-12-20'));
      const res = await http()
        .get('/api/v1/admin/members?q=Programado&tier=PREMIUM')
        .set(...auth())
        .expect(200);
      expect(res.body.total).toBe(1);
    });

    it('[R-09] "apply tier now" changes the tier from today', async () => {
      const m = await newBasic();
      const res = await renew(m.id, { tier: 'PLUS', months: 1, amount: 250, applyTierNow: true });
      expect(res.body.membership).toMatchObject({
        tier: 'PLUS',
        nextTier: null,
        endDate: '2027-01-18',
      });
    });

    it('[R-09] expired membership: the new tier applies immediately', async () => {
      const m = await newBasic();
      t.clock!.set(at('2027-01-05'));
      const res = await renew(m.id, { tier: 'PREMIUM', months: 1, amount: 400 });
      expect(res.body.membership).toMatchObject({
        tier: 'PREMIUM',
        nextTier: null,
        startDate: '2027-01-05',
      });
    });
  });

  describe('[R-11] tier prices', () => {
    it('[R-11] changing a price affects new suggestions but never past payments', async () => {
      const m = await newBasic();
      await http()
        .put('/api/v1/admin/pricing')
        .set(...auth())
        .send({ prices: [{ tier: 'BASIC', monthlyPrice: 180 }] })
        .expect(200);
      try {
        const d = await detail(m.id);
        expect(d.payments[0]).toMatchObject({ amount: '150.00', suggestedAmount: '150.00' });
        const preview = await http()
          .get(`/api/v1/admin/members/${m.id}/payments/preview?tier=BASIC&months=2`)
          .set(...auth())
          .expect(200);
        expect(preview.body.suggestedAmount).toBe('360.00');
      } finally {
        await http()
          .put('/api/v1/admin/pricing')
          .set(...auth())
          .send({ prices: [{ tier: 'BASIC', monthlyPrice: 150 }] })
          .expect(200);
      }
    });
  });

  describe('[R-12] void', () => {
    let m: CreatedMember;

    beforeEach(async () => {
      m = await newBasic(); // 11-19 .. 12-18
    });

    it('[R-12] voiding the last renewal restores the previous endDate', async () => {
      t.clock!.set(at('2026-12-01'));
      const r = await renew(m.id, { tier: 'BASIC', months: 1, amount: 150 });
      expect(r.body.membership.endDate).toBe('2027-01-18');

      const res = await http()
        .post(`/api/v1/admin/payments/${r.body.payment.id}/void`)
        .set(...auth())
        .send({ reason: 'Registrado dos veces' })
        .expect(200);
      expect(res.body.payment).toMatchObject({
        voidReason: 'Registrado dos veces',
        voidedById: expect.any(String),
      });
      expect(res.body.payment.voidedAt).not.toBeNull();
      expect(res.body.membership).toMatchObject({ startDate: '2026-11-19', endDate: '2026-12-18' });
    });

    it('[R-12] voiding a middle renewal recalculates later periods', async () => {
      t.clock!.set(at('2026-12-01'));
      const r1 = await renew(m.id, { tier: 'BASIC', months: 1, amount: 150 }); // 12-19..01-18
      const r2 = await renew(m.id, { tier: 'BASIC', months: 1, amount: 150 }); // 01-19..02-18
      expect(r2.body.membership.endDate).toBe('2027-02-18');
      const res = await http()
        .post(`/api/v1/admin/payments/${r1.body.payment.id}/void`)
        .set(...auth())
        .send({ reason: 'Error' })
        .expect(200);
      expect(res.body.membership.endDate).toBe('2027-01-18');
      const p2 = await t.prisma.payment.findUniqueOrThrow({ where: { id: r2.body.payment.id } });
      expect(p2.periodStart?.toISOString().slice(0, 10)).toBe('2026-12-19');
      expect(p2.periodEnd?.toISOString().slice(0, 10)).toBe('2027-01-18');
    });

    it('[R-12] voiding the only payment leaves the membership expired with 0 days', async () => {
      const res = await http()
        .post(`/api/v1/admin/payments/${m.payments[0].id}/void`)
        .set(...auth())
        .send({ reason: 'Socio de prueba' })
        .expect(200);
      expect(res.body.membership).toMatchObject({
        endDate: '2026-11-18',
        daysLeft: 0,
        status: 'expired',
      });
    });

    it('[R-12] voiding a renewal that scheduled a tier change cancels it', async () => {
      const r = await renew(m.id, { tier: 'PLUS', months: 1, amount: 250 });
      expect(r.body.membership.nextTier).toBe('PLUS');
      const res = await http()
        .post(`/api/v1/admin/payments/${r.body.payment.id}/void`)
        .set(...auth())
        .send({ reason: 'Error' })
        .expect(200);
      expect(res.body.membership).toMatchObject({ tier: 'BASIC', nextTier: null });
    });

    it('[R-12] a reason is required and a payment cannot be voided twice', async () => {
      const id = m.payments[0].id;
      const noReason = await http()
        .post(`/api/v1/admin/payments/${id}/void`)
        .set(...auth())
        .send({ reason: '  ' })
        .expect(400);
      expect(noReason.body.code).toBe('VALIDATION_ERROR');
      await http()
        .post(`/api/v1/admin/payments/${id}/void`)
        .set(...auth())
        .send({ reason: 'x' })
        .expect(200);
      const twice = await http()
        .post(`/api/v1/admin/payments/${id}/void`)
        .set(...auth())
        .send({ reason: 'x' })
        .expect(409);
      expect(twice.body.code).toBe('PAYMENT_ALREADY_VOIDED');
    });

    it('[R-12] payments cannot be deleted', async () => {
      const id = m.payments[0].id;
      await http()
        .delete(`/api/v1/admin/payments/${id}`)
        .set(...auth())
        .expect(404);
      expect(await t.prisma.payment.count({ where: { id } })).toBe(1);
    });
  });

  describe('tier changes', () => {
    it('[R-13] upgrade preview suggests round((new − old) / 30 × daysLeft)', async () => {
      const m = await newBasic();
      t.clock!.set(at('2026-12-07')); // 12 days left
      const res = await http()
        .post(`/api/v1/admin/members/${m.id}/tier-change/preview`)
        .set(...auth())
        .send({ toTier: 'PLUS' })
        .expect(200);
      expect(res.body).toEqual({
        fromTier: 'BASIC',
        toTier: 'PLUS',
        isUpgrade: true,
        daysLeft: 12,
        suggestedAmount: '40.00', // (250 − 150) / 30 × 12
        currency: 'BOB',
        warning: null,
      });
    });

    it('[R-13] upgrade applies immediately and records an UPGRADE payment with months 0', async () => {
      const m = await newBasic();
      t.clock!.set(at('2026-12-07'));
      const res = await http()
        .post(`/api/v1/admin/members/${m.id}/tier-change`)
        .set(...auth())
        .send({ toTier: 'PLUS', amount: 40, method: 'CASH' })
        .expect(200);
      expect(res.body.membership).toMatchObject({ tier: 'PLUS', endDate: '2026-12-18' });
      expect(res.body.payment).toMatchObject({
        kind: 'UPGRADE',
        months: 0,
        tier: 'PLUS',
        amount: '40.00',
        suggestedAmount: '40.00',
        periodStart: null,
        periodEnd: null,
      });
      const changes = await t.prisma.tierChange.count({
        where: { membership: { memberId: m.id } },
      });
      expect(changes).toBe(1);
    });

    it('[R-13] waiving the charge (amount 0) needs a note and is recorded', async () => {
      const m = await newBasic();
      const noNote = await http()
        .post(`/api/v1/admin/members/${m.id}/tier-change`)
        .set(...auth())
        .send({ toTier: 'PLUS', amount: 0 })
        .expect(400);
      expect(noNote.body.code).toBe('AMOUNT_NOTE_REQUIRED');
      const res = await http()
        .post(`/api/v1/admin/members/${m.id}/tier-change`)
        .set(...auth())
        .send({ toTier: 'PLUS', amount: 0, note: 'Cortesía' })
        .expect(200);
      expect(res.body.payment).toMatchObject({ amount: '0.00', note: 'Cortesía', method: 'OTHER' });
    });

    it('[R-13] a charged upgrade needs a payment method', async () => {
      const m = await newBasic();
      const res = await http()
        .post(`/api/v1/admin/members/${m.id}/tier-change`)
        .set(...auth())
        .send({ toTier: 'PLUS', amount: 100 })
        .expect(400);
      expect(res.body.code).toBe('PAYMENT_METHOD_REQUIRED');
    });

    it('[R-14] downgrade preview has no charge and warns about no refund', async () => {
      const m = await newBasic({ tier: 'PREMIUM', amount: 400 });
      const res = await http()
        .post(`/api/v1/admin/members/${m.id}/tier-change/preview`)
        .set(...auth())
        .send({ toTier: 'BASIC' })
        .expect(200);
      expect(res.body).toMatchObject({ isUpgrade: false, suggestedAmount: '0.00' });
      expect(res.body.warning).toMatch(/reembolso/);
    });

    it('[R-14] downgrade applies immediately, with no payment and no refund', async () => {
      const m = await newBasic({ tier: 'PLUS', amount: 250 });
      const charged = await http()
        .post(`/api/v1/admin/members/${m.id}/tier-change`)
        .set(...auth())
        .send({ toTier: 'BASIC', amount: 10 })
        .expect(400);
      expect(charged.body.code).toBe('DOWNGRADE_HAS_NO_CHARGE');
      const res = await http()
        .post(`/api/v1/admin/members/${m.id}/tier-change`)
        .set(...auth())
        .send({ toTier: 'BASIC' })
        .expect(200);
      expect(res.body.membership).toMatchObject({ tier: 'BASIC', endDate: '2026-12-18' });
      expect(res.body.payment).toBeNull();
      expect(await t.prisma.payment.count({ where: { membership: { memberId: m.id } } })).toBe(1);
    });

    it('[R-15] downgrading keeps all history; upgrading again shows the same records', async () => {
      const m = await newBasic({ tier: 'PLUS', amount: 250 });
      await t.prisma.checkin.create({
        data: { memberId: m.id, tier: Tier.PLUS, daysLeft: 30, kioskId: 'kiosk' },
      });
      const countAll = async () => ({
        payments: await t.prisma.payment.count({ where: { membership: { memberId: m.id } } }),
        checkins: await t.prisma.checkin.count({ where: { memberId: m.id } }),
      });
      const before = await countAll();
      await http()
        .post(`/api/v1/admin/members/${m.id}/tier-change`)
        .set(...auth())
        .send({ toTier: 'BASIC' })
        .expect(200);
      expect(await countAll()).toEqual(before);
      await http()
        .post(`/api/v1/admin/members/${m.id}/tier-change`)
        .set(...auth())
        .send({ toTier: 'PLUS', amount: 0, note: 'Vuelve' })
        .expect(200);
      const after = await countAll();
      expect(after.checkins).toBe(before.checkins);
      expect(after.payments).toBe(before.payments + 1); // only the new UPGRADE record
      expect((await detail(m.id)).membership.tier).toBe('PLUS');
    });

    it('[R-16] downgrading from PREMIUM unassigns the trainer (the trainer account is kept)', async () => {
      const m = await newBasic({ tier: 'PREMIUM', amount: 400 });
      const trainer = await createAndLogin(t.app, t.prisma, Role.TRAINER);
      await t.prisma.membership.update({
        where: { memberId: m.id },
        data: { trainerId: trainer.user.id },
      });
      expect((await detail(m.id)).trainer).toMatchObject({ id: trainer.user.id });
      await http()
        .post(`/api/v1/admin/members/${m.id}/tier-change`)
        .set(...auth())
        .send({ toTier: 'PLUS' })
        .expect(200);
      expect((await detail(m.id)).trainer).toBeNull();
      expect(await t.prisma.user.count({ where: { id: trainer.user.id } })).toBe(1);
    });

    it('[R-16] a scheduled downgrade from PREMIUM also unassigns the trainer when it applies', async () => {
      const m = await newBasic({ tier: 'PREMIUM', amount: 400 });
      const trainer = await createAndLogin(t.app, t.prisma, Role.TRAINER);
      await t.prisma.membership.update({
        where: { memberId: m.id },
        data: { trainerId: trainer.user.id },
      });
      await renew(m.id, { tier: 'BASIC', months: 1, amount: 150 });
      expect((await detail(m.id)).trainer).not.toBeNull();
      t.clock!.set(at('2026-12-19'));
      const d = await detail(m.id);
      expect(d.membership.tier).toBe('BASIC');
      expect(d.trainer).toBeNull();
    });

    it('rejects the same tier and an expired membership', async () => {
      const m = await newBasic();
      const same = await http()
        .post(`/api/v1/admin/members/${m.id}/tier-change/preview`)
        .set(...auth())
        .send({ toTier: 'BASIC' })
        .expect(400);
      expect(same.body.code).toBe('TIER_UNCHANGED');
      t.clock!.set(at('2026-12-19'));
      const expired = await http()
        .post(`/api/v1/admin/members/${m.id}/tier-change`)
        .set(...auth())
        .send({ toTier: 'PLUS', amount: 0, note: 'x' })
        .expect(409);
      expect(expired.body).toMatchObject({
        code: 'MEMBERSHIP_EXPIRED',
        details: { endDate: '2026-12-18' },
      });
    });
  });

  describe('GET /admin/payments', () => {
    it('filters by date/method/member and totals only non-voided payments', async () => {
      const m = await newBasic({ method: 'TRANSFER' }); // 150 TRANSFER on 11-19
      t.clock!.set(at('2026-11-21'));
      const r = await renew(m.id, { tier: 'BASIC', months: 1, amount: 150, method: 'CARD' });
      await renew(m.id, { tier: 'PLUS', months: 1, amount: 250, method: 'CARD' });
      await http()
        .post(`/api/v1/admin/payments/${r.body.payment.id}/void`)
        .set(...auth())
        .send({ reason: 'x' })
        .expect(200);

      const all = await http()
        .get(`/api/v1/admin/payments?memberId=${m.id}`)
        .set(...auth())
        .expect(200);
      expect(all.body.total).toBe(3);
      expect(all.body.totals).toEqual({ count: 2, amount: '400.00', currency: 'BOB' });

      const nonVoided = await http()
        .get(`/api/v1/admin/payments?memberId=${m.id}&includeVoided=false`)
        .set(...auth())
        .expect(200);
      expect(nonVoided.body.total).toBe(2);

      const byDate = await http()
        .get(`/api/v1/admin/payments?memberId=${m.id}&from=2026-11-21&to=2026-11-21`)
        .set(...auth())
        .expect(200);
      expect(byDate.body.total).toBe(2);
      expect(byDate.body.totals.amount).toBe('250.00');

      const byMethod = await http()
        .get(`/api/v1/admin/payments?memberId=${m.id}&method=TRANSFER`)
        .set(...auth())
        .expect(200);
      expect(byMethod.body.totals).toMatchObject({ count: 1, amount: '150.00' });
    });
  });

  describe('member endpoints', () => {
    it('GET /me/membership and /me/payments (no notes, no voided)', async () => {
      const m = await newBasic({ amount: 120, note: 'Nota interna' });
      const session = await activateMember(t.app, m);
      const r = await renew(m.id, { tier: 'BASIC', months: 1, amount: 150 });
      await http()
        .post(`/api/v1/admin/payments/${r.body.payment.id}/void`)
        .set(...auth())
        .send({ reason: 'x' })
        .expect(200);

      const mem = await http()
        .get('/api/v1/me/membership')
        .set(...bearer(session.accessToken))
        .expect(200);
      expect(mem.body).toMatchObject({
        tier: 'BASIC',
        startDate: '2026-11-19',
        endDate: '2026-12-18',
        daysLeft: 30,
        status: 'active',
        trainer: null,
      });

      const pays = await http()
        .get('/api/v1/me/payments')
        .set(...bearer(session.accessToken))
        .expect(200);
      expect(pays.body.total).toBe(1);
      expect(pays.body.items[0]).toMatchObject({ kind: 'NEW', amount: '120.00' });
      expect(pays.body.items[0]).not.toHaveProperty('note');
      expect(pays.body.items[0]).not.toHaveProperty('suggestedAmount');
    });

    it('staff get 403 on /me/membership', async () => {
      await http()
        .get('/api/v1/me/membership')
        .set(...auth())
        .expect(403);
    });
  });
});
