import { applyDecorators } from '@nestjs/common';
import { ApiProperty } from '@nestjs/swagger';
import { Transform } from 'class-transformer';
import { IsString, Matches } from 'class-validator';
import { NORMALIZED_PHONE_RE, normalizePhone } from '../phone/phone';

/**
 * [R-40] DTO field holding a phone number: accepts any common format and stores the
 * normalized value (+591 default). Invalid numbers fail validation (400 VALIDATION_ERROR).
 */
export function IsPhone() {
  return applyDecorators(
    ApiProperty({ example: '71234567', description: 'Normalized to +59171234567 [R-40]' }),
    Transform(({ value }: { value: unknown }) =>
      typeof value === 'string' ? (normalizePhone(value) ?? value) : value,
    ),
    IsString(),
    Matches(NORMALIZED_PHONE_RE, { message: 'phone must be a valid phone number' }),
  );
}
