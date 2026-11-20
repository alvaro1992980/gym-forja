import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_app/app.dart';
import 'package:gym_app/core/auth/auth_tokens.dart';
import 'package:gym_app/core/auth/token_storage.dart';
import 'package:gym_app/core/models/enums.dart';
import 'package:gym_app/core/models/paginated.dart';
import 'package:gym_app/core/network/api_exception.dart';
import 'package:gym_app/core/realtime/realtime_client.dart';
import 'package:gym_app/core/router/app_router.dart';
import 'package:gym_app/core/utils/preferences.dart';
import 'package:gym_app/features/admin/checkins/data/checkins_repository.dart';
import 'package:gym_app/features/admin/checkins/domain/checkin_models.dart';
import 'package:gym_app/features/auth/data/auth_repository.dart';
import 'package:gym_app/features/auth/domain/current_user.dart';
import 'package:gym_app/features/kiosk/data/kiosk_repository.dart';
import 'package:gym_app/features/kiosk/presentation/kiosk_controller.dart';
import 'package:gym_app/features/member/data/member_repository.dart';
import 'package:gym_app/l10n/generated/app_localizations.dart';
import 'package:gym_app/main.dart' show noRetry;
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockCheckinsRepository extends Mock implements CheckinsRepository {}

class MockMemberRepository extends Mock implements MemberRepository {}

class MockKioskRepository extends Mock implements KioskRepository {}

/// In-memory [Preferences].
class FakePreferences implements Preferences {
  final values = <String, bool>{};

  @override
  Future<bool?> getBool(String key) async => values[key];

  @override
  Future<void> setBool(String key, bool value) async => values[key] = value;
}

/// A realtime connection whose events the test sends with [emit].
class FakeRealtime implements RealtimeConnection {
  final _controller = StreamController<RealtimeEvent>.broadcast();

  @override
  Stream<RealtimeEvent> get events => _controller.stream;

  void emit(RealtimeEvent event) => _controller.add(event);

  @override
  void dispose() {}
}

/// Kiosk device mode without platform calls.
class FakeKioskDisplay implements KioskDisplay {
  int entered = 0;
  int exited = 0;

  @override
  Future<void> enter() async => entered++;

  @override
  Future<void> exit() async => exited++;
}

Paginated<T> pageOf<T>(List<T> items) =>
    Paginated(items: items, page: 1, pageSize: 100, total: items.length);

const activeMembership = MembershipSummary(
  tier: Tier.plus,
  startDate: '2026-11-01',
  endDate: '2026-11-30',
  daysLeft: 12,
  status: MembershipStatus.active,
);

/// Check-ins API with no data.
MockCheckinsRepository emptyCheckins() {
  final repo = MockCheckinsRepository();
  when(
    () => repo.list(
      from: any(named: 'from'),
      to: any(named: 'to'),
      memberId: any(named: 'memberId'),
      page: any(named: 'page'),
      pageSize: any(named: 'pageSize'),
    ),
  ).thenAnswer((_) async => pageOf(<CheckinItem>[]));
  when(repo.inside).thenAnswer(
    (_) async => const InsideNow(count: 0, windowMinutes: 120, items: []),
  );
  when(
    () => repo.attempts(
      from: any(named: 'from'),
      to: any(named: 'to'),
      memberId: any(named: 'memberId'),
      pageSize: any(named: 'pageSize'),
    ),
  ).thenAnswer((_) async => pageOf(<CheckinAttempt>[]));
  return repo;
}

/// A kiosk QR token (JWT-shaped, valid 45 s).
const testQrJwt =
    'eyJhbGciOiJIUzI1NiJ9.'
    'eyJ0eXAiOiJjaGVja2luIiwia2lkIjoiazEiLCJpYXQiOjEwMDAsImV4cCI6MTA0NX0.'
    'sig';

MockKioskRepository defaultKioskRepo() {
  final repo = MockKioskRepository();
  when(repo.qrToken).thenAnswer(
    (_) async => QrToken.fromJson(const {
      'token': testQrJwt,
      'refreshInSeconds': 30,
      'gymName': 'Forja Gym',
    }),
  );
  return repo;
}

/// Member API: an active PLUS membership and no check-ins.
MockMemberRepository defaultMemberRepo() {
  final repo = MockMemberRepository();
  when(repo.membership).thenAnswer((_) async => activeMembership);
  when(
    () => repo.checkinTimes(
      from: any(named: 'from'),
      to: any(named: 'to'),
    ),
  ).thenAnswer((_) async => []);
  return repo;
}

const storedTokens = AuthTokens(accessToken: 'access', refreshToken: 'refresh');

CurrentUser fakeUser({
  Role role = Role.admin,
  bool mustChangePassword = false,
  MembershipSummary? membership,
}) => CurrentUser(
  id: 'u1',
  role: role,
  firstName: 'Ana',
  lastName: 'Rojas',
  phone: '+59170000000',
  mustChangePassword: mustChangePassword,
  membership: membership,
);

ApiException apiError(int status, String code) =>
    ApiException(code: code, statusCode: status);

/// English strings, the locale widget tests run in.
final AppLocalizations en = lookupAppLocalizations(const Locale('en'));

/// Pumps the whole app (router + session) with fake storage and API.
Future<void> pumpGymApp(
  WidgetTester tester, {
  required MockAuthRepository repo,
  required TokenStorage storage,
  List<Override> overrides = const [],
  RealtimeConnection? realtime,
  CheckinsRepository? checkins,
  MemberRepository? member,
  KioskRepository? kiosk,
  KioskDisplay? kioskDisplay,
  Preferences? preferences,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      retry: noRetry,
      overrides: [
        tokenStorageProvider.overrideWithValue(storage),
        authRepositoryProvider.overrideWithValue(repo),
        // No sockets, plugins or network in widget tests.
        realtimeConnectionProvider.overrideWithValue(realtime),
        checkinsRepositoryProvider.overrideWithValue(
          checkins ?? emptyCheckins(),
        ),
        memberRepositoryProvider.overrideWithValue(
          member ?? defaultMemberRepo(),
        ),
        kioskRepositoryProvider.overrideWithValue(kiosk ?? defaultKioskRepo()),
        kioskDisplayProvider.overrideWithValue(
          kioskDisplay ?? FakeKioskDisplay(),
        ),
        preferencesProvider.overrideWithValue(preferences ?? FakePreferences()),
        ...overrides,
      ],
      child: const GymApp(),
    ),
  );
  await tester.pumpAndSettle();
}

/// A phone-sized viewport (about 412×915 dp) for long forms.
void usePhoneScreen(WidgetTester tester) {
  tester.view.physicalSize = const Size(1236, 2745);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
}

/// Scrolls [finder] into view and taps it.
Future<void> tapVisible(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

/// Navigates the running app to [location].
Future<void> goTo(WidgetTester tester, String location) async {
  ProviderScope.containerOf(tester.element(find.byType(GymApp)))
      .read(routerProvider)
      .go(location);
  await tester.pumpAndSettle();
}
