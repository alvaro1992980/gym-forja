// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'live_checkins_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// "Adentro ahora" and "Hoy", kept up to date by the realtime events.

@ProviderFor(LiveCheckins)
final liveCheckinsProvider = LiveCheckinsProvider._();

/// "Adentro ahora" and "Hoy", kept up to date by the realtime events.
final class LiveCheckinsProvider
    extends $AsyncNotifierProvider<LiveCheckins, LiveFeed> {
  /// "Adentro ahora" and "Hoy", kept up to date by the realtime events.
  LiveCheckinsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'liveCheckinsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$liveCheckinsHash();

  @$internal
  @override
  LiveCheckins create() => LiveCheckins();
}

String _$liveCheckinsHash() => r'8fc8592f8d47da8007ceac34ff3837a5631249e7';

/// "Adentro ahora" and "Hoy", kept up to date by the realtime events.

abstract class _$LiveCheckins extends $AsyncNotifier<LiveFeed> {
  FutureOr<LiveFeed> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<LiveFeed>, LiveFeed>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<LiveFeed>, LiveFeed>,
              AsyncValue<LiveFeed>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// The dashboard's "last 10 check-ins" (section 9.3 #1), live.

@ProviderFor(RecentCheckins)
final recentCheckinsProvider = RecentCheckinsProvider._();

/// The dashboard's "last 10 check-ins" (section 9.3 #1), live.
final class RecentCheckinsProvider
    extends $AsyncNotifierProvider<RecentCheckins, List<CheckinItem>> {
  /// The dashboard's "last 10 check-ins" (section 9.3 #1), live.
  RecentCheckinsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'recentCheckinsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$recentCheckinsHash();

  @$internal
  @override
  RecentCheckins create() => RecentCheckins();
}

String _$recentCheckinsHash() => r'978b584c97d4ece7632d7b6d4ec024be62ffa518';

/// The dashboard's "last 10 check-ins" (section 9.3 #1), live.

abstract class _$RecentCheckins extends $AsyncNotifier<List<CheckinItem>> {
  FutureOr<List<CheckinItem>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<List<CheckinItem>>, List<CheckinItem>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<CheckinItem>>, List<CheckinItem>>,
              AsyncValue<List<CheckinItem>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Sound/vibration on new live entries; can be turned off (section 9.3 #7).

@ProviderFor(CheckinAlertsEnabled)
final checkinAlertsEnabledProvider = CheckinAlertsEnabledProvider._();

/// Sound/vibration on new live entries; can be turned off (section 9.3 #7).
final class CheckinAlertsEnabledProvider
    extends $NotifierProvider<CheckinAlertsEnabled, bool> {
  /// Sound/vibration on new live entries; can be turned off (section 9.3 #7).
  CheckinAlertsEnabledProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'checkinAlertsEnabledProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$checkinAlertsEnabledHash();

  @$internal
  @override
  CheckinAlertsEnabled create() => CheckinAlertsEnabled();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$checkinAlertsEnabledHash() =>
    r'4cbb07184666073e42e8d231f895a443d2c45cc2';

/// Sound/vibration on new live entries; can be turned off (section 9.3 #7).

abstract class _$CheckinAlertsEnabled extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Plays the alert for every live check-in or denial while an admin screen
/// is open (watched by the admin shell).

@ProviderFor(checkinAlerts)
final checkinAlertsProvider = CheckinAlertsProvider._();

/// Plays the alert for every live check-in or denial while an admin screen
/// is open (watched by the admin shell).

final class CheckinAlertsProvider extends $FunctionalProvider<void, void, void>
    with $Provider<void> {
  /// Plays the alert for every live check-in or denial while an admin screen
  /// is open (watched by the admin shell).
  CheckinAlertsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'checkinAlertsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$checkinAlertsHash();

  @$internal
  @override
  $ProviderElement<void> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  void create(Ref ref) {
    return checkinAlerts(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$checkinAlertsHash() => r'969a6b3217711a1cd265f876d99ccd7687efb6ac';
