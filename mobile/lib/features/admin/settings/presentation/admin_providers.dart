import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/gym_admin_repository.dart';

part 'admin_providers.g.dart';

/// Current tier prices [R-11].
@riverpod
Future<List<TierPrice>> tierPrices(Ref ref) =>
    ref.watch(gymAdminRepositoryProvider).prices();

/// Gym settings.
@riverpod
Future<GymSettings> gymSettings(Ref ref) =>
    ref.watch(gymAdminRepositoryProvider).settings();

/// Staff accounts for the Personal screen.
@riverpod
Future<List<StaffMember>> staffList(
  Ref ref, {
  StaffRole? role,
  bool includeInactive = false,
}) async {
  final page = await ref
      .watch(gymAdminRepositoryProvider)
      .staff(role: role, includeInactive: includeInactive);
  return page.items;
}
