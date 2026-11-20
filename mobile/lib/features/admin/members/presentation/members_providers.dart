import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/models/enums.dart';
import '../../checkins/data/checkins_repository.dart';
import '../../checkins/domain/checkin_models.dart';
import '../data/members_repository.dart';
import '../domain/member_models.dart';

part 'members_providers.g.dart';

/// Search text and filter chips of the members list.
@Riverpod(keepAlive: true)
class MemberFiltersController extends _$MemberFiltersController {
  @override
  MemberFilters build() => const MemberFilters();

  void setQuery(String query) => state = state.copyWith(query: query);

  /// Tapping the selected chip again clears it.
  void toggleStatus(MemberStatusFilter status) =>
      state = state.copyWith(status: state.status == status ? null : status);

  void toggleTier(Tier tier) =>
      state = state.copyWith(tier: state.tier == tier ? null : tier);

  /// Only [status] (e.g. from the expiring-members notification).
  void show(MemberStatusFilter status) => state = MemberFilters(status: status);
}

class MembersListState {
  const MembersListState({
    required this.items,
    required this.page,
    required this.hasMore,
    this.loadingMore = false,
  });

  final List<MemberListItem> items;
  final int page;
  final bool hasMore;
  final bool loadingMore;
}

/// Pages of `GET /admin/members` for the current filters.
@Riverpod(keepAlive: true)
class MembersList extends _$MembersList {
  @override
  Future<MembersListState> build() async {
    final filters = ref.watch(memberFiltersControllerProvider);
    final page = await ref.read(membersRepositoryProvider).list(filters);
    return MembersListState(items: page.items, page: 1, hasMore: page.hasMore);
  }

  /// Infinite scroll; errors keep the loaded rows.
  Future<void> loadMore() async {
    final current = state.value;
    if (current == null || !current.hasMore || current.loadingMore) return;
    state = AsyncData(
      MembersListState(
        items: current.items,
        page: current.page,
        hasMore: current.hasMore,
        loadingMore: true,
      ),
    );
    final filters = ref.read(memberFiltersControllerProvider);
    try {
      final next = await ref
          .read(membersRepositoryProvider)
          .list(filters, page: current.page + 1);
      state = AsyncData(
        MembersListState(
          items: [...current.items, ...next.items],
          page: next.page,
          hasMore: next.hasMore,
        ),
      );
    } on Object {
      state = AsyncData(current);
    }
  }
}

/// `GET /admin/members/:id`.
@riverpod
Future<MemberDetail> memberDetail(Ref ref, String id) =>
    ref.watch(membersRepositoryProvider).detail(id);

/// The member's last denied entries (Ingresos tab). Reloaded with the
/// detail.
@riverpod
Future<List<CheckinAttempt>> memberDeniedAttempts(Ref ref, String id) async {
  await ref.watch(memberDetailProvider(id).future);
  final page = await ref
      .read(checkinsRepositoryProvider)
      .attempts(memberId: id, pageSize: 20);
  return page.items.where((a) => a.isDenied).take(10).toList();
}

/// Period and suggested amount for a new member.
@riverpod
Future<PaymentPreview> newMemberPreview(
  Ref ref, {
  required Tier tier,
  required int months,
  required String startDate,
}) => ref
    .watch(membersRepositoryProvider)
    .previewNew(tier: tier, months: months, startDate: startDate);

/// Renewal preview [R-07]–[R-10].
@riverpod
Future<PaymentPreview> renewalPreview(
  Ref ref,
  String memberId, {
  required Tier tier,
  required int months,
}) => ref
    .watch(membersRepositoryProvider)
    .previewRenewal(memberId, tier: tier, months: months);

/// Tier change preview [R-13]/[R-14].
@riverpod
Future<TierChangePreview> tierChangePreview(
  Ref ref,
  String memberId,
  Tier toTier,
) => ref.watch(membersRepositoryProvider).previewTierChange(memberId, toTier);

/// Refreshes everything that shows a member after a change.
void invalidateMember(WidgetRef ref, String memberId) {
  ref
    ..invalidate(memberDetailProvider(memberId))
    ..invalidate(membersListProvider);
}
