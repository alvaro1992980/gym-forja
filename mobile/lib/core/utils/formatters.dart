import 'package:intl/intl.dart';

final _apiDate = DateFormat('yyyy-MM-dd');
final _displayDate = DateFormat('dd/MM/yyyy');
final _displayDateTime = DateFormat('dd/MM/yyyy HH:mm');

/// `2026-12-14` (gym-local date from the API) → `14/12/2026`.
/// Parsed without time zones, so the calendar day never shifts.
String formatApiDate(String apiDate) =>
    _displayDate.format(parseApiDate(apiDate));

/// `2026-12-14` → a local `DateTime` at midnight.
DateTime parseApiDate(String apiDate) => _apiDate.parseStrict(apiDate);

/// Calendar date → `2026-12-14` for the API.
String toApiDate(DateTime date) => _apiDate.format(date);

/// Calendar date → `14/12/2026`.
String formatDate(DateTime date) => _displayDate.format(date);

/// API instant (ISO-8601 UTC) → `14/12/2026 18:05` in device time.
String formatInstant(String isoInstant) =>
    _displayDateTime.format(DateTime.parse(isoInstant).toLocal());

/// Whole calendar days from [from] to [to] (both dates, DST-safe).
int daysBetween(DateTime from, DateTime to) => DateTime.utc(
  to.year,
  to.month,
  to.day,
).difference(DateTime.utc(from.year, from.month, from.day)).inDays;
