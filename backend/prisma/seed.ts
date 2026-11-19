/**
 * Base data (docs/PLAN.md D1). Idempotent: safe to run many times.
 *  - GymSettings (single row, id = 1)
 *  - TierPrice for BASIC/PLUS/PREMIUM: placeholders (150/250/400 BOB) the owner will change.
 *    Existing prices are never overwritten.
 *  - The first ADMIN from SEED_ADMIN_* (skipped if the phone already exists),
 *    created with mustChangePassword = true.
 *
 * Run: npx prisma db seed
 */
import 'dotenv/config';
import { PrismaClient } from '@prisma/client';
import { seedBase } from './seed-core';

async function main(): Promise<void> {
  const prisma = new PrismaClient();
  try {
    await seedBase(prisma, process.env, (msg) => console.log(msg));
  } finally {
    await prisma.$disconnect();
  }
}

main().catch((error: unknown) => {
  console.error(error instanceof Error ? error.message : error);
  process.exit(1);
});
