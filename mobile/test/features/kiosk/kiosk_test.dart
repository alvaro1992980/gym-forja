import 'package:flutter_test/flutter_test.dart';
import 'package:gym_app/core/auth/token_storage.dart';
import 'package:gym_app/core/models/enums.dart';
import 'package:gym_app/core/network/api_exception.dart';
import 'package:gym_app/core/utils/clock.dart';
import 'package:gym_app/features/auth/presentation/login_screen.dart';
import 'package:gym_app/features/kiosk/data/kiosk_repository.dart';
import 'package:gym_app/features/kiosk/presentation/kiosk_home_screen.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/fakes.dart';

QrToken qr(String token) => QrToken(
  token: token,
  validFor: const Duration(seconds: 45),
  refreshIn: const Duration(seconds: 30),
  gymName: 'Forja Gym',
);

void main() {
  late MockAuthRepository auth;
  late MockKioskRepository kiosk;
  late FakeKioskDisplay display;
  late DateTime now;

  setUp(() {
    auth = MockAuthRepository();
    kiosk = MockKioskRepository();
    display = FakeKioskDisplay();
    now = DateTime(2026, 11, 19, 7, 30);
    when(auth.me).thenAnswer((_) async => fakeUser(role: Role.kiosk));
    when(() => auth.logout(any())).thenAnswer((_) async {});
  });

  Future<void> open(WidgetTester tester) => pumpGymApp(
    tester,
    repo: auth,
    storage: MemoryTokenStorage(storedTokens),
    kiosk: kiosk,
    kioskDisplay: display,
    overrides: [clockProvider.overrideWithValue(Clock(() => now))],
  );

  /// Moves the clock and the timers together.
  Future<void> advance(WidgetTester tester, Duration d) async {
    now = now.add(d);
    await tester.pump(d);
  }

  String? shownToken(WidgetTester tester) {
    final finder = find.byKey(const Key('kiosk.qr'));
    if (finder.evaluate().isEmpty) return null;
    return tester.widget<KioskQr>(finder).token;
  }

  testWidgets('[R-18] shows a big QR and rotates it every 30 s', (
    tester,
  ) async {
    var n = 0;
    when(kiosk.qrToken).thenAnswer((_) async => qr('token-${++n}'));
    await open(tester);

    expect(display.entered, 1); // wakelock, immersive, portrait
    expect(find.text('Forja Gym'), findsOneWidget);
    expect(find.text('07:30'), findsOneWidget);
    expect(find.text(en.kioskScanHint), findsWidgets);
    expect(shownToken(tester), 'token-1');
    final qrSize = tester.getSize(find.byKey(const Key('kiosk.qr')));
    final screen = tester.view.physicalSize / tester.view.devicePixelRatio;
    expect(qrSize.width, greaterThanOrEqualTo(screen.shortestSide * 0.6));

    await advance(tester, const Duration(seconds: 29));
    expect(shownToken(tester), 'token-1');
    await advance(tester, const Duration(seconds: 1));
    await tester.pump();
    expect(shownToken(tester), 'token-2');
    verify(kiosk.qrToken).called(2);
  });

  testWidgets('[R-18] offline: never shows an expired QR, then recovers', (
    tester,
  ) async {
    var offline = false;
    when(kiosk.qrToken).thenAnswer((_) async {
      if (offline) throw const ApiException(code: ClientErrorCode.network);
      return qr('token-a');
    });
    await open(tester);
    expect(shownToken(tester), 'token-a');

    offline = true;
    await advance(tester, const Duration(seconds: 30));
    await tester.pump();
    // Still valid (45 s): kept, with a "no connection" note.
    expect(shownToken(tester), 'token-a');
    expect(find.text(en.kioskOffline), findsOneWidget);

    await advance(tester, const Duration(seconds: 15));
    await advance(tester, const Duration(milliseconds: 500));
    expect(shownToken(tester), isNull);
    expect(find.byKey(const Key('kiosk.offline')), findsOneWidget);

    offline = false;
    await advance(tester, const Duration(seconds: 5));
    await tester.pump();
    expect(shownToken(tester), 'token-a');
    expect(find.text(en.kioskOffline), findsNothing);
  });

  group('hidden exit', () {
    setUp(() => when(kiosk.qrToken).thenAnswer((_) async => qr('t')));

    testWidgets('a short press does nothing', (tester) async {
      await open(tester);
      final gesture = await tester.startGesture(
        tester.getCenter(find.byKey(const Key('kiosk.logo'))),
      );
      await advance(tester, const Duration(seconds: 3));
      await gesture.up();
      await advance(tester, const Duration(seconds: 3));
      expect(find.text(en.kioskExitTitle), findsNothing);
    });

    testWidgets('5 s on the logo + admin credentials → logs out', (
      tester,
    ) async {
      when(() => kiosk.verifyAdmin(phone: '70000000', password: 'wrong'))
          .thenAnswer((_) async => false);
      when(() => kiosk.verifyAdmin(phone: '70000000', password: 'Admin1234'))
          .thenAnswer((_) async => true);
      await open(tester);

      final gesture = await tester.startGesture(
        tester.getCenter(find.byKey(const Key('kiosk.logo'))),
      );
      await advance(tester, const Duration(seconds: 5));
      await gesture.up();
      await tester.pumpAndSettle();
      expect(find.text(en.kioskExitTitle), findsOneWidget);

      await tester.enterText(
        find.byKey(const Key('kioskExit.phone')),
        '70000000',
      );
      await tester.enterText(
        find.byKey(const Key('kioskExit.password')),
        'wrong',
      );
      await tester.tap(find.byKey(const Key('kioskExit.confirm')));
      await tester.pumpAndSettle();
      expect(find.text(en.kioskExitWrong), findsOneWidget);

      await tester.enterText(
        find.byKey(const Key('kioskExit.password')),
        'Admin1234',
      );
      await tester.tap(find.byKey(const Key('kioskExit.confirm')));
      await tester.pumpAndSettle();
      verify(() => auth.logout('refresh')).called(1);
      expect(find.byType(LoginScreen), findsOneWidget);
      expect(display.exited, 1);
    });
  });
}
