import { randomUUID } from 'node:crypto';
import type { IncomingMessage, ServerResponse } from 'node:http';
import type { Params } from 'nestjs-pino';
import { AppConfigService } from '../../config/app-config.service';
import { NodeEnv } from '../../config/env.validation';

export const REQUEST_ID_HEADER = 'x-request-id';
const REQUEST_ID_RE = /^[A-Za-z0-9._-]{1,128}$/;

/** Reuses a well-formed incoming X-Request-Id, otherwise generates one; echoes it back. */
export function genReqId(req: IncomingMessage, res: ServerResponse): string {
  const incoming = req.headers[REQUEST_ID_HEADER];
  const id = typeof incoming === 'string' && REQUEST_ID_RE.test(incoming) ? incoming : randomUUID();
  res.setHeader(REQUEST_ID_HEADER, id);
  return id;
}

/**
 * Paths that must never be logged (section 10: no passwords, tokens or medical notes).
 * pino-http does not log bodies, but these also cover anything logged by hand.
 */
export const REDACT_PATHS = [
  'req.headers.authorization',
  'req.headers.cookie',
  'res.headers["set-cookie"]',
  '*.password',
  '*.currentPassword',
  '*.newPassword',
  '*.temporaryPassword',
  '*.passwordHash',
  '*.accessToken',
  '*.refreshToken',
  '*.qrToken',
  '*.fcmToken',
  '*.medicalNotes',
];

/** Structured JSON logs with a request id (pretty-printed in development). */
export function buildLoggerParams(config: AppConfigService): Params {
  const isDev = config.nodeEnv === NodeEnv.Development;
  return {
    pinoHttp: {
      level: config.get('LOG_LEVEL'),
      genReqId,
      redact: { paths: REDACT_PATHS, censor: '[REDACTED]' },
      customLogLevel: (_req, res, err) => {
        if (err || res.statusCode >= 500) return 'error';
        if (res.statusCode >= 400) return 'warn';
        return 'info';
      },
      serializers: {
        req: (req: { id: unknown; method: unknown; url: unknown }) => ({
          id: req.id,
          method: req.method,
          url: req.url,
        }),
        res: (res: { statusCode: unknown }) => ({ statusCode: res.statusCode }),
      },
      transport: isDev
        ? { target: 'pino-pretty', options: { singleLine: true, translateTime: 'SYS:HH:MM:ss' } }
        : undefined,
    },
  };
}
