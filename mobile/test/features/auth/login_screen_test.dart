import 'package:flutter_test/flutter_test.dart';
import 'package:gym_app/core/auth/token_storage.dart';
import 'package:gym_app/features/admin/presentation/admin_home_screen.dart';
import 'package:gym_app/features/auth/presentation/login_screen.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/fakes.dart';

void main() {
  late MockAuthRepository repo;
  late MemoryTokenStorage storage;

  setUp(() {
    repo = MockAuthRepository();
    storage = MemoryTokenStorage();
  });

  Future<void> openLogin(WidgetTester tester) async {
    await pumpGymApp(tester, repo: repo, storage: storage);
    expect(find.byType(LoginScreen), findsOneWidget);
  }

  Future<void> submit(WidgetTester tester) async {
    await tester.tap(find.byKey(const Key('login.submit')));
    await tester.pumpAndSettle();
  }

  testWidgets('empty form shows required errors and does not call the API', (
    tester,
  ) async {
    await openLogin(tester);
    await submit(tester);
    expect(find.text(en.validationRequired), findsNWidgets(2));
    verifyNever(
      () => repo.login(
        phone: any(named: 'phone'),
        password: any(named: 'password'),
      ),
    );
  });

  testWidgets('[R-40] an invalid phone is rejected on the client', (
    tester,
  ) async {
    await openLogin(tester);
    await tester.enterText(find.byKey(const Key('login.phone')), '123');
    await tester.enterText(find.byKey(const Key('login.password')), 'x');
    await submit(tester);
    expect(find.text(en.validationPhoneInvalid), findsOneWidget);
  });

  testWidgets('the password field has a show/hide toggle', (tester) async {
    await openLogin(tester);
    TextField field() => tester.widget<TextField>(
      find.descendant(
        of: find.byKey(const Key('login.password')),
        matching: find.byType(TextField),
      ),
    );
    expect(field().obscureText, isTrue);
    await tester.tap(find.byTooltip(en.loginShowPassword));
    await tester.pump();
    expect(field().obscureText, isFalse);
  });

  testWidgets('[R-40] valid input logs in with the normalized phone', (
    tester,
  ) async {
    when(
      () => repo.login(
        phone: any(named: 'phone'),
        password: any(named: 'password'),
      ),
    ).thenAnswer((_) async => storedTokens);
    when(() => repo.me()).thenAnswer((_) async => fakeUser());

    await openLogin(tester);
    await tester.enterText(find.byKey(const Key('login.phone')), '7000 0000');
    await tester.enterText(
      find.byKey(const Key('login.password')),
      'Secret123',
    );
    await submit(tester);

    verify(() => repo.login(phone: '+59170000000', password: 'Secret123'))
        .called(1);
    expect(storage.tokens, storedTokens);
    expect(find.byType(AdminHomeScreen), findsOneWidget);
  });

  testWidgets('a backend error code is shown as a localized message', (
    tester,
  ) async {
    when(
      () => repo.login(
        phone: any(named: 'phone'),
        password: any(named: 'password'),
      ),
    ).thenThrow(apiError(401, 'INVALID_CREDENTIALS'));

    await openLogin(tester);
    await tester.enterText(find.byKey(const Key('login.phone')), '70000000');
    await tester.enterText(find.byKey(const Key('login.password')), 'wrong');
    await submit(tester);

    expect(find.text(en.errorInvalidCredentials), findsOneWidget);
    expect(find.byType(LoginScreen), findsOneWidget);
    expect(storage.tokens, isNull);
  });
}
