import 'package:intl/intl.dart';

final _apiDate = DateFormat('yyyy-MM-dd');
final _displayDate = DateFormat('dd/MM/yyyy');

/// `2026-12-14` (gym-local date from the API) → `14/12/2026`.
/// Parsed without time zones, so the calendar day never shifts.
String formatApiDate(String apiDate) =>
    _displayDate.format(_apiDate.parseStrict(apiDate));
