import { Module } from '@nestjs/common';
import { KioskModule } from '../kiosk/kiosk.module';
import { MembershipsCoreModule } from '../memberships/memberships-core.module';
import { RealtimeModule } from '../realtime/realtime.module';
import { SettingsModule } from '../settings/settings.module';
import {
  AdminCheckinsController,
  CheckinsController,
  MyCheckinsController,
} from './checkins.controller';
import { CheckinsService } from './checkins.service';

@Module({
  imports: [KioskModule, MembershipsCoreModule, RealtimeModule, SettingsModule],
  controllers: [CheckinsController, AdminCheckinsController, MyCheckinsController],
  providers: [CheckinsService],
})
export class CheckinsModule {}
