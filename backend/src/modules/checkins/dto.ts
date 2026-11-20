import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { CheckinResult, Tier } from '@prisma/client';
import { IsEnum, IsNotEmpty, IsOptional, IsString, IsUUID, MaxLength } from 'class-validator';
import { PaginationQueryDto } from '../../common/pagination/pagination';
import { IsLocalDateString } from '../../common/validation/decorators';
import { PersonRefDto } from '../memberships/dto';

// ---------------------------------------------------------------- inputs

export class CheckinDto {
  @ApiProperty({ description: 'Token read from the kiosk QR' })
  @IsString()
  @IsNotEmpty()
  @MaxLength(2048)
  qrToken: string;
}

export class DateRangeQueryDto extends PaginationQueryDto {
  @ApiPropertyOptional({ example: '2026-11-01', description: 'From this gym date (inclusive)' })
  @IsOptional()
  @IsLocalDateString()
  from?: string;

  @ApiPropertyOptional({ example: '2026-11-30', description: 'Up to this gym date (inclusive)' })
  @IsOptional()
  @IsLocalDateString()
  to?: string;
}

export class ListCheckinsQueryDto extends DateRangeQueryDto {
  @ApiPropertyOptional()
  @IsOptional()
  @IsUUID()
  memberId?: string;
}

export const DENIED_RESULTS = [
  CheckinResult.DENIED_EXPIRED,
  CheckinResult.DENIED_INACTIVE,
  CheckinResult.INVALID_TOKEN,
] as const;

export class ListAttemptsQueryDto extends ListCheckinsQueryDto {
  @ApiPropertyOptional({
    enum: CheckinResult,
    description: 'Default: denied and invalid attempts (not SUCCESS / DUPLICATE)',
  })
  @IsOptional()
  @IsEnum(CheckinResult)
  result?: CheckinResult;
}

// ---------------------------------------------------------------- outputs

export class QrTokenDto {
  @ApiProperty() token: string;
  @ApiProperty() expiresAt: Date;
  @ApiProperty({ example: 30 }) refreshInSeconds: number;
  @ApiProperty({ example: 'Mi Gimnasio', description: 'Shown on the kiosk screen.' })
  gymName: string;
}

export class CheckinMembershipDto {
  @ApiProperty({ enum: Tier }) tier: Tier;
  @ApiProperty({ example: '2026-12-14' }) endDate: string;
  @ApiProperty() daysLeft: number;
}

export class CheckinResponseDto {
  @ApiProperty({ enum: ['SUCCESS', 'DUPLICATE'] }) result: 'SUCCESS' | 'DUPLICATE';
  @ApiProperty() duplicate: boolean;
  @ApiProperty({ description: 'The check-in created now, or the earlier one [R-19]' })
  checkinId: string;
  @ApiProperty({ description: 'When the member checked in (the earlier time on duplicates)' })
  checkedInAt: Date;
  @ApiProperty({ example: { firstName: 'Juan' } }) member: { firstName: string };
  @ApiProperty({ type: CheckinMembershipDto }) membership: CheckinMembershipDto;
  @ApiPropertyOptional({
    nullable: true,
    type: Object,
    description: "Today's workout (D11/D12); null for BASIC or without a plan",
  })
  todayWorkout: null;
}

export class CheckinItemDto {
  @ApiProperty() id: string;
  @ApiProperty({ type: PersonRefDto }) member: PersonRefDto;
  @ApiProperty({ enum: Tier }) tier: Tier;
  @ApiProperty() daysLeft: number;
  @ApiProperty() kioskId: string;
  @ApiProperty() createdAt: Date;
}

export class CheckinPageDto {
  @ApiProperty({ type: [CheckinItemDto] }) items: CheckinItemDto[];
  @ApiProperty() page: number;
  @ApiProperty() pageSize: number;
  @ApiProperty() total: number;
}

export class InsideNowDto {
  @ApiProperty() count: number;
  @ApiProperty({ description: '[R-23] Window used, in minutes' }) windowMinutes: number;
  @ApiProperty({ type: [CheckinItemDto], description: 'Latest check-in of each member' })
  items: CheckinItemDto[];
}

export class AttemptItemDto {
  @ApiProperty() id: string;
  @ApiProperty({ enum: CheckinResult }) result: CheckinResult;
  @ApiPropertyOptional({ type: PersonRefDto, nullable: true }) member: PersonRefDto | null;
  @ApiPropertyOptional({ nullable: true, type: String }) kioskId: string | null;
  @ApiPropertyOptional({ nullable: true, type: String }) detail: string | null;
  @ApiProperty() createdAt: Date;
}

export class AttemptPageDto {
  @ApiProperty({ type: [AttemptItemDto] }) items: AttemptItemDto[];
  @ApiProperty() page: number;
  @ApiProperty() pageSize: number;
  @ApiProperty() total: number;
}

export class MyCheckinDto {
  @ApiProperty() id: string;
  @ApiProperty({ enum: Tier }) tier: Tier;
  @ApiProperty() createdAt: Date;
}

export class MyCheckinPageDto {
  @ApiProperty({ type: [MyCheckinDto] }) items: MyCheckinDto[];
  @ApiProperty() page: number;
  @ApiProperty() pageSize: number;
  @ApiProperty() total: number;
}
