import {
  generateTemporaryPassword,
  hashPassword,
  PASSWORD_MIN_LENGTH,
  TEMP_PASSWORD_ALPHABET,
  verifyPassword,
} from './password';

describe('[R-41] generateTemporaryPassword', () => {
  const samples = Array.from({ length: 500 }, () => generateTemporaryPassword());

  it('[R-41] generates 8 characters', () => {
    for (const p of samples) expect(p).toHaveLength(8);
  });

  it('[R-41] never uses ambiguous characters (0/O, 1/l/I)', () => {
    for (const p of samples) expect(p).not.toMatch(/[0O1lIo]/);
  });

  it('[R-41] uses only the documented alphabet', () => {
    for (const p of samples) {
      for (const c of p) expect(TEMP_PASSWORD_ALPHABET).toContain(c);
    }
  });

  it('[R-41] always mixes uppercase, lowercase and digits', () => {
    for (const p of samples) {
      expect(p).toMatch(/[A-Z]/);
      expect(p).toMatch(/[a-z]/);
      expect(p).toMatch(/[2-9]/);
    }
  });

  it('[R-41] is random (no repeats in 500 samples)', () => {
    expect(new Set(samples).size).toBe(samples.length);
  });

  it('[R-41] satisfies the minimum password length [R-42]', () => {
    expect(generateTemporaryPassword().length).toBeGreaterThanOrEqual(PASSWORD_MIN_LENGTH);
  });
});

describe('[R-42] password hashing', () => {
  it('[R-42] hashes with argon2id and verifies', async () => {
    const hash = await hashPassword('Secreto123');
    expect(hash).toMatch(/^\$argon2id\$/);
    expect(hash).not.toContain('Secreto123');
    await expect(verifyPassword(hash, 'Secreto123')).resolves.toBe(true);
    await expect(verifyPassword(hash, 'secreto123')).resolves.toBe(false);
  });

  it('[R-42] uses a random salt (same password, different hashes)', async () => {
    const [a, b] = await Promise.all([hashPassword('Secreto123'), hashPassword('Secreto123')]);
    expect(a).not.toBe(b);
  });

  it('[R-42] returns false for a malformed hash instead of throwing', async () => {
    await expect(verifyPassword('not-a-hash', 'x')).resolves.toBe(false);
  });

  it('[R-42] minimum length is 8', () => {
    expect(PASSWORD_MIN_LENGTH).toBe(8);
  });
});
