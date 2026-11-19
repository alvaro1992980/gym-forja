import 'reflect-metadata';
import { plainToInstance, Transform, Type } from 'class-transformer';
import {
  IsBoolean,
  IsEnum,
  IsIn,
  IsInt,
  IsOptional,
  IsString,
  Matches,
  Max,
  Min,
  MinLength,
  ValidateIf,
  validateSync,
  ValidationError,
} from 'class-validator';

export enum NodeEnv {
  Development = 'development',
  Test = 'test',
  Production = 'production',
}

export const LOG_LEVELS = ['fatal', 'error', 'warn', 'info', 'debug', 'trace', 'silent'] as const;
export type LogLevel = (typeof LOG_LEVELS)[number];

function toBoolean({ obj, key }: { obj: Record<string, unknown>; key: string }): unknown {
  const raw = obj[key];
  if (typeof raw === 'boolean') return raw;
  if (typeof raw !== 'string') return raw;
  const v = raw.trim().toLowerCase();
  if (['true', '1', 'yes'].includes(v)) return true;
  if (['false', '0', 'no'].includes(v)) return false;
  return raw; // left as string so @IsBoolean reports it
}

function isValidTimeZone(tz: string): boolean {
  try {
    new Intl.DateTimeFormat('en-US', { timeZone: tz });
    return true;
  } catch {
    return false;
  }
}

/**
 * Every environment variable the API reads. Validated once at startup:
 * a missing or invalid value stops the process with a readable message (fail fast).
 * Documented in backend/.env.example.
 */
export class EnvironmentVariables {
  @IsEnum(NodeEnv)
  NODE_ENV: NodeEnv = NodeEnv.Development;

  @Type(() => Number)
  @IsInt()
  @Min(1)
  @Max(65535)
  PORT: number = 3000;

  @Matches(/^postgres(ql)?:\/\//, { message: 'DATABASE_URL must be a postgresql:// URL' })
  DATABASE_URL: string;

  @IsOptional()
  @Matches(/^postgres(ql)?:\/\//, { message: 'DATABASE_URL_TEST must be a postgresql:// URL' })
  DATABASE_URL_TEST?: string;

  @IsString()
  @MinLength(32)
  JWT_ACCESS_SECRET: string;

  @Matches(/^\d+[smhd]$/, { message: 'JWT_ACCESS_TTL must look like 15m, 1h, 30s or 1d' })
  JWT_ACCESS_TTL = '15m';

  @Type(() => Number)
  @IsInt()
  @Min(1)
  JWT_REFRESH_TTL_DAYS: number = 30;

  @IsString()
  @MinLength(32)
  QR_TOKEN_SECRET: string;

  @Type(() => Number)
  @IsInt()
  @Min(5)
  QR_TOKEN_TTL_SECONDS: number = 45;

  /** IANA name; checked with Intl in validateEnv(). */
  @IsString()
  GYM_TIMEZONE = 'America/La_Paz';

  @Transform(toBoolean)
  @IsBoolean()
  PUSH_ENABLED = false;

  @ValidateIf((env: EnvironmentVariables) => env.PUSH_ENABLED === true)
  @IsString({ message: 'FIREBASE_SERVICE_ACCOUNT_JSON is required when PUSH_ENABLED=true' })
  @MinLength(1)
  FIREBASE_SERVICE_ACCOUNT_JSON?: string;

  /** Undefined = enabled except in production. */
  @IsOptional()
  @Transform(toBoolean)
  @IsBoolean()
  SWAGGER_ENABLED?: boolean;

  @IsString()
  CORS_ORIGINS = '';

  @IsIn(LOG_LEVELS)
  LOG_LEVEL: LogLevel = 'info';
}

function formatErrors(errors: ValidationError[]): string {
  return errors
    .map((e) => `  - ${e.property}: ${Object.values(e.constraints ?? {}).join('; ')}`)
    .join('\n');
}

/** Used by ConfigModule.forRoot({ validate }). Throws on the first invalid configuration. */
export function validateEnv(raw: Record<string, unknown>): EnvironmentVariables {
  // Empty strings (e.g. `FIREBASE_SERVICE_ACCOUNT_JSON=`) mean "not set".
  const cleaned = Object.fromEntries(Object.entries(raw).filter(([, v]) => v !== ''));
  const env = plainToInstance(EnvironmentVariables, cleaned, {
    enableImplicitConversion: true,
    excludeExtraneousValues: false,
  });
  const errors = validateSync(env, { skipMissingProperties: false });
  if (!isValidTimeZone(env.GYM_TIMEZONE)) {
    errors.push(
      Object.assign(new ValidationError(), {
        property: 'GYM_TIMEZONE',
        constraints: { timeZone: `"${env.GYM_TIMEZONE}" is not a valid IANA time zone` },
      }),
    );
  }
  if (errors.length > 0) {
    throw new Error(`Invalid environment configuration:\n${formatErrors(errors)}`);
  }
  return env;
}

/** Swagger is on by default except in production, where it needs SWAGGER_ENABLED=true. */
export function isSwaggerEnabled(env: Pick<EnvironmentVariables, 'NODE_ENV' | 'SWAGGER_ENABLED'>) {
  return env.SWAGGER_ENABLED ?? env.NODE_ENV !== NodeEnv.Production;
}

export function parseCorsOrigins(value: string): string[] {
  return value
    .split(',')
    .map((o) => o.trim())
    .filter((o) => o.length > 0);
}
