import 'dart:async';

import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/utils/clock.dart';
import '../data/kiosk_repository.dart';

part 'kiosk_controller.g.dart';

/// What the kiosk shows (section 9.4).
class KioskState {
  const KioskState({
    required this.now,
    this.qr,
    this.receivedAt,
    this.offline = false,
    this.gymName = '',
  });

  final DateTime now;
  final QrToken? qr;
  final DateTime? receivedAt;

  /// The last fetch failed (no connection or server error).
  final bool offline;
  final String gymName;

  /// The QR is shown only while the server still accepts it: never an
  /// expired QR.
  bool get showQr {
    final qr = this.qr;
    final at = receivedAt;
    return qr != null && at != null && now.isBefore(at.add(qr.validFor));
  }

  /// 1 → 0 until the next rotation (the countdown bar).
  double get rotationProgress {
    final qr = this.qr;
    final at = receivedAt;
    if (qr == null || at == null) return 0;
    final left = at.add(qr.refreshIn).difference(now).inMilliseconds;
    return (left / qr.refreshIn.inMilliseconds).clamp(0, 1).toDouble();
  }

  KioskState copyWith({
    DateTime? now,
    QrToken? qr,
    DateTime? receivedAt,
    bool? offline,
  }) => KioskState(
    now: now ?? this.now,
    qr: qr ?? this.qr,
    receivedAt: receivedAt ?? this.receivedAt,
    offline: offline ?? this.offline,
    gymName: qr?.gymName ?? gymName,
  );
}

/// Fetches a new QR token every `refreshInSeconds` (30 s) [R-18]; after a
/// failure it retries every [retryDelay].
@riverpod
class KioskController extends _$KioskController {
  static const retryDelay = Duration(seconds: 5);
  static const _tick = Duration(milliseconds: 250);

  Timer? _next;

  @override
  KioskState build() {
    final ticker = Timer.periodic(_tick, (_) => _refreshNow());
    ref.onDispose(() {
      ticker.cancel();
      _next?.cancel();
    });
    _next = Timer(Duration.zero, _fetch);
    return KioskState(now: _now());
  }

  DateTime _now() => ref.read(clockProvider).now();

  void _refreshNow() {
    final now = _now();
    if (ref.mounted && now != state.now) state = state.copyWith(now: now);
  }

  Future<void> _fetch() async {
    Duration wait;
    try {
      final qr = await ref.read(kioskRepositoryProvider).qrToken();
      if (!ref.mounted) return;
      final now = _now();
      state = state.copyWith(now: now, qr: qr, receivedAt: now, offline: false);
      wait = qr.refreshIn;
    } on ApiException {
      if (!ref.mounted) return;
      state = state.copyWith(now: _now(), offline: true);
      wait = retryDelay;
    }
    _next = Timer(wait, _fetch);
  }
}

/// Kiosk device mode: screen always on, no system bars, portrait only.
class KioskDisplay {
  const KioskDisplay();

  Future<void> enter() async {
    await WakelockPlus.enable();
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }

  Future<void> exit() async {
    await WakelockPlus.disable();
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    await SystemChrome.setPreferredOrientations([]);
  }
}

@Riverpod(keepAlive: true)
KioskDisplay kioskDisplay(Ref ref) => const KioskDisplay();
