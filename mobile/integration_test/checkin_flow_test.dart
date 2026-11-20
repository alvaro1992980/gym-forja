// End-to-end QA of D7 (check-in) against a real backend (README "Integration
// test"). One device plays every role in turn: kiosk → member → admin. The
// camera is replaced by a scanner that "reads" the QR shown by the kiosk
// screen, so the token travels exactly as it would through a camera.
//
//   flutter test integration_test/checkin_flow_test.dart -d <device> \
//     --dart-define-from-file=config/dev.json \
//     --dart-define=QA_ADMIN_PHONE=70000000 \
//     --dart-define=QA_ADMIN_PASSWORD=<seed password>
import 'dart:async';
import 'dart:math';

import 'package:dio/dio.dart';
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
import 'package:socket_io_client/socket_io_client.dart' as io;

const adminPhone = String.fromEnvironment('QA_ADMIN_PHONE');
const adminSeedPassword = String.fromEnvironment('QA_ADMIN_PASSWORD');
const adminPassword = 'QaAdmin2026!';
const userPassword = 'QaUser2026!';

final _rand = Random();
String uniquePhone() => '6${_rand.nextInt(9000000) + 1000000}';

late WidgetTester t;
late AppLocalizations l10n;

/// The member's phone camera.
class QaScanner implements QrScanner {
  void Function(String code)? _onCode;
  void read(String code) => _onCode!(code);

  @override
  Widget view(void Function(String code) onCode) {
    _onCode = onCode;
    return const ColoredBox(color: Colors.black);
  }

  @override
  Future<void> toggleTorch() async {}
  @override
  Future<void> stop() async {}
  @override
  void dispose() {}
}

class QaCamera extends CameraPermission {
  const QaCamera();
  @override
  Future<CameraAccess> status() async => CameraAccess.granted;
}

/// Setup through the API (what reception would do in the app, see D5).
class Api {
  Api(String baseUrl) : dio = Dio(BaseOptions(baseUrl: baseUrl));
  final Dio dio;

  Options _auth(String token) =>
      Options(headers: {'Authorization': 'Bearer $token'});

  Future<String> login(String phone, String password) async {
    final res = await dio.post<Map<String, dynamic>>(
      '/auth/login',
      data: {'phone': phone, 'password': password},
    );
    return res.data!['accessToken'] as String;
  }

  /// Logs in with a temporary password and sets [userPassword].
  Future<void> activate(String phone, String temporary) async {
    final token = await login(phone, temporary);
    await dio.post<void>(
      '/auth/change-password',
      data: {'currentPassword': temporary, 'newPassword': userPassword},
      options: _auth(token),
    );
  }

  Future<String> adminToken() async {
    try {
      return await login(adminPhone, adminPassword);
    } on DioException {
      await activateAdmin();
      return login(adminPhone, adminPassword);
    }
  }

  Future<void> activateAdmin() async {
    final token = await login(adminPhone, adminSeedPassword);
    await dio.post<void>(
      '/auth/change-password',
      data: {
        'currentPassword': adminSeedPassword,
        'newPassword': adminPassword,
      },
      options: _auth(token),
    );
  }

  Future<String> createKiosk(String admin) async {
    final phone = uniquePhone();
    final res = await dio.post<Map<String, dynamic>>(
      '/admin/staff',
      data: {
        'role': 'KIOSK',
        'firstName': 'Kiosco',
        'lastName': 'Entrada',
        'phone': phone,
      },
      options: _auth(admin),
    );
    await activate(phone, res.data!['temporaryPassword'] as String);
    return phone;
  }

  /// Active BASIC member for 1 month; [expired] voids the payment.
  Future<String> createMember(
    String admin,
    String firstName, {
    bool expired = false,
  }) async {
    final phone = uniquePhone();
    final preview = await dio.get<Map<String, dynamic>>(
      '/admin/members/preview',
      queryParameters: {'tier': 'BASIC', 'months': 1},
      options: _auth(admin),
    );
    final res = await dio.post<Map<String, dynamic>>(
      '/admin/members',
      data: {
        'firstName': firstName,
        'lastName': 'QA',
        'phone': phone,
        'tier': 'BASIC',
        'months': 1,
        'amount': num.parse(preview.data!['suggestedAmount'] as String),
        'method': 'CASH',
      },
      options: _auth(admin),
    );
    if (expired) {
      final payment = (res.data!['payments'] as List).first as Map;
      await dio.post<void>(
        '/admin/payments/${payment['id']}/void',
        data: {'reason': 'QA: membresía vencida'},
        options: _auth(admin),
      );
    }
    await activate(phone, res.data!['temporaryPassword'] as String);
    return phone;
  }

  Future<String> qrToken(String kiosk) async {
    final res = await dio.get<Map<String, dynamic>>(
      '/kiosk/qr-token',
      options: _auth(kiosk),
    );
    return res.data!['token'] as String;
  }

  Future<void> checkIn(String member, String qr) => dio.post<void>(
    '/checkins',
    data: {'qrToken': qr},
    options: _auth(member),
  );
}

/// What an admin's socket receives, with the arrival time.
class AdminSocket {
  AdminSocket(String origin, String token) {
    socket = io.io(
      '$origin/realtime',
      io.OptionBuilder().setTransports(['websocket']).enableForceNew().setAuth({
        'token': token,
      }).build(),
    );
    socket
      ..on('ready', (_) => ready.complete())
      ..on('checkin.created', (d) => created.add((DateTime.now(), d as Map)))
      ..on('checkin.denied', (d) => denied.add((DateTime.now(), d as Map)));
  }

  late final io.Socket socket;
  final ready = Completer<void>();
  final created = <(DateTime, Map<dynamic, dynamic>)>[];
  final denied = <(DateTime, Map<dynamic, dynamic>)>[];
}

Future<void> waitFor(Finder finder, {int seconds = 20}) async {
  final end = DateTime.now().add(Duration(seconds: seconds));
  while (DateTime.now().isBefore(end)) {
    await t.pump(const Duration(milliseconds: 100));
    if (finder.evaluate().isNotEmpty) return;
  }
  throw TestFailure('Timed out waiting for $finder');
}

Future<void> wait(Duration d) async {
  final end = DateTime.now().add(d);
  while (DateTime.now().isBefore(end)) {
    await t.pump(const Duration(milliseconds: 100));
  }
}

Future<void> tapKey(String key) => tapOn(find.byKey(Key(key)));

/// Waits for [f], lets page transitions finish, then taps it.
Future<void> tapOn(Finder f) async {
  await waitFor(f);
  await wait(const Duration(milliseconds: 600));
  await t.tap(f.first);
  await t.pump(const Duration(milliseconds: 300));
}

Future<void> uiLogin(String phone, String password) async {
  await waitFor(find.byKey(const Key('login.phone')));
  await t.enterText(find.byKey(const Key('login.phone')), phone);
  await t.enterText(find.byKey(const Key('login.password')), password);
  await tapKey('login.submit');
}

String shownQr() => t.widget<KioskQr>(find.byKey(const Key('kiosk.qr'))).token;

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
