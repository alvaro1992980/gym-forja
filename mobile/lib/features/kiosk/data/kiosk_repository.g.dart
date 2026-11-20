// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kiosk_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(kioskRepository)
final kioskRepositoryProvider = KioskRepositoryProvider._();

final class KioskRepositoryProvider
    extends
        $FunctionalProvider<KioskRepository, KioskRepository, KioskRepository>
    with $Provider<KioskRepository> {
  KioskRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'kioskRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$kioskRepositoryHash();

  @$internal
  @override
  $ProviderElement<KioskRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  KioskRepository create(Ref ref) {
    return kioskRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(KioskRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<KioskRepository>(value),
    );
  }
}

String _$kioskRepositoryHash() => r'63b4104b062c6f2281dd17304503f72f1b51abf9';
