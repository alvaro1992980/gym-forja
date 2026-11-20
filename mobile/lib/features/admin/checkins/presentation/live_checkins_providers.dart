import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/realtime/realtime_client.dart';
import '../../../../core/utils/clock.dart';
import '../../../../core/utils/device_actions.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/parallel.dart';
import '../../../../core/utils/preferences.dart';
import '../../members/domain/member_models.dart';
import '../data/checkins_repository.dart';
import '../domain/checkin_models.dart';

part 'live_checkins_providers.g.dart';

/// State of the live check-ins screen (section 9.3 #7).
class LiveFeed {
  const LiveFeed({
    required this.inside,
    required this.windowMinutes,
    required this.today,
    this.fresh = const {},
  });

  /// Latest check-in of each member inside now, newest first [R-23].
  final List<CheckinItem> inside;
  final int windowMinutes;

  /// Today's check-ins and denied entries, newest first.
  final List<FeedEntry> today;

  /// Keys of entries that arrived live (animated in).
  final Set<String> fresh;

  LiveFeed copyWith({
    List<CheckinItem>? inside,
    List<FeedEntry>? today,
    Set<String>? fresh,
  }) => LiveFeed(
    inside: inside ?? this.inside,
    windowMinutes: windowMinutes,
    today: today ?? this.today,
    fresh: fresh ?? this.fresh,
  );
}

PersonRef _person(EventMember m) =>
    PersonRef(id: m.id, firstName: m.firstName, lastName: m.lastName);

CheckinItem _checkinFrom(CheckinCreated e) => CheckinItem(
  id: e.checkinId,
  member: _person(e.member),
  tier: e.tier,
  daysLeft: e.daysLeft,
  createdAt: e.createdAt,
);

FeedDenied _deniedFrom(CheckinDenied e) => FeedDenied(
  member: _person(e.member),
  expired: e.isExpired,
  endDate: e.endDate,
  createdAt: e.createdAt,
);

/// Newest first, without repeated keys.
List<T> _mergeNewestFirst<T>(
  Iterable<T> items,
  String Function(T) key,
  String Function(T) createdAt,
) {
  final seen = <String>{};
  final list = [
    for (final item in items)
      if (seen.add(key(item))) item,
  ]..sort((a, b) => createdAt(b).compareTo(createdAt(a)));
  return list;
}

/// Reload after a reconnection: events sent while offline were missed
/// (section 8.5).
mixin _ReloadOnReconnect {
  bool _disconnected = false;

  /// True when [event] is a `ready` that follows a disconnection.
  bool shouldReload(RealtimeEvent event) {
    switch (event) {
      case RealtimeDisconnected():
        _disconnected = true;
      case RealtimeReady() when _disconnected:
        _disconnected = false;
        return true;
      default:
    }
    return false;
  }
}

/// "Adentro ahora" and "Hoy", kept up to date by the realtime events.
@riverpod
class LiveCheckins extends _$LiveCheckins with _ReloadOnReconnect {
  @override
  Future<LiveFeed> build() {
    ref.listen(realtimeEventsProvider, (_, next) {
      if (next case AsyncData(:final value)) _onEvent(value);
    });
    return _load();
  }

  Future<LiveFeed> _load() async {
    final repo = ref.read(checkinsRepositoryProvider);
    final today = toApiDate(ref.read(clockProvider).today());
    final (inside, checkins, attempts) = await all3(
      repo.inside(),
      repo.list(from: today, to: today),
      repo.attempts(from: today, to: today),
    );
    return LiveFeed(
      inside: inside.items,
      windowMinutes: inside.windowMinutes,
      today: _mergeNewestFirst<FeedEntry>(
        [
          for (final c in checkins.items) FeedCheckin(c),
          for (final a in attempts.items)
            if (a.isDenied && a.member != null)
              FeedDenied(
                member: a.member!,
                expired: a.result == CheckinResult.deniedExpired,
                endDate: a.endDate,
                createdAt: a.createdAt,
              ),
        ],
        (e) => e.key,
        (e) => e.createdAt,
      ),
    );
  }

  /// Pull-to-refresh and Retry.
  Future<void> refresh() async {
    state = await AsyncValue.guard(_load);
  }

  void _onEvent(RealtimeEvent event) {
    if (shouldReload(event)) {
      unawaited(refresh());
      return;
    }
    final feed = state.value;
    if (feed == null) return; // still loading: the load includes it
    switch (event) {
      case CheckinCreated():
        final checkin = _checkinFrom(event);
        final entry = FeedCheckin(checkin);
        state = AsyncData(
          feed.copyWith(
            inside: [
              checkin,
              ...feed.inside.where((c) => c.member.id != checkin.member.id),
            ],
            today: _mergeNewestFirst<FeedEntry>(
              [entry, ...feed.today],
              (e) => e.key,
              (e) => e.createdAt,
            ),
            fresh: {...feed.fresh, entry.key},
          ),
        );
      case CheckinDenied():
        final entry = _deniedFrom(event);
        state = AsyncData(
          feed.copyWith(
            today: _mergeNewestFirst<FeedEntry>(
              [entry, ...feed.today],
              (e) => e.key,
              (e) => e.createdAt,
            ),
            fresh: {...feed.fresh, entry.key},
          ),
        );
      default:
    }
  }
}

/// The dashboard's "last 10 check-ins" (section 9.3 #1), live.
@riverpod
class RecentCheckins extends _$RecentCheckins with _ReloadOnReconnect {
  static const size = 10;

  @override
  Future<List<CheckinItem>> build() {
    ref.listen(realtimeEventsProvider, (_, next) {
      if (next case AsyncData(:final value)) _onEvent(value);
    });
    return _load();
  }

  Future<List<CheckinItem>> _load() async =>
      (await ref.read(checkinsRepositoryProvider).list(pageSize: size)).items;

  Future<void> refresh() async {
    state = await AsyncValue.guard(_load);
  }

  void _onEvent(RealtimeEvent event) {
    if (shouldReload(event)) {
      unawaited(refresh());
      return;
    }
    final list = state.value;
    if (event is CheckinCreated && list != null) {
      state = AsyncData(
        _mergeNewestFirst(
          [_checkinFrom(event), ...list],
          (c) => c.id,
          (c) => c.createdAt,
        ).take(size).toList(),
      );
    }
  }
}

/// Sound/vibration on new live entries; can be turned off (section 9.3 #7).
@Riverpod(keepAlive: true)
class CheckinAlertsEnabled extends _$CheckinAlertsEnabled {
  static const _key = 'admin.checkinAlerts';

  @override
  bool build() {
    unawaited(_restore());
    return true;
  }

  Future<void> _restore() async {
    final stored = await ref.read(preferencesProvider).getBool(_key);
    if (stored != null && ref.mounted) state = stored;
  }

  Future<void> toggle() async {
    state = !state;
    await ref.read(preferencesProvider).setBool(_key, state);
  }
}

/// Plays the alert for every live check-in or denial while an admin screen
/// is open (watched by the admin shell).
@Riverpod(keepAlive: true)
void checkinAlerts(Ref ref) {
  ref.listen(realtimeEventsProvider, (_, next) {
    final event = next.value;
    if ((event is CheckinCreated || event is CheckinDenied) &&
        ref.read(checkinAlertsEnabledProvider)) {
      unawaited(ref.read(deviceActionsProvider).alert());
    }
  });
}
