import { HttpStatus } from '@nestjs/common';

/**
 * Every error code the API can return (docs/PLAN.md section 8, "Errors").
 * The mobile app maps these codes to localized messages, so codes are a public contract:
 * add new ones, never rename or remove.
 */
export const ErrorCode = {
  // Generic
  VALIDATION_ERROR: 'VALIDATION_ERROR',
  BAD_REQUEST: 'BAD_REQUEST',
  UNAUTHORIZED: 'UNAUTHORIZED',
  FORBIDDEN: 'FORBIDDEN',
  NOT_FOUND: 'NOT_FOUND',
  METHOD_NOT_ALLOWED: 'METHOD_NOT_ALLOWED',
  CONFLICT: 'CONFLICT',
  PAYLOAD_TOO_LARGE: 'PAYLOAD_TOO_LARGE',
  TOO_MANY_REQUESTS: 'TOO_MANY_REQUESTS',
  INTERNAL_ERROR: 'INTERNAL_ERROR',
  SERVICE_UNAVAILABLE: 'SERVICE_UNAVAILABLE',

  // Auth & accounts (D2+)
  INVALID_CREDENTIALS: 'INVALID_CREDENTIALS',
  PASSWORD_CHANGE_REQUIRED: 'PASSWORD_CHANGE_REQUIRED',
  ACCOUNT_INACTIVE: 'ACCOUNT_INACTIVE',
  PHONE_ALREADY_EXISTS: 'PHONE_ALREADY_EXISTS',
  EMAIL_ALREADY_EXISTS: 'EMAIL_ALREADY_EXISTS',
  INVALID_REFRESH_TOKEN: 'INVALID_REFRESH_TOKEN',
  WRONG_CURRENT_PASSWORD: 'WRONG_CURRENT_PASSWORD',
  PASSWORD_UNCHANGED: 'PASSWORD_UNCHANGED',
  LAST_ACTIVE_ADMIN: 'LAST_ACTIVE_ADMIN',

  // Memberships & payments (D3+)
  AMOUNT_NOTE_REQUIRED: 'AMOUNT_NOTE_REQUIRED',
  MEMBERSHIP_EXPIRED: 'MEMBERSHIP_EXPIRED',

  // Check-in (D6+)
  QR_TOKEN_INVALID: 'QR_TOKEN_INVALID',
  QR_TOKEN_EXPIRED: 'QR_TOKEN_EXPIRED',

  // Training (D11+)
  TIER_REQUIRED: 'TIER_REQUIRED',
  SESSION_ALREADY_OPEN: 'SESSION_ALREADY_OPEN',
} as const;

export type ErrorCode = (typeof ErrorCode)[keyof typeof ErrorCode];

/** Default human-readable messages (Spanish, as required by the plan). */
export const DEFAULT_ERROR_MESSAGES: Record<ErrorCode, string> = {
  VALIDATION_ERROR: 'Los datos enviados no son válidos.',
  BAD_REQUEST: 'La solicitud no es válida.',
  UNAUTHORIZED: 'Debes iniciar sesión.',
  FORBIDDEN: 'No tienes permiso para realizar esta acción.',
  NOT_FOUND: 'No se encontró el recurso solicitado.',
  METHOD_NOT_ALLOWED: 'Método no permitido.',
  CONFLICT: 'La operación entra en conflicto con el estado actual.',
  PAYLOAD_TOO_LARGE: 'La solicitud es demasiado grande.',
  TOO_MANY_REQUESTS: 'Demasiadas solicitudes. Intenta de nuevo en un momento.',
  INTERNAL_ERROR: 'Ocurrió un error inesperado. Intenta de nuevo.',
  SERVICE_UNAVAILABLE: 'El servicio no está disponible en este momento.',
  INVALID_CREDENTIALS: 'Teléfono o contraseña incorrectos.',
  PASSWORD_CHANGE_REQUIRED: 'Debes cambiar tu contraseña antes de continuar.',
  ACCOUNT_INACTIVE: 'Tu cuenta está desactivada. Acércate a recepción.',
  PHONE_ALREADY_EXISTS: 'Ya existe una cuenta con ese número de teléfono.',
  EMAIL_ALREADY_EXISTS: 'Ya existe una cuenta con ese correo.',
  INVALID_REFRESH_TOKEN: 'Tu sesión expiró. Inicia sesión de nuevo.',
  WRONG_CURRENT_PASSWORD: 'La contraseña actual no es correcta.',
  PASSWORD_UNCHANGED: 'La nueva contraseña debe ser distinta de la actual.',
  LAST_ACTIVE_ADMIN: 'Debe existir al menos un administrador activo.',
  AMOUNT_NOTE_REQUIRED: 'Si el monto cambia respecto al sugerido, debes agregar una nota.',
  MEMBERSHIP_EXPIRED: 'Tu membresía está vencida. Acércate a recepción para renovar.',
  QR_TOKEN_INVALID: 'Código no válido, vuelve a escanear.',
  QR_TOKEN_EXPIRED: 'Código vencido, escanea de nuevo.',
  TIER_REQUIRED: 'Tu plan de membresía no incluye esta función.',
  SESSION_ALREADY_OPEN: 'Ya tienes un entrenamiento en curso.',
};

/** Fallback code for plain HttpExceptions that were not raised as AppException. */
const CODE_BY_STATUS = new Map<number, ErrorCode>([
  [HttpStatus.BAD_REQUEST, ErrorCode.BAD_REQUEST],
  [HttpStatus.UNAUTHORIZED, ErrorCode.UNAUTHORIZED],
  [HttpStatus.FORBIDDEN, ErrorCode.FORBIDDEN],
  [HttpStatus.NOT_FOUND, ErrorCode.NOT_FOUND],
  [HttpStatus.METHOD_NOT_ALLOWED, ErrorCode.METHOD_NOT_ALLOWED],
  [HttpStatus.CONFLICT, ErrorCode.CONFLICT],
  [HttpStatus.PAYLOAD_TOO_LARGE, ErrorCode.PAYLOAD_TOO_LARGE],
  [HttpStatus.TOO_MANY_REQUESTS, ErrorCode.TOO_MANY_REQUESTS],
  [HttpStatus.SERVICE_UNAVAILABLE, ErrorCode.SERVICE_UNAVAILABLE],
]);

export function errorCodeForStatus(status: number): ErrorCode {
  return (
    CODE_BY_STATUS.get(status) ?? (status >= 500 ? ErrorCode.INTERNAL_ERROR : ErrorCode.BAD_REQUEST)
  );
}
