import { isSwaggerEnabled, NodeEnv, parseCorsOrigins, validateEnv } from './env.validation';

const base = {
  DATABASE_URL: 'postgresql://gym:gym@localhost:5433/gym',
  JWT_ACCESS_SECRET: 'a'.repeat(32),
  QR_TOKEN_SECRET: 'b'.repeat(32),
};

describe('validateEnv', () => {
  it('applies defaults for optional variables', () => {
    const env = validateEnv({ ...base });
    expect(env.NODE_ENV).toBe(NodeEnv.Development);
    expect(env.PORT).toBe(3000);
    expect(env.JWT_ACCESS_TTL).toBe('15m');
    expect(env.JWT_REFRESH_TTL_DAYS).toBe(30);
    expect(env.QR_TOKEN_TTL_SECONDS).toBe(45);
    expect(env.GYM_TIMEZONE).toBe('America/La_Paz');
    expect(env.PUSH_ENABLED).toBe(false);
    expect(env.SWAGGER_ENABLED).toBeUndefined();
  });

  it('converts strings from process.env to numbers and booleans', () => {
    const env = validateEnv({
      ...base,
      PORT: '8080',
      PUSH_ENABLED: 'false',
      SWAGGER_ENABLED: 'true',
    });
    expect(env.PORT).toBe(8080);
    expect(env.PUSH_ENABLED).toBe(false);
    expect(env.SWAGGER_ENABLED).toBe(true);
  });

  it.each(['DATABASE_URL', 'JWT_ACCESS_SECRET', 'QR_TOKEN_SECRET'])(
    'fails fast when %s is missing',
    (key) => {
      const raw: Record<string, string> = { ...base };
      delete raw[key];
      expect(() => validateEnv(raw)).toThrow(
        new RegExp(`Invalid environment configuration[\\s\\S]*${key}`),
      );
    },
  );

  it('treats empty strings as missing', () => {
    expect(() => validateEnv({ ...base, DATABASE_URL: '' })).toThrow(/DATABASE_URL/);
  });

  it('rejects a short JWT secret', () => {
    expect(() => validateEnv({ ...base, JWT_ACCESS_SECRET: 'short' })).toThrow(/JWT_ACCESS_SECRET/);
  });

  it('rejects an unknown timezone', () => {
    expect(() => validateEnv({ ...base, GYM_TIMEZONE: 'Mars/Olympus' })).toThrow(/GYM_TIMEZONE/);
  });

  it('rejects a malformed boolean', () => {
    expect(() => validateEnv({ ...base, PUSH_ENABLED: 'maybe' })).toThrow(/PUSH_ENABLED/);
  });

  it('requires FIREBASE_SERVICE_ACCOUNT_JSON only when PUSH_ENABLED=true', () => {
    expect(() => validateEnv({ ...base, PUSH_ENABLED: 'true' })).toThrow(
      /FIREBASE_SERVICE_ACCOUNT_JSON/,
    );
    expect(() =>
      validateEnv({ ...base, PUSH_ENABLED: 'true', FIREBASE_SERVICE_ACCOUNT_JSON: 'e30=' }),
    ).not.toThrow();
  });

  it('rejects a bad JWT_ACCESS_TTL format', () => {
    expect(() => validateEnv({ ...base, JWT_ACCESS_TTL: '15 minutes' })).toThrow(/JWT_ACCESS_TTL/);
  });
});

describe('isSwaggerEnabled', () => {
  it('is on by default outside production', () => {
    expect(isSwaggerEnabled({ NODE_ENV: NodeEnv.Development })).toBe(true);
  });

  it('is off in production unless SWAGGER_ENABLED=true', () => {
    expect(isSwaggerEnabled({ NODE_ENV: NodeEnv.Production })).toBe(false);
    expect(isSwaggerEnabled({ NODE_ENV: NodeEnv.Production, SWAGGER_ENABLED: true })).toBe(true);
  });

  it('can be turned off explicitly', () => {
    expect(isSwaggerEnabled({ NODE_ENV: NodeEnv.Development, SWAGGER_ENABLED: false })).toBe(false);
  });
});

describe('parseCorsOrigins', () => {
  it('splits and trims a comma-separated list', () => {
    expect(parseCorsOrigins(' http://a.com, http://b.com ,,')).toEqual([
      'http://a.com',
      'http://b.com',
    ]);
  });

  it('returns an empty list for an empty string', () => {
    expect(parseCorsOrigins('')).toEqual([]);
  });
});
