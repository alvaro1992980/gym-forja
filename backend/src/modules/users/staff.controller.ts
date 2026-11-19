import {
  Body,
  Controller,
  Get,
  HttpCode,
  HttpStatus,
  Param,
  ParseUUIDPipe,
  Post,
  Query,
} from '@nestjs/common';
import { ApiBearerAuth, ApiCreatedResponse, ApiOkResponse, ApiTags } from '@nestjs/swagger';
import { Prisma, Role, User } from '@prisma/client';
import { Roles } from '../../common/auth/decorators';
import { AppException } from '../../common/errors/app.exception';
import { ErrorCode } from '../../common/errors/error-codes';
import { paginated, Paginated, skipTake } from '../../common/pagination/pagination';
import { PrismaService } from '../../prisma/prisma.service';
import {
  CreatedStaffDto,
  CreateStaffDto,
  ListStaffQueryDto,
  STAFF_ROLES,
  StaffDto,
  StaffPageDto,
} from './staff.dto';
import { UsersService } from './users.service';

function toStaffDto(u: User): StaffDto {
  return {
    id: u.id,
    role: u.role,
    firstName: u.firstName,
    lastName: u.lastName,
    phone: u.phone,
    email: u.email,
    isActive: u.isActive,
    mustChangePassword: u.mustChangePassword,
    createdAt: u.createdAt,
  };
}

/** Staff accounts: ADMIN, TRAINER, KIOSK (section 8.2). ADMIN only. */
@ApiTags('admin / staff')
@ApiBearerAuth()
@Roles(Role.ADMIN)
@Controller('admin/staff')
export class StaffController {
  constructor(
    private readonly users: UsersService,
    private readonly prisma: PrismaService,
  ) {}

  @Post()
  @ApiCreatedResponse({ type: CreatedStaffDto })
  async create(@Body() dto: CreateStaffDto): Promise<CreatedStaffDto> {
    const { user, temporaryPassword } = await this.users.createWithTemporaryPassword({
      role: dto.role,
      firstName: dto.firstName,
      lastName: dto.lastName,
      phone: dto.phone,
      email: dto.email,
    });
    return { ...toStaffDto(user), temporaryPassword };
  }

  @Get()
  @ApiOkResponse({ type: StaffPageDto })
  async list(@Query() q: ListStaffQueryDto): Promise<Paginated<StaffDto>> {
    const where: Prisma.UserWhereInput = {
      role: q.role ?? { in: [...STAFF_ROLES] },
      ...(q.includeInactive ? {} : { isActive: true }),
    };
    const [items, total] = await this.prisma.$transaction([
      this.prisma.user.findMany({
        where,
        orderBy: [{ role: 'asc' }, { firstName: 'asc' }, { lastName: 'asc' }],
        ...skipTake(q),
      }),
      this.prisma.user.count({ where }),
    ]);
    return paginated(items.map(toStaffDto), total, q);
  }

  /** [R-43] [R-45] */
  @Post(':id/deactivate')
  @HttpCode(HttpStatus.OK)
  @ApiOkResponse({ type: StaffDto })
  async deactivate(@Param('id', ParseUUIDPipe) id: string): Promise<StaffDto> {
    await this.assertStaff(id);
    return toStaffDto(await this.users.deactivate(id));
  }

  @Post(':id/reactivate')
  @HttpCode(HttpStatus.OK)
  @ApiOkResponse({ type: StaffDto })
  async reactivate(@Param('id', ParseUUIDPipe) id: string): Promise<StaffDto> {
    await this.assertStaff(id);
    return toStaffDto(await this.users.reactivate(id));
  }

  private async assertStaff(id: string): Promise<void> {
    const user = await this.prisma.user.findUnique({ where: { id }, select: { role: true } });
    if (!user || user.role === Role.MEMBER) {
      throw new AppException(HttpStatus.NOT_FOUND, ErrorCode.NOT_FOUND);
    }
  }
}
