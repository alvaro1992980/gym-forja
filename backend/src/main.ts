import { NestFactory } from '@nestjs/core';
import { Logger } from 'nestjs-pino';
import { AppModule } from './app.module';
import { API_PREFIX, configureApp, SWAGGER_PATH } from './app.setup';
import { AppConfigService } from './config/app-config.service';

async function bootstrap(): Promise<void> {
  const app = await NestFactory.create(AppModule, { bufferLogs: true });
  configureApp(app);

  const config = app.get(AppConfigService);
  await app.listen(config.port);

  const logger = app.get(Logger);
  logger.log(`API listening on http://localhost:${config.port}/${API_PREFIX}`, 'Bootstrap');
  if (config.swaggerEnabled) {
    logger.log(`Swagger UI on http://localhost:${config.port}/${SWAGGER_PATH}`, 'Bootstrap');
  }
}

void bootstrap();
