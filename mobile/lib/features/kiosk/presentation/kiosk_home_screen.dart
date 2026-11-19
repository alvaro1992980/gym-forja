import 'package:material_ui/material_ui.dart';

import '../../../core/widgets/role_home_scaffold.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../shared/greeting_placeholder.dart';

/// Placeholder kiosk home (D4). The rotating QR screen comes with D7.
class KioskHomeScreen extends StatelessWidget {
  const KioskHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return RoleHomeScaffold(
      title: l10n.homeKioskTitle,
      body: GreetingPlaceholder(roleLabel: l10n.roleKiosk),
    );
  }
}
