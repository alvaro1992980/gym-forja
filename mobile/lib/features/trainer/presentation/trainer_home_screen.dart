import 'package:material_ui/material_ui.dart';

import '../../../core/widgets/role_home_scaffold.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../shared/greeting_placeholder.dart';

/// Placeholder trainer home (D4). "My members" comes with D13.
class TrainerHomeScreen extends StatelessWidget {
  const TrainerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return RoleHomeScaffold(
      title: l10n.homeTrainerTitle,
      body: GreetingPlaceholder(roleLabel: l10n.roleTrainer),
    );
  }
}
