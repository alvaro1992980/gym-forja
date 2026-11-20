import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/utils/device_actions.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../data/member_repository.dart';
import '../../home/presentation/member_home_providers.dart';
import '../../home/presentation/member_home_screen.dart';
import '../domain/checkin_result.dart';
import 'scanner_devices.dart';

enum _Step { checking, explain, denied, blocked, scanning, sending }

/// Scanner (section 9.5 #2): explain → request the camera → scan (frame
/// overlay, torch). On a QR: vibrate, stop the camera, `POST /checkins`,
/// then the result screen.
class ScannerScreen extends ConsumerStatefulWidget {
  const ScannerScreen({super.key});

  @override
  ConsumerState<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends ConsumerState<ScannerScreen>
    with WidgetsBindingObserver {
  _Step _step = _Step.checking;
  QrScanner? _scanner;

  CameraPermission get _permission => ref.read(cameraPermissionProvider);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(_checkPermission());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scanner?.dispose();
    super.dispose();
  }

  /// Back from the system settings: check again.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed &&
        (_step == _Step.blocked || _step == _Step.denied)) {
      unawaited(_checkPermission());
    }
  }

  Future<void> _checkPermission() async {
    final access = await _permission.status();
    if (!mounted) return;
    switch (access) {
      case CameraAccess.granted:
        _startScanning();
      case CameraAccess.denied:
        // Not asked yet, or asked once: explain first.
        if (_step == _Step.checking) setState(() => _step = _Step.explain);
      case CameraAccess.permanentlyDenied:
        setState(() => _step = _Step.blocked);
    }
  }

  Future<void> _request() async {
    final access = await _permission.request();
    if (!mounted) return;
    switch (access) {
      case CameraAccess.granted:
        _startScanning();
      case CameraAccess.denied:
        setState(() => _step = _Step.denied);
      case CameraAccess.permanentlyDenied:
        setState(() => _step = _Step.blocked);
    }
  }

  void _startScanning() {
    _scanner ??= ref.read(qrScannerFactoryProvider)();
    setState(() => _step = _Step.scanning);
  }

  Future<void> _onCode(String code) async {
    if (_step != _Step.scanning) return;
    setState(() => _step = _Step.sending);
    unawaited(ref.read(deviceActionsProvider).vibrate());
    unawaited(_scanner?.stop());

    CheckinOutcome outcome;
    try {
      outcome = CheckinAccepted(
        await ref.read(memberRepositoryProvider).checkIn(code),
      );
    } on Object catch (e) {
      outcome = CheckinOutcome.fromError(e);
    }
    ref.invalidate(memberHomeProvider);
    if (mounted) {
      context.pushReplacement(MemberRoutes.result, extra: outcome);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scanner = _scanner;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.scannerTitle),
        actions: [
          if (_step == _Step.scanning && scanner != null)
            IconButton(
              key: const Key('scanner.torch'),
              tooltip: l10n.scannerTorch,
              icon: const Icon(Icons.flashlight_on_outlined),
              onPressed: scanner.toggleTorch,
            ),
        ],
      ),
      body: switch (_step) {
        _Step.checking => const SizedBox.shrink(),
        _Step.explain => _PermissionMessage(
          icon: Icons.photo_camera_outlined,
          message: l10n.scannerExplain,
          action: l10n.scannerAllowCamera,
          onPressed: _request,
        ),
        _Step.denied => _PermissionMessage(
          icon: Icons.no_photography_outlined,
          message: l10n.scannerDenied,
          action: l10n.scannerAllowCamera,
          onPressed: _request,
        ),
        _Step.blocked => _PermissionMessage(
          icon: Icons.no_photography_outlined,
          message: l10n.scannerBlocked,
          action: l10n.scannerOpenSettings,
          onPressed: _permission.openSettings,
        ),
        _Step.scanning || _Step.sending => Stack(
          fit: StackFit.expand,
          children: [
            scanner!.view(_onCode),
            const _ScanFrame(),
            Positioned(
              left: 24,
              right: 24,
              bottom: 48,
              child: Text(
                l10n.scannerHint,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  shadows: const [Shadow(blurRadius: 4)],
                ),
              ),
            ),
            if (_step == _Step.sending)
              ColoredBox(
                color: Colors.black54,
                child: LoadingView(message: l10n.scannerSending),
              ),
          ],
        ),
      },
    );
  }
}

class _PermissionMessage extends StatelessWidget {
  const _PermissionMessage({
    required this.icon,
    required this.message,
    required this.action,
    required this.onPressed,
  });

  final IconData icon;
  final String message;
  final String action;
  final Future<Object?> Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 72, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 24),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            FilledButton(
              key: const Key('scanner.permissionAction'),
              onPressed: onPressed,
              child: Text(action),
            ),
          ],
        ),
      ),
    );
  }
}

/// Square frame in the middle of the preview.
class _ScanFrame extends StatelessWidget {
  const _ScanFrame();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, box) {
        final side = box.biggest.shortestSide * 0.7;
        return Center(
          child: Container(
            width: side,
            height: side,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white, width: 4),
              borderRadius: BorderRadius.circular(24),
            ),
          ),
        );
      },
    );
  }
}
