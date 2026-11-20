// Shared helpers of the integration tests (QA against a real backend).
import 'dart:async';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_app/features/kiosk/presentation/kiosk_home_screen.dart';
import 'package:gym_app/features/member/checkin/presentation/scanner_devices.dart';
import 'package:gym_app/l10n/generated/app_localizations.dart';
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
    memberIds[phone] = res.data!['id'] as String;
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

  /// Member id by phone, for members created here.
  final memberIds = <String, String>{};

  /// Renews 1 month of BASIC at the list price.
  Future<void> renew(String admin, String memberId) async {
    final preview = await dio.get<Map<String, dynamic>>(
      '/admin/members/$memberId/payments/preview',
      queryParameters: {'tier': 'BASIC', 'months': 1},
      options: _auth(admin),
    );
    await dio.post<void>(
      '/admin/members/$memberId/payments',
      data: {
        'tier': 'BASIC',
        'months': 1,
        'amount': num.parse(preview.data!['suggestedAmount'] as String),
        'method': 'CASH',
      },
      options: _auth(admin),
    );
  }

  Future<Map<String, dynamic>> runJob(String admin, String name) async {
    final res = await dio.post<Map<String, dynamic>>(
      '/admin/jobs/$name/run',
      options: _auth(admin),
    );
    return res.data!;
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
