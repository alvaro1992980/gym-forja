import '../../l10n/generated/app_localizations.dart';
import 'phone.dart';

/// [R-42] Minimum password length, as enforced by the backend.
const passwordMinLength = 8;

/// Form validators that mirror the backend DTO rules. Each returns a
/// localized message, or null when the value is valid.
class Validators {
  const Validators(this._l10n);

  final AppLocalizations _l10n;

  String? required(String? value) =>
      value == null || value.trim().isEmpty ? _l10n.validationRequired : null;

  String? phone(String? value, {String countryCode = defaultCountryCode}) {
    if (value == null || value.trim().isEmpty) return _l10n.validationRequired;
    return normalizePhone(value, countryCode: countryCode) == null
        ? _l10n.validationPhoneInvalid
        : null;
  }

  static final _email = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  String? optionalEmail(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    return _email.hasMatch(value.trim()) ? null : _l10n.validationEmailInvalid;
  }

  /// Whole number in [min, max].
  String? intInRange(String? value, int min, int max) {
    final n = int.tryParse(value?.trim() ?? '');
    return n == null || n < min || n > max
        ? _l10n.validationIntRange(min, max)
        : null;
  }

  /// Login password: only required (old accounts may have any length).
  String? password(String? value) =>
      value == null || value.isEmpty ? _l10n.validationRequired : null;

  String? newPassword(String? value, {String? current}) {
    if (value == null || value.isEmpty) return _l10n.validationRequired;
    if (value.length < passwordMinLength) {
      return _l10n.validationPasswordTooShort(passwordMinLength);
    }
    if (current != null && value == current) {
      return _l10n.validationPasswordSameAsCurrent;
    }
    return null;
  }

  String? confirmPassword(String? value, String newPassword) {
    if (value == null || value.isEmpty) return _l10n.validationRequired;
    return value == newPassword ? null : _l10n.validationPasswordsDontMatch;
  }
}

enum PasswordStrength { weak, medium, strong }

/// Rough strength for the change-password hint (section 9.1 #3).
PasswordStrength passwordStrength(String value) {
  if (value.length < passwordMinLength) return PasswordStrength.weak;
  final kinds = [
    RegExp('[a-z]'),
    RegExp('[A-Z]'),
    RegExp(r'\d'),
    RegExp(r'[^A-Za-z\d]'),
  ].where((re) => re.hasMatch(value)).length;
  if (kinds >= 3 && value.length >= 10) return PasswordStrength.strong;
  if (kinds >= 2) return PasswordStrength.medium;
  return PasswordStrength.weak;
}
