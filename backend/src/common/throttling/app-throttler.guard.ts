import { Injectable } from '@nestjs/common';
import { ThrottlerGuard } from '@nestjs/throttler';
import { normalizePhone } from '../phone/phone';

interface ThrottledRequest {
  ip?: string;
  method?: string;
  body?: unknown;
  headers?: Record<string, unknown>;
  route?: { path?: string };
}

/**
 * Global throttler (section 8: "login 5/min per IP+phone, check-in 10/min per user").
 *  - Login is tracked per IP + phone, so one attacker cannot lock out every account and one
 *    shared gym Wi-Fi IP does not block everyone.
 *  - Check-in is tracked per user. This guard runs before authentication, so the user is
 *    read from the bearer token's `sub` without verifying it: it only picks the counter, and
 *    a forged token still fails authentication right after.
 *  - Every other route is tracked per IP.
 */
@Injectable()
export class AppThrottlerGuard extends ThrottlerGuard {
  protected override getTracker(req: Record<string, unknown>): Promise<string> {
    const r = req as ThrottledRequest;
    const ip = r.ip ?? 'unknown';
    const path = r.route?.path ?? '';
    if (path.endsWith('/auth/login')) {
      const body = (r.body ?? {}) as { phone?: unknown };
      const phone =
        typeof body.phone === 'string' ? (normalizePhone(body.phone) ?? body.phone) : '';
      return Promise.resolve(`${ip}|${phone}`);
    }
    if (path.endsWith('/checkins') && r.method === 'POST') {
      const sub = bearerSubject(r.headers?.authorization);
      return Promise.resolve(sub ? `user:${sub}` : ip);
    }
    return Promise.resolve(ip);
  }
}

/** `sub` claim of a bearer JWT, without verifying it (tracking key only). */
export function bearerSubject(header: unknown): string | null {
  if (typeof header !== 'string' || !header.startsWith('Bearer ')) return null;
  const payload = header.slice('Bearer '.length).split('.')[1];
  if (!payload) return null;
  try {
    const claims = JSON.parse(Buffer.from(payload, 'base64url').toString('utf8')) as {
      sub?: unknown;
    };
    return typeof claims.sub === 'string' ? claims.sub : null;
  } catch {
    return null;
  }
}
