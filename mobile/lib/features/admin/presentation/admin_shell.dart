import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/widgets/state_views.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../checkins/presentation/live_checkins_providers.dart';

/// Admin bottom navigation (section 9.2): Dashboard · Socios · Ingresos ·
/// Planes · Más. While it is shown, live check-ins play the alert.
class AdminShell extends ConsumerWidget {
  const AdminShell({super.key, required this.shell});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(checkinAlertsProvider);
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: shell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: shell.currentIndex,
        onDestinationSelected: (i) =>
            shell.goBranch(i, initialLocation: i == shell.currentIndex),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.dashboard_outlined),
            selectedIcon: const Icon(Icons.dashboard),
            label: l10n.navDashboard,
          ),
          NavigationDestination(
            key: const Key('nav.members'),
            icon: const Icon(Icons.people_outline),
            selectedIcon: const Icon(Icons.people),
            label: l10n.navMembers,
          ),
          NavigationDestination(
            key: const Key('nav.checkins'),
            icon: const Icon(Icons.login_outlined),
            selectedIcon: const Icon(Icons.login),
            label: l10n.navCheckins,
          ),
          NavigationDestination(
            icon: const Icon(Icons.fitness_center_outlined),
            selectedIcon: const Icon(Icons.fitness_center),
            label: l10n.navPlans,
          ),
          NavigationDestination(
            key: const Key('nav.more'),
            icon: const Icon(Icons.menu),
            selectedIcon: const Icon(Icons.menu_open),
            label: l10n.navMore,
          ),
        ],
      ),
    );
  }
}

/// Tabs whose screens come in later deliverables (plans D11).
class ComingSoonScreen extends StatelessWidget {
  const ComingSoonScreen({super.key, required this.title});

  final String Function(AppLocalizations l10n) title;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(title(l10n))),
      body: EmptyView(message: l10n.commonComingSoon, icon: Icons.construction),
    );
  }
}
