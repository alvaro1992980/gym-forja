import { HttpStatus, ValidationError, ValidationPipe } from '@nestjs/common';
import { AppException } from '../errors/app.exception';
import { ErrorCode } from '../errors/error-codes';

export interface FieldError {
  field: string;
  constraints: Record<string, string>;
}

/** Flattens nested class-validator errors into `[{ field: 'days.0.title', constraints }]`. */
export function flattenValidationErrors(errors: ValidationError[], parent = ''): FieldError[] {
  return errors.flatMap((error) => {
    const field = parent ? `${parent}.${error.property}` : error.property;
    const own: FieldError[] = error.constraints ? [{ field, constraints: error.constraints }] : [];
    return [...own, ...flattenValidationErrors(error.children ?? [], field)];
  });
}

/** Global pipe: strict DTO validation (section 10: whitelist + forbidNonWhitelisted). */
export function createValidationPipe(): ValidationPipe {
  return new ValidationPipe({
    whitelist: true,
    forbidNonWhitelisted: true,
    transform: true,
    exceptionFactory: (errors: ValidationError[]) =>
      new AppException(HttpStatus.BAD_REQUEST, ErrorCode.VALIDATION_ERROR, undefined, {
        fields: flattenValidationErrors(errors),
      }),
  });
}
