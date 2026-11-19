import { Injectable } from '@nestjs/common';
import { ThrottlerGuard } from '@nestjs/throttler';
import { normalizePhone } from '../phone/phone';

interface ThrottledRequest {
  ip?: string;
  body?: unknown;
  route?: { path?: string };
}

/**
 * Global throttler. Login is limited per IP + phone (section 8: "login 5/min per IP+phone"),
 * so one attacker cannot lock out every account and one shared gym Wi-Fi IP does not block
 * everyone. Every other route is tracked per IP.
 */
@Injectable()
export class AppThrottlerGuard extends ThrottlerGuard {
  protected override getTracker(req: Record<string, unknown>): Promise<string> {
    const r = req as ThrottledRequest;
    const ip = r.ip ?? 'unknown';
    if (r.route?.path?.endsWith('/auth/login')) {
      const body = (r.body ?? {}) as { phone?: unknown };
      const phone =
        typeof body.phone === 'string' ? (normalizePhone(body.phone) ?? body.phone) : '';
      return Promise.resolve(`${ip}|${phone}`);
    }
    return Promise.resolve(ip);
  }
}
