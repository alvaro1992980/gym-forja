import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { Role } from '@prisma/client';
import { Transform, Type } from 'class-transformer';
import {
  IsBoolean,
  IsEmail,
  IsIn,
  IsNotEmpty,
  IsOptional,
  IsString,
  MaxLength,
} from 'class-validator';
import { PaginationQueryDto } from '../../common/pagination/pagination';
import { IsPhone } from '../../common/validation/phone.decorator';

export const STAFF_ROLES = [Role.ADMIN, Role.TRAINER, Role.KIOSK] as const;
export type StaffRole = (typeof STAFF_ROLES)[number];

const trim = ({ value }: { value: unknown }) => (typeof value === 'string' ? value.trim() : value);

export class CreateStaffDto {
  @ApiProperty({ enum: STAFF_ROLES })
  @IsIn(STAFF_ROLES)
  role: StaffRole;

  @ApiProperty()
  @Transform(trim)
  @IsString()
  @IsNotEmpty()
  @MaxLength(80)
  firstName: string;

  @ApiProperty()
  @Transform(trim)
  @IsString()
  @IsNotEmpty()
  @MaxLength(80)
  lastName: string;

  @IsPhone()
  phone: string;

  @ApiPropertyOptional()
  @IsOptional()
  @Transform(trim)
  @IsEmail()
  @MaxLength(200)
  email?: string;
}

export class ListStaffQueryDto extends PaginationQueryDto {
  @ApiPropertyOptional({ enum: STAFF_ROLES })
  @IsOptional()
  @IsIn(STAFF_ROLES)
  role?: StaffRole;

  @ApiPropertyOptional({ default: false, description: 'Include deactivated accounts' })
  @IsOptional()
  @Transform(({ value }: { value: unknown }) => value === true || value === 'true')
  @Type(() => Boolean)
  @IsBoolean()
  includeInactive: boolean = false;
}

export class StaffDto {
  @ApiProperty() id: string;
  @ApiProperty({ enum: STAFF_ROLES }) role: Role;
  @ApiProperty() firstName: string;
  @ApiProperty() lastName: string;
  @ApiProperty() phone: string;
  @ApiPropertyOptional({ nullable: true, type: String }) email: string | null;
  @ApiProperty() isActive: boolean;
  @ApiProperty() mustChangePassword: boolean;
  @ApiProperty() createdAt: Date;
}

export class CreatedStaffDto extends StaffDto {
  @ApiProperty({ description: '[R-41] Shown only once' })
  temporaryPassword: string;
}

export class StaffPageDto {
  @ApiProperty({ type: [StaffDto] }) items: StaffDto[];
  @ApiProperty() page: number;
  @ApiProperty() pageSize: number;
  @ApiProperty() total: number;
}
