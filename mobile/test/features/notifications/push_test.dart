import 'package:flutter_test/flutter_test.dart';
import 'package:gym_app/core/auth/token_storage.dart';
import 'package:gym_app/core/models/enums.dart';
import 'package:gym_app/core/push/push_controller.dart';
import 'package:gym_app/core/push/push_service.dart';
import 'package:gym_app/features/admin/members/presentation/member_detail_screen.dart';
import 'package:gym_app/features/admin/members/presentation/members_list_screen.dart';
import 'package:gym_app/features/auth/presentation/login_screen.dart';
import 'package:gym_app/features/member/home/presentation/member_home_screen.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/admin_fixtures.dart';
import '../../helpers/fakes.dart';

void main() {
  setUpAll(registerAdminFallbacks);

  late MockAuthRepository auth;
  late MockNotificationsRepository notifications;
  late FakePushService push;
  late FakePreferences prefs;

  setUp(() {
    auth = MockAuthRepository();
    notifications = inboxWith();
    push = FakePushService();
    prefs = FakePreferences();
    when(auth.me).thenAnswer((_) async => fakeUser(role: Role.member));
    when(() => auth.logout(any(), fcmToken: any(named: 'fcmToken')))
        .thenAnswer((_) async {});
  });

  tearDown(() => push.close());

  Future<void> openAsMember(WidgetTester tester) => pumpGymApp(
    tester,
    repo: auth,
    storage: MemoryTokenStorage(storedTokens),
    push: push,
    notifications: notifications,
    preferences: prefs,
  );

  group('permission and token (9.8)', () {
    testWidgets(
      'explains first, then asks the system and registers the token',
      (tester) async {
        await openAsMember(tester);
        expect(find.text(en.pushExplainTitle), findsOneWidget);
        expect(push.permissionRequests, 0);

        await tester.tap(find.byKey(const Key('push.enable')));
        await tester.pumpAndSettle();
        expect(push.permissionRequests, 1);
        verify(() => notifications.registerDevice('fcm-token-1', 'android'))
            .called(1);
        expect(find.byType(MemberHomeScreen), findsOneWidget);
      },
    );

    testWidgets('"not now": no system request, and not asked again', (
      tester,
    ) async {
      await openAsMember(tester);
      await tester.tap(find.byKey(const Key('push.later')));
      await tester.pumpAndSettle();
      expect(push.permissionRequests, 0);
      verifyNever(() => notifications.registerDevice(any(), any()));
      expect(prefs.values[PushController.askedKey], isTrue);

      await tester.pumpWidget(const SizedBox());
      await openAsMember(tester);
      expect(find.text(en.pushExplainTitle), findsNothing);
    });

    testWidgets('already allowed: registers at once and on token refresh', (
      tester,
    ) async {
      push.permissionStatus = PushPermission.granted;
      await openAsMember(tester);
      expect(find.text(en.pushExplainTitle), findsNothing);
      verify(() => notifications.registerDevice('fcm-token-1', 'android'))
          .called(1);

      push.refresh.add('fcm-token-2');
      await tester.pumpAndSettle();
      verify(() => notifications.registerDevice('fcm-token-2', 'android'))
          .called(1);
    });

    testWidgets('logout sends the FCM token so the server drops the device', (
      tester,
    ) async {
      push.permissionStatus = PushPermission.granted;
      await openAsMember(tester);
      await tester.tap(find.byTooltip(en.logout));
      await tester.pumpAndSettle();
      verify(() => auth.logout('refresh', fcmToken: 'fcm-token-1')).called(1);
      expect(find.byType(LoginScreen), findsOneWidget);
    });

    testWidgets('without Firebase config: no dialog, inbox only', (
      tester,
    ) async {
      push.available = false;
      await openAsMember(tester);
      expect(find.text(en.pushExplainTitle), findsNothing);
      verifyNever(() => notifications.registerDevice(any(), any()));
    });
  });

  testWidgets('a foreground push shows a banner and refreshes the badge', (
    tester,
  ) async {
    push.permissionStatus = PushPermission.granted;
    await openAsMember(tester);
    clearInteractions(notifications);

    push.foregroundCtrl.add(
      const PushMessage(
        title: 'Pago registrado',
        body: 'Renovaste Mensual hasta el 14/12/2026.',
        data: {'screen': 'home'},
      ),
    );
    await tester.pumpAndSettle();
    expect(push.banners.single.title, 'Pago registrado');
    verify(
      () => notifications.inbox(
        page: any(named: 'page'),
        size: any(named: 'size'),
      ),
    ).called(greaterThanOrEqualTo(1));
  });

  group('tap routing (background and terminated)', () {
    late AdminHarness h;

    setUp(() {
      h = AdminHarness();
      when(() => h.members.detail('m1')).thenAnswer((_) async => detail());
      when(() => h.members.list(any(), page: any(named: 'page')))
          .thenAnswer((_) async => page([listItem()]));
      push.permissionStatus = PushPermission.granted;
    });

    testWidgets('admin: a check-in push opens the member and marks it read', (
      tester,
    ) async {
      await h.open(tester, '/admin', push: push, notifications: notifications);
      push.openedCtrl.add({
        'memberId': 'm1',
        'checkinId': 'c1',
        'notificationId': 'n1',
      });
      await tester.pumpAndSettle();
      expect(find.byType(MemberDetailScreen), findsOneWidget);
      verify(() => notifications.markRead('n1')).called(1);
    });

    testWidgets('admin: the daily summary opens "Por vencer"', (tester) async {
      await h.open(
        tester,
        '/admin/more',
        push: push,
        notifications: notifications,
      );
      push.openedCtrl.add({'screen': 'admin_expiring'});
      await tester.pumpAndSettle();
      expect(find.byType(MembersListScreen), findsOneWidget);
      final chip = tester.widget<FilterChip>(
        find.widgetWithText(FilterChip, en.filterExpiring),
      );
      expect(chip.selected, isTrue);
    });

    testWidgets(
      'terminated: the launching push opens after the session loads',
      (tester) async {
        push.launch = {'memberId': 'm1'};
        await h.open(tester, null, push: push, notifications: notifications);
        await tester.pumpAndSettle();
        expect(find.byType(MemberDetailScreen), findsOneWidget);
      },
    );
  });
}
