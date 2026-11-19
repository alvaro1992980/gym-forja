import 'package:material_ui/material_ui.dart';

import '../../../core/widgets/role_home_scaffold.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../shared/greeting_placeholder.dart';

/// Placeholder admin home (D4). Dashboard and bottom navigation come in D5/D9.
class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return RoleHomeScaffold(
      title: l10n.homeAdminTitle,
      body: GreetingPlaceholder(roleLabel: l10n.roleAdmin),
    );
  }
}
