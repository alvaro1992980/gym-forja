import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/network/error_messages.dart';
import '../../../core/push/push_controller.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/async_view.dart';
import '../../../core/widgets/dialogs.dart';
import '../../../core/widgets/state_views.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../domain/app_notification.dart';
import 'inbox_providers.dart';

/// Notifications inbox (section 9.5 #9): newest first, tap → mark as read and
/// open the related screen, "mark all as read".
class InboxScreen extends ConsumerWidget {
  const InboxScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final inbox = ref.watch(inboxProvider);
    final hasUnread = inbox.value?.items.any((n) => !n.isRead) ?? false;

    Future<void> refresh() async {
      ref.invalidate(unreadCountProvider);
      final _ = await ref.refresh(inboxProvider.future);
    }

    Future<void> run(Future<void> Function() action) async {
      try {
        await action();
      } on ApiException catch (e) {
        if (context.mounted) showMessage(context, errorMessage(l10n, e));
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.notificationsTitle),
        actions: [
          IconButton(
            key: const Key('inbox.readAll'),
            tooltip: l10n.notificationsReadAll,
            icon: const Icon(Icons.done_all),
            onPressed: hasUnread
                ? () => run(ref.read(inboxProvider.notifier).markAllRead)
                : null,
          ),
        ],
      ),
      body: AsyncView(
        value: inbox,
        onRetry: () => ref.invalidate(inboxProvider),
        data: (state) => RefreshIndicator(
          onRefresh: refresh,
          child: state.items.isEmpty
              ? ListView(
                  children: [
                    const SizedBox(height: 80),
                    EmptyView(
                      message: l10n.notificationsEmpty,
                      icon: Icons.notifications_none,
                    ),
                  ],
                )
              : NotificationListener<ScrollNotification>(
                  onNotification: (n) {
                    if (n.metrics.extentAfter < 300) {
                      unawaited(ref.read(inboxProvider.notifier).loadMore());
                    }
                    return false;
                  },
                  child: ListView.separated(
                    itemCount: state.items.length + (state.hasMore ? 1 : 0),
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, i) {
                      if (i == state.items.length) {
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      final n = state.items[i];
                      return _NotificationTile(
                        notification: n,
                        onTap: () {
                          if (!n.isRead) {
                            unawaited(
                              run(
                                () => ref
                                    .read(inboxProvider.notifier)
                                    .markRead(n.id),
                              ),
                            );
                          }
                          ref
                              .read(pushControllerProvider.notifier)
                              .open(n.data);
                        },
                      );
                    },
                  ),
                ),
        ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.notification, required this.onTap});

  final AppNotification notification;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final unread = !notification.isRead;
    return ListTile(
      key: Key('inbox.${notification.id}'),
      leading: Icon(
        unread ? Icons.circle : Icons.circle_outlined,
        size: 12,
        color: unread ? theme.colorScheme.primary : theme.colorScheme.outline,
        semanticLabel: unread
            ? AppLocalizations.of(context).notificationsUnreadLabel
            : null,
      ),
      minLeadingWidth: 12,
      title: Text(
        notification.title,
        style: unread ? const TextStyle(fontWeight: FontWeight.bold) : null,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(notification.body),
          const SizedBox(height: 4),
          Text(
            formatInstant(notification.createdAt),
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
      isThreeLine: true,
      onTap: onTap,
    );
  }
}
