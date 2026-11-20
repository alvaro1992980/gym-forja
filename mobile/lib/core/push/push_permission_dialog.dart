import 'package:material_ui/material_ui.dart';

import '../../l10n/generated/app_localizations.dart';
import '../router/app_router.dart';

/// The short explanation before the system permission request (section
/// 9.8). True when the user wants notifications.
Future<bool> showPushExplanation() async {
  final context = rootNavigatorKey.currentContext;
  if (context == null) return false;
  final accepted = await showDialog<bool>(
    context: context,
    builder: (context) {
      final l10n = AppLocalizations.of(context);
      return AlertDialog(
        icon: const Icon(Icons.notifications_active_outlined),
        title: Text(l10n.pushExplainTitle),
        content: Text(l10n.pushExplainBody),
        actions: [
          TextButton(
            key: const Key('push.later'),
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.pushExplainLater),
          ),
          FilledButton(
            key: const Key('push.enable'),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.pushExplainEnable),
          ),
        ],
      );
    },
  );
  return accepted ?? false;
}
