import 'package:flutter_test/flutter_test.dart';
import 'package:gym_app/core/models/enums.dart';
import 'package:gym_app/core/models/paginated.dart';
import 'package:gym_app/features/admin/settings/data/gym_admin_repository.dart';
import 'package:gym_app/features/admin/shared/labels.dart';
import 'package:gym_app/features/admin/shared/temporary_password_screen.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/admin_fixtures.dart';
import '../../helpers/fakes.dart';

StaffMember staff(StaffRole role, {String id = 's1', bool active = true}) =>
    StaffMember(
      id: id,
      role: role,
      firstName: 'Kiosco',
      lastName: 'Entrada',
      phone: '+59170000001',
      email: null,
      isActive: active,
    );

void main() {
  setUpAll(registerAdminFallbacks);

  late AdminHarness h;
  setUp(() {
    h = AdminHarness();
    when(
      () => h.admin.staff(
        role: any(named: 'role'),
        includeInactive: any(named: 'includeInactive'),
      ),
    ).thenAnswer(
      (_) async => Paginated(
        items: [staff(StaffRole.admin, id: 'a1')],
        page: 1,
        pageSize: 100,
        total: 1,
      ),
    );
  });

  for (final role in [StaffRole.trainer, StaffRole.kiosk]) {
    testWidgets('create a ${role.name.toUpperCase()} account', (tester) async {
      usePhoneScreen(tester);
      when(
        () => h.admin.createStaff(
          role: any(named: 'role'),
          firstName: any(named: 'firstName'),
          lastName: any(named: 'lastName'),
          phone: any(named: 'phone'),
          email: any(named: 'email'),
        ),
      ).thenAnswer((_) async => (staff(role), 'Kq7mPw3x'));

      await h.open(tester, '/admin/more/staff');
      await tapVisible(tester, find.byKey(const Key('staff.new')));
      await tapVisible(tester, find.text(en.staffRoleLabel(role)));
      await tester.enterText(
        find.byKey(const Key('staff.firstName')),
        'Kiosco',
      );
      await tester.enterText(
        find.byKey(const Key('staff.lastName')),
        'Entrada',
      );
      await tester.enterText(find.byKey(const Key('staff.phone')), '70000001');
      await tapVisible(tester, find.byKey(const Key('staff.create')));

      verify(
        () => h.admin.createStaff(
          role: role,
          firstName: 'Kiosco',
          lastName: 'Entrada',
          phone: '+59170000001',
        ),
      ).called(1);
      expect(find.byType(TemporaryPasswordScreen), findsOneWidget);
      expect(find.text('Kq7mPw3x'), findsOneWidget);
    });
  }

  testWidgets('[R-45] deactivating the last admin shows the server error', (
    tester,
  ) async {
    usePhoneScreen(tester);
    when(() => h.admin.setStaffActive('a1', active: false))
        .thenThrow(apiError(409, 'LAST_ACTIVE_ADMIN'));
    await h.open(tester, '/admin/more/staff');
    await tester.tap(
      find.descendant(
        of: find.byKey(const Key('staff.a1')),
        matching: find.byType(PopupMenuButton<bool>),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text(en.actionDeactivate).last);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('dialog.confirm')));
    await tester.pumpAndSettle();
    expect(find.text(en.errorLastActiveAdmin), findsOneWidget);
  });

  testWidgets('[R-11] prices are edited per tier', (tester) async {
    usePhoneScreen(tester);
    when(() => h.admin.updatePrices(any())).thenAnswer((_) async {});
    await h.open(tester, '/admin/more/pricing');
    await tester.enterText(find.byKey(const Key('pricing.plus')), '275,50');
    await tapVisible(tester, find.byKey(const Key('pricing.save')));
    final sent =
        verify(() => h.admin.updatePrices(captureAny())).captured.single
            as Map<Tier, int>;
    expect(sent, {Tier.basic: 15000, Tier.plus: 27550, Tier.premium: 40000});
    expect(find.text(en.commonSaved), findsOneWidget);
  });

  testWidgets('settings are validated and saved; time zone is read-only', (
    tester,
  ) async {
    usePhoneScreen(tester);
    const settings = GymSettings(
      gymName: 'Forja',
      timezone: 'America/La_Paz',
      checkinCooldownMinutes: 180,
      insideWindowMinutes: 120,
      defaultCountryCode: '+591',
    );
    when(h.admin.settings).thenAnswer((_) async => settings);
    when(
      () => h.admin.updateSettings(
        gymName: any(named: 'gymName'),
        checkinCooldownMinutes: any(named: 'checkinCooldownMinutes'),
        insideWindowMinutes: any(named: 'insideWindowMinutes'),
        defaultCountryCode: any(named: 'defaultCountryCode'),
      ),
    ).thenAnswer((_) async => settings);
    await h.open(tester, '/admin/more/settings');
    expect(find.text('America/La_Paz'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('settings.cooldown')), '0');
    await tapVisible(tester, find.byKey(const Key('settings.save')));
    expect(find.text(en.validationIntRange(1, 1440)), findsOneWidget);

    await tester.enterText(find.byKey(const Key('settings.cooldown')), '90');
    await tapVisible(tester, find.byKey(const Key('settings.save')));
    verify(
      () => h.admin.updateSettings(
        gymName: 'Forja',
        checkinCooldownMinutes: 90,
        insideWindowMinutes: 120,
        defaultCountryCode: '+591',
      ),
    ).called(1);
  });
}
