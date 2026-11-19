import { PaymentKind, Tier } from '@prisma/client';
import { formatLocalDate, parseLocalDate } from '../../common/date/gym-date';
import {
  Decimal,
  DOWNGRADE_WARNING,
  formatMoney,
  hasNote,
  isDowngrade,
  isNoteRequired,
  isUpgrade,
  nextPeriodStart,
  previewTierChange,
  proratedUpgradeCharge,
  renewalPeriod,
  renewalTierTiming,
  replayPayments,
  ReplayPayment,
  suggestedAmount,
} from './membership-rules';

const d = parseLocalDate;
const fmt = formatLocalDate;
const TZ = 'America/La_Paz';
const PRICES: Record<Tier, string> = { BASIC: '150.00', PLUS: '250.00', PREMIUM: '400.00' };

/** Noon in La Paz on a local date → a paidAt instant whose local date is `date`. */
const noon = (date: string) => new Date(`${date}T16:00:00Z`);

let seq = 0;
function pay(
  kind: PaymentKind,
  months: number,
  paidOn: string,
  extra: Partial<ReplayPayment> = {},
): ReplayPayment {
  seq += 1;
  return {
    id: `p${String(seq).padStart(3, '0')}`,
    kind,
    months,
    paidAt: noon(paidOn),
    periodStart: null,
    voidedAt: null,
    ...extra,
  };
}

describe('membership rules', () => {
  describe('[R-07] / [R-08] renewal start', () => {
    it('[R-07] renewal while active starts on endDate + 1 (no paid day is lost)', () => {
      expect(fmt(nextPeriodStart(d('2026-12-14'), d('2026-12-01')))).toBe('2026-12-15');
    });

    it('[R-07] renewal on the last day (still active) starts the next day', () => {
      expect(fmt(nextPeriodStart(d('2026-12-14'), d('2026-12-14')))).toBe('2026-12-15');
    });

    it('[R-08] renewal while expired starts today', () => {
      expect(fmt(nextPeriodStart(d('2026-12-14'), d('2026-12-15')))).toBe('2026-12-15');
      expect(fmt(nextPeriodStart(d('2026-12-14'), d('2027-02-03')))).toBe('2027-02-03');
    });

    it('[R-08] with no previous period it starts today', () => {
      expect(fmt(nextPeriodStart(null, d('2026-11-19')))).toBe('2026-11-19');
    });

    it('[R-07] the renewed period is N calendar months [R-04]', () => {
      const p = renewalPeriod(d('2026-12-14'), d('2026-12-01'), 1);
      expect([fmt(p.start), fmt(p.end)]).toEqual(['2026-12-15', '2027-01-14']);
    });

    it('[R-08] a late renewal does not backfill the missed days', () => {
      const p = renewalPeriod(d('2026-12-14'), d('2026-12-20'), 3);
      expect([fmt(p.start), fmt(p.end)]).toEqual(['2026-12-20', '2027-03-19']);
    });
  });

  describe('[R-10] amounts', () => {
    it('[R-10] suggested amount = monthly price × months', () => {
      expect(formatMoney(suggestedAmount('150.00', 1))).toBe('150.00');
      expect(formatMoney(suggestedAmount('250.00', 3))).toBe('750.00');
      expect(formatMoney(suggestedAmount('133.33', 12))).toBe('1599.96');
    });

    it('[R-10] no note needed when the amount equals the suggestion (any format)', () => {
      expect(isNoteRequired('750', '750.00')).toBe(false);
      expect(isNoteRequired(new Decimal('750.004'), '750.00')).toBe(false);
    });

    it('[R-10] a discount or surcharge requires a note', () => {
      expect(isNoteRequired('700.00', '750.00')).toBe(true);
      expect(isNoteRequired('800.00', '750.00')).toBe(true);
      expect(isNoteRequired('0', '750.00')).toBe(true);
    });

    it('[R-10] a blank note does not count', () => {
      expect(hasNote('Descuento estudiante')).toBe(true);
      expect(hasNote('   ')).toBe(false);
      expect(hasNote(undefined)).toBe(false);
      expect(hasNote(null)).toBe(false);
    });

    it('[R-10] money never uses floats', () => {
      expect(formatMoney(suggestedAmount('0.10', 3))).toBe('0.30'); // 0.1 * 3 = 0.30000000000000004 in floats
    });
  });

  describe('[R-09] tier of a renewal', () => {
    const base = { currentTier: Tier.BASIC, newTier: Tier.PLUS };

    it('[R-09] an expired membership changes tier immediately', () => {
      expect(renewalTierTiming({ ...base, wasExpired: true, applyTierNow: false })).toBe('now');
    });

    it('[R-09] an active membership changes tier at the start of the new period', () => {
      expect(renewalTierTiming({ ...base, wasExpired: false, applyTierNow: false })).toBe(
        'scheduled',
      );
    });

    it('[R-09] "apply tier now" changes it from today', () => {
      expect(renewalTierTiming({ ...base, wasExpired: false, applyTierNow: true })).toBe('now');
    });

    it('[R-09] same tier → nothing to change', () => {
      expect(
        renewalTierTiming({
          currentTier: Tier.PLUS,
          newTier: Tier.PLUS,
          wasExpired: true,
          applyTierNow: true,
        }),
      ).toBe('unchanged');
    });
  });

  describe('[R-13] / [R-14] tier changes', () => {
    it('ranks tiers BASIC < PLUS < PREMIUM', () => {
      expect(isUpgrade(Tier.BASIC, Tier.PLUS)).toBe(true);
      expect(isUpgrade(Tier.PLUS, Tier.PREMIUM)).toBe(true);
      expect(isDowngrade(Tier.PREMIUM, Tier.BASIC)).toBe(true);
      expect(isUpgrade(Tier.PLUS, Tier.PLUS)).toBe(false);
      expect(isDowngrade(Tier.PLUS, Tier.PLUS)).toBe(false);
    });

    it('[R-13] prorated charge = round((new − old) / 30 × daysLeft)', () => {
      // (250 − 150) / 30 × 12 = 40
      expect(formatMoney(proratedUpgradeCharge('150', '250', 12))).toBe('40.00');
      // (400 − 150) / 30 × 7 = 58.33 → 58
      expect(formatMoney(proratedUpgradeCharge('150', '400', 7))).toBe('58.00');
      // (400 − 250) / 30 × 1 = 5
      expect(formatMoney(proratedUpgradeCharge('250', '400', 1))).toBe('5.00');
      // (250 − 150) / 30 × 5 = 16.67 → 17 (half up)
      expect(formatMoney(proratedUpgradeCharge('150', '250', 5))).toBe('17.00');
      // (400 − 150) / 30 × 3 = 25
      expect(formatMoney(proratedUpgradeCharge('150', '400', 3))).toBe('25.00');
    });

    it('[R-13] rounds .5 up', () => {
      // (165 − 150) / 30 × 1 = 0.5 → 1
      expect(formatMoney(proratedUpgradeCharge('150', '165', 1))).toBe('1.00');
    });

    it('[R-13] is never negative and is 0 without days left', () => {
      expect(formatMoney(proratedUpgradeCharge('250', '150', 10))).toBe('0.00');
      expect(formatMoney(proratedUpgradeCharge('150', '250', 0))).toBe('0.00');
    });

    it('[R-13] upgrade preview suggests the prorated charge, no warning', () => {
      const p = previewTierChange({
        fromTier: Tier.BASIC,
        toTier: Tier.PLUS,
        prices: PRICES,
        daysLeft: 12,
      });
      expect(p.isUpgrade).toBe(true);
      expect(formatMoney(p.suggestedAmount)).toBe('40.00');
      expect(p.warning).toBeNull();
    });

    it('[R-14] downgrade preview: no charge and a no-refund warning', () => {
      const p = previewTierChange({
        fromTier: Tier.PREMIUM,
        toTier: Tier.BASIC,
        prices: PRICES,
        daysLeft: 20,
      });
      expect(p.isUpgrade).toBe(false);
      expect(formatMoney(p.suggestedAmount)).toBe('0.00');
      expect(p.warning).toBe(DOWNGRADE_WARNING);
      expect(p.warning).toMatch(/reembolso/);
    });
  });

  describe('[R-12] recalculation (replay of non-voided payments)', () => {
    const periodsOf = (r: ReturnType<typeof replayPayments>) =>
      Object.fromEntries(
        [...r.periods.entries()].map(([id, p]) => [id, `${fmt(p.start)}..${fmt(p.end)}`]),
      );

    it('[R-12] scenario: on-time renewal continues the period', () => {
      const n = pay('NEW', 1, '2026-01-15', { periodStart: d('2026-01-15') });
      const r1 = pay('RENEWAL', 1, '2026-02-14'); // paid on the last day
      const r = replayPayments([n, r1], TZ);
      expect(periodsOf(r)).toEqual({
        [n.id]: '2026-01-15..2026-02-14',
        [r1.id]: '2026-02-15..2026-03-14',
      });
      expect(fmt(r.startDate!)).toBe('2026-01-15');
      expect(fmt(r.endDate!)).toBe('2026-03-14');
    });

    it('[R-12] scenario: early renewal starts after the current end [R-07]', () => {
      const n = pay('NEW', 1, '2026-01-15', { periodStart: d('2026-01-15') });
      const r1 = pay('RENEWAL', 3, '2026-01-20');
      const r = replayPayments([n, r1], TZ);
      expect(periodsOf(r)[r1.id]).toBe('2026-02-15..2026-05-14');
      expect(fmt(r.startDate!)).toBe('2026-01-15');
    });

    it('[R-12] scenario: late renewal starts on its payment day and opens a new continuous period [R-08]', () => {
      const n = pay('NEW', 1, '2026-01-15', { periodStart: d('2026-01-15') });
      const r1 = pay('RENEWAL', 1, '2026-02-20');
      const r = replayPayments([n, r1], TZ);
      expect(periodsOf(r)[r1.id]).toBe('2026-02-20..2026-03-19');
      expect(fmt(r.startDate!)).toBe('2026-02-20');
      expect(fmt(r.endDate!)).toBe('2026-03-19');
    });

    it('[R-12] scenario: voiding the last payment restores the previous endDate', () => {
      const n = pay('NEW', 1, '2026-01-15', { periodStart: d('2026-01-15') });
      const r1 = pay('RENEWAL', 1, '2026-02-10');
      const before = replayPayments([n, r1], TZ);
      expect(fmt(before.endDate!)).toBe('2026-03-14');
      const after = replayPayments([n, { ...r1, voidedAt: noon('2026-02-11') }], TZ);
      expect(fmt(after.endDate!)).toBe('2026-02-14');
      expect(after.periods.has(r1.id)).toBe(false);
    });

    it('[R-12] scenario: voiding a middle payment pulls the later periods back', () => {
      const n = pay('NEW', 1, '2026-01-15', { periodStart: d('2026-01-15') });
      const r1 = pay('RENEWAL', 1, '2026-02-01'); // 02-15..03-14
      const r2 = pay('RENEWAL', 1, '2026-02-05'); // 03-15..04-14
      expect(fmt(replayPayments([n, r1, r2], TZ).endDate!)).toBe('2026-04-14');
      const r = replayPayments([n, { ...r1, voidedAt: noon('2026-02-06') }, r2], TZ);
      expect(periodsOf(r)[r2.id]).toBe('2026-02-15..2026-03-14');
      expect(fmt(r.endDate!)).toBe('2026-03-14');
    });

    it('[R-12] scenario: voiding a middle payment can turn a renewal into a late one', () => {
      const n = pay('NEW', 1, '2026-01-15', { periodStart: d('2026-01-15') }); // ..02-14
      const r1 = pay('RENEWAL', 1, '2026-02-10'); // 02-15..03-14
      const r2 = pay('RENEWAL', 1, '2026-03-01'); // 03-15..04-14
      const r = replayPayments([n, { ...r1, voidedAt: noon('2026-03-02') }, r2], TZ);
      // Without r1 the membership had expired on 02-14, so r2 starts on its payment day.
      expect(periodsOf(r)[r2.id]).toBe('2026-03-01..2026-03-31');
      expect(fmt(r.startDate!)).toBe('2026-03-01');
    });

    it('[R-12] scenario: month-end dates chain without gaps [R-04]', () => {
      const n = pay('NEW', 1, '2026-01-31', { periodStart: d('2026-01-31') }); // ..02-27
      const r1 = pay('RENEWAL', 1, '2026-02-20'); // 02-28..03-27
      const r2 = pay('RENEWAL', 1, '2026-03-20'); // 03-28..04-27
      const r = replayPayments([n, r1, r2], TZ);
      expect(periodsOf(r)).toEqual({
        [n.id]: '2026-01-31..2026-02-27',
        [r1.id]: '2026-02-28..2026-03-27',
        [r2.id]: '2026-03-28..2026-04-27',
      });
    });

    it('[R-12] the NEW payment keeps the start date chosen by the admin [R-05]', () => {
      const n = pay('NEW', 1, '2026-01-10', { periodStart: d('2026-01-15') });
      const r = replayPayments([n], TZ);
      expect(periodsOf(r)[n.id]).toBe('2026-01-15..2026-02-14');
    });

    it('[R-12] ignores payments without months (UPGRADE / ADJUSTMENT)', () => {
      const n = pay('NEW', 1, '2026-01-15', { periodStart: d('2026-01-15') });
      const up = pay('UPGRADE', 0, '2026-01-20');
      const r = replayPayments([n, up], TZ);
      expect(r.periods.has(up.id)).toBe(false);
      expect(fmt(r.endDate!)).toBe('2026-02-14');
    });

    it('[R-12] uses the gym-local date of paidAt (late evening in La Paz)', () => {
      const n = pay('NEW', 1, '2026-01-15', { periodStart: d('2026-01-15') }); // ..02-14
      // 2026-02-14 23:30 in La Paz = 2026-02-15T03:30Z → still the last day, so on time.
      const r1 = pay('RENEWAL', 1, '2026-02-14', { paidAt: new Date('2026-02-15T03:30:00Z') });
      expect(periodsOf(replayPayments([n, r1], TZ))[r1.id]).toBe('2026-02-15..2026-03-14');
    });

    it('[R-12] with every period voided there are no dates left', () => {
      const n = pay('NEW', 1, '2026-01-15', {
        periodStart: d('2026-01-15'),
        voidedAt: noon('2026-01-16'),
      });
      const r = replayPayments([n], TZ);
      expect(r.endDate).toBeNull();
      expect(r.startDate).toBeNull();
    });

    it('[R-12] replays in paidAt order regardless of input order', () => {
      const n = pay('NEW', 1, '2026-01-15', { periodStart: d('2026-01-15') });
      const r1 = pay('RENEWAL', 1, '2026-02-01');
      const r2 = pay('RENEWAL', 1, '2026-02-02');
      const a = replayPayments([r2, n, r1], TZ);
      const b = replayPayments([n, r1, r2], TZ);
      expect(periodsOf(a)).toEqual(periodsOf(b));
    });
  });
});
