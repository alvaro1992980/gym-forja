import { bearerSubject } from './app-throttler.guard';

const jwtWith = (payload: object) =>
  `Bearer h.${Buffer.from(JSON.stringify(payload)).toString('base64url')}.sig`;

describe('check-in rate limit key', () => {
  it('uses the bearer token subject (10/min per user)', () => {
    expect(bearerSubject(jwtWith({ sub: 'user-1' }))).toBe('user-1');
  });

  it('falls back (null) for missing or malformed tokens', () => {
    expect(bearerSubject(undefined)).toBeNull();
    expect(bearerSubject('Basic abc')).toBeNull();
    expect(bearerSubject('Bearer nope')).toBeNull();
    expect(bearerSubject('Bearer a.!!!.b')).toBeNull();
    expect(bearerSubject(jwtWith({ sub: 42 }))).toBeNull();
  });
});
