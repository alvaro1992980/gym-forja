import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/auth/session_controller.dart';
import '../../../core/network/error_messages.dart';
import '../../../core/widgets/state_views.dart';
import '../../../l10n/generated/app_localizations.dart';

/// Shown while the stored session is checked (section 9.1 #1). The router
/// leaves this screen as soon as the session is known.
class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final session = ref.watch(sessionControllerProvider);
    return Scaffold(
      body: SafeArea(
        child: switch (session) {
          SessionRestoreFailed(:final error) => ErrorView(
            message:
                '${l10n.splashRestoreFailed}\n${errorMessage(l10n, error)}',
            onRetry: () =>
                ref.read(sessionControllerProvider.notifier).restore(),
          ),
          _ => const LoadingView(),
        },
      ),
    );
  }
}
