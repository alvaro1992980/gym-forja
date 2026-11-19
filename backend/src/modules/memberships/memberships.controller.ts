import {
  Body,
  Controller,
  Get,
  HttpCode,
  HttpStatus,
  Param,
  ParseUUIDPipe,
  Patch,
  Post,
  Query,
} from '@nestjs/common';
import { ApiBearerAuth, ApiCreatedResponse, ApiOkResponse, ApiTags } from '@nestjs/swagger';
import { Role } from '@prisma/client';
import type { AuthUser } from '../../common/auth/auth-user';
import { CurrentUser, Roles } from '../../common/auth/decorators';
import { AppException } from '../../common/errors/app.exception';
import { ErrorCode } from '../../common/errors/error-codes';
import {
  Paginated,
  PaginationQueryDto,
  paginated,
  skipTake,
} from '../../common/pagination/pagination';
import { ClockService } from '../../common/clock/clock.service';
import { PrismaService } from '../../prisma/prisma.service';
import {
  CreatedMemberDto,
  CreateMemberDto,
  CreatePaymentDto,
  ListMembersQueryDto,
  ListPaymentsQueryDto,
  MemberDetailDto,
  MemberPageDto,
  MyMembershipDto,
  MyPaymentDto,
  NewMemberPreviewQueryDto,
  PaymentPageDto,
  PaymentPreviewDto,
  PaymentPreviewQueryDto,
  PaymentResultDto,
  TemporaryPasswordDto,
  TierChangeDto,
  TierChangePreviewDto,
  TierChangePreviewResultDto,
  TierChangeResultDto,
  UpdateMemberDto,
  VoidPaymentDto,
} from './dto';
import { toMyPaymentDto } from './mappers';
import { MembersService } from './members.service';
import { toMembershipSummary } from './membership-view';
import { MembershipsService } from './memberships.service';
import { PaymentsService } from './payments.service';

const Uuid = () => new ParseUUIDPipe({ version: '4' });

@ApiTags('admin / members')
@ApiBearerAuth()
@Roles(Role.ADMIN)
@Controller('admin/members')
export class AdminMembersController {
  constructor(
    private readonly members: MembersService,
    private readonly payments: PaymentsService,
  ) {}

  /** Period + suggested amount for the "new member" stepper. Declared before `:id`. */
  @Get('preview')
  @ApiOkResponse({ type: PaymentPreviewDto })
  previewNew(@Query() q: NewMemberPreviewQueryDto): Promise<PaymentPreviewDto> {
    return this.members.previewNew(q);
  }

  @Post()
  @ApiCreatedResponse({ type: CreatedMemberDto })
  create(@CurrentUser() admin: AuthUser, @Body() dto: CreateMemberDto): Promise<CreatedMemberDto> {
    return this.members.create(admin.id, dto);
  }

  @Get()
  @ApiOkResponse({ type: MemberPageDto })
  list(@Query() q: ListMembersQueryDto) {
    return this.members.list(q);
  }

  @Get(':id')
  @ApiOkResponse({ type: MemberDetailDto })
  detail(@Param('id', Uuid()) id: string): Promise<MemberDetailDto> {
    return this.members.detail(id);
  }

  @Patch(':id')
  @ApiOkResponse({ type: MemberDetailDto })
  update(@Param('id', Uuid()) id: string, @Body() dto: UpdateMemberDto): Promise<MemberDetailDto> {
    return this.members.update(id, dto);
  }

  @Post(':id/deactivate')
  @HttpCode(HttpStatus.OK)
  @ApiOkResponse({ type: MemberDetailDto })
  deactivate(@Param('id', Uuid()) id: string): Promise<MemberDetailDto> {
    return this.members.deactivate(id);
  }

  @Post(':id/reactivate')
  @HttpCode(HttpStatus.OK)
  @ApiOkResponse({ type: MemberDetailDto })
  reactivate(@Param('id', Uuid()) id: string): Promise<MemberDetailDto> {
    return this.members.reactivate(id);
  }

  @Post(':id/reset-password')
  @HttpCode(HttpStatus.OK)
  @ApiOkResponse({ type: TemporaryPasswordDto })
  resetPassword(@Param('id', Uuid()) id: string): Promise<TemporaryPasswordDto> {
    return this.members.resetPassword(id);
  }

  @Get(':id/payments/preview')
  @ApiOkResponse({ type: PaymentPreviewDto })
  previewRenewal(
    @Param('id', Uuid()) id: string,
    @Query() q: PaymentPreviewQueryDto,
  ): Promise<PaymentPreviewDto> {
    return this.payments.previewRenewal(id, q);
  }

  @Post(':id/payments')
  @ApiCreatedResponse({ type: PaymentResultDto })
  createPayment(
    @CurrentUser() admin: AuthUser,
    @Param('id', Uuid()) id: string,
    @Body() dto: CreatePaymentDto,
  ): Promise<PaymentResultDto> {
    return this.payments.createRenewal(admin.id, id, dto);
  }

  @Post(':id/tier-change/preview')
  @HttpCode(HttpStatus.OK)
  @ApiOkResponse({ type: TierChangePreviewResultDto })
  previewTierChange(
    @Param('id', Uuid()) id: string,
    @Body() dto: TierChangePreviewDto,
  ): Promise<TierChangePreviewResultDto> {
    return this.payments.previewTierChange(id, dto.toTier);
  }

  @Post(':id/tier-change')
  @HttpCode(HttpStatus.OK)
  @ApiOkResponse({ type: TierChangeResultDto })
  changeTier(
    @CurrentUser() admin: AuthUser,
    @Param('id', Uuid()) id: string,
    @Body() dto: TierChangeDto,
  ): Promise<TierChangeResultDto> {
    return this.payments.applyTierChange(admin.id, id, dto);
  }
}

@ApiTags('admin / payments')
@ApiBearerAuth()
@Roles(Role.ADMIN)
@Controller('admin/payments')
export class AdminPaymentsController {
  constructor(private readonly payments: PaymentsService) {}

  @Get()
  @ApiOkResponse({ type: PaymentPageDto })
  list(@Query() q: ListPaymentsQueryDto) {
    return this.payments.list(q);
  }

  /** [R-12] */
  @Post(':id/void')
  @HttpCode(HttpStatus.OK)
  @ApiOkResponse({ type: PaymentResultDto })
  void(
    @CurrentUser() admin: AuthUser,
    @Param('id', Uuid()) id: string,
    @Body() dto: VoidPaymentDto,
  ): Promise<PaymentResultDto> {
    return this.payments.voidPayment(admin.id, id, dto);
  }
}

@ApiTags('me')
@ApiBearerAuth()
@Roles(Role.MEMBER)
@Controller('me')
export class MyMembershipController {
  constructor(
    private readonly memberships: MembershipsService,
    private readonly prisma: PrismaService,
    private readonly clock: ClockService,
  ) {}

  @Get('membership')
  @ApiOkResponse({ type: MyMembershipDto })
  async membership(@CurrentUser() user: AuthUser): Promise<MyMembershipDto> {
    const m = await this.memberships.getCurrentByMember(user.id);
    if (!m) throw new AppException(HttpStatus.NOT_FOUND, ErrorCode.NO_MEMBERSHIP);
    const trainer = m.trainerId
      ? await this.prisma.user.findUnique({
          where: { id: m.trainerId },
          select: { id: true, firstName: true, lastName: true, phone: true },
        })
      : null;
    return { ...toMembershipSummary(m, this.clock.today()), trainer };
  }

  /** Own history: no notes, no voided payments (section 8.3). */
  @Get('payments')
  async payments(
    @CurrentUser() user: AuthUser,
    @Query() q: PaginationQueryDto,
  ): Promise<Paginated<MyPaymentDto>> {
    const where = { voidedAt: null, membership: { memberId: user.id } };
    const [items, total] = await this.prisma.$transaction([
      this.prisma.payment.findMany({ where, orderBy: { paidAt: 'desc' }, ...skipTake(q) }),
      this.prisma.payment.count({ where }),
    ]);
    return paginated(items.map(toMyPaymentDto), total, q);
  }
}
