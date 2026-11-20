import { Injectable, Logger } from '@nestjs/common';
import { App, cert, deleteApp, initializeApp, ServiceAccount } from 'firebase-admin/app';
import { getMessaging } from 'firebase-admin/messaging';

export interface PushMessage {
  title: string;
  body: string;
  /** FCM data values must be strings. */
  data: Record<string, string>;
}

export interface PushResult {
  /** Tokens FCM reported as no longer valid: their devices are deleted. */
  invalidTokens: string[];
}

/** Sends a push to device tokens. Never throws for per-token failures. */
export abstract class PushSender {
  abstract send(tokens: string[], message: PushMessage): Promise<PushResult>;
}

/** `PUSH_ENABLED=false`: nothing is sent, only logged (section D8). */
@Injectable()
export class LogPushSender extends PushSender {
  private readonly logger = new Logger('Push');

  send(tokens: string[], message: PushMessage): Promise<PushResult> {
    this.logger.log(`Push disabled: "${message.title}" not sent to ${tokens.length} device(s)`);
    return Promise.resolve({ invalidTokens: [] });
  }
}

/** FCM codes meaning the token will never work again. */
const INVALID_TOKEN_CODES = new Set([
  'messaging/registration-token-not-registered',
  'messaging/invalid-registration-token',
  'messaging/invalid-argument',
]);

/** Firebase Cloud Messaging through firebase-admin. */
export class FcmPushSender extends PushSender {
  private readonly logger = new Logger('Push');
  private readonly app: App;

  /** @param serviceAccountBase64 FIREBASE_SERVICE_ACCOUNT_JSON (base64 of the JSON key). */
  constructor(serviceAccountBase64: string) {
    super();
    const json = JSON.parse(
      Buffer.from(serviceAccountBase64, 'base64').toString('utf8'),
    ) as ServiceAccount;
    this.app = initializeApp({ credential: cert(json) }, 'gym-push');
  }

  async send(tokens: string[], message: PushMessage): Promise<PushResult> {
    if (tokens.length === 0) return { invalidTokens: [] };
    const res = await getMessaging(this.app).sendEachForMulticast({
      tokens,
      notification: { title: message.title, body: message.body },
      data: message.data,
      android: { priority: 'high', notification: { channelId: 'gym_default' } },
      apns: { payload: { aps: { sound: 'default' } } },
    });
    const invalidTokens: string[] = [];
    res.responses.forEach((r, i) => {
      if (r.success) return;
      const code = r.error?.code ?? 'unknown';
      if (INVALID_TOKEN_CODES.has(code)) invalidTokens.push(tokens[i]);
      else this.logger.warn(`Push to one device failed: ${code}`);
    });
    return { invalidTokens };
  }

  close(): Promise<void> {
    return deleteApp(this.app);
  }
}
