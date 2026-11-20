import 'package:flutter_test/flutter_test.dart';
import 'package:gym_app/core/auth/token_storage.dart';
import 'package:gym_app/core/models/enums.dart';
import 'package:gym_app/core/utils/clock.dart';
import 'package:gym_app/features/auth/domain/current_user.dart';
import 'package:gym_app/features/member/checkin/presentation/scanner_screen.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/fakes.dart';

void main() {
  late MockAuthRepository auth;
  late MockMemberRepository member;

  setUp(() {
    auth = MockAuthRepository();
    member = defaultMemberRepo();
    when(auth.me).thenAnswer((_) async => fakeUser(role: Role.member));
  });

  Future<void> open(
    WidgetTester tester,
    MembershipSummary membership, {
    List<String> checkins = const [],
  }) async {
    usePhoneScreen(tester);
    when(member.membership).thenAnswer((_) async => membership);
    when(
      () => member.checkinTimes(
        from: any(named: 'from'),
        to: any(named: 'to'),
      ),
    ).thenAnswer((_) async => checkins);
    await pumpGymApp(
      tester,
      repo: auth,
      storage: MemoryTokenStorage(storedTokens),
      member: member,
      overrides: [
        clockProvider.overrideWithValue(Clock(() => DateTime(2026, 11, 19))),
      ],
    );
  }

  Color ringColor(WidgetTester tester) => tester
      .widget<CircularProgressIndicator>(
        find.descendant(
          of: find.byKey(const Key('member.card')),
          matching: find.byType(CircularProgressIndicator),
        ),
      )
      .color!;

  testWidgets('active (> 7 days): green ring with days left and end date', (
    tester,
  ) async {
    await open(tester, activeMembership);
    expect(find.text(en.membershipDaysLeft(12)), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(const Key('member.card')),
        matching: find.text('12'),
      ),
      findsOneWidget,
    );
    expect(find.text(en.membershipEndDate('30/11/2026')), findsOneWidget);
    expect(ringColor(tester), Colors.green.shade700);
  });

  testWidgets('expiring (1–7 days): orange', (tester) async {
    await open(
      tester,
      activeMembership.copyWith(daysLeft: 3, endDate: '2026-11-21'),
    );
    expect(find.text(en.membershipDaysLeft(3)), findsOneWidget);
    expect(ringColor(tester), Colors.orange.shade800);
  });

  testWidgets('expired: red card, "go to the front desk", scan stays enabled', (
    tester,
  ) async {
    await open(
      tester,
      activeMembership.copyWith(
        daysLeft: 0,
        endDate: '2026-11-10',
        status: MembershipStatus.expired,
      ),
    );
    expect(find.text(en.membershipExpired), findsOneWidget);
    expect(find.text(en.memberExpiredOn('10/11/2026')), findsOneWidget);
    final theme = Theme.of(
      tester.element(find.byKey(const Key('member.card'))),
    );
    expect(ringColor(tester), theme.colorScheme.error);

    await tester.tap(find.byKey(const Key('member.scan')));
    await tester.pumpAndSettle();
    expect(find.byType(ScannerScreen), findsOneWidget);
  });

  testWidgets("this month's attendance count and calendar marks", (
    tester,
  ) async {
    await open(
      tester,
      activeMembership,
      checkins: [
        DateTime(2026, 11, 18, 18).toUtc().toIso8601String(),
        DateTime(2026, 11, 3, 7).toUtc().toIso8601String(),
        DateTime(2026, 11, 3, 19).toUtc().toIso8601String(),
      ],
    );
    expect(find.text(en.memberCheckinsThisMonth(2)), findsOneWidget);
    expect(find.byKey(const Key('calendar.checkin.3')), findsOneWidget);
    expect(find.byKey(const Key('calendar.checkin.18')), findsOneWidget);
    expect(find.byKey(const Key('calendar.checkin.19')), findsNothing);
    verify(() => member.checkinTimes(from: '2026-11-01', to: '2026-11-19'))
        .called(1);
  });
}
