/**
 * [R-40] Phone numbers are the login identifier, stored normalized as "+" followed by
 * the country code and the number, digits only (E.164 style), e.g. +59171234567.
 */

export const DEFAULT_COUNTRY_CODE = '+591';

/** "+" and 8–15 digits (E.164 allows at most 15). */
export const NORMALIZED_PHONE_RE = /^\+[1-9]\d{7,14}$/;

const SEPARATORS_RE = /[\s\-.()/]/g;

/**
 * Normalizes user input. Returns null when the input cannot be a phone number.
 *  - "71234567"          → "+59171234567"   (default country code added)
 *  - "7123 4567", "7123-4567", "(7) 123.4567" → "+59171234567"
 *  - "+591 7123-4567"    → "+59171234567"   (already prefixed)
 *  - "0059171234567"     → "+59171234567"   (international 00 prefix)
 */
export function normalizePhone(
  input: string,
  defaultCountryCode: string = DEFAULT_COUNTRY_CODE,
): string | null {
  if (typeof input !== 'string') return null;
  let value = input.trim().replace(SEPARATORS_RE, '');
  if (value.length === 0) return null;

  if (value.startsWith('00')) {
    value = `+${value.slice(2)}`;
  } else if (!value.startsWith('+')) {
    const cc = defaultCountryCode.replace(SEPARATORS_RE, '');
    value = `${cc.startsWith('+') ? cc : `+${cc}`}${value}`;
  }

  return NORMALIZED_PHONE_RE.test(value) ? value : null;
}

export function isNormalizedPhone(value: string): boolean {
  return NORMALIZED_PHONE_RE.test(value);
}
