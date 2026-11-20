import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/widgets/async_view.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../notifications/presentation/notification_bell.dart';
import '../checkins/presentation/live_checkins_providers.dart';
import '../checkins/presentation/live_checkins_screen.dart';

/// Admin dashboard (section 9.3 #1). The metric cards come with D9; the
/// "last check-ins" list is live since D7.
class AdminHomeScreen extends ConsumerWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final recent = ref.watch(recentCheckinsProvider);
    Future<void> refresh() =>
        ref.read(recentCheckinsProvider.notifier).refresh();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.navDashboard),
        actions: const [NotificationBell()],
      ),
      body: RefreshIndicator(
        onRefresh: refresh,
        child: ListView(
          children: [
            Card(
              margin: const EdgeInsets.all(16),
              child: ListTile(
                leading: const Icon(Icons.insights_outlined),
                title: Text(l10n.dashboardMetricsSoon),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Text(
                l10n.dashboardRecentCheckins,
                style: theme.textTheme.titleMedium,
              ),
            ),
            AsyncView(
              value: recent,
              onRetry: refresh,
              data: (items) => items.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(l10n.dashboardNoCheckins),
                    )
                  : Column(
                      children: [
                        for (final c in items)
                          CheckinTile(key: ValueKey(c.id), checkin: c),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
