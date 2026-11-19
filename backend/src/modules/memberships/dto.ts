import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { PaymentKind, PaymentMethod, Tier } from '@prisma/client';
import { Transform, Type } from 'class-transformer';
import {
  IsBoolean,
  IsEmail,
  IsEnum,
  IsIn,
  IsInt,
  IsNotEmpty,
  IsOptional,
  IsString,
  IsUUID,
  Max,
  MaxLength,
  Min,
  ValidateIf,
} from 'class-validator';
import { PaginationQueryDto } from '../../common/pagination/pagination';
import {
  IsLocalDateString,
  IsMoney,
  TrimKeepNull,
  TrimToUndefined,
} from '../../common/validation/decorators';
import { IsPhone } from '../../common/validation/phone.decorator';
import { MAX_MONTHS, MIN_MONTHS } from './membership-rules';

const NOTE_MAX = 500;

// ---------------------------------------------------------------- inputs

/** [R-06] Payment fields shared by new members and renewals. */
export class PaymentInputDto {
  @ApiProperty({ enum: Tier })
  @IsEnum(Tier)
  tier: Tier;

  @ApiProperty({ minimum: MIN_MONTHS, maximum: MAX_MONTHS, example: 1 })
  @Type(() => Number)
  @IsInt()
  @Min(MIN_MONTHS)
  @Max(MAX_MONTHS)
  months: number;

  @ApiProperty({
    example: 150,
    description: 'Paid amount (BOB); may differ from the suggestion [R-10]',
  })
  @IsMoney()
  amount: number;

  @ApiProperty({ enum: PaymentMethod })
  @IsEnum(PaymentMethod)
  method: PaymentMethod;

  @ApiPropertyOptional({ description: 'Required when amount ≠ suggested amount [R-10]' })
  @IsOptional()
  @TrimToUndefined()
  @IsString()
  @MaxLength(NOTE_MAX)
  note?: string;
}

export class CreatePaymentDto extends PaymentInputDto {
  @ApiPropertyOptional({
    default: false,
    description: '[R-09] Apply a different tier from today instead of from the new period',
  })
  @IsOptional()
  @IsBoolean()
  applyTierNow?: boolean;
}

export class CreateMemberDto extends PaymentInputDto {
  @ApiProperty()
  @TrimToUndefined()
  @IsString()
  @IsNotEmpty()
  @MaxLength(80)
  firstName: string;

  @ApiProperty()
  @TrimToUndefined()
  @IsString()
  @IsNotEmpty()
  @MaxLength(80)
  lastName: string;

  @IsPhone()
  phone: string;

  @ApiPropertyOptional()
  @IsOptional()
  @TrimToUndefined()
  @IsEmail()
  @MaxLength(200)
  email?: string;

  @ApiPropertyOptional({ example: '1990-05-01' })
  @IsOptional()
  @IsLocalDateString()
  birthDate?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @TrimToUndefined()
  @IsString()
  @MaxLength(30)
  gender?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @TrimToUndefined()
  @IsString()
  @MaxLength(200)
  emergencyContact?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @TrimToUndefined()
  @IsString()
  @MaxLength(2000)
  medicalNotes?: string;

  @ApiPropertyOptional({
    example: '2026-11-19',
    description: '[R-05] Default today; allowed today − 7 to today + 30 days',
  })
  @IsOptional()
  @IsLocalDateString()
  startDate?: string;
}

/** PATCH: profile only (not tier/dates). `null` clears an optional field. */
export class UpdateMemberDto {
  @ApiPropertyOptional()
  @IsOptional()
  @TrimToUndefined()
  @IsString()
  @IsNotEmpty()
  @MaxLength(80)
  firstName?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @TrimToUndefined()
  @IsString()
  @IsNotEmpty()
  @MaxLength(80)
  lastName?: string;

  @IsOptional()
  @IsPhone()
  phone?: string;

  @ApiPropertyOptional({ nullable: true, type: String })
  @IsOptional()
  @TrimKeepNull()
  @ValidateIf((_o, v) => v !== null)
  @IsEmail()
  @MaxLength(200)
  email?: string | null;

  @ApiPropertyOptional({ nullable: true, type: String, example: '1990-05-01' })
  @IsOptional()
  @ValidateIf((_o, v) => v !== null)
  @IsLocalDateString()
  birthDate?: string | null;

  @ApiPropertyOptional({ nullable: true, type: String })
  @IsOptional()
  @TrimKeepNull()
  @ValidateIf((_o, v) => v !== null)
  @IsString()
  @MaxLength(30)
  gender?: string | null;

  @ApiPropertyOptional({ nullable: true, type: String })
  @IsOptional()
  @TrimKeepNull()
  @ValidateIf((_o, v) => v !== null)
  @IsString()
  @MaxLength(200)
  emergencyContact?: string | null;

  @ApiPropertyOptional({ nullable: true, type: String })
  @IsOptional()
  @TrimKeepNull()
  @ValidateIf((_o, v) => v !== null)
  @IsString()
  @MaxLength(2000)
  medicalNotes?: string | null;
}

export class PaymentPreviewQueryDto {
  @ApiProperty({ enum: Tier })
  @IsEnum(Tier)
  tier: Tier;

  @ApiProperty({ minimum: MIN_MONTHS, maximum: MAX_MONTHS })
  @Type(() => Number)
  @IsInt()
  @Min(MIN_MONTHS)
  @Max(MAX_MONTHS)
  months: number;
}

export class NewMemberPreviewQueryDto extends PaymentPreviewQueryDto {
  @ApiPropertyOptional({ example: '2026-11-19' })
  @IsOptional()
  @IsLocalDateString()
  startDate?: string;
}

export class TierChangePreviewDto {
  @ApiProperty({ enum: Tier })
  @IsEnum(Tier)
  toTier: Tier;
}

export class TierChangeDto extends TierChangePreviewDto {
  @ApiPropertyOptional({
    example: 40,
    description: 'Upgrade: amount charged (suggestion from preview). Downgrade: omit or 0',
  })
  @IsOptional()
  @IsMoney()
  amount?: number;

  @ApiPropertyOptional({ enum: PaymentMethod, description: 'Required when amount > 0' })
  @IsOptional()
  @IsEnum(PaymentMethod)
  method?: PaymentMethod;

  @ApiPropertyOptional()
  @IsOptional()
  @TrimToUndefined()
  @IsString()
  @MaxLength(NOTE_MAX)
  note?: string;
}

export class VoidPaymentDto {
  @ApiProperty({ description: '[R-12] Required' })
  @TrimToUndefined()
  @IsString()
  @IsNotEmpty()
  @MaxLength(NOTE_MAX)
  reason: string;
}

export const MEMBER_STATUS_FILTERS = ['active', 'expiring', 'expired', 'inactive'] as const;
export type MemberStatusFilter = (typeof MEMBER_STATUS_FILTERS)[number];
export const MEMBER_SORTS = ['name', 'endDate', 'createdAt'] as const;

export class ListMembersQueryDto extends PaginationQueryDto {
  @ApiPropertyOptional({ description: 'Name or phone' })
  @IsOptional()
  @TrimToUndefined()
  @IsString()
  @MaxLength(100)
  q?: string;

  @ApiPropertyOptional({ enum: Tier })
  @IsOptional()
  @IsEnum(Tier)
  tier?: Tier;

  @ApiPropertyOptional({ enum: MEMBER_STATUS_FILTERS })
  @IsOptional()
  @IsIn(MEMBER_STATUS_FILTERS)
  status?: MemberStatusFilter;

  @ApiPropertyOptional({
    minimum: 1,
    maximum: 90,
    description: 'Active members with 1..N days left (default 7 for status=expiring)',
  })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  @Max(90)
  expiringWithinDays?: number;

  @ApiPropertyOptional()
  @IsOptional()
  @IsUUID()
  trainerId?: string;

  @ApiPropertyOptional({ enum: MEMBER_SORTS, default: 'name' })
  @IsOptional()
  @IsIn(MEMBER_SORTS)
  sort: (typeof MEMBER_SORTS)[number] = 'name';
}

export class ListPaymentsQueryDto extends PaginationQueryDto {
  @ApiPropertyOptional({ example: '2026-11-01', description: 'Paid on or after (gym date)' })
  @IsOptional()
  @IsLocalDateString()
  from?: string;

  @ApiPropertyOptional({ example: '2026-11-30', description: 'Paid on or before (gym date)' })
  @IsOptional()
  @IsLocalDateString()
  to?: string;

  @ApiPropertyOptional({ enum: PaymentMethod })
  @IsOptional()
  @IsEnum(PaymentMethod)
  method?: PaymentMethod;

  @ApiPropertyOptional()
  @IsOptional()
  @IsUUID()
  memberId?: string;

  @ApiPropertyOptional({ default: true, description: 'Include voided payments in items' })
  @IsOptional()
  @Transform(({ value }: { value: unknown }) => !(value === false || value === 'false'))
  @IsBoolean()
  includeVoided: boolean = true;
}

// ---------------------------------------------------------------- outputs

export class PersonRefDto {
  @ApiProperty() id: string;
  @ApiProperty() firstName: string;
  @ApiProperty() lastName: string;
}

export class MembershipDto {
  @ApiProperty({ enum: Tier }) tier: Tier;
  @ApiProperty({ example: '2026-11-19' }) startDate: string;
  @ApiProperty({ example: '2026-12-18' }) endDate: string;
  @ApiProperty() daysLeft: number;
  @ApiProperty({ enum: ['active', 'expired'] }) status: 'active' | 'expired';
  @ApiPropertyOptional({ enum: Tier, nullable: true }) nextTier: Tier | null;
  @ApiPropertyOptional({ nullable: true, type: String }) nextTierStartDate: string | null;
}

export class PaymentDto {
  @ApiProperty() id: string;
  @ApiProperty() memberId: string;
  @ApiProperty({ enum: PaymentKind }) kind: PaymentKind;
  @ApiProperty({ enum: Tier }) tier: Tier;
  @ApiProperty() months: number;
  @ApiPropertyOptional({ nullable: true, type: String }) periodStart: string | null;
  @ApiPropertyOptional({ nullable: true, type: String }) periodEnd: string | null;
  @ApiProperty({ example: '150.00' }) amount: string;
  @ApiProperty({ example: '150.00' }) suggestedAmount: string;
  @ApiProperty({ example: 'BOB' }) currency: string;
  @ApiProperty({ enum: PaymentMethod }) method: PaymentMethod;
  @ApiPropertyOptional({ nullable: true, type: String }) note: string | null;
  @ApiProperty({ type: PersonRefDto }) recordedBy: PersonRefDto;
  @ApiProperty() paidAt: Date;
  @ApiPropertyOptional({ nullable: true, type: Date }) voidedAt: Date | null;
  @ApiPropertyOptional({ nullable: true, type: String }) voidedById: string | null;
  @ApiPropertyOptional({ nullable: true, type: String }) voidReason: string | null;
}

export class PaymentPreviewDto {
  @ApiProperty({ example: '2026-12-15' }) periodStart: string;
  @ApiProperty({ example: '2027-01-14' }) periodEnd: string;
  @ApiProperty({ example: '250.00' }) suggestedAmount: string;
  @ApiProperty({ example: 'BOB' }) currency: string;
  @ApiProperty({ description: 'When the tier of this payment applies [R-09]' })
  tierApplies: 'unchanged' | 'now' | 'scheduled';
}

export class PaymentResultDto {
  @ApiProperty({ type: PaymentDto }) payment: PaymentDto;
  @ApiProperty({ type: MembershipDto }) membership: MembershipDto;
}

export class TierChangePreviewResultDto {
  @ApiProperty({ enum: Tier }) fromTier: Tier;
  @ApiProperty({ enum: Tier }) toTier: Tier;
  @ApiProperty() isUpgrade: boolean;
  @ApiProperty() daysLeft: number;
  @ApiProperty({ example: '40.00' }) suggestedAmount: string;
  @ApiProperty({ example: 'BOB' }) currency: string;
  @ApiPropertyOptional({ nullable: true, type: String }) warning: string | null;
}

export class TierChangeResultDto {
  @ApiProperty({ type: MembershipDto }) membership: MembershipDto;
  @ApiPropertyOptional({ type: PaymentDto, nullable: true }) payment: PaymentDto | null;
}

export class CheckinRefDto {
  @ApiProperty() id: string;
  @ApiProperty() createdAt: Date;
  @ApiProperty({ enum: Tier }) tier: Tier;
  @ApiProperty() daysLeft: number;
}

export class MemberListItemDto {
  @ApiProperty() id: string;
  @ApiProperty() firstName: string;
  @ApiProperty() lastName: string;
  @ApiProperty() phone: string;
  @ApiProperty() isActive: boolean;
  @ApiProperty({ enum: Tier }) tier: Tier;
  @ApiProperty() endDate: string;
  @ApiProperty() daysLeft: number;
  @ApiProperty({ enum: ['active', 'expired', 'inactive'] }) status:
    'active' | 'expired' | 'inactive';
  @ApiPropertyOptional({ nullable: true, type: String }) trainerId: string | null;
  @ApiPropertyOptional({ nullable: true, type: Date }) lastCheckinAt: Date | null;
}

export class MemberPageDto {
  @ApiProperty({ type: [MemberListItemDto] }) items: MemberListItemDto[];
  @ApiProperty() page: number;
  @ApiProperty() pageSize: number;
  @ApiProperty() total: number;
}

export class MemberDetailDto {
  @ApiProperty() id: string;
  @ApiProperty() firstName: string;
  @ApiProperty() lastName: string;
  @ApiProperty() phone: string;
  @ApiPropertyOptional({ nullable: true, type: String }) email: string | null;
  @ApiPropertyOptional({ nullable: true, type: String }) birthDate: string | null;
  @ApiPropertyOptional({ nullable: true, type: String }) gender: string | null;
  @ApiPropertyOptional({ nullable: true, type: String }) emergencyContact: string | null;
  @ApiPropertyOptional({ nullable: true, type: String }) medicalNotes: string | null;
  @ApiProperty() isActive: boolean;
  @ApiProperty() mustChangePassword: boolean;
  @ApiProperty() createdAt: Date;
  @ApiProperty({ type: MembershipDto }) membership: MembershipDto;
  @ApiPropertyOptional({ type: PersonRefDto, nullable: true }) trainer: PersonRefDto | null;
  @ApiProperty({ type: [CheckinRefDto] }) recentCheckins: CheckinRefDto[];
  @ApiProperty({ type: [PaymentDto] }) payments: PaymentDto[];
  @ApiPropertyOptional({
    nullable: true,
    type: Object,
    description: 'Training plan assignment (D11)',
  })
  assignment: null;
}

export class CreatedMemberDto extends MemberDetailDto {
  @ApiProperty({ description: '[R-41] Shown only once' }) temporaryPassword: string;
}

export class TemporaryPasswordDto {
  @ApiProperty({ description: '[R-44] Shown only once' }) temporaryPassword: string;
}

export class PaymentTotalsDto {
  @ApiProperty() count: number;
  @ApiProperty({ example: '1500.00' }) amount: string;
  @ApiProperty({ example: 'BOB' }) currency: string;
}

export class PaymentPageDto {
  @ApiProperty({ type: [PaymentDto] }) items: PaymentDto[];
  @ApiProperty() page: number;
  @ApiProperty() pageSize: number;
  @ApiProperty() total: number;
  @ApiProperty({ type: PaymentTotalsDto, description: 'Non-voided payments matching the filters' })
  totals: PaymentTotalsDto;
}

export class MyPaymentDto {
  @ApiProperty() id: string;
  @ApiProperty({ enum: PaymentKind }) kind: PaymentKind;
  @ApiProperty({ enum: Tier }) tier: Tier;
  @ApiProperty() months: number;
  @ApiPropertyOptional({ nullable: true, type: String }) periodStart: string | null;
  @ApiPropertyOptional({ nullable: true, type: String }) periodEnd: string | null;
  @ApiProperty({ example: '150.00' }) amount: string;
  @ApiProperty() currency: string;
  @ApiProperty({ enum: PaymentMethod }) method: PaymentMethod;
  @ApiProperty() paidAt: Date;
}

export class MyMembershipDto extends MembershipDto {
  @ApiPropertyOptional({ nullable: true, type: PersonRefDto }) trainer:
    (PersonRefDto & { phone: string }) | null;
}
