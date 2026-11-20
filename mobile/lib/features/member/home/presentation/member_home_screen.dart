import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/auth/session_controller.dart';
import '../../../../core/models/enums.dart';
import '../../../../core/utils/clock.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/async_view.dart';
import '../../../../core/widgets/tier_badge.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../auth/domain/current_user.dart';
import 'member_home_providers.dart';

/// Member home (section 9.5 #1): membership card, scan button and this
/// month's attendance.
class MemberHomeScreen extends ConsumerWidget {
  const MemberHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final session = ref.watch(sessionControllerProvider);
    final home = ref.watch(memberHomeProvider);
    final name = session is SessionSignedIn ? session.user.firstName : '';
    Future<void> refresh() => ref.refresh(memberHomeProvider.future);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.homeMemberTitle),
        actions: [
          IconButton(
            tooltip: l10n.logout,
            icon: const Icon(Icons.logout),
            onPressed: () =>
                ref.read(sessionControllerProvider.notifier).signOut(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: refresh,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              l10n.homeGreeting(name),
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            AsyncView(
              value: home,
              onRetry: refresh,
              data: (data) => MembershipCard(membership: data.membership),
            ),
            const SizedBox(height: 16),
            // Always enabled, also when expired: the server denies the entry
            // and tells the admin (section 9.5 #1).
            FilledButton.icon(
              key: const Key('member.scan'),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(64),
                textStyle: Theme.of(context).textTheme.titleMedium,
              ),
              onPressed: () => context.push(MemberRoutes.scan),
              icon: const Icon(Icons.qr_code_scanner, size: 28),
              label: Text(l10n.memberScanButton),
            ),
            if (home.value case final data?) ...[
              const SizedBox(height: 24),
              _Attendance(data: data),
            ],
          ],
        ),
      ),
    );
  }
}

/// Member routes (under `/member`, section 9.2).
abstract final class MemberRoutes {
  static const scan = '/member/scan';
  static const result = '/member/checkin-result';
}

/// Days-left ring colors (section 9.5 #1): green > 7 days, orange 1–7, red
/// expired.
Color membershipColor(BuildContext context, MembershipSummary m) {
  if (m.status == MembershipStatus.expired) {
    return Theme.of(context).colorScheme.error;
  }
  return m.daysLeft > 7 ? Colors.green.shade700 : Colors.orange.shade800;
}

/// Name, tier badge, "Te quedan 12 días" with a progress ring, end date.
class MembershipCard extends StatelessWidget {
  const MembershipCard({super.key, required this.membership});

  final MembershipSummary membership;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final m = membership;
    final expired = m.status == MembershipStatus.expired;
    final color = membershipColor(context, m);
    final periodDays =
        daysBetween(parseApiDate(m.startDate), parseApiDate(m.endDate)) + 1;

    return Card(
      key: const Key('member.card'),
      color: expired ? theme.colorScheme.errorContainer : null,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            SizedBox.square(
              dimension: 96,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CircularProgressIndicator(
                    value: expired
                        ? 1
                        : (m.daysLeft / periodDays).clamp(0, 1).toDouble(),
                    strokeWidth: 8,
                    color: color,
                    backgroundColor: color.withAlpha(40),
                  ),
                  Center(
                    child: expired
                        ? Icon(Icons.block, size: 40, color: color)
                        : Text(
                            '${m.daysLeft}',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              color: color,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TierBadge(m.tier),
                  const SizedBox(height: 8),
                  Text(
                    expired
                        ? l10n.membershipExpired
                        : l10n.membershipDaysLeft(m.daysLeft),
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: expired
                          ? theme.colorScheme.onErrorContainer
                          : color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    expired
                        ? l10n.memberExpiredOn(formatApiDate(m.endDate))
                        : l10n.membershipEndDate(formatApiDate(m.endDate)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Attendance extends ConsumerWidget {
  const _Attendance({required this.data});

  final MemberHomeData data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final today = ref.watch(clockProvider).today();
    final locale = Localizations.localeOf(context).toLanguageTag();
    final title = DateFormat.yMMMM(locale).format(data.month);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.memberCheckinsThisMonth(data.checkinsThisMonth),
              key: const Key('member.attendance'),
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              '${title[0].toUpperCase()}${title.substring(1)}',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            MiniCalendar(
              month: data.month,
              marked: data.checkinDays,
              today: today,
            ),
          ],
        ),
      ),
    );
  }
}

/// A month grid (Monday first) with the check-in days filled in.
class MiniCalendar extends StatelessWidget {
  const MiniCalendar({
    super.key,
    required this.month,
    required this.marked,
    required this.today,
  });

  final DateTime month;
  final Set<int> marked;
  final DateTime today;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final leading = month.weekday - 1; // Monday = 0
    final weekdayFormat = DateFormat.E(locale);
    // 2024-01-01 was a Monday.
    final weekdays = [
      for (var i = 0; i < 7; i++)
        weekdayFormat.format(DateTime(2024, 1, 1 + i)).substring(0, 1),
    ];
    final isThisMonth = today.year == month.year && today.month == month.month;

    Widget cell(int day) {
      final checked = marked.contains(day);
      final isToday = isThisMonth && today.day == day;
      return Container(
        key: checked ? Key('calendar.checkin.$day') : null,
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: checked ? theme.colorScheme.primary : null,
          border: isToday
              ? Border.all(color: theme.colorScheme.primary, width: 2)
              : null,
        ),
        alignment: Alignment.center,
        child: Text(
          '$day',
          style: theme.textTheme.bodySmall?.copyWith(
            color: checked ? theme.colorScheme.onPrimary : null,
            fontWeight: checked ? FontWeight.bold : null,
          ),
        ),
      );
    }

    return GridView.count(
      crossAxisCount: 7,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        for (final d in weekdays)
          Center(child: Text(d, style: theme.textTheme.labelSmall)),
        for (var i = 0; i < leading; i++) const SizedBox.shrink(),
        for (var day = 1; day <= daysInMonth; day++) cell(day),
      ],
    );
  }
}
