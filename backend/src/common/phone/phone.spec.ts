import { isNormalizedPhone, normalizePhone } from './phone';

describe('[R-40] normalizePhone', () => {
  it('[R-40] adds the default country code +591 to a local number', () => {
    expect(normalizePhone('71234567')).toBe('+59171234567');
  });

  it.each(['7123 4567', '7123-4567', ' 71 23 45 67 ', '(7) 123.4567', '7123/4567'])(
    '[R-40] strips spaces, dashes and other separators: %p',
    (input) => {
      expect(normalizePhone(input)).toBe('+59171234567');
    },
  );

  it.each(['+59171234567', '+591 7123 4567', '+591-7123-4567', '+591 (7) 123-4567'])(
    '[R-40] keeps an already prefixed number: %p',
    (input) => {
      expect(normalizePhone(input)).toBe('+59171234567');
    },
  );

  it('[R-40] converts the international 00 prefix to +', () => {
    expect(normalizePhone('0059171234567')).toBe('+59171234567');
    expect(normalizePhone('00 54 9 11 1234 5678')).toBe('+5491112345678');
  });

  it('[R-40] keeps other country codes when given with +', () => {
    expect(normalizePhone('+54 9 11 1234-5678')).toBe('+5491112345678');
  });

  it('[R-40] uses a configurable default country code', () => {
    expect(normalizePhone('912345678', '+56')).toBe('+56912345678');
    expect(normalizePhone('912345678', '56')).toBe('+56912345678');
  });

  it.each(['', '   ', 'abc', '7123abcd', '+', '+12', '123', '+0123456789', '+1234567890123456'])(
    '[R-40] rejects invalid input: %p',
    (input) => {
      expect(normalizePhone(input)).toBeNull();
    },
  );

  it('[R-40] is idempotent', () => {
    const once = normalizePhone('7123-4567')!;
    expect(normalizePhone(once)).toBe(once);
  });

  it('[R-40] isNormalizedPhone accepts only the stored format', () => {
    expect(isNormalizedPhone('+59171234567')).toBe(true);
    expect(isNormalizedPhone('71234567')).toBe(false);
    expect(isNormalizedPhone('+591 7123 4567')).toBe(false);
  });
});
