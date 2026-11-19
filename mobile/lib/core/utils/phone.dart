/// [R-40] Phone normalization, the same rules as
/// `backend/src/common/phone/phone.ts`, so the form validates like the server.
library;

const defaultCountryCode = '+591';

/// Country codes offered by the login prefix selector (Bolivia first).
const countryCodes = [
  '+591',
  '+54',
  '+55',
  '+56',
  '+51',
  '+595',
  '+598',
  '+57',
  '+593',
  '+52',
  '+1',
  '+34',
];

final _separators = RegExp(r'[\s\-.()/]');
final _normalized = RegExp(r'^\+[1-9]\d{7,14}$');

/// Returns `+<country code><number>` or null when [input] cannot be a phone.
///  - `71234567` → `+59171234567` (default country code added)
///  - `7123 4567`, `7123-4567` → `+59171234567`
///  - `+591 7123-4567`, `0059171234567` → `+59171234567`
String? normalizePhone(
  String input, {
  String countryCode = defaultCountryCode,
}) {
  var value = input.trim().replaceAll(_separators, '');
  if (value.isEmpty) return null;
  if (value.startsWith('00')) {
    value = '+${value.substring(2)}';
  } else if (!value.startsWith('+')) {
    final cc = countryCode.replaceAll(_separators, '');
    value = '${cc.startsWith('+') ? cc : '+$cc'}$value';
  }
  return _normalized.hasMatch(value) ? value : null;
}
