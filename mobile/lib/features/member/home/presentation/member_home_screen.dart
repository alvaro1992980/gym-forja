import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/auth/session_controller.dart';
import '../../../../core/models/enums.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/role_home_scaffold.dart';
import '../../../../core/widgets/tier_badge.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../auth/domain/current_user.dart';
import '../../../shared/greeting_placeholder.dart';

/// Placeholder member home (D4): tier and days left from `/me`. The full
/// membership card and scan button come with D7.
class MemberHomeScreen extends ConsumerWidget {
  const MemberHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final session = ref.watch(sessionControllerProvider);
    final membership = session is SessionSignedIn
        ? session.user.membership
        : null;
    return RoleHomeScaffold(
      title: l10n.homeMemberTitle,
      body: GreetingPlaceholder(
        roleLabel: l10n.roleMember,
        child: _MembershipSummaryCard(membership: membership),
      ),
    );
  }
}

class _MembershipSummaryCard extends StatelessWidget {
  const _MembershipSummaryCard({required this.membership});

  final MembershipSummary? membership;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final m = membership;
    if (m == null) return Text(l10n.membershipNone);

    final expired = m.status == MembershipStatus.expired;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TierBadge(m.tier),
            const SizedBox(height: 12),
            Text(
              expired
                  ? l10n.membershipExpired
                  : l10n.membershipDaysLeft(m.daysLeft),
              style: theme.textTheme.titleLarge?.copyWith(
                color: expired ? theme.colorScheme.error : null,
              ),
            ),
            const SizedBox(height: 4),
            Text(l10n.membershipEndDate(formatApiDate(m.endDate))),
          ],
        ),
      ),
    );
  }
}
