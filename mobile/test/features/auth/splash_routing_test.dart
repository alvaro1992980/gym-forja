import 'package:flutter_test/flutter_test.dart';
import 'package:gym_app/core/auth/token_storage.dart';
import 'package:gym_app/core/models/enums.dart';
import 'package:gym_app/core/network/api_exception.dart';
import 'package:gym_app/core/widgets/tier_badge.dart';
import 'package:gym_app/features/admin/presentation/admin_home_screen.dart';
import 'package:gym_app/features/auth/domain/current_user.dart';
import 'package:gym_app/features/auth/presentation/change_password_screen.dart';
import 'package:gym_app/features/auth/presentation/login_screen.dart';
import 'package:gym_app/features/auth/presentation/splash_screen.dart';
import 'package:gym_app/features/kiosk/presentation/kiosk_home_screen.dart';
import 'package:gym_app/features/member/home/presentation/member_home_screen.dart';
import 'package:gym_app/features/trainer/presentation/trainer_home_screen.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/fakes.dart';

void main() {
  late MockAuthRepository repo;

  setUp(() => repo = MockAuthRepository());

  testWidgets('without stored tokens the splash opens the login', (
    tester,
  ) async {
    await pumpGymApp(tester, repo: repo, storage: MemoryTokenStorage());
    expect(find.byType(LoginScreen), findsOneWidget);
    verifyNever(() => repo.me());
  });

  for (final (role, screen) in [
    (Role.admin, AdminHomeScreen),
    (Role.trainer, TrainerHomeScreen),
    (Role.kiosk, KioskHomeScreen),
  ]) {
    testWidgets('stored session of a $role opens its home', (tester) async {
      when(() => repo.me()).thenAnswer((_) async => fakeUser(role: role));
      await pumpGymApp(
        tester,
        repo: repo,
        storage: MemoryTokenStorage(storedTokens),
      );
      expect(find.byType(screen), findsOneWidget);
    });
  }

  testWidgets('a member lands on the member home with the tier badge', (
    tester,
  ) async {
    when(() => repo.me()).thenAnswer(
      (_) async => fakeUser(
        role: Role.member,
        membership: const MembershipSummary(
          tier: Tier.plus,
          startDate: '2026-11-01',
          endDate: '2026-11-30',
          daysLeft: 12,
          status: MembershipStatus.active,
        ),
      ),
    );
    await pumpGymApp(
      tester,
      repo: repo,
      storage: MemoryTokenStorage(storedTokens),
    );
    expect(find.byType(MemberHomeScreen), findsOneWidget);
    expect(find.byType(TierBadge), findsOneWidget);
    expect(find.text(en.membershipDaysLeft(12)), findsOneWidget);
    expect(find.text(en.membershipEndDate('30/11/2026')), findsOneWidget);
  });

  testWidgets('a pending password change opens the change-password screen', (
    tester,
  ) async {
    when(() => repo.me())
        .thenAnswer((_) async => fakeUser(mustChangePassword: true));
    await pumpGymApp(
      tester,
      repo: repo,
      storage: MemoryTokenStorage(storedTokens),
    );
    expect(find.byType(ChangePasswordScreen), findsOneWidget);
  });

  testWidgets('a rejected session clears the tokens and opens the login', (
    tester,
  ) async {
    final storage = MemoryTokenStorage(storedTokens);
    when(() => repo.me()).thenThrow(apiError(401, 'UNAUTHORIZED'));
    await pumpGymApp(tester, repo: repo, storage: storage);
    expect(find.byType(LoginScreen), findsOneWidget);
    expect(storage.tokens, isNull);
  });

  testWidgets('offline at launch: splash error with Retry, tokens kept', (
    tester,
  ) async {
    final storage = MemoryTokenStorage(storedTokens);
    when(() => repo.me())
        .thenThrow(const ApiException(code: ClientErrorCode.network));
    await pumpGymApp(tester, repo: repo, storage: storage);

    expect(find.byType(SplashScreen), findsOneWidget);
    expect(find.textContaining(en.errorNetwork), findsOneWidget);
    expect(storage.tokens, storedTokens);

    when(() => repo.me()).thenAnswer((_) async => fakeUser());
    await tester.tap(find.text(en.commonRetry));
    await tester.pumpAndSettle();
    expect(find.byType(AdminHomeScreen), findsOneWidget);
  });

  testWidgets(
    'seeded admin: login → forced password change → admin home → logout',
    (tester) async {
      final storage = MemoryTokenStorage();
      var mustChange = true;
      when(
        () => repo.login(
          phone: any(named: 'phone'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => storedTokens);
      when(() => repo.me())
          .thenAnswer((_) async => fakeUser(mustChangePassword: mustChange));
      when(
        () => repo.changePassword(
          currentPassword: any(named: 'currentPassword'),
          newPassword: any(named: 'newPassword'),
        ),
      ).thenAnswer((_) async => mustChange = false);
      when(() => repo.logout(any())).thenAnswer((_) async {});

      await pumpGymApp(tester, repo: repo, storage: storage);
      await tester.enterText(find.byKey(const Key('login.phone')), '70000000');
      await tester.enterText(
        find.byKey(const Key('login.password')),
        'ChangeMe123',
      );
      await tester.tap(find.byKey(const Key('login.submit')));
      await tester.pumpAndSettle();
      expect(find.byType(ChangePasswordScreen), findsOneWidget);

      await tester.enterText(
        find.byKey(const Key('changePassword.current')),
        'ChangeMe123',
      );
      await tester.enterText(
        find.byKey(const Key('changePassword.new')),
        'NuevaClave2026',
      );
      await tester.enterText(
        find.byKey(const Key('changePassword.confirm')),
        'NuevaClave2026',
      );
      await tester.tap(find.byKey(const Key('changePassword.submit')));
      await tester.pumpAndSettle();
      verify(
        () => repo.changePassword(
          currentPassword: 'ChangeMe123',
          newPassword: 'NuevaClave2026',
        ),
      ).called(1);
      expect(find.byType(AdminHomeScreen), findsOneWidget);

      await tester.tap(find.byKey(const Key('nav.more')));
      await tester.pumpAndSettle();
      await tester.tap(find.text(en.logout));
      await tester.pumpAndSettle();
      verify(() => repo.logout('refresh')).called(1);
      expect(storage.tokens, isNull);
      expect(find.byType(LoginScreen), findsOneWidget);
    },
  );
}
