import {
  Body,
  Controller,
  Delete,
  Get,
  Global,
  HttpCode,
  HttpStatus,
  Logger,
  Module,
  OnApplicationShutdown,
  Param,
  ParseUUIDPipe,
  Post,
  Query,
} from '@nestjs/common';
import { ApiBearerAuth, ApiNoContentResponse, ApiOkResponse, ApiTags } from '@nestjs/swagger';
import type { AuthUser } from '../../common/auth/auth-user';
import { CurrentUser } from '../../common/auth/decorators';
import { PaginationQueryDto } from '../../common/pagination/pagination';
import { AppConfigService } from '../../config/app-config.service';
import { InboxDto, RegisterDeviceDto } from './dto';
import { NotificationsService } from './notifications.service';
import { FcmPushSender, LogPushSender, PushSender } from './push.sender';

/** Devices and inbox of the signed-in user (PLAN section 8.6). Any role. */
@ApiTags('notifications')
@ApiBearerAuth()
@Controller('me')
export class MyNotificationsController {
  constructor(private readonly notifications: NotificationsService) {}

  @Post('devices')
  @HttpCode(HttpStatus.NO_CONTENT)
  @ApiNoContentResponse({ description: 'Upserted by token' })
  registerDevice(@CurrentUser() user: AuthUser, @Body() dto: RegisterDeviceDto): Promise<void> {
    return this.notifications.registerDevice(user.id, dto);
  }

  @Delete('devices/:fcmToken')
  @HttpCode(HttpStatus.NO_CONTENT)
  removeDevice(@CurrentUser() user: AuthUser, @Param('fcmToken') fcmToken: string): Promise<void> {
    return this.notifications.removeDevice(user.id, fcmToken);
  }

  @Get('notifications')
  @ApiOkResponse({ type: InboxDto })
  inbox(@CurrentUser() user: AuthUser, @Query() q: PaginationQueryDto): Promise<InboxDto> {
    return this.notifications.inbox(user.id, q);
  }

  @Post('notifications/read-all')
  @HttpCode(HttpStatus.NO_CONTENT)
  readAll(@CurrentUser() user: AuthUser): Promise<void> {
    return this.notifications.markAllRead(user.id);
  }

  @Post('notifications/:id/read')
  @HttpCode(HttpStatus.NO_CONTENT)
  read(@CurrentUser() user: AuthUser, @Param('id', new ParseUUIDPipe()) id: string): Promise<void> {
    return this.notifications.markRead(user.id, id);
  }
}

/** Global so check-in, payments and the scheduler can notify without import cycles. */
@Global()
@Module({
  controllers: [MyNotificationsController],
  providers: [
    NotificationsService,
    {
      provide: PushSender,
      inject: [AppConfigService],
      useFactory: (config: AppConfigService): PushSender => {
        if (!config.get('PUSH_ENABLED')) return new LogPushSender();
        new Logger('Push').log('Push enabled (FCM)');
        return new FcmPushSender(config.get('FIREBASE_SERVICE_ACCOUNT_JSON') as string);
      },
    },
  ],
  exports: [NotificationsService],
})
export class NotificationsModule implements OnApplicationShutdown {
  constructor(
    private readonly notifications: NotificationsService,
    private readonly push: PushSender,
  ) {}

  async onApplicationShutdown(): Promise<void> {
    await this.notifications.flush();
    if (this.push instanceof FcmPushSender) await this.push.close();
  }
}
