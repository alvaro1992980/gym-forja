import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/auth/session_controller.dart';
import '../../../core/router/app_router.dart';
import '../../../l10n/generated/app_localizations.dart';
import 'inbox_providers.dart';

/// App bar bell with the unread count (section 9.5 #1). Opens the inbox.
class NotificationBell extends ConsumerWidget {
  const NotificationBell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final count = ref.watch(unreadCountProvider).value ?? 0;
    final session = ref.watch(sessionControllerProvider);
    if (session is! SessionSignedIn) return const SizedBox.shrink();
    return IconButton(
      key: const Key('notifications.bell'),
      tooltip: count == 0
          ? l10n.notificationsTitle
          : l10n.notificationsUnread(count),
      onPressed: () => context.push(Routes.notificationsFor(session.user.role)),
      icon: Badge(
        isLabelVisible: count > 0,
        label: Text(count > 99 ? '99+' : '$count'),
        child: Icon(count > 0 ? Icons.notifications : Icons.notifications_none),
      ),
    );
  }
}
