import { Body, Controller, Get, HttpCode, HttpStatus, Post, Query } from '@nestjs/common';
import { ApiBearerAuth, ApiOkResponse, ApiOperation, ApiTags } from '@nestjs/swagger';
import { Throttle } from '@nestjs/throttler';
import { Role } from '@prisma/client';
import type { AuthUser } from '../../common/auth/auth-user';
import { AllowInactiveAccount, CurrentUser, Roles } from '../../common/auth/decorators';
import { Paginated } from '../../common/pagination/pagination';
import { CheckinsService } from './checkins.service';
import {
  AttemptItemDto,
  AttemptPageDto,
  CheckinDto,
  CheckinItemDto,
  CheckinPageDto,
  CheckinResponseDto,
  DateRangeQueryDto,
  InsideNowDto,
  ListAttemptsQueryDto,
  ListCheckinsQueryDto,
  MyCheckinDto,
  MyCheckinPageDto,
} from './dto';

/** Section 8: "check-in 10/min per user" (tracked per user by AppThrottlerGuard). */
export const CHECKIN_RATE_LIMIT = { default: { limit: 10, ttl: 60_000 } };

@ApiTags('checkins')
@ApiBearerAuth()
@Controller('checkins')
export class CheckinsController {
  constructor(private readonly checkins: CheckinsService) {}

  @Post()
  @Roles(Role.MEMBER)
  @AllowInactiveAccount()
  @Throttle(CHECKIN_RATE_LIMIT)
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'Check in with the kiosk QR token [R-17]–[R-22]',
    description:
      '200 SUCCESS or DUPLICATE [R-19]. 400 QR_TOKEN_INVALID / QR_TOKEN_EXPIRED, ' +
      '403 MEMBERSHIP_EXPIRED (details.endDate) / ACCOUNT_INACTIVE.',
  })
  @ApiOkResponse({ type: CheckinResponseDto })
  checkIn(@CurrentUser() user: AuthUser, @Body() dto: CheckinDto): Promise<CheckinResponseDto> {
    return this.checkins.checkIn(user, dto.qrToken);
  }
}

@ApiTags('checkins')
@ApiBearerAuth()
@Controller('admin/checkins')
@Roles(Role.ADMIN)
export class AdminCheckinsController {
  constructor(private readonly checkins: CheckinsService) {}

  @Get()
  @ApiOkResponse({ type: CheckinPageDto })
  list(@Query() q: ListCheckinsQueryDto): Promise<Paginated<CheckinItemDto>> {
    return this.checkins.list(q);
  }

  @Get('inside')
  @ApiOperation({ summary: 'Members inside now [R-23]' })
  @ApiOkResponse({ type: InsideNowDto })
  inside(): Promise<InsideNowDto> {
    return this.checkins.inside();
  }

  @Get('attempts')
  @ApiOperation({ summary: 'Denied and invalid check-in attempts [R-22]' })
  @ApiOkResponse({ type: AttemptPageDto })
  attempts(@Query() q: ListAttemptsQueryDto): Promise<Paginated<AttemptItemDto>> {
    return this.checkins.attempts(q);
  }
}

@ApiTags('checkins')
@ApiBearerAuth()
@Controller('me/checkins')
@Roles(Role.MEMBER)
export class MyCheckinsController {
  constructor(private readonly checkins: CheckinsService) {}

  @Get()
  @ApiOperation({ summary: 'Own check-in history (attendance calendar)' })
  @ApiOkResponse({ type: MyCheckinPageDto })
  mine(
    @CurrentUser() user: AuthUser,
    @Query() q: DateRangeQueryDto,
  ): Promise<Paginated<MyCheckinDto>> {
    return this.checkins.mine(user.id, q);
  }
}
