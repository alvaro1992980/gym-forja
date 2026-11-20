// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kiosk_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Fetches a new QR token every `refreshInSeconds` (30 s) [R-18]; after a
/// failure it retries every [retryDelay].

@ProviderFor(KioskController)
final kioskControllerProvider = KioskControllerProvider._();

/// Fetches a new QR token every `refreshInSeconds` (30 s) [R-18]; after a
/// failure it retries every [retryDelay].
final class KioskControllerProvider
    extends $NotifierProvider<KioskController, KioskState> {
  /// Fetches a new QR token every `refreshInSeconds` (30 s) [R-18]; after a
  /// failure it retries every [retryDelay].
  KioskControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'kioskControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$kioskControllerHash();

  @$internal
  @override
  KioskController create() => KioskController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(KioskState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<KioskState>(value),
    );
  }
}

String _$kioskControllerHash() => r'92d66be9ce755f0c6d10baf83b59bb6462b4aad1';

/// Fetches a new QR token every `refreshInSeconds` (30 s) [R-18]; after a
/// failure it retries every [retryDelay].

abstract class _$KioskController extends $Notifier<KioskState> {
  KioskState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<KioskState, KioskState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<KioskState, KioskState>,
              KioskState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(kioskDisplay)
final kioskDisplayProvider = KioskDisplayProvider._();

final class KioskDisplayProvider
    extends $FunctionalProvider<KioskDisplay, KioskDisplay, KioskDisplay>
    with $Provider<KioskDisplay> {
  KioskDisplayProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'kioskDisplayProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$kioskDisplayHash();

  @$internal
  @override
  $ProviderElement<KioskDisplay> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  KioskDisplay create(Ref ref) {
    return kioskDisplay(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(KioskDisplay value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<KioskDisplay>(value),
    );
  }
}

String _$kioskDisplayHash() => r'528a7efc9e4e4f10e997d2719190816fd7d63a35';
