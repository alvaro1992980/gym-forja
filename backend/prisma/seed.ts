/**
 * Base data (docs/PLAN.md D1). Idempotent: safe to run many times.
 *  - GymSettings (single row, id = 1)
 *  - TierPrice for BASIC/PLUS/PREMIUM: placeholders (150/250/400 BOB) the owner will change.
 *    Existing prices are never overwritten.
 *  - The first ADMIN from SEED_ADMIN_* (skipped if the phone already exists).
 *    Created with mustChangePassword = true.
 *
 * Run: npx prisma db seed
 */
import 'dotenv/config';
import { PrismaClient, Role, Tier } from '@prisma/client';
import * as argon2 from 'argon2';

const PLACEHOLDER_PRICES: Record<Tier, string> = {
  BASIC: '150.00',
  PLUS: '250.00',
  PREMIUM: '400.00',
};

const NORMALIZED_PHONE_RE = /^\+\d{8,15}$/;

function requireEnv(name: string): string {
  const value = process.env[name]?.trim();
  if (!value) throw new Error(`Missing environment variable ${name} (see backend/.env.example)`);
  return value;
}

async function main(): Promise<void> {
  const prisma = new PrismaClient();
  try {
    await prisma.gymSettings.upsert({
      where: { id: 1 },
      update: {},
      create: { id: 1, timezone: process.env.GYM_TIMEZONE?.trim() || 'America/La_Paz' },
    });
    console.log('GymSettings: ok');

    for (const tier of Object.values(Tier)) {
      await prisma.tierPrice.upsert({
        where: { tier },
        update: {},
        create: { tier, monthlyPrice: PLACEHOLDER_PRICES[tier], currency: 'BOB' },
      });
    }
    console.log('TierPrice: ok (existing prices left unchanged)');

    const phone = requireEnv('SEED_ADMIN_PHONE');
    const password = requireEnv('SEED_ADMIN_PASSWORD');
    if (!NORMALIZED_PHONE_RE.test(phone)) {
      throw new Error(
        'SEED_ADMIN_PHONE must be normalized: "+" and 8-15 digits, e.g. +59170000000',
      );
    }
    if (password.length < 8) {
      throw new Error('SEED_ADMIN_PASSWORD must have at least 8 characters [R-42]');
    }

    const existing = await prisma.user.findUnique({ where: { phone } });
    if (existing) {
      console.log(`Admin ${phone}: already exists, left unchanged`);
      return;
    }
    await prisma.user.create({
      data: {
        role: Role.ADMIN,
        firstName: process.env.SEED_ADMIN_FIRST_NAME?.trim() || 'Admin',
        lastName: process.env.SEED_ADMIN_LAST_NAME?.trim() || 'Gym',
        phone,
        passwordHash: await argon2.hash(password, { type: argon2.argon2id }),
        mustChangePassword: true,
      },
    });
    console.log(`Admin ${phone}: created (must change password on first login)`);
  } finally {
    await prisma.$disconnect();
  }
}

main().catch((error: unknown) => {
  console.error(error instanceof Error ? error.message : error);
  process.exit(1);
});
