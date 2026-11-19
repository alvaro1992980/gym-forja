import 'package:flutter_test/flutter_test.dart';
import 'package:gym_app/core/models/enums.dart';
import 'package:gym_app/features/admin/members/domain/member_models.dart';
import 'package:gym_app/features/admin/members/presentation/member_detail_screen.dart';
import 'package:gym_app/features/admin/shared/temporary_password_screen.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/admin_fixtures.dart';
import '../../helpers/fakes.dart';

String fieldText(WidgetTester tester, Key key) => tester
    .widget<EditableText>(
      find.descendant(of: find.byKey(key), matching: find.byType(EditableText)),
    )
    .controller
    .text;

void main() {
  setUpAll(registerAdminFallbacks);

  late AdminHarness h;
  setUp(() => h = AdminHarness());

  group('renew', () {
    setUp(() {
      when(() => h.members.detail('m1')).thenAnswer((_) async => detail());
      when(
        () => h.members.previewRenewal(
          'm1',
          tier: any(named: 'tier'),
          months: any(named: 'months'),
        ),
      ).thenAnswer((inv) async {
        final months = inv.namedArguments[#months] as int;
        final tier = inv.namedArguments[#tier] as Tier;
        return PaymentPreview(
          // [R-07] Active: the new period starts the day after endDate.
          periodStart: '2026-12-01',
          periodEnd: months == 1 ? '2026-12-31' : '2027-02-28',
          suggestedAmount: tier == Tier.premium
              ? '${400 * months}.00'
              : '${250 * months}.00',
          currency: 'BOB',
          tierApplies: tier == Tier.plus
              ? TierApplies.unchanged
              : TierApplies.scheduled,
        );
      });
      when(
        () => h.members.renew(
          'm1',
          tier: any(named: 'tier'),
          months: any(named: 'months'),
          amountCents: any(named: 'amountCents'),
          method: any(named: 'method'),
          note: any(named: 'note'),
          applyTierNow: any(named: 'applyTierNow'),
        ),
      ).thenAnswer((_) async {});
    });

    testWidgets(
      '[R-07] renew shows the new period from the preview before confirming',
      (tester) async {
        usePhoneScreen(tester);
        await h.open(tester, '/admin/members/m1/renew');

        expect(
          find.text(en.newPeriod('01/12/2026', '31/12/2026')),
          findsOneWidget,
        );
        expect(find.text(en.suggestedAmount('Bs 250,00')), findsOneWidget);
        expect(fieldText(tester, const Key('payment.amount')), '250');

        await tapVisible(tester, find.byKey(const Key('months.3')));
        expect(
          find.text(en.newPeriod('01/12/2026', '28/02/2027')),
          findsOneWidget,
        );
        // The suggestion follows the months until the admin edits it.
        expect(fieldText(tester, const Key('payment.amount')), '750');

        await tapVisible(tester, find.byKey(const Key('renew.confirm')));
        verify(
          () => h.members.renew(
            'm1',
            tier: Tier.plus,
            months: 3,
            amountCents: 75000,
            method: PaymentMethod.cash,
            applyTierNow: false,
          ),
        ).called(1);
        expect(find.byType(MemberDetailScreen), findsOneWidget);
        expect(find.text(en.renewDone), findsOneWidget);
      },
    );

    testWidgets('[R-09] a new tier is scheduled unless applied now', (
      tester,
    ) async {
      usePhoneScreen(tester);
      await h.open(tester, '/admin/members/m1/renew');
      await tapVisible(tester, find.byKey(const Key('tier.premium')));
      expect(find.text(en.tierAppliesScheduled('01/12/2026')), findsOneWidget);

      await tapVisible(tester, find.byKey(const Key('renew.applyTierNow')));
      expect(find.text(en.tierAppliesNow), findsOneWidget);
      await tapVisible(tester, find.byKey(const Key('renew.confirm')));
      verify(
        () => h.members.renew(
          'm1',
          tier: Tier.premium,
          months: 1,
          amountCents: 40000,
          method: PaymentMethod.cash,
          applyTierNow: true,
        ),
      ).called(1);
    });

    testWidgets('[R-10] a changed amount requires a note', (tester) async {
      usePhoneScreen(tester);
      await h.open(tester, '/admin/members/m1/renew');
      await tester.enterText(find.byKey(const Key('payment.amount')), '200');
      await tapVisible(tester, find.byKey(const Key('renew.confirm')));
      expect(find.text(en.validationNoteRequired), findsOneWidget);
      verifyNever(
        () => h.members.renew(
          any(),
          tier: any(named: 'tier'),
          months: any(named: 'months'),
          amountCents: any(named: 'amountCents'),
          method: any(named: 'method'),
          note: any(named: 'note'),
          applyTierNow: any(named: 'applyTierNow'),
        ),
      );
    });
  });

  group('tier change', () {
    setUp(() {
      when(
        () => h.members.changeTier(
          'm1',
          toTier: any(named: 'toTier'),
          amountCents: any(named: 'amountCents'),
          method: any(named: 'method'),
          note: any(named: 'note'),
        ),
      ).thenAnswer((_) async {});
    });

    testWidgets('[R-13] upgrade shows the prorated suggestion', (tester) async {
      usePhoneScreen(tester);
      when(() => h.members.detail('m1'))
          .thenAnswer((_) async => detail(tier: Tier.basic));
      when(() => h.members.previewTierChange('m1', Tier.plus)).thenAnswer(
        (_) async => const TierChangePreview(
          fromTier: Tier.basic,
          toTier: Tier.plus,
          isUpgrade: true,
          daysLeft: 12,
          suggestedAmount: '40.00',
          currency: 'BOB',
        ),
      );
      await h.open(tester, '/admin/members/m1/tier-change');
      // The current tier is not offered.
      expect(find.byKey(const Key('tier.basic')), findsNothing);

      await tapVisible(tester, find.byKey(const Key('tier.plus')));
      expect(
        find.text(en.tierChangeUpgradeInfo(12, 'Bs 40,00')),
        findsOneWidget,
      );
      expect(fieldText(tester, const Key('payment.amount')), '40');

      await tapVisible(tester, find.byKey(const Key('tierChange.confirm')));
      verify(
        () => h.members.changeTier(
          'm1',
          toTier: Tier.plus,
          amountCents: 4000,
          method: PaymentMethod.cash,
        ),
      ).called(1);
      expect(find.text(en.tierChangeDone), findsOneWidget);
    });

    testWidgets('[R-14] downgrade shows the warning and charges nothing', (
      tester,
    ) async {
      usePhoneScreen(tester);
      when(() => h.members.detail('m1'))
          .thenAnswer((_) async => detail(tier: Tier.premium));
      when(() => h.members.previewTierChange('m1', Tier.basic)).thenAnswer(
        (_) async => const TierChangePreview(
          fromTier: Tier.premium,
          toTier: Tier.basic,
          isUpgrade: false,
          daysLeft: 12,
          suggestedAmount: '0.00',
          currency: 'BOB',
          warning: 'Sin reembolso',
        ),
      );
      await h.open(tester, '/admin/members/m1/tier-change');
      await tapVisible(tester, find.byKey(const Key('tier.basic')));

      expect(find.text(en.tierChangeDowngradeWarning), findsOneWidget);
      // [R-16] Leaving PREMIUM removes the trainer.
      expect(find.text(en.tierChangePremiumWarning), findsOneWidget);
      expect(find.byKey(const Key('payment.amount')), findsNothing);

      await tapVisible(tester, find.byKey(const Key('tierChange.confirm')));
      verify(() => h.members.changeTier('m1', toTier: Tier.basic)).called(1);
    });

    testWidgets('an expired membership cannot change tier (renew instead)', (
      tester,
    ) async {
      usePhoneScreen(tester);
      when(() => h.members.detail('m1')).thenAnswer(
        (_) async => detail(
          status: MembershipStatus.expired,
          daysLeft: 0,
          endDate: '2026-11-10',
        ),
      );
      await h.open(tester, '/admin/members/m1');
      final button = tester.widget<OutlinedButton>(
        find.byKey(const Key('memberDetail.changeTier')),
      );
      expect(button.onPressed, isNull);
      expect(find.text(en.changeTierExpiredHint), findsOneWidget);
    });
  });

  group('void', () {
    testWidgets(
      '[R-12] void asks for a reason and refreshes the member dates',
      (tester) async {
        usePhoneScreen(tester);
        var voided = false;
        when(() => h.members.detail('m1')).thenAnswer(
          (_) async => voided
              ? detail(
                  endDate: '2026-11-15',
                  daysLeft: 0,
                  status: MembershipStatus.expired,
                  payments: [
                    payment(
                      voidedAt: '2026-11-19T10:00:00Z',
                      voidReason: 'Error',
                    ),
                  ],
                )
              : detail(),
        );
        when(() => h.members.voidPayment('p1', any())).thenAnswer((_) async {
          voided = true;
        });
        await h.open(tester, '/admin/members/m1');
        expect(find.text('30/11/2026'), findsOneWidget);

        await tapVisible(tester, find.text(en.memberTabPayments));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('payment.p1.void')));
        await tester.pumpAndSettle();
        expect(find.text(en.voidTitle), findsOneWidget);

        // The reason is required.
        await tester.tap(find.byKey(const Key('dialog.confirm')));
        await tester.pumpAndSettle();
        expect(find.text(en.validationRequired), findsOneWidget);
        verifyNever(() => h.members.voidPayment(any(), any()));

        await tester.enterText(
          find.byKey(const Key('dialog.reason')),
          'Monto equivocado',
        );
        await tester.tap(find.byKey(const Key('dialog.confirm')));
        await tester.pumpAndSettle();

        verify(() => h.members.voidPayment('p1', 'Monto equivocado')).called(1);
        expect(find.text(en.voidDone), findsOneWidget);
        expect(find.text(en.paymentVoided('Error')), findsOneWidget);
        expect(find.byKey(const Key('payment.p1.void')), findsNothing);

        await tapVisible(tester, find.text(en.memberTabMembership));
        await tester.pumpAndSettle();
        expect(find.text('15/11/2026'), findsOneWidget);
      },
    );
  });

  group('profile actions', () {
    setUp(() {
      when(() => h.members.detail('m1')).thenAnswer((_) async => detail());
    });

    Future<void> openProfileTab(WidgetTester tester) async {
      usePhoneScreen(tester);
      await h.open(tester, '/admin/members/m1');
      await tapVisible(tester, find.text(en.memberTabProfile));
      await tester.pumpAndSettle();
    }

    testWidgets('[R-44] reset password shows the new temporary password', (
      tester,
    ) async {
      when(() => h.members.resetPassword('m1'))
          .thenAnswer((_) async => 'Zx9kLm2p');
      await openProfileTab(tester);
      await tapVisible(
        tester,
        find.byKey(const Key('memberDetail.resetPassword')),
      );
      await tester.tap(find.byKey(const Key('dialog.confirm')));
      await tester.pumpAndSettle();
      expect(find.byType(TemporaryPasswordScreen), findsOneWidget);
      expect(find.text('Zx9kLm2p'), findsOneWidget);
    });

    testWidgets('[R-43] deactivate after confirming', (tester) async {
      when(() => h.members.setActive('m1', active: false))
          .thenAnswer((_) async => detail(isActive: false));
      await openProfileTab(tester);
      await tapVisible(
        tester,
        find.byKey(const Key('memberDetail.deactivate')),
      );
      expect(find.text(en.deactivateConfirm), findsOneWidget);
      await tester.tap(find.byKey(const Key('dialog.confirm')));
      await tester.pumpAndSettle();
      verify(() => h.members.setActive('m1', active: false)).called(1);
      expect(find.text(en.memberDeactivated), findsOneWidget);
    });
  });
}
