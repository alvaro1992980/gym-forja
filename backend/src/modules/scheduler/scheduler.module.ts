import { Controller, HttpCode, HttpStatus, Module, Param, Post } from '@nestjs/common';
import { ApiBearerAuth, ApiOperation, ApiParam, ApiTags } from '@nestjs/swagger';
import { Role } from '@prisma/client';
import { Roles } from '../../common/auth/decorators';
import { AppException } from '../../common/errors/app.exception';
import { ErrorCode } from '../../common/errors/error-codes';
import { AppConfigService } from '../../config/app-config.service';
import { JOB_NAMES, JobName, SchedulerService } from './scheduler.service';

/** Runs a scheduled job now, for testing. Not available in production (404). */
@ApiTags('jobs')
@ApiBearerAuth()
@Controller('admin/jobs')
@Roles(Role.ADMIN)
export class JobsController {
  constructor(
    private readonly scheduler: SchedulerService,
    private readonly config: AppConfigService,
  ) {}

  @Post(':name/run')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Run a scheduled job now (non-production only)' })
  @ApiParam({ name: 'name', enum: JOB_NAMES })
  run(@Param('name') name: string): Promise<unknown> {
    if (this.config.isProduction || !(JOB_NAMES as readonly string[]).includes(name)) {
      throw new AppException(HttpStatus.NOT_FOUND, ErrorCode.NOT_FOUND);
    }
    return this.scheduler.run(name as JobName);
  }
}

@Module({
  controllers: [JobsController],
  providers: [SchedulerService],
  exports: [SchedulerService],
})
export class SchedulerModule {}
