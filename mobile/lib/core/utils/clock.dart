import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'clock.g.dart';

/// Current time, injectable so tests never depend on the real date
/// (docs/PLAN.md section 11: `clockProvider`).
class Clock {
  const Clock([this._now]);

  final DateTime Function()? _now;

  DateTime now() => _now?.call() ?? DateTime.now();

  /// Today's calendar date (device time zone; the gym and its phones share
  /// one time zone, see DECISIONS).
  DateTime today() {
    final n = now();
    return DateTime(n.year, n.month, n.day);
  }
}

@Riverpod(keepAlive: true)
Clock clock(Ref ref) => const Clock();
