import { HttpException, HttpStatus } from '@nestjs/common';
import { DEFAULT_ERROR_MESSAGES, ErrorCode } from './error-codes';

/** The JSON body of every error response (docs/PLAN.md section 8). */
export interface ErrorResponseBody {
  statusCode: number;
  code: ErrorCode;
  message: string;
  details?: Record<string, unknown>;
}

/**
 * Throw this from services/controllers for any expected error:
 * `throw new AppException(HttpStatus.CONFLICT, ErrorCode.PHONE_ALREADY_EXISTS)`.
 */
export class AppException extends HttpException {
  constructor(
    status: HttpStatus,
    readonly code: ErrorCode,
    message?: string,
    readonly details?: Record<string, unknown>,
  ) {
    const body: ErrorResponseBody = {
      statusCode: status,
      code,
      message: message ?? DEFAULT_ERROR_MESSAGES[code],
      ...(details ? { details } : {}),
    };
    super(body, status);
  }

  toBody(): ErrorResponseBody {
    return this.getResponse() as ErrorResponseBody;
  }
}
