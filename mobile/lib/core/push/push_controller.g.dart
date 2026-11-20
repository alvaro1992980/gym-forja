// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'push_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Push notifications on the device (section 9.8):
///  - after login, a short explanation and then the system permission
///    request (asked once per install);
///  - registers the FCM token (`POST /me/devices`) on login and on refresh;
///  - foreground pushes show an in-app banner and refresh the inbox badge;
///  - taps (background, terminated or banner) open the screen from `data`.
/// The state is whether push works on this build (Firebase configured).

@ProviderFor(PushController)
final pushControllerProvider = PushControllerProvider._();

/// Push notifications on the device (section 9.8):
///  - after login, a short explanation and then the system permission
///    request (asked once per install);
///  - registers the FCM token (`POST /me/devices`) on login and on refresh;
///  - foreground pushes show an in-app banner and refresh the inbox badge;
///  - taps (background, terminated or banner) open the screen from `data`.
/// The state is whether push works on this build (Firebase configured).
final class PushControllerProvider
    extends $NotifierProvider<PushController, bool> {
  /// Push notifications on the device (section 9.8):
  ///  - after login, a short explanation and then the system permission
  ///    request (asked once per install);
  ///  - registers the FCM token (`POST /me/devices`) on login and on refresh;
  ///  - foreground pushes show an in-app banner and refresh the inbox badge;
  ///  - taps (background, terminated or banner) open the screen from `data`.
  /// The state is whether push works on this build (Firebase configured).
  PushControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pushControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pushControllerHash();

  @$internal
  @override
  PushController create() => PushController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$pushControllerHash() => r'76132b83463a0fde456cc47dc348d500fc2df446';

/// Push notifications on the device (section 9.8):
///  - after login, a short explanation and then the system permission
///    request (asked once per install);
///  - registers the FCM token (`POST /me/devices`) on login and on refresh;
///  - foreground pushes show an in-app banner and refresh the inbox badge;
///  - taps (background, terminated or banner) open the screen from `data`.
/// The state is whether push works on this build (Firebase configured).

abstract class _$PushController extends $Notifier<bool> {
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
