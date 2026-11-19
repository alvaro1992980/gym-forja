import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/models/enums.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/async_view.dart';
import '../../../../core/widgets/chip_bar.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../../core/widgets/tier_badge.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../shared/labels.dart';
import '../../shared/member_status_label.dart';
import '../domain/member_models.dart';
import 'members_providers.dart';

/// Members list (section 9.3 #2): search, filter chips, infinite scroll,
/// pull-to-refresh and the "Nuevo socio" button.
class MembersListScreen extends ConsumerStatefulWidget {
  const MembersListScreen({super.key});

  @override
  ConsumerState<MembersListScreen> createState() => _MembersListScreenState();
}

class _MembersListScreenState extends ConsumerState<MembersListScreen> {
  final _search = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _search.text = ref.read(memberFiltersControllerProvider).query;
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _search.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      ref.read(memberFiltersControllerProvider.notifier).setQuery(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final filters = ref.watch(memberFiltersControllerProvider);
    final controller = ref.read(memberFiltersControllerProvider.notifier);
    final list = ref.watch(membersListProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.navMembers)),
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('members.new'),
        heroTag: null,
        icon: const Icon(Icons.person_add),
        label: Text(l10n.membersNew),
        onPressed: () => context.push('/admin/members/new'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: TextField(
              key: const Key('members.search'),
              controller: _search,
              onChanged: _onSearchChanged,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: l10n.membersSearchHint,
                prefixIcon: const Icon(Icons.search),
              ),
            ),
          ),
          SizedBox(
            height: 56,
            child: ChipBar(
              children: [
                for (final (status, label) in [
                  (MemberStatusFilter.active, l10n.filterActive),
                  (MemberStatusFilter.expiring, l10n.filterExpiring),
                  (MemberStatusFilter.expired, l10n.filterExpired),
                  (MemberStatusFilter.inactive, l10n.filterInactive),
                ])
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      key: Key('members.filter.${status.name}'),
                      label: Text(label),
                      selected: filters.status == status,
                      onSelected: (_) => controller.toggleStatus(status),
                    ),
                  ),
                for (final tier in Tier.values)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      key: Key('members.filter.${tier.name}'),
                      label: Text(l10n.tierLabel(tier)),
                      selected: filters.tier == tier,
                      onSelected: (_) => controller.toggleTier(tier),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => ref.refresh(membersListProvider.future),
              child: AsyncView(
                value: list,
                onRetry: () => ref.invalidate(membersListProvider),
                data: (state) => state.items.isEmpty
                    ? ListView(
                        children: [
                          const SizedBox(height: 48),
                          EmptyView(
                            message: l10n.membersEmpty,
                            icon: Icons.people_outline,
                          ),
                        ],
                      )
                    : _MembersListView(state: state),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MembersListView extends ConsumerWidget {
  const _MembersListView({required this.state});

  final MembersListState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return NotificationListener<ScrollNotification>(
      onNotification: (n) {
        if (n.metrics.extentAfter < 300) {
          ref.read(membersListProvider.notifier).loadMore();
        }
        return false;
      },
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 96),
        itemCount: state.items.length + (state.hasMore ? 1 : 0),
        separatorBuilder: (_, _) => const Divider(height: 1),
        itemBuilder: (context, i) {
          if (i >= state.items.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          return MemberRow(member: state.items[i]);
        },
      ),
    );
  }
}

/// One member in the list: name, tier badge, days left, last check-in.
class MemberRow extends StatelessWidget {
  const MemberRow({super.key, required this.member});

  final MemberListItem member;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final last = member.lastCheckinAt;
    return ListTile(
      key: Key('member.${member.id}'),
      title: Text(member.fullName),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MemberStatusLabel(
            status: member.status,
            daysLeft: member.daysLeft,
            endDate: member.endDate,
          ),
          Text(
            last == null
                ? l10n.memberNoCheckins
                : l10n.memberLastCheckin(formatInstant(last)),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
      trailing: TierBadge(member.tier),
      onTap: () => context.push('/admin/members/${member.id}'),
    );
  }
}
