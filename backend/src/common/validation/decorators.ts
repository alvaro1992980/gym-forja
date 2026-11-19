import { applyDecorators } from '@nestjs/common';
import { Transform, Type } from 'class-transformer';
import { IsNumber, IsString, Max, Min, ValidateBy } from 'class-validator';
import { parseLocalDate } from '../date/gym-date';

export const MAX_AMOUNT = 999_999.99;

/** Money input: a number ≥ 0 with at most 2 decimals (converted to Decimal in services). */
export function IsMoney() {
  return applyDecorators(
    Type(() => Number),
    IsNumber({ maxDecimalPlaces: 2, allowNaN: false, allowInfinity: false }),
    Min(0),
    Max(MAX_AMOUNT),
  );
}

/** A real calendar date as `YYYY-MM-DD` (API date format, section 8). */
export function IsLocalDateString() {
  return applyDecorators(
    IsString(),
    ValidateBy({
      name: 'isLocalDateString',
      validator: {
        validate: (value: unknown) => {
          if (typeof value !== 'string') return false;
          try {
            parseLocalDate(value);
            return true;
          } catch {
            return false;
          }
        },
        defaultMessage: () => '$property must be a valid date in YYYY-MM-DD format',
      },
    }),
  );
}

/** Trims strings; turns blank strings into undefined (so optional fields stay optional). */
export const TrimToUndefined = () =>
  Transform(({ value }: { value: unknown }) => {
    if (typeof value !== 'string') return value;
    const trimmed = value.trim();
    return trimmed.length > 0 ? trimmed : undefined;
  });

/** Trims strings; keeps null (used by PATCH to clear a field). */
export const TrimKeepNull = () =>
  Transform(({ value }: { value: unknown }) => {
    if (value === null) return null;
    if (typeof value !== 'string') return value;
    const trimmed = value.trim();
    return trimmed.length > 0 ? trimmed : null;
  });
