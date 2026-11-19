import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/auth/session_controller.dart';
import '../../../../l10n/generated/app_localizations.dart';

/// "Más" tab (section 9.3 #9).
class MoreScreen extends ConsumerWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.navMore)),
      body: ListView(
        children: [
          ListTile(
            key: const Key('more.pricing'),
            leading: const Icon(Icons.sell_outlined),
            title: Text(l10n.morePricing),
            onTap: () => context.go('/admin/more/pricing'),
          ),
          ListTile(
            key: const Key('more.staff'),
            leading: const Icon(Icons.badge_outlined),
            title: Text(l10n.moreStaff),
            onTap: () => context.go('/admin/more/staff'),
          ),
          ListTile(
            leading: const Icon(Icons.bar_chart),
            title: Text(l10n.moreReports),
            subtitle: Text(l10n.commonComingSoon),
            enabled: false,
          ),
          ListTile(
            key: const Key('more.settings'),
            leading: const Icon(Icons.settings_outlined),
            title: Text(l10n.moreSettings),
            onTap: () => context.go('/admin/more/settings'),
          ),
          ListTile(
            key: const Key('more.profile'),
            leading: const Icon(Icons.person_outline),
            title: Text(l10n.moreProfile),
            onTap: () => context.go('/admin/more/profile'),
          ),
          const Divider(),
          ListTile(
            key: const Key('more.logout'),
            leading: const Icon(Icons.logout),
            title: Text(l10n.logout),
            onTap: () => ref.read(sessionControllerProvider.notifier).signOut(),
          ),
        ],
      ),
    );
  }
}

/// Own profile (read-only in v1).
class AdminProfileScreen extends ConsumerWidget {
  const AdminProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final session = ref.watch(sessionControllerProvider);
    final user = session is SessionSignedIn ? session.user : null;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.moreProfile)),
      body: user == null
          ? const SizedBox()
          : ListView(
              children: [
                ListTile(
                  title: Text(l10n.profileFirstName),
                  subtitle: Text(user.fullName),
                ),
                ListTile(
                  title: Text(l10n.profilePhone),
                  subtitle: Text(user.phone),
                ),
                ListTile(
                  title: Text(l10n.profileEmail),
                  subtitle: Text(user.email ?? l10n.commonNotSet),
                ),
                ListTile(
                  title: Text(l10n.fieldRole),
                  subtitle: Text(l10n.roleAdmin),
                ),
              ],
            ),
    );
  }
}
