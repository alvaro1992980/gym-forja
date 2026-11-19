import { Body, Controller, Get, Injectable, Put } from '@nestjs/common';
import {
  ApiBearerAuth,
  ApiOkResponse,
  ApiProperty,
  ApiPropertyOptional,
  ApiTags,
} from '@nestjs/swagger';
import { GymSettings, Role } from '@prisma/client';
import { Type } from 'class-transformer';
import {
  IsInt,
  IsNotEmpty,
  IsOptional,
  IsString,
  Matches,
  Max,
  MaxLength,
  Min,
} from 'class-validator';
import { Roles } from '../../common/auth/decorators';
import { TrimToUndefined } from '../../common/validation/decorators';
import { AppConfigService } from '../../config/app-config.service';
import { PrismaService } from '../../prisma/prisma.service';

export class GymSettingsDto {
  @ApiProperty() gymName: string;
  @ApiProperty({ description: 'Read-only: comes from GYM_TIMEZONE' }) timezone: string;
  @ApiProperty() checkinCooldownMinutes: number;
  @ApiProperty() insideWindowMinutes: number;
  @ApiProperty({ example: '+591' }) defaultCountryCode: string;
}

export class UpdateGymSettingsDto {
  @ApiPropertyOptional()
  @IsOptional()
  @TrimToUndefined()
  @IsString()
  @IsNotEmpty()
  @MaxLength(80)
  gymName?: string;

  @ApiPropertyOptional({ minimum: 1, maximum: 1440 })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  @Max(1440)
  checkinCooldownMinutes?: number;

  @ApiPropertyOptional({ minimum: 1, maximum: 1440 })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  @Max(1440)
  insideWindowMinutes?: number;

  @ApiPropertyOptional({ example: '+591' })
  @IsOptional()
  @Matches(/^\+[1-9]\d{0,3}$/, { message: 'defaultCountryCode must look like +591' })
  defaultCountryCode?: string;
}

@Injectable()
export class SettingsService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly config: AppConfigService,
  ) {}

  /** The single settings row (created with defaults if the seed has not run). */
  async get(): Promise<GymSettings> {
    return this.prisma.gymSettings.upsert({
      where: { id: 1 },
      update: {},
      create: { id: 1, timezone: this.config.gymTimezone },
    });
  }

  async update(dto: UpdateGymSettingsDto): Promise<GymSettings> {
    await this.get();
    return this.prisma.gymSettings.update({ where: { id: 1 }, data: dto });
  }

  toDto(s: GymSettings): GymSettingsDto {
    return {
      gymName: s.gymName,
      // The effective timezone is the env value (docs/DECISIONS.md).
      timezone: this.config.gymTimezone,
      checkinCooldownMinutes: s.checkinCooldownMinutes,
      insideWindowMinutes: s.insideWindowMinutes,
      defaultCountryCode: s.defaultCountryCode,
    };
  }
}

@ApiTags('admin / settings')
@ApiBearerAuth()
@Roles(Role.ADMIN)
@Controller('admin/settings')
export class SettingsController {
  constructor(private readonly settings: SettingsService) {}

  @Get()
  @ApiOkResponse({ type: GymSettingsDto })
  async get(): Promise<GymSettingsDto> {
    return this.settings.toDto(await this.settings.get());
  }

  @Put()
  @ApiOkResponse({ type: GymSettingsDto })
  async update(@Body() dto: UpdateGymSettingsDto): Promise<GymSettingsDto> {
    return this.settings.toDto(await this.settings.update(dto));
  }
}
