import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import {
  EnvironmentVariables,
  isSwaggerEnabled,
  NodeEnv,
  parseCorsOrigins,
} from './env.validation';

/** Typed, read-only access to the validated configuration. */
@Injectable()
export class AppConfigService {
  constructor(private readonly config: ConfigService<EnvironmentVariables, true>) {}

  get<K extends keyof EnvironmentVariables>(key: K): EnvironmentVariables[K] {
    return this.config.get(key, { infer: true });
  }

  get nodeEnv(): NodeEnv {
    return this.get('NODE_ENV');
  }

  get isProduction(): boolean {
    return this.nodeEnv === NodeEnv.Production;
  }

  get port(): number {
    return this.get('PORT');
  }

  get gymTimezone(): string {
    return this.get('GYM_TIMEZONE');
  }

  get swaggerEnabled(): boolean {
    return isSwaggerEnabled({
      NODE_ENV: this.nodeEnv,
      SWAGGER_ENABLED: this.get('SWAGGER_ENABLED'),
    });
  }

  get corsOrigins(): string[] {
    return parseCorsOrigins(this.get('CORS_ORIGINS'));
  }
}
