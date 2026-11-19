import { Module } from '@nestjs/common';
import { AuthModule } from '../auth/auth.module';
import { StaffController } from './staff.controller';
import { UsersService } from './users.service';

@Module({
  imports: [AuthModule],
  controllers: [StaffController],
  providers: [UsersService],
  exports: [UsersService],
})
export class UsersModule {}
