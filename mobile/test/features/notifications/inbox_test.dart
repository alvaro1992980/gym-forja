import 'package:flutter_test/flutter_test.dart';
import 'package:gym_app/core/auth/token_storage.dart';
import 'package:gym_app/core/models/enums.dart';
import 'package:gym_app/features/member/home/presentation/member_home_screen.dart';
import 'package:gym_app/features/notifications/domain/app_notification.dart';
import 'package:gym_app/features/notifications/presentation/inbox_screen.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/fakes.dart';

const payment = AppNotification(
  id: 'n2',
  type: 'PAYMENT_RECORDED',
  title: 'Pago registrado',
  body: 'Renovaste Mensual + hasta el 14/12/2026. ¡Gracias!',
  data: {'screen': 'home'},
  createdAt: '2026-11-19T14:00:00.000Z',
);

const reminder = AppNotification(
  id: 'n1',
  type: 'EXPIRING_7',
  title: 'Tu membresía vence pronto',
  body: 'Te quedan 7 días (vence el 25/11/2026).',
  data: {'screen': 'home'},
  readAt: '2026-11-19T12:30:00.000Z',
  createdAt: '2026-11-19T12:00:00.000Z',
);

void main() {
  late MockAuthRepository auth;
  late MockNotificationsRepository notifications;

  setUp(() {
    auth = MockAuthRepository();
    notifications = inboxWith([payment, reminder]);
    when(auth.me).thenAnswer((_) async => fakeUser(role: Role.member));
  });

  Future<void> open(WidgetTester tester) => pumpGymApp(
    tester,
    repo: auth,
    storage: MemoryTokenStorage(storedTokens),
    notifications: notifications,
  );

  Future<void> openInbox(WidgetTester tester) async {
    await open(tester);
    await tester.tap(find.byKey(const Key('notifications.bell')));
    await tester.pumpAndSettle();
  }

  testWidgets('the bell shows the unread count (9.5 #1)', (tester) async {
    await open(tester);
    expect(
      find.descendant(
        of: find.byKey(const Key('notifications.bell')),
        matching: find.text('1'),
      ),
      findsOneWidget,
    );
    expect(find.byTooltip(en.notificationsUnread(1)), findsOneWidget);
  });

  testWidgets('inbox: newest first, unread in bold', (tester) async {
    await openInbox(tester);
    expect(find.byType(InboxScreen), findsOneWidget);
    expect(
      tester.getTopLeft(find.text('Pago registrado')).dy,
      lessThan(tester.getTopLeft(find.text('Tu membresía vence pronto')).dy),
    );
    expect(
      tester.widget<Text>(find.text('Pago registrado')).style?.fontWeight,
      FontWeight.bold,
    );
    expect(
      tester.widget<Text>(find.text('Tu membresía vence pronto')).style,
      isNull,
    );
  });

  testWidgets('tap: marks it read and opens its screen (data.screen)', (
    tester,
  ) async {
    await openInbox(tester);
    await tester.tap(find.text('Pago registrado'));
    await tester.pumpAndSettle();
    verify(() => notifications.markRead('n2')).called(1);
    expect(find.byType(MemberHomeScreen), findsOneWidget);
    expect(find.byType(InboxScreen), findsNothing);
  });

  testWidgets('mark all as read', (tester) async {
    await openInbox(tester);
    await tester.tap(find.byKey(const Key('inbox.readAll')));
    await tester.pumpAndSettle();
    verify(notifications.markAllRead).called(1);
    expect(
      tester.widget<Text>(find.text('Pago registrado')).style?.fontWeight,
      isNot(FontWeight.bold),
    );
  });

  testWidgets('empty inbox', (tester) async {
    notifications = inboxWith();
    await openInbox(tester);
    expect(find.text(en.notificationsEmpty), findsOneWidget);
  });
}
