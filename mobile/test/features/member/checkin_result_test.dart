import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:gym_app/app.dart';
import 'package:gym_app/core/auth/token_storage.dart';
import 'package:gym_app/core/models/enums.dart';
import 'package:gym_app/core/network/api_exception.dart';
import 'package:gym_app/core/router/app_router.dart';
import 'package:gym_app/features/member/checkin/domain/checkin_result.dart';
import 'package:gym_app/features/member/checkin/presentation/scanner_screen.dart';
import 'package:gym_app/features/member/home/presentation/member_home_screen.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/fakes.dart';

CheckinResponse response({bool duplicate = false, Tier tier = Tier.basic}) =>
    CheckinResponse(
      duplicate: duplicate,
      checkinId: 'c1',
      checkedInAt: DateTime(2026, 11, 19, 18, 5).toUtc().toIso8601String(),
      member: const CheckinMember(firstName: 'Juan'),
      membership: CheckinMembership(
        tier: tier,
        endDate: '2026-11-30',
        daysLeft: 12,
      ),
    );

void main() {
  late MockAuthRepository auth;

  setUp(() {
    auth = MockAuthRepository();
    when(auth.me).thenAnswer((_) async => fakeUser(role: Role.member));
  });

  Future<void> showOutcome(WidgetTester tester, CheckinOutcome outcome) async {
    await pumpGymApp(
      tester,
      repo: auth,
      storage: MemoryTokenStorage(storedTokens),
    );
    unawaited(
      ProviderScope.containerOf(tester.element(find.byType(GymApp)))
          .read(routerProvider)
          .push(MemberRoutes.result, extra: outcome),
    );
    await tester.pumpAndSettle();
  }

  group('CheckinOutcome.fromError', () {
    test('maps the API codes of POST /checkins to the screen variants', () {
      expect(
        CheckinOutcome.fromError(
          const ApiException(
            code: 'MEMBERSHIP_EXPIRED',
            statusCode: 403,
            details: {'endDate': '2026-11-10'},
          ),
        ),
        isA<CheckinExpired>().having((e) => e.endDate, 'endDate', '2026-11-10'),
      );
      for (final code in ['QR_TOKEN_EXPIRED', 'QR_TOKEN_INVALID']) {
        expect(
          CheckinOutcome.fromError(ApiException(code: code, statusCode: 400)),
          isA<CheckinInvalidQr>(),
        );
      }
      expect(
        CheckinOutcome.fromError(
          const ApiException(code: 'ACCOUNT_INACTIVE', statusCode: 403),
        ),
        isA<CheckinInactive>(),
      );
      expect(
        CheckinOutcome.fromError(
          const ApiException(code: ClientErrorCode.network),
        ),
        isA<CheckinFailed>(),
      );
    });
  });

  testWidgets('success: welcome, days left and "have a great workout"', (
    tester,
  ) async {
    await showOutcome(tester, CheckinAccepted(response()));
    expect(find.text(en.checkinWelcome('Juan')), findsOneWidget);
    expect(find.text(en.membershipDaysLeft(12)), findsOneWidget);
    expect(find.text(en.membershipEndDate('30/11/2026')), findsOneWidget);
    expect(find.text(en.checkinEnjoy), findsOneWidget);
    expect(find.byKey(const Key('result.duplicate')), findsNothing);

    await tester.tap(find.byKey(const Key('result.action')));
    await tester.pumpAndSettle();
    expect(find.byType(MemberHomeScreen), findsOneWidget);
  });

  testWidgets('[R-19] duplicate: "already checked in today at 18:05"', (
    tester,
  ) async {
    await showOutcome(tester, CheckinAccepted(response(duplicate: true)));
    expect(find.text(en.checkinDuplicate('18:05')), findsOneWidget);
    expect(find.text(en.checkinWelcome('Juan')), findsOneWidget);
    expect(find.text(en.membershipDaysLeft(12)), findsOneWidget);
  });

  testWidgets('[R-20] expired: red screen with the end date', (tester) async {
    await showOutcome(tester, const CheckinExpired(endDate: '2026-11-10'));
    expect(find.text(en.checkinExpiredTitle), findsOneWidget);
    expect(find.text(en.memberExpiredOn('10/11/2026')), findsOneWidget);
    expect(find.text(en.checkinExpiredBody), findsOneWidget);
    final scaffold = tester.widget<Scaffold>(
      find
          .descendant(
            of: find.byKey(const Key('result.expired')),
            matching: find.byType(Scaffold),
          )
          .first,
    );
    final theme = Theme.of(tester.element(find.text(en.checkinExpiredTitle)));
    expect(scaffold.backgroundColor, theme.colorScheme.error);
  });

  testWidgets('invalid or expired QR: "scan again" opens the scanner', (
    tester,
  ) async {
    await showOutcome(tester, const CheckinInvalidQr());
    expect(find.text(en.checkinInvalidQr), findsOneWidget);
    await tester.tap(find.byKey(const Key('result.action')));
    await tester.pumpAndSettle();
    expect(find.byType(ScannerScreen), findsOneWidget);
  });

  testWidgets('[R-21] inactive account', (tester) async {
    await showOutcome(tester, const CheckinInactive());
    expect(find.text(en.checkinInactive), findsOneWidget);
  });

  testWidgets('no connection: message and retry', (tester) async {
    await showOutcome(
      tester,
      const CheckinFailed(ApiException(code: ClientErrorCode.network)),
    );
    expect(find.text(en.errorNetwork), findsOneWidget);
    expect(find.text(en.checkinScanAgain), findsOneWidget);
  });
}
