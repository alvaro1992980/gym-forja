import { Injectable } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { randomUUID } from 'node:crypto';
import { ClockService } from '../../common/clock/clock.service';
import { AppConfigService } from '../../config/app-config.service';
import { QR_REFRESH_SECONDS } from '../checkins/checkin-rules';

/** Claims of a kiosk QR token (section 8.4). */
export interface QrTokenClaims {
  typ: 'checkin';
  /** Kiosk user id. */
  kid: string;
  jti: string;
  iat: number;
  exp: number;
}

export interface IssuedQrToken {
  token: string;
  expiresAt: Date;
  refreshInSeconds: number;
}

export type QrTokenFailure = 'invalid' | 'expired';

export class QrTokenError extends Error {
  constructor(readonly reason: QrTokenFailure) {
    super(`QR token ${reason}`);
  }
}

/**
 * Signs and verifies the rotating kiosk QR tokens [R-17]/[R-18] with QR_TOKEN_SECRET, a
 * secret separate from the access tokens, so no other token can be used as a QR. Time comes
 * from ClockService, so tests can move it.
 */
@Injectable()
export class QrTokenService {
  private readonly jwt: JwtService;
  private readonly ttlSeconds: number;

  constructor(
    config: AppConfigService,
    private readonly clock: ClockService,
  ) {
    this.jwt = new JwtService({ secret: config.get('QR_TOKEN_SECRET') });
    this.ttlSeconds = config.get('QR_TOKEN_TTL_SECONDS');
  }

  issue(kioskId: string): IssuedQrToken {
    const iat = Math.floor(this.clock.now().getTime() / 1000);
    const exp = iat + this.ttlSeconds;
    const claims: QrTokenClaims = { typ: 'checkin', kid: kioskId, jti: randomUUID(), iat, exp };
    return {
      token: this.jwt.sign(claims, { algorithm: 'HS256' }),
      expiresAt: new Date(exp * 1000),
      refreshInSeconds: QR_REFRESH_SECONDS,
    };
  }

  /** Throws QrTokenError('expired' | 'invalid'). */
  verify(token: string): QrTokenClaims {
    let claims: Partial<QrTokenClaims>;
    try {
      claims = this.jwt.verify<Partial<QrTokenClaims>>(token, {
        algorithms: ['HS256'],
        clockTimestamp: Math.floor(this.clock.now().getTime() / 1000),
      });
    } catch (e) {
      const expired = e instanceof Error && e.name === 'TokenExpiredError';
      throw new QrTokenError(expired ? 'expired' : 'invalid');
    }
    if (
      claims.typ !== 'checkin' ||
      typeof claims.kid !== 'string' ||
      typeof claims.jti !== 'string' ||
      typeof claims.exp !== 'number'
    ) {
      throw new QrTokenError('invalid');
    }
    return claims as QrTokenClaims;
  }
}
