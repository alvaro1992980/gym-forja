import { JwtService } from '@nestjs/jwt';
import { FixedClockService } from '../../common/clock/clock.service';
import { AppConfigService } from '../../config/app-config.service';
import { QrTokenError, QrTokenService } from './qr-token.service';

const QR_SECRET = 'q'.repeat(32);
const ACCESS_SECRET = 'a'.repeat(32);

function makeService(now: string) {
  const config = {
    get: (key: string) => ({ QR_TOKEN_SECRET: QR_SECRET, QR_TOKEN_TTL_SECONDS: 45 })[key] as never,
    gymTimezone: 'America/La_Paz',
  } as unknown as AppConfigService;
  const clock = new FixedClockService(config, now);
  return { service: new QrTokenService(config, clock), clock };
}

function failureOf(fn: () => unknown): string | undefined {
  try {
    fn();
    return undefined;
  } catch (e) {
    return e instanceof QrTokenError ? e.reason : 'other';
  }
}

describe('[R-18] kiosk QR tokens', () => {
  it('[R-18] rotate every 30 s and are valid for 45 s', () => {
    const { service } = makeService('2026-11-19T15:00:00.000Z');
    const issued = service.issue('kiosk-1');
    expect(issued.refreshInSeconds).toBe(30);
    expect(issued.expiresAt).toEqual(new Date('2026-11-19T15:00:45.000Z'));
    expect(service.verify(issued.token)).toMatchObject({ typ: 'checkin', kid: 'kiosk-1' });
  });

  it('[R-18] a token scanned during the rotation overlap (40 s old) still works', () => {
    const { service, clock } = makeService('2026-11-19T15:00:00.000Z');
    const { token } = service.issue('kiosk-1');
    clock.set('2026-11-19T15:00:40.000Z');
    expect(service.verify(token).kid).toBe('kiosk-1');
  });

  it('[R-18] a token older than 45 s is expired', () => {
    const { service, clock } = makeService('2026-11-19T15:00:00.000Z');
    const { token } = service.issue('kiosk-1');
    clock.set('2026-11-19T15:00:46.000Z');
    expect(failureOf(() => service.verify(token))).toBe('expired');
  });

  it('[R-17] every token has a unique id', () => {
    const { service } = makeService('2026-11-19T15:00:00.000Z');
    const a = service.verify(service.issue('k').token);
    const b = service.verify(service.issue('k').token);
    expect(a.jti).not.toBe(b.jti);
  });

  it('[R-17] a tampered token is invalid', () => {
    const { service } = makeService('2026-11-19T15:00:00.000Z');
    const { token } = service.issue('kiosk-1');
    const [h, p, s] = token.split('.');
    const forged = Buffer.from(
      JSON.stringify({ ...JSON.parse(Buffer.from(p, 'base64url').toString()), kid: 'other' }),
    ).toString('base64url');
    expect(failureOf(() => service.verify(`${h}.${forged}.${s}`))).toBe('invalid');
    expect(failureOf(() => service.verify('not-a-token'))).toBe('invalid');
  });

  it('[R-17] an access token (another secret) cannot be used as a QR', () => {
    const { service } = makeService('2026-11-19T15:00:00.000Z');
    const access = new JwtService({ secret: ACCESS_SECRET }).sign(
      { sub: 'u1', role: 'MEMBER', typ: 'access' },
      { expiresIn: 900 },
    );
    expect(failureOf(() => service.verify(access))).toBe('invalid');
  });

  it('[R-17] a token signed with the QR secret but of another type is invalid', () => {
    const { service } = makeService('2026-11-19T15:00:00.000Z');
    const other = new JwtService({ secret: QR_SECRET }).sign(
      { typ: 'access', kid: 'kiosk-1', jti: 'x' },
      { expiresIn: 45 },
    );
    expect(failureOf(() => service.verify(other))).toBe('invalid');
  });
});
