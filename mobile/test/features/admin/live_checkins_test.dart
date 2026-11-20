import 'package:flutter_test/flutter_test.dart';
import 'package:gym_app/core/models/enums.dart';
import 'package:gym_app/core/realtime/realtime_client.dart';
import 'package:gym_app/features/admin/checkins/domain/checkin_models.dart';
import 'package:gym_app/features/admin/members/domain/member_models.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/admin_fixtures.dart';
import '../../helpers/fakes.dart';

const juan = PersonRef(id: 'm1', firstName: 'Juan', lastName: 'Pérez');
const luis = PersonRef(id: 'm2', firstName: 'Luis', lastName: 'Mamani');

CheckinItem checkin(String id, PersonRef member, String at) => CheckinItem(
  id: id,
  member: member,
  tier: Tier.plus,
  daysLeft: 12,
  createdAt: at,
);

CheckinCreated created(String id, String firstName, String at) =>
    CheckinCreated(
      checkinId: id,
      member: EventMember(id: 'x-$id', firstName: firstName, lastName: 'Live'),
      tier: Tier.premium,
      daysLeft: 20,
      createdAt: at,
    );

void main() {
  setUpAll(registerAdminFallbacks);

  late AdminHarness h;

  setUp(() {
    h = AdminHarness();
    when(h.checkins.inside).thenAnswer(
      (_) async => InsideNow(
        count: 1,
        windowMinutes: 120,
        items: [checkin('c1', juan, '2026-11-19T13:00:00.000Z')],
      ),
    );
    when(
      () => h.checkins.list(
        from: '2026-11-19',
        to: '2026-11-19',
        memberId: any(named: 'memberId'),
        page: any(named: 'page'),
        pageSize: any(named: 'pageSize'),
      ),
    ).thenAnswer(
      (_) async => pageOf([checkin('c1', juan, '2026-11-19T13:00:00.000Z')]),
    );
    when(
      () => h.checkins.attempts(
        from: '2026-11-19',
        to: '2026-11-19',
        memberId: any(named: 'memberId'),
        pageSize: any(named: 'pageSize'),
      ),
    ).thenAnswer(
      (_) async => pageOf(const [
        CheckinAttempt(
          id: 'a1',
          result: CheckinResult.deniedExpired,
          member: luis,
          detail: 'endDate=2026-11-10',
          createdAt: '2026-11-19T12:00:00.000Z',
        ),
        CheckinAttempt(
          id: 'a2',
          result: CheckinResult.invalidToken,
          member: luis,
          detail: 'expired',
          createdAt: '2026-11-19T11:00:00.000Z',
        ),
      ]),
    );
  });

  Future<void> openToday(WidgetTester tester) async {
    await h.open(tester, '/admin/checkins');
    await tester.tap(find.text(en.checkinsTodayTab));
    await tester.pumpAndSettle();
  }

  testWidgets('[R-23] "Inside now" lists the members inside', (tester) async {
    await h.open(tester, '/admin/checkins');
    expect(find.text(en.checkinsInsideTabCount(1)), findsOneWidget);
    expect(find.text(en.checkinsInsideHint(120)), findsOneWidget);
    expect(find.text('Juan Pérez'), findsOneWidget);
  });

  testWidgets('"Today" shows check-ins and denied entries (in words), '
      'not invalid scans', (tester) async {
    await openToday(tester);
    expect(find.text('Juan Pérez'), findsOneWidget);
    expect(find.text('Luis Mamani'), findsOneWidget);
    expect(
      find.textContaining(en.checkinsDeniedExpired('10/11/2026')),
      findsOneWidget,
    );
    expect(find.textContaining(en.checkinsDenied), findsOneWidget);
  });

  testWidgets('a live check-in appears at the top with an alert', (
    tester,
  ) async {
    await openToday(tester);
    h.realtime.emit(created('c9', 'Rosa', '2026-11-19T14:00:00.000Z'));
    await tester.pumpAndSettle();

    final rosa = tester.getTopLeft(find.text('Rosa Live')).dy;
    final juanY = tester.getTopLeft(find.text('Juan Pérez')).dy;
    expect(rosa, lessThan(juanY));
    verify(h.device.alert).called(1);

    // Also counted as inside now.
    expect(find.text(en.checkinsInsideTabCount(2)), findsOneWidget);
  });

  testWidgets('a live denial shows in red words', (tester) async {
    await openToday(tester);
    h.realtime.emit(
      const CheckinDenied(
        member: EventMember(id: 'm3', firstName: 'Eva', lastName: 'Quispe'),
        reason: 'INACTIVE',
        endDate: null,
        createdAt: '2026-11-19T14:30:00.000Z',
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Eva Quispe'), findsOneWidget);
    expect(find.textContaining(en.checkinsDeniedInactive), findsOneWidget);
  });

  testWidgets('reloads after a reconnection to fill the gap (8.5)', (
    tester,
  ) async {
    await h.open(tester, '/admin/checkins');
    verify(h.checkins.inside).called(1);

    h.realtime.emit(const RealtimeReady()); // first connection: no reload
    await tester.pumpAndSettle();
    verifyNever(h.checkins.inside);

    h.realtime
      ..emit(const RealtimeDisconnected())
      ..emit(const RealtimeReady());
    await tester.pumpAndSettle();
    verify(h.checkins.inside).called(1);
  });

  testWidgets('sound and vibration can be turned off (and stays off)', (
    tester,
  ) async {
    await h.open(tester, '/admin/checkins');
    await tester.tap(find.byKey(const Key('checkins.alerts')));
    await tester.pumpAndSettle();
    expect(h.preferences.values['admin.checkinAlerts'], isFalse);

    h.realtime.emit(created('c9', 'Rosa', '2026-11-19T14:00:00.000Z'));
    await tester.pumpAndSettle();
    verifyNever(h.device.alert);
  });

  testWidgets('dashboard: the last check-ins are live', (tester) async {
    when(
      () => h.checkins.list(
        from: any(named: 'from'),
        to: any(named: 'to'),
        memberId: any(named: 'memberId'),
        page: any(named: 'page'),
        pageSize: 10,
      ),
    ).thenAnswer(
      (_) async => pageOf([checkin('c1', juan, '2026-11-19T13:00:00.000Z')]),
    );
    await h.open(tester, '/admin');
    expect(find.text(en.dashboardRecentCheckins), findsOneWidget);
    expect(find.text('Juan Pérez'), findsOneWidget);

    h.realtime.emit(created('c9', 'Rosa', '2026-11-19T14:00:00.000Z'));
    await tester.pumpAndSettle();
    expect(
      tester.getTopLeft(find.text('Rosa Live')).dy,
      lessThan(tester.getTopLeft(find.text('Juan Pérez')).dy),
    );
  });
}
