import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/utils/device_actions.dart';
import '../../../core/widgets/dialogs.dart';
import '../../../l10n/generated/app_localizations.dart';

/// What the temporary password screen shows, passed as the route `extra`.
class TemporaryPasswordArgs {
  const TemporaryPasswordArgs({
    required this.firstName,
    required this.fullName,
    required this.phone,
    required this.password,
    required this.doneLocation,
  });

  final String firstName;
  final String fullName;
  final String phone;
  final String password;

  /// Where "Listo" goes (e.g. the new member's detail).
  final String doneLocation;
}

/// [R-41]/[R-44] Shows a temporary password once, with copy and share
/// (section 9.3 #3.5). Leaving the screen discards it.
class TemporaryPasswordScreen extends ConsumerWidget {
  const TemporaryPasswordScreen({super.key, required this.args});

  final TemporaryPasswordArgs args;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final actions = ref.read(deviceActionsProvider);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) context.go(args.doneLocation);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.tempPasswordTitle),
          automaticallyImplyLeading: false,
        ),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Icon(
                Icons.check_circle,
                size: 56,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                l10n.tempPasswordCreated(args.fullName),
                textAlign: TextAlign.center,
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.tempPasswordUser(args.phone),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: SelectableText(
                    args.password,
                    key: const Key('tempPassword.value'),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.displaySmall?.copyWith(
                      fontFamily: 'monospace',
                      letterSpacing: 4,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                color: theme.colorScheme.errorContainer,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(
                        Icons.warning_amber,
                        color: theme.colorScheme.onErrorContainer,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          l10n.tempPasswordWarning,
                          style: TextStyle(
                            color: theme.colorScheme.onErrorContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              OutlinedButton.icon(
                key: const Key('tempPassword.copy'),
                icon: const Icon(Icons.copy),
                label: Text(l10n.tempPasswordCopy),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
                onPressed: () async {
                  await actions.copy(args.password);
                  if (context.mounted) {
                    showMessage(context, l10n.tempPasswordCopied);
                  }
                },
              ),
              const SizedBox(height: 12),
              FilledButton.tonalIcon(
                key: const Key('tempPassword.share'),
                icon: const Icon(Icons.share),
                label: Text(l10n.tempPasswordShare),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
                onPressed: () => actions.share(
                  l10n.tempPasswordShareText(
                    args.firstName,
                    args.phone,
                    args.password,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              FilledButton(
                key: const Key('tempPassword.done'),
                onPressed: () => context.go(args.doneLocation),
                child: Text(l10n.commonDone),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
