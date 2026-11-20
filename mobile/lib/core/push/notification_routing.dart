import '../../features/admin/members/domain/member_models.dart';
import '../models/enums.dart';

/// Where a notification opens (section 9.8: by `data.screen` / `memberId`).
class NotificationTarget {
  const NotificationTarget(this.location, {this.membersFilter});

  final String location;

  /// For `admin_expiring`: open the members list with this filter.
  final MemberStatusFilter? membersFilter;

  @override
  bool operator ==(Object other) =>
      other is NotificationTarget &&
      other.location == location &&
      other.membersFilter == membersFilter;

  @override
  int get hashCode => Object.hash(location, membersFilter);

  @override
  String toString() => 'NotificationTarget($location, $membersFilter)';
}

/// Maps a notification's `data` to a screen of [role]'s area. Screens that
/// arrive in later deliverables (workout, trainer notes) open the home.
NotificationTarget targetFor(Role role, Map<String, dynamic> data) {
  final screen = data['screen'];
  final memberId = data['memberId'];
  switch (role) {
    case Role.admin:
      if (memberId is String && memberId.isNotEmpty) {
        return NotificationTarget('/admin/members/$memberId');
      }
      if (screen == 'admin_expiring') {
        return const NotificationTarget(
          '/admin/members',
          membersFilter: MemberStatusFilter.expiring,
        );
      }
      return const NotificationTarget('/admin');
    case Role.member:
      return const NotificationTarget('/member');
    case Role.trainer:
      return const NotificationTarget('/trainer');
    case Role.kiosk:
      return const NotificationTarget('/kiosk');
  }
}
