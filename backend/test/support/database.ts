import { PrismaClient } from '@prisma/client';

/** Truncates every application table in the TEST database (migrations table excluded). */
export async function resetDatabase(prisma?: PrismaClient): Promise<void> {
  const url = process.env.DATABASE_URL ?? '';
  if (url !== process.env.DATABASE_URL_TEST) {
    throw new Error('resetDatabase() refused: DATABASE_URL is not the test database');
  }
  const client = prisma ?? new PrismaClient();
  try {
    const rows = await client.$queryRaw<{ tablename: string }[]>`
      SELECT tablename FROM pg_tables
      WHERE schemaname = 'public' AND tablename <> '_prisma_migrations'`;
    if (rows.length > 0) {
      const tables = rows.map((r) => `"public"."${r.tablename}"`).join(', ');
      await client.$executeRawUnsafe(`TRUNCATE TABLE ${tables} RESTART IDENTITY CASCADE`);
    }
  } finally {
    if (!prisma) await client.$disconnect();
  }
}
