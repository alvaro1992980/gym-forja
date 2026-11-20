import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/auth/session_controller.dart';
import '../../../../core/utils/clock.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/parallel.dart';
import '../../../auth/domain/current_user.dart';
import '../../data/member_repository.dart';

part 'member_home_providers.g.dart';

/// Data of the member home (section 9.5 #1).
class MemberHomeData {
  const MemberHomeData({
    required this.membership,
    required this.month,
    required this.checkinDays,
  });

  final MembershipSummary membership;

  /// First day of the current month.
  final DateTime month;

  /// Days of this month with at least one check-in.
  final Set<int> checkinDays;

  int get checkinsThisMonth => checkinDays.length;
}

@riverpod
Future<MemberHomeData> memberHome(Ref ref) async {
  // Never show the previous user's data after switching accounts.
  ref.watch(sessionControllerProvider);
  final repo = ref.watch(memberRepositoryProvider);
  final today = ref.watch(clockProvider).today();
  final month = DateTime(today.year, today.month);
  final (membership, times) = await both(
    repo.membership(),
    repo.checkinTimes(from: toApiDate(month), to: toApiDate(today)),
  );
  return MemberHomeData(
    membership: membership,
    month: month,
    checkinDays: {
      for (final t in times)
        if (DateTime.parse(t).toLocal() case final local
            when local.month == month.month && local.year == month.year)
          local.day,
    },
  );
}
