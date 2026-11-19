import {
  ArgumentsHost,
  Catch,
  ExceptionFilter,
  HttpException,
  HttpStatus,
  Logger,
} from '@nestjs/common';
import type { Response } from 'express';
import { AppException, ErrorResponseBody } from './app.exception';
import { DEFAULT_ERROR_MESSAGES, ErrorCode, errorCodeForStatus } from './error-codes';

/**
 * Turns every thrown error into `{ statusCode, code, message, details? }`.
 * Unknown errors become 500 INTERNAL_ERROR and are logged; their details never reach the client.
 */
@Catch()
export class AllExceptionsFilter implements ExceptionFilter {
  private readonly logger = new Logger(AllExceptionsFilter.name);

  catch(exception: unknown, host: ArgumentsHost): void {
    const response = host.switchToHttp().getResponse<Response>();
    const body = this.toBody(exception);
    if (body.statusCode >= 500) {
      this.logger.error(
        exception instanceof Error ? (exception.stack ?? exception.message) : String(exception),
      );
    }
    response.status(body.statusCode).json(body);
  }

  toBody(exception: unknown): ErrorResponseBody {
    if (exception instanceof AppException) {
      return exception.toBody();
    }
    if (exception instanceof HttpException) {
      const status = exception.getStatus();
      const code = errorCodeForStatus(status);
      return { statusCode: status, code, message: DEFAULT_ERROR_MESSAGES[code] };
    }
    return {
      statusCode: HttpStatus.INTERNAL_SERVER_ERROR,
      code: ErrorCode.INTERNAL_ERROR,
      message: DEFAULT_ERROR_MESSAGES.INTERNAL_ERROR,
    };
  }
}
