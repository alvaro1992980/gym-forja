import { INestApplication } from '@nestjs/common';
import { Test } from '@nestjs/testing';
import type { App } from 'supertest/types';
import { AppModule } from '../../src/app.module';
import { configureApp } from '../../src/app.setup';
import { ClockService, FixedClockService } from '../../src/common/clock/clock.service';
import { AppConfigService } from '../../src/config/app-config.service';
import { PushSender } from '../../src/modules/notifications/push.sender';
import { PrismaService } from '../../src/prisma/prisma.service';

export interface TestApp {
  app: INestApplication<App>;
  prisma: PrismaService;
  /** Present when the app was created with a fixed `now`. */
  clock?: FixedClockService;
}

/**
 * Boots the real AppModule with the same global setup as main.ts.
 * Pass `now` to freeze the clock (section 11: tests never depend on the real date) and `push`
 * to record pushes instead of logging them.
 */
export async function createTestApp(
  options: { now?: string; push?: PushSender } = {},
): Promise<TestApp> {
  let clock: FixedClockService | undefined;
  let builder = Test.createTestingModule({ imports: [AppModule] });
  if (options.push) builder = builder.overrideProvider(PushSender).useValue(options.push);
  if (options.now) {
    const now = options.now;
    builder = builder.overrideProvider(ClockService).useFactory({
      inject: [AppConfigService],
      factory: (config: AppConfigService) => {
        clock = new FixedClockService(config, now);
        return clock;
      },
    });
  }
  const moduleRef = await builder.compile();
  const app = moduleRef.createNestApplication<INestApplication<App>>({ bufferLogs: true });
  configureApp(app);
  await app.init();
  return { app, prisma: app.get(PrismaService), clock };
}
