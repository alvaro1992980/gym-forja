import { Body, Controller, Get, Put } from '@nestjs/common';
import { ApiBearerAuth, ApiOkResponse, ApiProperty, ApiTags } from '@nestjs/swagger';
import { Role, Tier } from '@prisma/client';
import { Type } from 'class-transformer';
import { ArrayMaxSize, ArrayMinSize, IsArray, IsEnum, Min, ValidateNested } from 'class-validator';
import { Roles } from '../../common/auth/decorators';
import { IsMoney } from '../../common/validation/decorators';
import { formatMoney } from '../memberships/membership-rules';
import { PricingService, TierPriceView } from './pricing.service';

export class TierPriceDto {
  @ApiProperty({ enum: Tier }) tier: Tier;
  @ApiProperty({ example: '150.00' }) monthlyPrice: string;
  @ApiProperty({ example: 'BOB' }) currency: string;
}

export class TierPriceInput {
  @ApiProperty({ enum: Tier })
  @IsEnum(Tier)
  tier: Tier;

  @ApiProperty({ example: 150 })
  @IsMoney()
  @Min(0.01)
  monthlyPrice: number;
}

export class UpdatePricingDto {
  @ApiProperty({ type: [TierPriceInput] })
  @IsArray()
  @ArrayMinSize(1)
  @ArrayMaxSize(3)
  @ValidateNested({ each: true })
  @Type(() => TierPriceInput)
  prices: TierPriceInput[];
}

function toDtos(prices: Record<Tier, TierPriceView>): TierPriceDto[] {
  return Object.values(Tier).map((tier) => ({
    tier,
    monthlyPrice: formatMoney(prices[tier].monthlyPrice),
    currency: prices[tier].currency,
  }));
}

@ApiTags('admin / pricing')
@ApiBearerAuth()
@Roles(Role.ADMIN)
@Controller('admin/pricing')
export class PricingController {
  constructor(private readonly pricing: PricingService) {}

  @Get()
  @ApiOkResponse({ type: [TierPriceDto] })
  async get(): Promise<TierPriceDto[]> {
    return toDtos(await this.pricing.getAll());
  }

  /** [R-11] Only future payments use the new prices. */
  @Put()
  @ApiOkResponse({ type: [TierPriceDto] })
  async update(@Body() dto: UpdatePricingDto): Promise<TierPriceDto[]> {
    const unique = new Map(dto.prices.map((p) => [p.tier, p]));
    return toDtos(await this.pricing.update([...unique.values()]));
  }
}
