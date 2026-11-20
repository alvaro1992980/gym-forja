import 'package:flutter_test/flutter_test.dart';
import 'package:gym_app/core/models/enums.dart';
import 'package:gym_app/core/push/notification_routing.dart';
import 'package:gym_app/features/admin/members/domain/member_models.dart';

void main() {
  group('targetFor (section 9.8: route by data.screen / memberId)', () {
    test('admin: memberId opens the member detail', () {
      expect(
        targetFor(Role.admin, {'memberId': 'm1', 'checkinId': 'c1'}),
        const NotificationTarget('/admin/members/m1'),
      );
    });

    test('admin: the daily summary opens the expiring members', () {
      expect(
        targetFor(Role.admin, {'screen': 'admin_expiring'}),
        const NotificationTarget(
          '/admin/members',
          membersFilter: MemberStatusFilter.expiring,
        ),
      );
    });

    test('member: home, check-in result and later screens open the home', () {
      for (final screen in ['home', 'checkin_result', 'workout', 'x']) {
        expect(
          targetFor(Role.member, {'screen': screen}),
          const NotificationTarget('/member'),
        );
      }
    });

    test('other roles and empty data open the role home', () {
      expect(targetFor(Role.trainer, {}), const NotificationTarget('/trainer'));
      expect(targetFor(Role.admin, {}), const NotificationTarget('/admin'));
    });
  });
}
