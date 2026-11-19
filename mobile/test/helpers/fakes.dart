import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_app/app.dart';
import 'package:gym_app/core/auth/auth_tokens.dart';
import 'package:gym_app/core/auth/token_storage.dart';
import 'package:gym_app/core/models/enums.dart';
import 'package:gym_app/core/network/api_exception.dart';
import 'package:gym_app/core/router/app_router.dart';
import 'package:gym_app/features/auth/data/auth_repository.dart';
import 'package:gym_app/features/auth/domain/current_user.dart';
import 'package:gym_app/l10n/generated/app_localizations.dart';
import 'package:gym_app/main.dart' show noRetry;
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

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
}) async {
  await tester.pumpWidget(
    ProviderScope(
      retry: noRetry,
      overrides: [
        tokenStorageProvider.overrideWithValue(storage),
        authRepositoryProvider.overrideWithValue(repo),
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
