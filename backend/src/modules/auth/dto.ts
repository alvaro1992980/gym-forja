import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { Role } from '@prisma/client';
import { IsNotEmpty, IsOptional, IsString, MaxLength, MinLength } from 'class-validator';
import { PASSWORD_MIN_LENGTH } from '../../common/security/password';
import { IsPhone } from '../../common/validation/phone.decorator';

export class LoginDto {
  @IsPhone()
  phone: string;

  @ApiProperty()
  @IsString()
  @IsNotEmpty()
  @MaxLength(200)
  password: string;
}

export class RefreshDto {
  @ApiProperty()
  @IsString()
  @IsNotEmpty()
  @MaxLength(200)
  refreshToken: string;
}

export class LogoutDto extends RefreshDto {
  @ApiPropertyOptional({ description: 'Also unregisters this device from push notifications' })
  @IsOptional()
  @IsString()
  @MaxLength(4096)
  fcmToken?: string;
}

export class ChangePasswordDto {
  @ApiProperty()
  @IsString()
  @IsNotEmpty()
  @MaxLength(200)
  currentPassword: string;

  @ApiProperty({ minLength: PASSWORD_MIN_LENGTH, description: '[R-42] at least 8 characters' })
  @IsString()
  @MinLength(PASSWORD_MIN_LENGTH)
  @MaxLength(200)
  newPassword: string;
}

export class SessionUserDto {
  @ApiProperty() id: string;
  @ApiProperty({ enum: Role }) role: Role;
  @ApiProperty() firstName: string;
  @ApiProperty() lastName: string;
  @ApiProperty() mustChangePassword: boolean;
}

export class AuthResponseDto {
  @ApiProperty() accessToken: string;
  @ApiProperty() refreshToken: string;
  @ApiProperty({ type: SessionUserDto }) user: SessionUserDto;
}

export const MEMBERSHIP_STATUSES = ['active', 'expired'] as const;

export class MembershipSummaryDto {
  @ApiProperty({ enum: ['BASIC', 'PLUS', 'PREMIUM'] }) tier: string;
  @ApiProperty({ example: '2026-11-19' }) startDate: string;
  @ApiProperty({ example: '2026-12-18' }) endDate: string;
  @ApiProperty() daysLeft: number;
  @ApiProperty({ enum: MEMBERSHIP_STATUSES }) status: (typeof MEMBERSHIP_STATUSES)[number];
}

export class MeResponseDto {
  @ApiProperty() id: string;
  @ApiProperty({ enum: Role }) role: Role;
  @ApiProperty() firstName: string;
  @ApiProperty() lastName: string;
  @ApiProperty() phone: string;
  @ApiPropertyOptional({ nullable: true, type: String }) email: string | null;
  @ApiProperty() mustChangePassword: boolean;
  @ApiPropertyOptional({ nullable: true, type: String, example: '1990-05-01' })
  birthDate: string | null;
  @ApiPropertyOptional({ nullable: true, type: String }) gender: string | null;
  @ApiPropertyOptional({ nullable: true, type: String }) emergencyContact: string | null;
  @ApiPropertyOptional({ nullable: true, type: MembershipSummaryDto, description: 'MEMBER only' })
  membership: MembershipSummaryDto | null;
}
