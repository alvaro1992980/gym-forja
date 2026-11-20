import 'dart:async';
import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../core/auth/session_controller.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/network/error_messages.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../data/kiosk_repository.dart';
import 'kiosk_controller.dart';

/// Kiosk mode (section 9.4): gym name, a big rotating QR, a countdown bar to
/// the next rotation and a clock. Offline it shows "Sin conexión" instead
/// of an expired QR. Long-pressing the logo for 5 s asks for an admin's
/// credentials and logs the kiosk out.
class KioskHomeScreen extends ConsumerStatefulWidget {
  const KioskHomeScreen({super.key});

  static const exitHold = Duration(seconds: 5);

  @override
  ConsumerState<KioskHomeScreen> createState() => _KioskHomeScreenState();
}

class _KioskHomeScreenState extends ConsumerState<KioskHomeScreen> {
  late final KioskDisplay _display;
  Timer? _hold;

  @override
  void initState() {
    super.initState();
    _display = ref.read(kioskDisplayProvider);
    unawaited(_display.enter());
  }

  @override
  void dispose() {
    _hold?.cancel();
    unawaited(_display.exit());
    super.dispose();
  }

  void _startHold() {
    _hold?.cancel();
    _hold = Timer(KioskHomeScreen.exitHold, _askExit);
  }

  void _cancelHold() => _hold?.cancel();

  Future<void> _askExit() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => const _AdminExitDialog(),
    );
    if (ok ?? false) {
      await ref.read(sessionControllerProvider.notifier).signOut();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(kioskControllerProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, box) {
            final qrSize = math.min(box.maxWidth, box.maxHeight) * 0.75;
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Row(
                    children: [
                      Listener(
                        key: const Key('kiosk.logo'),
                        onPointerDown: (_) => _startHold(),
                        onPointerUp: (_) => _cancelHold(),
                        onPointerCancel: (_) => _cancelHold(),
                        child: Icon(
                          Icons.fitness_center,
                          size: 40,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          state.gymName.isEmpty ? l10n.appTitle : state.gymName,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: Colors.black87,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        DateFormat.Hm().format(state.now),
                        key: const Key('kiosk.clock'),
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: Center(
                      child: state.showQr
                          ? KioskQr(
                              key: const Key('kiosk.qr'),
                              token: state.qr!.token,
                              size: qrSize,
                            )
                          : _Status(offline: state.offline, size: qrSize),
                    ),
                  ),
                  if (state.showQr) ...[
                    LinearProgressIndicator(
                      key: const Key('kiosk.countdown'),
                      value: state.rotationProgress,
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    if (state.offline)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          l10n.kioskOffline,
                          style: TextStyle(color: theme.colorScheme.error),
                        ),
                      ),
                  ],
                  const SizedBox(height: 24),
                  Text(
                    l10n.kioskScanHint,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _Status extends StatelessWidget {
  const _Status({required this.offline, required this.size});

  final bool offline;
  final double size;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return SizedBox.square(
      dimension: size,
      child: offline
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.wifi_off, size: 96, color: theme.colorScheme.error),
                const SizedBox(height: 16),
                Text(
                  l10n.kioskOffline,
                  key: const Key('kiosk.offline'),
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.kioskRetrying,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: Colors.black54,
                  ),
                ),
              ],
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}

/// Asks for an admin's phone and password before leaving kiosk mode.
class _AdminExitDialog extends ConsumerStatefulWidget {
  const _AdminExitDialog();

  @override
  ConsumerState<_AdminExitDialog> createState() => _AdminExitDialogState();
}

class _AdminExitDialogState extends ConsumerState<_AdminExitDialog> {
  final _phone = TextEditingController();
  final _password = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _phone.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context);
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final ok = await ref
          .read(kioskRepositoryProvider)
          .verifyAdmin(phone: _phone.text, password: _password.text);
      if (!mounted) return;
      if (ok) {
        Navigator.of(context).pop(true);
        return;
      }
      setState(() => _error = l10n.kioskExitWrong);
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = errorMessage(l10n, e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.kioskExitTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(l10n.kioskExitBody),
          const SizedBox(height: 12),
          TextField(
            key: const Key('kioskExit.phone'),
            controller: _phone,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(labelText: l10n.loginPhoneLabel),
          ),
          TextField(
            key: const Key('kioskExit.password'),
            controller: _password,
            obscureText: true,
            decoration: InputDecoration(labelText: l10n.loginPasswordLabel),
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _busy ? null : () => Navigator.of(context).pop(false),
          child: Text(l10n.commonCancel),
        ),
        FilledButton(
          key: const Key('kioskExit.confirm'),
          onPressed: _busy ? null : _submit,
          child: Text(l10n.kioskExitConfirm),
        ),
      ],
    );
  }
}

/// The rotating check-in QR, black on white.
class KioskQr extends StatelessWidget {
  const KioskQr({super.key, required this.token, required this.size});

  final String token;
  final double size;

  @override
  Widget build(BuildContext context) => QrImageView(
    data: token,
    size: size,
    backgroundColor: Colors.white,
    semanticsLabel: AppLocalizations.of(context).kioskScanHint,
  );
}
