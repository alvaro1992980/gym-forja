import { plainToInstance } from 'class-transformer';
import { validateSync } from 'class-validator';
import { CreatePaymentDto, TierChangeDto, VoidPaymentDto } from './dto';

function errorsOf<T extends object>(cls: new () => T, body: Record<string, unknown>): string[] {
  const dto = plainToInstance(cls, body);
  return validateSync(dto, { whitelist: true, forbidNonWhitelisted: true }).map((e) => e.property);
}

const valid = { tier: 'PLUS', months: 3, amount: 750, method: 'CASH' };

describe('[R-06] payment input', () => {
  it('[R-06] accepts tier, months, amount, method and an optional note', () => {
    expect(errorsOf(CreatePaymentDto, valid)).toEqual([]);
    expect(errorsOf(CreatePaymentDto, { ...valid, note: 'Descuento' })).toEqual([]);
  });

  it.each([0, 13, 1.5, -1, 'x'])('[R-06] months must be an integer 1–12 (rejects %p)', (months) => {
    expect(errorsOf(CreatePaymentDto, { ...valid, months })).toContain('months');
  });

  it.each([1, 12])('[R-06] months %p is allowed', (months) => {
    expect(errorsOf(CreatePaymentDto, { ...valid, months })).toEqual([]);
  });

  it.each(['CASH', 'TRANSFER', 'QR', 'CARD', 'OTHER'])('[R-06] method %s is allowed', (method) => {
    expect(errorsOf(CreatePaymentDto, { ...valid, method })).toEqual([]);
  });

  it('[R-06] rejects an unknown method', () => {
    expect(errorsOf(CreatePaymentDto, { ...valid, method: 'BITCOIN' })).toContain('method');
  });

  it('[R-06] rejects an unknown tier', () => {
    expect(errorsOf(CreatePaymentDto, { ...valid, tier: 'GOLD' })).toContain('tier');
  });

  it.each([-1, 1.234, 'abc', 1_000_000])(
    '[R-06] amount must be ≥ 0 with 2 decimals (rejects %p)',
    (amount) => {
      expect(errorsOf(CreatePaymentDto, { ...valid, amount })).toContain('amount');
    },
  );

  it('[R-06] accepts amount 0 and 2 decimals', () => {
    expect(errorsOf(CreatePaymentDto, { ...valid, amount: 0 })).toEqual([]);
    expect(errorsOf(CreatePaymentDto, { ...valid, amount: 149.99 })).toEqual([]);
  });

  it('[R-06] currency and recordedBy are set by the server, not the client', () => {
    expect(errorsOf(CreatePaymentDto, { ...valid, currency: 'USD' })).toContain('currency');
    expect(errorsOf(CreatePaymentDto, { ...valid, recordedById: 'x' })).toContain('recordedById');
  });
});

describe('[R-12] void input', () => {
  it('[R-12] voiding requires a reason', () => {
    expect(errorsOf(VoidPaymentDto, {})).toContain('reason');
    expect(errorsOf(VoidPaymentDto, { reason: '   ' })).toContain('reason');
    expect(errorsOf(VoidPaymentDto, { reason: 'Monto equivocado' })).toEqual([]);
  });
});

describe('tier change input', () => {
  it('requires a valid target tier; amount and method are optional', () => {
    expect(errorsOf(TierChangeDto, { toTier: 'PREMIUM' })).toEqual([]);
    expect(errorsOf(TierChangeDto, { toTier: 'X' })).toContain('toTier');
    expect(errorsOf(TierChangeDto, { toTier: 'PLUS', amount: -5 })).toContain('amount');
  });
});
