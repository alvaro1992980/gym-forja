import { Module } from '@nestjs/common';
import { PricingModule } from '../pricing/pricing.module';
import { UsersModule } from '../users/users.module';
import { MembersService } from './members.service';
import {
  AdminMembersController,
  AdminPaymentsController,
  MyMembershipController,
} from './memberships.controller';
import { MembershipsCoreModule } from './memberships-core.module';
import { PaymentsService } from './payments.service';

@Module({
  imports: [UsersModule, PricingModule, MembershipsCoreModule],
  controllers: [AdminMembersController, AdminPaymentsController, MyMembershipController],
  providers: [MembersService, PaymentsService],
})
export class MembershipsModule {}
