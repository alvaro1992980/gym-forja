import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/models/enums.dart';
import '../../../core/utils/clock.dart';
import '../../../core/utils/formatters.dart';
import '../../../l10n/generated/app_localizations.dart';

/// Days a membership is still covered, worded for lists: "12 días",
/// "Vencido hace 3 días" (red) or "Inactivo". Color is never the only cue.
class MemberStatusLabel extends ConsumerWidget {
  const MemberStatusLabel({
    super.key,
    required this.status,
    required this.daysLeft,
    required this.endDate,
    this.style,
  });

  final MemberStatus status;
  final int daysLeft;
  final String endDate;
  final TextStyle? style;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final (text, color) = describe(
      l10n,
      Theme.of(context).colorScheme,
      today: ref.watch(clockProvider).today(),
    );
    return Text(
      text,
      style: (style ?? Theme.of(context).textTheme.bodyMedium)?.copyWith(
        color: color,
        fontWeight: status == MemberStatus.active ? null : FontWeight.w600,
      ),
    );
  }

  (String, Color?) describe(
    AppLocalizations l10n,
    ColorScheme scheme, {
    required DateTime today,
  }) => switch (status) {
    MemberStatus.inactive => (l10n.memberInactive, scheme.outline),
    MemberStatus.expired => (
      l10n.memberExpiredAgo(daysBetween(parseApiDate(endDate), today)),
      scheme.error,
    ),
    MemberStatus.active => (
      l10n.memberDaysLeftShort(daysLeft),
      daysLeft <= 7 ? Colors.orange.shade800 : null,
    ),
  };
}
