import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/async_view.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../../core/widgets/tier_badge.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../domain/checkin_models.dart';
import 'live_checkins_providers.dart';

/// Check-ins (live), section 9.3 #7: tabs "Adentro ahora" and "Hoy". New
/// entries slide in at the top; denied entries are red.
class LiveCheckinsScreen extends ConsumerWidget {
  const LiveCheckinsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final feed = ref.watch(liveCheckinsProvider);
    final alerts = ref.watch(checkinAlertsEnabledProvider);
    Future<void> refresh() => ref.read(liveCheckinsProvider.notifier).refresh();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.navCheckins),
          actions: [
            IconButton(
              key: const Key('checkins.alerts'),
              tooltip: alerts ? l10n.checkinsAlertsOn : l10n.checkinsAlertsOff,
              icon: Icon(
                alerts ? Icons.notifications_active : Icons.notifications_off,
              ),
              onPressed: () =>
                  ref.read(checkinAlertsEnabledProvider.notifier).toggle(),
            ),
          ],
          bottom: TabBar(
            tabs: [
              Tab(
                text: feed.value == null
                    ? l10n.checkinsInsideTab
                    : l10n.checkinsInsideTabCount(feed.value!.inside.length),
              ),
              Tab(text: l10n.checkinsTodayTab),
            ],
          ),
        ),
        body: AsyncView(
          value: feed,
          onRetry: refresh,
          data: (feed) => TabBarView(
            children: [
              _RefreshableList(
                onRefresh: refresh,
                header: l10n.checkinsInsideHint(feed.windowMinutes),
                empty: l10n.checkinsInsideEmpty,
                children: [
                  for (final c in feed.inside)
                    _Animated(
                      key: ValueKey('inside:${c.id}'),
                      animate: feed.fresh.contains('c:${c.id}'),
                      child: CheckinTile(checkin: c),
                    ),
                ],
              ),
              _RefreshableList(
                onRefresh: refresh,
                empty: l10n.checkinsTodayEmpty,
                children: [
                  for (final e in feed.today)
                    _Animated(
                      key: ValueKey(e.key),
                      animate: feed.fresh.contains(e.key),
                      child: switch (e) {
                        FeedCheckin(:final checkin) => CheckinTile(
                          checkin: checkin,
                        ),
                        final FeedDenied d => DeniedTile(entry: d),
                      },
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RefreshableList extends StatelessWidget {
  const _RefreshableList({
    required this.onRefresh,
    required this.children,
    required this.empty,
    this.header,
  });

  final Future<void> Function() onRefresh;
  final List<Widget> children;
  final String empty;
  final String? header;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: children.isEmpty
          ? ListView(
              children: [
                const SizedBox(height: 80),
                EmptyView(message: empty, icon: Icons.door_front_door_outlined),
              ],
            )
          : ListView(
              children: [
                if (header != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                    child: Text(
                      header!,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ...children,
              ],
            ),
    );
  }
}

/// Slides and fades in entries that arrived live.
class _Animated extends StatelessWidget {
  const _Animated({super.key, required this.animate, required this.child});

  final bool animate;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!animate) return child;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOutCubic,
      builder: (_, t, child) => Opacity(
        opacity: t,
        child: Align(
          alignment: Alignment.topCenter,
          heightFactor: t,
          child: child,
        ),
      ),
      child: Material(
        color: Theme.of(context).colorScheme.primaryContainer.withAlpha(60),
        child: child,
      ),
    );
  }
}

/// A successful check-in: member, tier, days left and time. Opens the member.
class CheckinTile extends StatelessWidget {
  const CheckinTile({super.key, required this.checkin});

  final CheckinItem checkin;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ListTile(
      leading: const CircleAvatar(child: Icon(Icons.login)),
      title: Text(checkin.member.fullName),
      subtitle: Text(
        '${formatTime(checkin.createdAt)} · '
        '${l10n.memberDaysLeftShort(checkin.daysLeft)}',
      ),
      trailing: TierBadge(checkin.tier),
      onTap: () => context.push('/admin/members/${checkin.member.id}'),
    );
  }
}

/// A denied entry, in red with the reason in words (never color alone).
class DeniedTile extends StatelessWidget {
  const DeniedTile({super.key, required this.entry});

  final FeedDenied entry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final error = Theme.of(context).colorScheme.error;
    final reason = entry.expired
        ? (entry.endDate == null
              ? l10n.checkinsDeniedExpiredShort
              : l10n.checkinsDeniedExpired(formatApiDate(entry.endDate!)))
        : l10n.checkinsDeniedInactive;
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: error,
        foregroundColor: Theme.of(context).colorScheme.onError,
        child: const Icon(Icons.block),
      ),
      title: Text(
        entry.member.fullName,
        style: TextStyle(color: error, fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        '${formatTime(entry.createdAt)} · ${l10n.checkinsDenied} · $reason',
        style: TextStyle(color: error),
      ),
      onTap: () => context.push('/admin/members/${entry.member.id}'),
    );
  }
}
