import 'package:flutter_test/flutter_test.dart';
import 'package:gym_app/core/models/enums.dart';
import 'package:gym_app/features/admin/members/domain/member_models.dart';
import 'package:gym_app/features/admin/members/presentation/member_detail_screen.dart';
import 'package:gym_app/features/admin/shared/temporary_password_screen.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/admin_fixtures.dart';
import '../../helpers/fakes.dart';

void main() {
  setUpAll(registerAdminFallbacks);

  late AdminHarness h;
  setUp(() {
    h = AdminHarness();
    when(
      () => h.members.previewNew(
        tier: any(named: 'tier'),
        months: any(named: 'months'),
        startDate: any(named: 'startDate'),
      ),
    ).thenAnswer((inv) async {
      final months = inv.namedArguments[#months] as int;
      final tier = inv.namedArguments[#tier] as Tier;
      final monthly = {Tier.basic: 150, Tier.plus: 250, Tier.premium: 400};
      return PaymentPreview(
        periodStart: '2026-11-19',
        periodEnd: months == 3 ? '2027-02-18' : '2026-12-18',
        suggestedAmount: '${monthly[tier]! * months}.00',
        currency: 'BOB',
        tierApplies: TierApplies.unchanged,
      );
    });
    when(() => h.members.detail('m1')).thenAnswer((_) async => detail());
  });

  Future<void> next(WidgetTester tester) =>
      tapVisible(tester, find.byKey(const Key('newMember.next')));

  testWidgets('personal data is validated before continuing', (tester) async {
    usePhoneScreen(tester);
    await h.open(tester, '/admin/members/new');

    await next(tester);
    // First name, last name and phone.
    expect(find.text(en.validationRequired), findsNWidgets(3));

    await tester.enterText(find.byKey(const Key('member.firstName')), 'Juan');
    await tester.enterText(find.byKey(const Key('member.lastName')), 'Pérez');
    await tester.enterText(find.byKey(const Key('member.phone')), '123');
    await tester.enterText(find.byKey(const Key('member.email')), 'no-at');
    await next(tester);
    expect(find.text(en.validationPhoneInvalid), findsOneWidget);
    expect(find.text(en.validationEmailInvalid), findsOneWidget);
    verifyNever(() => h.members.create(any()));
  });

  testWidgets(
    'create a member with the stepper; the temporary password is shown once '
    'with copy and share',
    (tester) async {
      usePhoneScreen(tester);
      when(() => h.members.create(any()))
          .thenAnswer((_) async => (detail(), 'Ab3dEf7h'));
      await h.open(tester, '/admin/members/new');

      // 1. Personal data.
      await tester.enterText(find.byKey(const Key('member.firstName')), 'Juan');
      await tester.enterText(find.byKey(const Key('member.lastName')), 'Pérez');
      await tester.enterText(
        find.byKey(const Key('member.phone')),
        '7123 4567',
      );
      await next(tester);

      // 2. Membership: tier with its monthly price, 3 months.
      expect(find.text(en.tierWithPrice('Bs 250,00')), findsOneWidget);
      await tapVisible(tester, find.byKey(const Key('tier.plus')));
      await tapVisible(tester, find.byKey(const Key('months.3')));
      await next(tester);

      // 3. Payment: preview + suggested amount prefilled.
      expect(
        find.text(en.newPeriod('19/11/2026', '18/02/2027')),
        findsOneWidget,
      );
      expect(find.text(en.suggestedAmount('Bs 750,00')), findsOneWidget);
      final amount = find.byKey(const Key('payment.amount'));
      expect(
        tester
            .widget<EditableText>(
              find.descendant(of: amount, matching: find.byType(EditableText)),
            )
            .controller
            .text,
        '750',
      );

      // [R-10] A different amount needs a note.
      await tester.enterText(amount, '700');
      await next(tester);
      expect(find.text(en.validationNoteRequired), findsOneWidget);
      await tester.enterText(
        find.byKey(const Key('payment.note')),
        'Descuento estudiante',
      );
      await next(tester);

      // 4. Summary → confirm.
      expect(find.text('Bs 700,00'), findsOneWidget);
      await tapVisible(tester, find.byKey(const Key('newMember.confirm')));

      final input =
          verify(() => h.members.create(captureAny())).captured.single
              as NewMemberInput;
      expect(input.firstName, 'Juan');
      expect(input.phone, '+59171234567');
      expect(input.tier, Tier.plus);
      expect(input.months, 3);
      expect(input.startDate, '2026-11-19');
      expect(input.amountCents, 70000);
      expect(input.method, PaymentMethod.cash);
      expect(input.note, 'Descuento estudiante');

      // 5. Temporary password with copy / share.
      expect(find.byType(TemporaryPasswordScreen), findsOneWidget);
      expect(find.text('Ab3dEf7h'), findsOneWidget);
      expect(find.text(en.tempPasswordWarning), findsOneWidget);
      await tapVisible(tester, find.byKey(const Key('tempPassword.copy')));
      verify(() => h.device.copy('Ab3dEf7h')).called(1);
      await tapVisible(tester, find.byKey(const Key('tempPassword.share')));
      final shared =
          verify(() => h.device.share(captureAny())).captured.single as String;
      expect(shared, contains('Ab3dEf7h'));
      expect(shared, contains('+59171234567'));

      await tapVisible(tester, find.byKey(const Key('tempPassword.done')));
      expect(find.byType(MemberDetailScreen), findsOneWidget);
      expect(find.text('Ab3dEf7h'), findsNothing);
    },
  );

  testWidgets('a backend error is shown on the summary step', (tester) async {
    usePhoneScreen(tester);
    when(() => h.members.create(any()))
        .thenThrow(apiError(409, 'PHONE_ALREADY_EXISTS'));
    await h.open(tester, '/admin/members/new');
    await tester.enterText(find.byKey(const Key('member.firstName')), 'Juan');
    await tester.enterText(find.byKey(const Key('member.lastName')), 'Pérez');
    await tester.enterText(find.byKey(const Key('member.phone')), '71234567');
    await next(tester);
    await next(tester);
    await next(tester);
    await tapVisible(tester, find.byKey(const Key('newMember.confirm')));
    expect(find.text(en.errorPhoneAlreadyExists), findsOneWidget);
    expect(find.byType(TemporaryPasswordScreen), findsNothing);
  });
}
