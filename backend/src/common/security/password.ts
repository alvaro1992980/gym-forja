import * as argon2 from 'argon2';
import { randomInt } from 'node:crypto';

/** [R-42] Minimum password length. */
export const PASSWORD_MIN_LENGTH = 8;

/** [R-41] Length of generated temporary passwords. */
export const TEMP_PASSWORD_LENGTH = 8;

/**
 * [R-41] Characters for temporary passwords: no ambiguous characters
 * (0/O/o, 1/l/I), so the admin can read them aloud or the member can type them from a photo.
 */
const UPPER = 'ABCDEFGHJKLMNPQRSTUVWXYZ';
const LOWER = 'abcdefghijkmnpqrstuvwxyz';
const DIGITS = '23456789';
export const TEMP_PASSWORD_ALPHABET = UPPER + LOWER + DIGITS;

/** [R-42] argon2id hash. */
export function hashPassword(plain: string): Promise<string> {
  return argon2.hash(plain, { type: argon2.argon2id });
}

export async function verifyPassword(hash: string, plain: string): Promise<boolean> {
  try {
    return await argon2.verify(hash, plain);
  } catch {
    return false;
  }
}

/**
 * A hash of a random value, verified against when the user does not exist so that
 * login takes the same time for unknown phones (no user enumeration by timing).
 */
let dummyHash: Promise<string> | undefined;
export function getDummyHash(): Promise<string> {
  dummyHash ??= hashPassword(`dummy-${randomInt(1e9)}`);
  return dummyHash;
}

function pick(chars: string): string {
  return chars[randomInt(chars.length)];
}

/**
 * [R-41] Cryptographically random temporary password: 8 characters from
 * TEMP_PASSWORD_ALPHABET, always containing an uppercase letter, a lowercase letter and a digit.
 */
export function generateTemporaryPassword(length: number = TEMP_PASSWORD_LENGTH): string {
  if (length < 3) throw new RangeError('length must be >= 3');
  const chars = [pick(UPPER), pick(LOWER), pick(DIGITS)];
  while (chars.length < length) chars.push(pick(TEMP_PASSWORD_ALPHABET));
  // Fisher–Yates shuffle so the guaranteed classes are not always first.
  for (let i = chars.length - 1; i > 0; i--) {
    const j = randomInt(i + 1);
    [chars[i], chars[j]] = [chars[j], chars[i]];
  }
  return chars.join('');
}
