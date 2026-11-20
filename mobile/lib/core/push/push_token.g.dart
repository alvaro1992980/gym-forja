// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'push_token.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// FCM token registered for the signed-in user (`POST /me/devices`). Sent on
/// logout so the server deletes the device. Kept apart from the push
/// controller so the session can read it without a provider cycle.

@ProviderFor(RegisteredPushToken)
final registeredPushTokenProvider = RegisteredPushTokenProvider._();

/// FCM token registered for the signed-in user (`POST /me/devices`). Sent on
/// logout so the server deletes the device. Kept apart from the push
/// controller so the session can read it without a provider cycle.
final class RegisteredPushTokenProvider
    extends $NotifierProvider<RegisteredPushToken, String?> {
  /// FCM token registered for the signed-in user (`POST /me/devices`). Sent on
  /// logout so the server deletes the device. Kept apart from the push
  /// controller so the session can read it without a provider cycle.
  RegisteredPushTokenProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'registeredPushTokenProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$registeredPushTokenHash();

  @$internal
  @override
  RegisteredPushToken create() => RegisteredPushToken();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$registeredPushTokenHash() =>
    r'3ee10dbdfb47903014b9560a17ecae5d4571d713';

/// FCM token registered for the signed-in user (`POST /me/devices`). Sent on
/// logout so the server deletes the device. Kept apart from the push
/// controller so the session can read it without a provider cycle.

abstract class _$RegisteredPushToken extends $Notifier<String?> {
  String? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<String?, String?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String?, String?>,
              String?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
