import { Module } from '@nestjs/common';
import { SettingsController, SettingsService } from './settings.controller';

@Module({
  controllers: [SettingsController],
  providers: [SettingsService],
  exports: [SettingsService],
})
export class SettingsModule {}
