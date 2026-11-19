import { Injectable, Logger } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { OnGatewayConnection, WebSocketGateway, WebSocketServer } from '@nestjs/websockets';
import type { Namespace, Socket } from 'socket.io';
import { AccessTokenPayload } from '../../common/auth/auth-user';
import { AppConfigService } from '../../config/app-config.service';
import { PrismaService } from '../../prisma/prisma.service';

export const ADMINS_ROOM = 'admins';

/** `checkin.created` payload (section 8.5). */
export interface CheckinCreatedEvent {
  checkinId: string;
  member: { id: string; firstName: string; lastName: string };
  tier: string;
  daysLeft: number;
  createdAt: Date;
}

/** `checkin.denied` payload (section 8.5). */
export interface CheckinDeniedEvent {
  member: { id: string; firstName: string; lastName: string };
  reason: 'EXPIRED' | 'INACTIVE';
  endDate: string | null;
  createdAt: Date;
}

/**
 * Socket.IO namespace `/realtime` (section 8.5). The access token goes in the handshake
 * `auth.token`; it is verified and the user reloaded (inactive accounts and pending password
 * changes are refused). Only ADMIN sockets join the `admins` room. After joining, the server
 * emits `ready` so clients know they will receive events.
 */
@Injectable()
@WebSocketGateway({ namespace: '/realtime', cors: { origin: true } })
export class RealtimeGateway implements OnGatewayConnection {
  private readonly logger = new Logger(RealtimeGateway.name);
  private readonly jwt: JwtService;

  @WebSocketServer()
  server: Namespace;

  constructor(
    config: AppConfigService,
    private readonly prisma: PrismaService,
  ) {
    this.jwt = new JwtService({ secret: config.get('JWT_ACCESS_SECRET') });
  }

  async handleConnection(client: Socket): Promise<void> {
    const auth = client.handshake.auth as { token?: unknown } | undefined;
    const token = typeof auth?.token === 'string' ? auth.token : '';
    try {
      const payload = await this.jwt.verifyAsync<AccessTokenPayload>(token, {
        algorithms: ['HS256'],
      });
      if (payload.typ !== 'access' || typeof payload.sub !== 'string') throw new Error('typ');
      const user = await this.prisma.user.findUnique({
        where: { id: payload.sub },
        select: { id: true, role: true, isActive: true, mustChangePassword: true },
      });
      if (!user || !user.isActive || user.mustChangePassword) throw new Error('user');
      const rooms: string[] = [];
      if (user.role === 'ADMIN') {
        await client.join(ADMINS_ROOM);
        rooms.push(ADMINS_ROOM);
      }
      client.data = { userId: user.id, role: user.role };
      client.emit('ready', { rooms });
    } catch {
      client.emit('unauthorized', { code: 'UNAUTHORIZED' });
      client.disconnect(true);
    }
  }

  checkinCreated(event: CheckinCreatedEvent): void {
    this.emitToAdmins('checkin.created', event);
  }

  checkinDenied(event: CheckinDeniedEvent): void {
    this.emitToAdmins('checkin.denied', event);
  }

  /** Never throws: realtime is best effort and must not fail a request. */
  private emitToAdmins(event: string, payload: object): void {
    try {
      this.server?.to(ADMINS_ROOM).emit(event, payload);
    } catch (e) {
      this.logger.error(`Could not emit ${event}: ${String(e)}`);
    }
  }
}
