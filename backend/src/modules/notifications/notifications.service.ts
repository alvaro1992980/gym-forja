import { HttpStatus, Injectable, Logger } from '@nestjs/common';
import { Prisma, Role } from '@prisma/client';
import { ClockService } from '../../common/clock/clock.service';
import { AppException } from '../../common/errors/app.exception';
import { ErrorCode } from '../../common/errors/error-codes';
import { paginated, PaginationQueryDto, skipTake } from '../../common/pagination/pagination';
import { PrismaService } from '../../prisma/prisma.service';
import { InboxDto, NotificationDto, RegisterDeviceDto } from './dto';
import { PushSender } from './push.sender';
import { NotificationMessage } from './templates';

/**
 * Stores every notification for the in-app inbox and pushes it to the user's devices
 * (PLAN section 7). Sending runs in the background after the caller's transaction committed:
 * a failure is logged and never fails the request.
 */
@Injectable()
export class NotificationsService {
  private readonly logger = new Logger(NotificationsService.name);
  private readonly pending = new Set<Promise<void>>();

  constructor(
    private readonly prisma: PrismaService,
    private readonly clock: ClockService,
    private readonly push: PushSender,
  ) {}

  /** Queues [message] for each user. Returns at once. */
  notify(userIds: string[], message: NotificationMessage): void {
    this.track(this.deliver(userIds, message));
  }

  /** Queues [message] for every active ADMIN. */
  notifyAdmins(message: NotificationMessage): void {
    this.track(
      (async () => {
        const admins = await this.prisma.user.findMany({
          where: { role: Role.ADMIN, isActive: true },
          select: { id: true },
        });
        await this.deliver(
          admins.map((a) => a.id),
          message,
        );
      })(),
    );
  }

  /** Stores and pushes now (used by the scheduler, which already runs in the background). */
  async deliver(userIds: string[], message: NotificationMessage): Promise<void> {
    if (userIds.length === 0) return;
    const createdAt = this.clock.now();
    const rows = await this.prisma.notification.createManyAndReturn({
      data: userIds.map((userId) => ({
        userId,
        type: message.type,
        title: message.title,
        body: message.body,
        data: message.data,
        createdAt,
      })),
      select: { id: true, userId: true },
    });
    const devices = await this.prisma.device.findMany({
      where: { userId: { in: userIds } },
      select: { userId: true, fcmToken: true },
    });
    for (const row of rows) {
      const tokens = devices.filter((d) => d.userId === row.userId).map((d) => d.fcmToken);
      if (tokens.length === 0) continue;
      try {
        const { invalidTokens } = await this.push.send(tokens, {
          title: message.title,
          body: message.body,
          data: { ...message.data, type: message.type, notificationId: row.id },
        });
        if (invalidTokens.length > 0) {
          await this.prisma.device.deleteMany({ where: { fcmToken: { in: invalidTokens } } });
          this.logger.log(`Deleted ${invalidTokens.length} invalid device token(s)`);
        }
      } catch (e) {
        this.logger.error(`Push ${message.type} failed: ${String(e)}`);
      }
    }
  }

  /** Waits for queued notifications (tests and graceful shutdown). */
  async flush(): Promise<void> {
    while (this.pending.size > 0) {
      await Promise.all([...this.pending]);
    }
  }

  private track(work: Promise<void>): void {
    const p = work
      .catch((e: unknown) => this.logger.error(`Notification failed: ${String(e)}`))
      .finally(() => this.pending.delete(p));
    this.pending.add(p);
  }

  // ------------------------------------------------------------ devices

  /** POST /me/devices: upsert by token (a phone that changes user moves to the new one). */
  async registerDevice(userId: string, dto: RegisterDeviceDto): Promise<void> {
    const now = this.clock.now();
    await this.prisma.device.upsert({
      where: { fcmToken: dto.fcmToken },
      create: { userId, fcmToken: dto.fcmToken, platform: dto.platform, lastSeenAt: now },
      update: { userId, platform: dto.platform, lastSeenAt: now },
    });
  }

  /** DELETE /me/devices/:fcmToken (only the caller's own). */
  async removeDevice(userId: string, fcmToken: string): Promise<void> {
    await this.prisma.device.deleteMany({ where: { userId, fcmToken } });
  }

  // -------------------------------------------------------------- inbox

  async inbox(userId: string, q: PaginationQueryDto): Promise<InboxDto> {
    const where: Prisma.NotificationWhereInput = { userId };
    const [rows, total, unreadCount] = await this.prisma.$transaction([
      this.prisma.notification.findMany({
        where,
        orderBy: { createdAt: 'desc' },
        ...skipTake(q),
      }),
      this.prisma.notification.count({ where }),
      this.prisma.notification.count({ where: { userId, readAt: null } }),
    ]);
    return { ...paginated(rows.map(toDto), total, q), unreadCount };
  }

  async markRead(userId: string, id: string): Promise<void> {
    const { count } = await this.prisma.notification.updateMany({
      where: { id, userId },
      data: { readAt: this.clock.now() },
    });
    if (count === 0) {
      const exists = await this.prisma.notification.count({ where: { id, userId } });
      if (!exists) throw new AppException(HttpStatus.NOT_FOUND, ErrorCode.NOT_FOUND);
    }
  }

  async markAllRead(userId: string): Promise<void> {
    await this.prisma.notification.updateMany({
      where: { userId, readAt: null },
      data: { readAt: this.clock.now() },
    });
  }
}

function toDto(n: {
  id: string;
  type: NotificationDto['type'];
  title: string;
  body: string;
  data: Prisma.JsonValue;
  readAt: Date | null;
  createdAt: Date;
}): NotificationDto {
  return {
    id: n.id,
    type: n.type,
    title: n.title,
    body: n.body,
    data: (n.data as Record<string, string> | null) ?? {},
    readAt: n.readAt,
    createdAt: n.createdAt,
  };
}
