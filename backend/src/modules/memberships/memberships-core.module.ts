import { Module } from '@nestjs/common';
import { MembershipsService } from './memberships.service';

/** MembershipsService only (depends on Prisma + Clock), importable by auth without cycles. */
@Module({
  providers: [MembershipsService],
  exports: [MembershipsService],
})
export class MembershipsCoreModule {}
