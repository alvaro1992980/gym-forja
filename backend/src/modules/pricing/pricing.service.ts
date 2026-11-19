import { HttpStatus, Injectable } from '@nestjs/common';
import { Prisma, Tier } from '@prisma/client';
import { AppException } from '../../common/errors/app.exception';
import { ErrorCode } from '../../common/errors/error-codes';
import { PrismaService } from '../../prisma/prisma.service';
import { Decimal, DEFAULT_CURRENCY, money } from '../memberships/membership-rules';

type Db = PrismaService | Prisma.TransactionClient;

export interface TierPriceView {
  tier: Tier;
  monthlyPrice: Decimal;
  currency: string;
}

/** [R-11] Tier prices. Payments store their own amounts, so price changes never touch them. */
@Injectable()
export class PricingService {
  constructor(private readonly prisma: PrismaService) {}

  async getAll(db: Db = this.prisma): Promise<Record<Tier, TierPriceView>> {
    const rows = await db.tierPrice.findMany();
    const byTier = new Map(rows.map((r) => [r.tier, r]));
    const result = {} as Record<Tier, TierPriceView>;
    for (const tier of Object.values(Tier)) {
      const row = byTier.get(tier);
      if (!row) {
        // Seed creates all three; a missing row is a deployment error.
        throw new AppException(
          HttpStatus.INTERNAL_SERVER_ERROR,
          ErrorCode.INTERNAL_ERROR,
          `Falta el precio del plan ${tier}. Ejecuta el seed.`,
        );
      }
      result[tier] = { tier, monthlyPrice: money(row.monthlyPrice), currency: row.currency };
    }
    return result;
  }

  async get(tier: Tier, db: Db = this.prisma): Promise<TierPriceView> {
    return (await this.getAll(db))[tier];
  }

  async update(
    prices: { tier: Tier; monthlyPrice: number }[],
  ): Promise<Record<Tier, TierPriceView>> {
    await this.prisma.$transaction(
      prices.map((p) =>
        this.prisma.tierPrice.upsert({
          where: { tier: p.tier },
          update: { monthlyPrice: money(p.monthlyPrice) },
          create: { tier: p.tier, monthlyPrice: money(p.monthlyPrice), currency: DEFAULT_CURRENCY },
        }),
      ),
    );
    return this.getAll();
  }
}
