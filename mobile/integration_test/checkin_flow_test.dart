// End-to-end QA of D7 (check-in) against a real backend (README "Integration
// test"). One device plays every role in turn: kiosk → member → admin. The
// camera is replaced by a scanner that "reads" the QR shown by the kiosk
// screen, so the token travels exactly as it would through a camera.
//
//   flutter test integration_test/checkin_flow_test.dart -d <device> \
//     --dart-define-from-file=config/dev.json \
//     --dart-define=QA_ADMIN_PHONE=70000000 \
//     --dart-define=QA_ADMIN_PASSWORD=<seed password>
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_app/app.dart';
import 'package:gym_app/core/config/app_config.dart';
import 'package:gym_app/features/kiosk/presentation/kiosk_home_screen.dart';
import 'package:gym_app/features/member/checkin/presentation/scanner_devices.dart';
import 'package:gym_app/l10n/generated/app_localizations.dart';
import 'package:gym_app/main.dart' show noRetry;
import 'package:integration_test/integration_test.dart';
import 'package:material_ui/material_ui.dart';

import 'qa_support.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('D7: kiosk QR → member scan → admin live feed', (tester) async {
    t = tester;
    l10n = lookupAppLocalizations(const Locale('en'));
    final config = AppConfig.fromEnvironment();
    final api = Api(config.apiUrl);

    final admin = await api.adminToken();
    final kioskPhone = await api.createKiosk(admin);
    final anaPhone = await api.createMember(admin, 'Ana');
    final evaPhone = await api.createMember(admin, 'Eva', expired: true);
    final luisPhone = await api.createMember(admin, 'Luis');
    final kioskApi = await api.login(kioskPhone, userPassword);

    final socket = AdminSocket(config.apiOrigin, admin);
    await socket.ready.future.timeout(const Duration(seconds: 10));

    final scanner = QaScanner();
    await tester.pumpWidget(
      ProviderScope(
        retry: noRetry,
        overrides: [
          qrScannerFactoryProvider.overrideWithValue(() => scanner),
          cameraPermissionProvider.overrideWithValue(const QaCamera()),
        ],
        child: const GymApp(),
      ),
    );
    l10n = lookupAppLocalizations(
      Localizations.localeOf(t.element(find.byType(Navigator).first)),
    );

    // --- Kiosk: rotating QR (R-18) ---
    await uiLogin(kioskPhone, userPassword);
    await waitFor(find.byKey(const Key('kiosk.qr')));
    final firstToken = shownQr();
    final firstSeen = DateTime.now();
    await waitFor(
      find.byWidgetPredicate((w) => w is KioskQr && w.token != firstToken),
      seconds: 35,
    );
    final rotation = DateTime.now().difference(firstSeen);
    expect(rotation.inSeconds, inInclusiveRange(25, 31));
    final kioskToken = shownQr();

    // Hidden exit: 5 s on the logo + admin credentials.
    final hold = await t.startGesture(
      t.getCenter(find.byKey(const Key('kiosk.logo'))),
    );
    await wait(const Duration(milliseconds: 5500));
    await hold.up();
    await waitFor(find.byKey(const Key('kioskExit.phone')));
    await t.enterText(find.byKey(const Key('kioskExit.phone')), adminPhone);
    await t.enterText(
      find.byKey(const Key('kioskExit.password')),
      adminPassword,
    );
    await tapKey('kioskExit.confirm');

    // --- Member: scan the QR the kiosk showed → success (R-17) ---
    await uiLogin(anaPhone, userPassword);
    await waitFor(find.byKey(const Key('member.card')));
    await tapKey('member.scan');
    await waitFor(find.text(l10n.scannerHint));
    final scannedAt = DateTime.now();
    scanner.read(kioskToken);
    await waitFor(find.byKey(const Key('result.accepted')));
    expect(find.text(l10n.checkinWelcome('Ana')), findsOneWidget);
    // BASIC for 1 month from today: 28–31 days left (R-02/R-04).
    expect(
      find.byWidgetPredicate(
        (w) =>
            w is Text &&
            [for (var d = 28; d <= 31; d++) l10n.membershipDaysLeft(d)]
                .contains(w.data),
      ),
      findsOneWidget,
    );
    await wait(const Duration(seconds: 2));
    expect(socket.created, hasLength(1));
    expect((socket.created.single.$2['member'] as Map)['firstName'], 'Ana');
    final latency = socket.created.single.$1.difference(scannedAt);
    expect(latency, lessThan(const Duration(seconds: 2)));

    // Second scan within 3 h → duplicate, no new admin event (R-19).
    await tapKey('result.action');
    await tapKey('member.scan');
    await waitFor(find.text(l10n.scannerHint));
    scanner.read(await api.qrToken(kioskApi));
    await waitFor(find.byKey(const Key('result.duplicate')));
    await wait(const Duration(seconds: 2));
    expect(socket.created, hasLength(1));

    // --- Expired member → red screen, admin gets a denial (R-20) ---
    await tapKey('result.action');
    await tapOn(find.byTooltip(l10n.logout));
    await uiLogin(evaPhone, userPassword);
    await waitFor(find.text(l10n.membershipExpired));
    await tapKey('member.scan');
    await waitFor(find.text(l10n.scannerHint));
    scanner.read(await api.qrToken(kioskApi));
    await waitFor(find.byKey(const Key('result.expired')));
    await wait(const Duration(seconds: 2));
    expect(socket.denied, hasLength(1));
    expect(socket.denied.single.$2['reason'], 'EXPIRED');

    // --- A QR older than 45 s is rejected (R-18) ---
    final age = DateTime.now().difference(firstSeen);
    if (age < const Duration(seconds: 46)) {
      await wait(const Duration(seconds: 46) - age);
    }
    await tapKey('result.action');
    await tapKey('member.scan');
    await waitFor(find.text(l10n.scannerHint));
    scanner.read(firstToken);
    await waitFor(find.byKey(const Key('result.invalidQr')));
    expect(find.text(l10n.checkinInvalidQr), findsOneWidget);

    // --- Admin: live screen (9.3 #7) ---
    await tapOn(find.text(l10n.checkinGoHome));
    await tapOn(find.byTooltip(l10n.logout));
    await uiLogin(adminPhone, adminPassword);
    await tapKey('nav.checkins');
    await waitFor(find.textContaining('Ana QA'));
    await tapKey('nav.checkins');
    await tapOn(find.text(l10n.checkinsTodayTab));
    await waitFor(find.textContaining('Eva QA'));
    expect(find.textContaining(l10n.checkinsDenied), findsWidgets);

    // A new check-in shows up live within 2 s.
    final luis = await api.login(luisPhone, userPassword);
    final sentAt = DateTime.now();
    await api.checkIn(luis, await api.qrToken(kioskApi));
    await waitFor(find.textContaining('Luis QA'), seconds: 2);
    debugPrint(
      'QA D7: rotation ${rotation.inMilliseconds} ms, socket latency '
      '${latency.inMilliseconds} ms, live feed '
      '${DateTime.now().difference(sentAt).inMilliseconds} ms',
    );
    socket.socket.dispose();
  });
}
