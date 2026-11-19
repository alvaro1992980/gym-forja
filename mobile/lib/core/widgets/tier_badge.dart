import 'package:material_ui/material_ui.dart';

import '../../l10n/generated/app_localizations.dart';
import '../models/enums.dart';
import '../theme/app_theme.dart';

/// The same tier badge everywhere: colored pill with the tier name, so the
/// tier never relies on color alone.
class TierBadge extends StatelessWidget {
  const TierBadge(this.tier, {super.key});

  final Tier tier;

  static String label(AppLocalizations l10n, Tier tier) => switch (tier) {
    Tier.basic => l10n.tierBasic,
    Tier.plus => l10n.tierPlus,
    Tier.premium => l10n.tierPremium,
  };

  @override
  Widget build(BuildContext context) {
    final text = label(AppLocalizations.of(context), tier);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: TierColors.background(tier),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text.toUpperCase(),
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: TierColors.foreground(tier),
          fontWeight: FontWeight.bold,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}
