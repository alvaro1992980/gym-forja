import { INestApplication } from '@nestjs/common';
import { DocumentBuilder, SwaggerModule } from '@nestjs/swagger';
import helmet from 'helmet';
import { Logger } from 'nestjs-pino';
import { AllExceptionsFilter } from './common/errors/all-exceptions.filter';
import { createValidationPipe } from './common/validation/validation.pipe';
import { AppConfigService } from './config/app-config.service';

export const API_PREFIX = 'api/v1';
export const SWAGGER_PATH = 'api/docs';

/**
 * Global HTTP setup shared by main.ts and the e2e tests, so tests exercise the
 * same pipeline as production.
 */
export function configureApp(app: INestApplication): void {
  const config = app.get(AppConfigService);

  app.useLogger(app.get(Logger));
  app.enableShutdownHooks();
  app.setGlobalPrefix(API_PREFIX);
  // HSTS and upgrade-insecure-requests only make sense behind HTTPS (production);
  // on http://localhost they would break Swagger UI and stick in the browser.
  app.use(
    helmet({
      hsts: config.isProduction,
      contentSecurityPolicy: {
        directives: { upgradeInsecureRequests: config.isProduction ? [] : null },
      },
    }),
  );
  const origins = config.corsOrigins;
  app.enableCors({ origin: origins.length > 0 ? origins : false, credentials: false });
  app.useGlobalPipes(createValidationPipe());
  app.useGlobalFilters(new AllExceptionsFilter());

  if (config.swaggerEnabled) {
    const document = SwaggerModule.createDocument(
      app,
      new DocumentBuilder()
        .setTitle('Gym API')
        .setDescription('REST API of the gym app. Contract: docs/PLAN.md section 8.')
        .setVersion('1')
        .addBearerAuth()
        .build(),
    );
    SwaggerModule.setup(SWAGGER_PATH, app, document, {
      jsonDocumentUrl: `${SWAGGER_PATH}-json`,
    });
  }
}
