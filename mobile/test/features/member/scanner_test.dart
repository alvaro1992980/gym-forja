import 'package:flutter_test/flutter_test.dart';
import 'package:gym_app/core/auth/token_storage.dart';
import 'package:gym_app/core/models/enums.dart';
import 'package:gym_app/core/network/api_exception.dart';
import 'package:gym_app/core/utils/device_actions.dart';
import 'package:gym_app/features/member/checkin/domain/checkin_result.dart';
import 'package:gym_app/features/member/checkin/presentation/scanner_devices.dart';
import 'package:gym_app/features/member/home/presentation/member_home_screen.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/fakes.dart';

class MockCameraPermission extends Mock implements CameraPermission {}

class MockDeviceActions extends Mock implements DeviceActions {}

/// A "camera" that reads whatever the test sends with [read].
class FakeScanner implements QrScanner {
  void Function(String code)? _onCode;
  bool stopped = false;
  int torch = 0;

  void read(String code) => _onCode!(code);

  @override
  Widget view(void Function(String code) onCode) {
    _onCode = onCode;
    return const ColoredBox(key: Key('fake.camera'), color: Colors.black);
  }

  @override
  Future<void> toggleTorch() async => torch++;

  @override
  Future<void> stop() async => stopped = true;

  @override
  void dispose() {}
}

void main() {
  late MockAuthRepository auth;
  late MockMemberRepository member;
  late MockCameraPermission permission;
  late MockDeviceActions device;
  late FakeScanner scanner;

  setUp(() {
    auth = MockAuthRepository();
    member = defaultMemberRepo();
    permission = MockCameraPermission();
    device = MockDeviceActions();
    scanner = FakeScanner();
    when(auth.me).thenAnswer((_) async => fakeUser(role: Role.member));
    when(device.vibrate).thenAnswer((_) async {});
    when(permission.openSettings).thenAnswer((_) async => true);
  });

  Future<void> openScanner(WidgetTester tester) async {
    await pumpGymApp(
      tester,
      repo: auth,
      storage: MemoryTokenStorage(storedTokens),
      member: member,
      overrides: [
        cameraPermissionProvider.overrideWithValue(permission),
        qrScannerFactoryProvider.overrideWithValue(() => scanner),
        deviceActionsProvider.overrideWithValue(device),
      ],
    );
    await tester.tap(find.byKey(const Key('member.scan')));
    await tester.pumpAndSettle();
  }

  testWidgets('explains, asks for the camera, then scans', (tester) async {
    when(permission.status).thenAnswer((_) async => CameraAccess.denied);
    when(permission.request).thenAnswer((_) async => CameraAccess.granted);
    await openScanner(tester);

    expect(find.text(en.scannerExplain), findsOneWidget);
    verifyNever(permission.request);
    await tester.tap(find.byKey(const Key('scanner.permissionAction')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('fake.camera')), findsOneWidget);
    expect(find.text(en.scannerHint), findsOneWidget);

    await tester.tap(find.byKey(const Key('scanner.torch')));
    expect(scanner.torch, 1);
  });

  testWidgets('denied: explains again and offers to ask', (tester) async {
    when(permission.status).thenAnswer((_) async => CameraAccess.denied);
    when(permission.request).thenAnswer((_) async => CameraAccess.denied);
    await openScanner(tester);
    await tester.tap(find.byKey(const Key('scanner.permissionAction')));
    await tester.pumpAndSettle();
    expect(find.text(en.scannerDenied), findsOneWidget);
    expect(find.text(en.scannerAllowCamera), findsOneWidget);
  });

  testWidgets('blocked: a button opens the system settings', (tester) async {
    when(permission.status)
        .thenAnswer((_) async => CameraAccess.permanentlyDenied);
    await openScanner(tester);
    expect(find.text(en.scannerBlocked), findsOneWidget);
    await tester.tap(find.text(en.scannerOpenSettings));
    verify(permission.openSettings).called(1);
  });

  testWidgets('a QR read: vibrate, stop the camera, check in, show result', (
    tester,
  ) async {
    when(permission.status).thenAnswer((_) async => CameraAccess.granted);
    when(() => member.checkIn('qr-token')).thenAnswer(
      (_) async => const CheckinResponse(
        duplicate: false,
        checkinId: 'c1',
        checkedInAt: '2026-11-19T22:05:00.000Z',
        member: CheckinMember(firstName: 'Ana'),
        membership: CheckinMembership(
          tier: Tier.basic,
          endDate: '2026-11-30',
          daysLeft: 12,
        ),
      ),
    );
    await openScanner(tester);

    scanner.read('qr-token');
    scanner.read('qr-token'); // the camera keeps reading: sent only once
    await tester.pumpAndSettle();

    verify(device.vibrate).called(1);
    expect(scanner.stopped, isTrue);
    verify(() => member.checkIn('qr-token')).called(1);
    expect(find.text(en.checkinWelcome('Ana')), findsOneWidget);

    // Back goes home, not to the scanner.
    await tester.tap(find.byKey(const Key('result.action')));
    await tester.pumpAndSettle();
    expect(find.byType(MemberHomeScreen), findsOneWidget);
  });

  testWidgets('[R-18] an expired QR shows "invalid code, scan again"', (
    tester,
  ) async {
    when(permission.status).thenAnswer((_) async => CameraAccess.granted);
    when(
      () => member.checkIn(any()),
    ).thenThrow(const ApiException(code: 'QR_TOKEN_EXPIRED', statusCode: 400));
    await openScanner(tester);
    scanner.read('old-token');
    await tester.pumpAndSettle();
    expect(find.text(en.checkinInvalidQr), findsOneWidget);
  });
}
