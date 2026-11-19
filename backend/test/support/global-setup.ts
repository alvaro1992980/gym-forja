/**
 * Once per e2e run: apply all migrations to the TEST database and empty every table,
 * so each run starts from a known state. Suites that need isolation call resetDatabase().
 */
import { execSync } from 'node:child_process';
import { resolve } from 'node:path';
import './env';
import { resetDatabase } from './database';

export default async function globalSetup(): Promise<void> {
  execSync('npx prisma migrate deploy', {
    cwd: resolve(__dirname, '../..'),
    env: process.env,
    stdio: 'pipe',
  });
  await resetDatabase();
}
