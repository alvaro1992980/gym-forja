import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../features/notifications/presentation/notification_bell.dart';
import '../../l10n/generated/app_localizations.dart';
import '../auth/session_controller.dart';

/// Shell for the placeholder role homes (D4): title, logout action and body.
class RoleHomeScaffold extends ConsumerWidget {
  const RoleHomeScaffold({
    super.key,
    required this.title,
    required this.body,
    this.showBell = false,
  });

  final String title;
  final Widget body;
  final bool showBell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          if (showBell) const NotificationBell(),
          IconButton(
            tooltip: l10n.logout,
            icon: const Icon(Icons.logout),
            onPressed: () =>
                ref.read(sessionControllerProvider.notifier).signOut(),
          ),
        ],
      ),
      body: SafeArea(child: body),
    );
  }
}
