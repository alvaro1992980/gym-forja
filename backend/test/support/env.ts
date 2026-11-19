/**
 * Runs before every e2e test file (and in globalSetup): points the app at the TEST database
 * and silences logs. The e2e suites never touch the development database.
 */
import { config } from 'dotenv';
import { resolve } from 'node:path';

const fromFile = config({ path: resolve(__dirname, '../../.env'), quiet: true }).parsed ?? {};

const testUrl = process.env.DATABASE_URL_TEST;
if (!testUrl) {
  throw new Error('DATABASE_URL_TEST is not set (see backend/.env.example)');
}
const devUrl = fromFile.DATABASE_URL;
if (devUrl && testUrl === devUrl) {
  throw new Error('DATABASE_URL_TEST must be different from DATABASE_URL');
}

process.env.DATABASE_URL = testUrl;
process.env.NODE_ENV = 'test';
process.env.LOG_LEVEL = 'silent';
process.env.SWAGGER_ENABLED = 'true';
