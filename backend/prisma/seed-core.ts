/**
 * Base data shared by `prisma db seed` and the e2e tests (so tests exercise the real seed).
 * Idempotent: safe to run many times.
 */
import { PrismaClient, Role, Tier } from '@prisma/client';
import { normalizePhone } from '../src/common/phone/phone';
import { hashPassword, PASSWORD_MIN_LENGTH } from '../src/common/security/password';

/** Placeholder prices (BOB) the owner will change (OPEN_QUESTIONS #1). */
export const PLACEHOLDER_PRICES: Record<Tier, string> = {
  BASIC: '150.00',
  PLUS: '250.00',
  PREMIUM: '400.00',
};

export interface SeedEnv {
  SEED_ADMIN_PHONE?: string;
  SEED_ADMIN_PASSWORD?: string;
  SEED_ADMIN_FIRST_NAME?: string;
  SEED_ADMIN_LAST_NAME?: string;
  GYM_TIMEZONE?: string;
}

export async function seedBase(
  prisma: PrismaClient,
  env: SeedEnv,
  log: (msg: string) => void = () => undefined,
): Promise<{ adminId: string; adminCreated: boolean }> {
  await prisma.gymSettings.upsert({
    where: { id: 1 },
    update: {},
    create: { id: 1, timezone: env.GYM_TIMEZONE?.trim() || 'America/La_Paz' },
  });
  log('GymSettings: ok');

  for (const tier of Object.values(Tier)) {
    await prisma.tierPrice.upsert({
      where: { tier },
      update: {},
      create: { tier, monthlyPrice: PLACEHOLDER_PRICES[tier], currency: 'BOB' },
    });
  }
  log('TierPrice: ok (existing prices left unchanged)');

  const rawPhone = env.SEED_ADMIN_PHONE?.trim();
  const password = env.SEED_ADMIN_PASSWORD?.trim();
  if (!rawPhone || !password) {
    throw new Error('SEED_ADMIN_PHONE and SEED_ADMIN_PASSWORD are required (backend/.env.example)');
  }
  const phone = normalizePhone(rawPhone); // [R-40]
  if (!phone) throw new Error(`SEED_ADMIN_PHONE "${rawPhone}" is not a valid phone number`);
  if (password.length < PASSWORD_MIN_LENGTH) {
    throw new Error(
      `SEED_ADMIN_PASSWORD must have at least ${PASSWORD_MIN_LENGTH} characters [R-42]`,
    );
  }

  const existing = await prisma.user.findUnique({ where: { phone } });
  if (existing) {
    log(`Admin ${phone}: already exists, left unchanged`);
    return { adminId: existing.id, adminCreated: false };
  }
  const admin = await prisma.user.create({
    data: {
      role: Role.ADMIN,
      firstName: env.SEED_ADMIN_FIRST_NAME?.trim() || 'Admin',
      lastName: env.SEED_ADMIN_LAST_NAME?.trim() || 'Gym',
      phone,
      passwordHash: await hashPassword(password),
      mustChangePassword: true,
    },
  });
  log(`Admin ${phone}: created (must change password on first login)`);
  return { adminId: admin.id, adminCreated: true };
}
