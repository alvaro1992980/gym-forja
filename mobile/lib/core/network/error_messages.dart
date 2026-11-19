import '../../l10n/generated/app_localizations.dart';
import 'api_exception.dart';

/// Localized message for any error thrown by an API call.
String errorMessage(AppLocalizations l10n, Object error) {
  if (error is! ApiException) return l10n.errorUnknown;
  return messageForCode(l10n, error.code) ?? _byStatus(l10n, error.statusCode);
}

/// Localized message for a backend error `code`
/// (`backend/src/common/errors/error-codes.ts`), or null when unknown.
String? messageForCode(AppLocalizations l10n, String code) => switch (code) {
  ClientErrorCode.network => l10n.errorNetwork,
  ClientErrorCode.timeout => l10n.errorTimeout,
  ClientErrorCode.unknown => l10n.errorUnknown,
  'VALIDATION_ERROR' => l10n.errorValidation,
  'BAD_REQUEST' => l10n.errorBadRequest,
  'UNAUTHORIZED' => l10n.errorUnauthorized,
  'FORBIDDEN' => l10n.errorForbidden,
  'NOT_FOUND' => l10n.errorNotFound,
  'METHOD_NOT_ALLOWED' => l10n.errorBadRequest,
  'CONFLICT' => l10n.errorConflict,
  'PAYLOAD_TOO_LARGE' => l10n.errorBadRequest,
  'TOO_MANY_REQUESTS' => l10n.errorTooManyRequests,
  'INTERNAL_ERROR' => l10n.errorServer,
  'SERVICE_UNAVAILABLE' => l10n.errorServer,
  'INVALID_CREDENTIALS' => l10n.errorInvalidCredentials,
  'PASSWORD_CHANGE_REQUIRED' => l10n.errorPasswordChangeRequired,
  'ACCOUNT_INACTIVE' => l10n.errorAccountInactive,
  'PHONE_ALREADY_EXISTS' => l10n.errorPhoneAlreadyExists,
  'EMAIL_ALREADY_EXISTS' => l10n.errorEmailAlreadyExists,
  'INVALID_REFRESH_TOKEN' => l10n.errorUnauthorized,
  'WRONG_CURRENT_PASSWORD' => l10n.errorWrongCurrentPassword,
  'PASSWORD_UNCHANGED' => l10n.errorPasswordUnchanged,
  'LAST_ACTIVE_ADMIN' => l10n.errorLastActiveAdmin,
  'AMOUNT_NOTE_REQUIRED' => l10n.errorAmountNoteRequired,
  'MEMBERSHIP_EXPIRED' => l10n.errorMembershipExpired,
  'START_DATE_OUT_OF_RANGE' => l10n.errorStartDateOutOfRange,
  'TIER_UNCHANGED' => l10n.errorTierUnchanged,
  'PAYMENT_ALREADY_VOIDED' => l10n.errorPaymentAlreadyVoided,
  'PAYMENT_METHOD_REQUIRED' => l10n.errorPaymentMethodRequired,
  'DOWNGRADE_HAS_NO_CHARGE' => l10n.errorDowngradeHasNoCharge,
  'NO_MEMBERSHIP' => l10n.errorNoMembership,
  'QR_TOKEN_INVALID' => l10n.errorQrTokenInvalid,
  'QR_TOKEN_EXPIRED' => l10n.errorQrTokenExpired,
  'TIER_REQUIRED' => l10n.errorTierRequired,
  'SESSION_ALREADY_OPEN' => l10n.errorSessionAlreadyOpen,
  _ => null,
};

String _byStatus(AppLocalizations l10n, int? status) => switch (status) {
  401 => l10n.errorUnauthorized,
  403 => l10n.errorForbidden,
  404 => l10n.errorNotFound,
  409 => l10n.errorConflict,
  429 => l10n.errorTooManyRequests,
  final s? when s >= 500 => l10n.errorServer,
  final s? when s >= 400 => l10n.errorBadRequest,
  _ => l10n.errorUnknown,
};
