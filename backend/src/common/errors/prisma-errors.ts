import { HttpStatus } from '@nestjs/common';
import { Prisma } from '@prisma/client';
import { AppException } from './app.exception';
import { ErrorCode } from './error-codes';

/** True for a unique-constraint violation (P2002), optionally on a given field. */
export function isUniqueViolation(error: unknown, field?: string): boolean {
  if (!(error instanceof Prisma.PrismaClientKnownRequestError) || error.code !== 'P2002') {
    return false;
  }
  if (!field) return true;
  const target = (error.meta as { target?: unknown } | undefined)?.target;
  const text = Array.isArray(target) ? target.join(',') : typeof target === 'string' ? target : '';
  return text.includes(field);
}

/** Maps a unique violation on User.phone / User.email to the API error codes. */
export function mapUserUniqueViolation(error: unknown): never {
  if (isUniqueViolation(error, 'phone')) {
    throw new AppException(HttpStatus.CONFLICT, ErrorCode.PHONE_ALREADY_EXISTS);
  }
  if (isUniqueViolation(error, 'email')) {
    throw new AppException(HttpStatus.CONFLICT, ErrorCode.EMAIL_ALREADY_EXISTS);
  }
  throw error;
}
