// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scanner_devices.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(cameraPermission)
final cameraPermissionProvider = CameraPermissionProvider._();

final class CameraPermissionProvider
    extends
        $FunctionalProvider<
          CameraPermission,
          CameraPermission,
          CameraPermission
        >
    with $Provider<CameraPermission> {
  CameraPermissionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'cameraPermissionProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$cameraPermissionHash();

  @$internal
  @override
  $ProviderElement<CameraPermission> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CameraPermission create(Ref ref) {
    return cameraPermission(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CameraPermission value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CameraPermission>(value),
    );
  }
}

String _$cameraPermissionHash() => r'b0c58ef5a25bb7f65e42563c2017314d9156b1df';

/// Creates a scanner for each scanner screen.

@ProviderFor(qrScannerFactory)
final qrScannerFactoryProvider = QrScannerFactoryProvider._();

/// Creates a scanner for each scanner screen.

final class QrScannerFactoryProvider
    extends
        $FunctionalProvider<
          QrScanner Function(),
          QrScanner Function(),
          QrScanner Function()
        >
    with $Provider<QrScanner Function()> {
  /// Creates a scanner for each scanner screen.
  QrScannerFactoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'qrScannerFactoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$qrScannerFactoryHash();

  @$internal
  @override
  $ProviderElement<QrScanner Function()> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  QrScanner Function() create(Ref ref) {
    return qrScannerFactory(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(QrScanner Function() value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<QrScanner Function()>(value),
    );
  }
}

String _$qrScannerFactoryHash() => r'd814f729f8a5c569d8770b5ea808ec226a432d2d';
