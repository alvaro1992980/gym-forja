import 'package:material_ui/material_ui.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'scanner_devices.g.dart';

/// Camera permission as the scanner needs it.
enum CameraAccess { granted, denied, permanentlyDenied }

/// Camera permission (permission_handler), replaceable in tests.
class CameraPermission {
  const CameraPermission();

  Future<CameraAccess> status() async => _map(await Permission.camera.status);

  Future<CameraAccess> request() async =>
      _map(await Permission.camera.request());

  Future<bool> openSettings() => openAppSettings();

  static CameraAccess _map(PermissionStatus s) => switch (s) {
    PermissionStatus.granted ||
    PermissionStatus.limited => CameraAccess.granted,
    PermissionStatus.permanentlyDenied ||
    PermissionStatus.restricted => CameraAccess.permanentlyDenied,
    _ => CameraAccess.denied,
  };
}

@Riverpod(keepAlive: true)
CameraPermission cameraPermission(Ref ref) => const CameraPermission();

/// A QR camera: its preview widget, torch and stop. Replaceable in tests,
/// where there is no camera.
abstract class QrScanner {
  /// Camera preview; [onCode] gets the text of each QR read.
  Widget view(void Function(String code) onCode);
  Future<void> toggleTorch();
  Future<void> stop();
  void dispose();
}

class MobileQrScanner implements QrScanner {
  final _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    formats: const [BarcodeFormat.qrCode],
  );

  @override
  Widget view(void Function(String code) onCode) => MobileScanner(
    controller: _controller,
    onDetect: (capture) {
      for (final barcode in capture.barcodes) {
        final value = barcode.rawValue;
        if (value != null && value.isNotEmpty) {
          onCode(value);
          return;
        }
      }
    },
  );

  @override
  Future<void> toggleTorch() => _controller.toggleTorch();

  @override
  Future<void> stop() => _controller.stop();

  @override
  void dispose() => _controller.dispose();
}

/// Creates a scanner for each scanner screen.
@Riverpod(keepAlive: true)
QrScanner Function() qrScannerFactory(Ref ref) => MobileQrScanner.new;
