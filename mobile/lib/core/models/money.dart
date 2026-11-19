import 'package:intl/intl.dart';

/// Money is handled as integer cents on the device. The API sends amounts as
/// strings (`"150.00"`) and accepts numbers with at most 2 decimals.
abstract final class Money {
  static final _input = RegExp(r'^\d{1,7}([.,]\d{1,2})?$');
  static final _display = NumberFormat('#,##0.00', 'es');

  /// `"150.00"` (API) → 15000. Throws on malformed input.
  static int centsFromApi(String amount) {
    final cents = parseInput(amount);
    if (cents == null) throw FormatException('Invalid amount', amount);
    return cents;
  }

  /// User input (`150`, `150,5`, `150.50`) → cents, or null when invalid.
  static int? parseInput(String input) {
    final value = input.trim();
    if (!_input.hasMatch(value)) return null;
    final parts = value.replaceAll(',', '.').split('.');
    final whole = int.parse(parts[0]);
    final fraction = parts.length > 1 ? parts[1].padRight(2, '0') : '00';
    return whole * 100 + int.parse(fraction);
  }

  /// Cents → JSON number for the API (exact for 2 decimals).
  static num toApi(int cents) => cents % 100 == 0 ? cents ~/ 100 : cents / 100;

  /// Cents → editable text, e.g. `150` or `150.50`.
  static String toInput(int cents) => cents % 100 == 0
      ? '${cents ~/ 100}'
      : '${cents ~/ 100}.${(cents % 100).toString().padLeft(2, '0')}';

  /// Cents → `Bs 1.500,00` (section 9: locale es_BO).
  static String format(int cents, {String currency = 'BOB'}) {
    final symbol = currency == 'BOB' ? 'Bs' : currency;
    return '$symbol ${_display.format(cents / 100)}';
  }

  /// API amount string → `Bs 150,00`.
  static String formatApi(String amount, {String currency = 'BOB'}) =>
      format(centsFromApi(amount), currency: currency);
}
