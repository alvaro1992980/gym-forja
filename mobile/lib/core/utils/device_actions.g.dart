// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_actions.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(deviceActions)
final deviceActionsProvider = DeviceActionsProvider._();

final class DeviceActionsProvider
    extends $FunctionalProvider<DeviceActions, DeviceActions, DeviceActions>
    with $Provider<DeviceActions> {
  DeviceActionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'deviceActionsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$deviceActionsHash();

  @$internal
  @override
  $ProviderElement<DeviceActions> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  DeviceActions create(Ref ref) {
    return deviceActions(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DeviceActions value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DeviceActions>(value),
    );
  }
}

String _$deviceActionsHash() => r'675958446e514ab14b5ef5f0f8114ba34025c95d';
