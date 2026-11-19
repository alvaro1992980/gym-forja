import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_app/app.dart';
import 'package:gym_app/core/auth/auth_tokens.dart';
import 'package:gym_app/core/auth/token_storage.dart';
import 'package:gym_app/core/models/enums.dart';
import 'package:gym_app/core/network/api_exception.dart';
import 'package:gym_app/features/auth/data/auth_repository.dart';
import 'package:gym_app/features/auth/domain/current_user.dart';
import 'package:gym_app/l10n/generated/app_localizations.dart';
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
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        tokenStorageProvider.overrideWithValue(storage),
        authRepositoryProvider.overrideWithValue(repo),
      ],
      child: const GymApp(),
    ),
  );
  await tester.pumpAndSettle();
}
