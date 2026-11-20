import { Controller, Get, Module } from '@nestjs/common';
import { ApiBearerAuth, ApiOkResponse, ApiOperation, ApiTags } from '@nestjs/swagger';
import { Role } from '@prisma/client';
import type { AuthUser } from '../../common/auth/auth-user';
import { CurrentUser, Roles } from '../../common/auth/decorators';
import { QrTokenDto } from '../checkins/dto';
import { SettingsModule } from '../settings/settings.module';
import { SettingsService } from '../settings/settings.controller';
import { QrTokenService } from './qr-token.service';

@ApiTags('kiosk')
@ApiBearerAuth()
@Controller('kiosk')
@Roles(Role.KIOSK)
export class KioskController {
  constructor(
    private readonly qr: QrTokenService,
    private readonly settings: SettingsService,
  ) {}

  @Get('qr-token')
  @ApiOperation({
    summary: 'Rotating check-in QR token [R-18]',
    description: 'Fetch a new one every `refreshInSeconds` (30); each is valid for 45 s.',
  })
  @ApiOkResponse({ type: QrTokenDto })
  async qrToken(@CurrentUser() kiosk: AuthUser): Promise<QrTokenDto> {
    const { gymName } = await this.settings.get();
    return { ...this.qr.issue(kiosk.id), gymName };
  }
}

@Module({
  imports: [SettingsModule],
  controllers: [KioskController],
  providers: [QrTokenService],
  exports: [QrTokenService],
})
export class KioskModule {}
