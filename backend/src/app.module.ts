import { Module } from '@nestjs/common';
import { APP_GUARD } from '@nestjs/core';
import { ThrottlerModule } from '@nestjs/throttler';
import { LoggerModule } from 'nestjs-pino';
import { JwtAuthGuard, MustChangePasswordGuard, RolesGuard } from './common/auth/guards';
import { ClockModule } from './common/clock/clock.module';
import { buildLoggerParams } from './common/logging/logger.config';
import { AppThrottlerGuard } from './common/throttling/app-throttler.guard';
import { AppConfigService } from './config/app-config.service';
import { AppConfigModule } from './config/config.module';
import { AuthModule } from './modules/auth/auth.module';
import { HealthModule } from './modules/health/health.module';
import { UsersModule } from './modules/users/users.module';
import { PrismaModule } from './prisma/prisma.module';

@Module({
  imports: [
    AppConfigModule,
    LoggerModule.forRootAsync({
      inject: [AppConfigService],
      useFactory: buildLoggerParams,
    }),
    // Default limit for every route; stricter per-route limits (login, check-in) come in D2/D6.
    ThrottlerModule.forRoot([{ name: 'default', ttl: 60_000, limit: 120 }]),
    PrismaModule,
    ClockModule,
    HealthModule,
    AuthModule,
    UsersModule,
  ],
  // Global guards run in this order: rate limit → access token → forced password change → roles.
  providers: [
    { provide: APP_GUARD, useClass: AppThrottlerGuard },
    { provide: APP_GUARD, useClass: JwtAuthGuard },
    { provide: APP_GUARD, useClass: MustChangePasswordGuard },
    { provide: APP_GUARD, useClass: RolesGuard },
  ],
})
export class AppModule {}
