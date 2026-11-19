import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/auth/session_controller.dart';
import '../../l10n/generated/app_localizations.dart';

/// Body of the D4 placeholder homes: greeting, role and an optional extra.
class GreetingPlaceholder extends ConsumerWidget {
  const GreetingPlaceholder({super.key, required this.roleLabel, this.child});

  final String roleLabel;
  final Widget? child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final session = ref.watch(sessionControllerProvider);
    final name = session is SessionSignedIn ? session.user.firstName : '';

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(l10n.homeGreeting(name), style: theme.textTheme.headlineSmall),
        const SizedBox(height: 4),
        Text(roleLabel, style: theme.textTheme.titleMedium),
        if (child != null) ...[const SizedBox(height: 24), child!],
        const SizedBox(height: 24),
        Text(l10n.commonComingSoon, style: theme.textTheme.bodyMedium),
      ],
    );
  }
}
