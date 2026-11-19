// End-to-end QA of D5 against a real backend (see README "Integration test").
//
// Needs a freshly seeded backend whose admin still must change the password:
//   flutter test integration_test -d <device> \
//     --dart-define-from-file=config/dev.json \
//     --dart-define=QA_ADMIN_PHONE=70000000 \
//     --dart-define=QA_ADMIN_PASSWORD=<seed password>
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_app/app.dart';
import 'package:gym_app/core/router/app_router.dart';
import 'package:gym_app/core/utils/formatters.dart';
import 'package:gym_app/features/admin/members/presentation/member_detail_screen.dart';
import 'package:gym_app/l10n/generated/app_localizations.dart';
import 'package:gym_app/main.dart' as app;
import 'package:integration_test/integration_test.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

const adminPhone = String.fromEnvironment('QA_ADMIN_PHONE');
const adminPassword = String.fromEnvironment('QA_ADMIN_PASSWORD');
const newAdminPassword = 'QaAdmin2026!';

final _rand = Random();
String uniquePhone() => '6${_rand.nextInt(9000000) + 1000000}';

late WidgetTester t;
late AppLocalizations l10n;

/// Pumps until [finder] shows up (real network calls are in flight).
Future<void> waitFor(Finder finder, {int seconds = 20}) async {
  final end = DateTime.now().add(Duration(seconds: seconds));
  while (DateTime.now().isBefore(end)) {
    await t.pump(const Duration(milliseconds: 200));
    if (finder.evaluate().isNotEmpty) return;
  }
  throw TestFailure('Timed out waiting for $finder');
}

Future<void> tapKey(String key) => tapOn(find.byKey(Key(key)));

Future<void> tapOn(Finder finder) async {
  await waitFor(finder);
  // A confirmation snackbar may cover a floating button for a few seconds.
  final snack = find.byType(SnackBar);
  if (snack.evaluate().isNotEmpty) {
    ScaffoldMessenger.of(t.element(snack.first)).removeCurrentSnackBar();
    await t.pumpAndSettle();
  }
  await t.ensureVisible(finder.first);
  await t.pumpAndSettle();
  await t.tap(finder.first);
  await t.pump(const Duration(milliseconds: 300));
}

Future<void> type(String key, String text) async {
  final f = find.byKey(Key(key));
  await waitFor(f);
  await t.ensureVisible(f);
  await t.enterText(f, text);
  await t.pump();
}

String textOf(String key) => t.widget<Text>(find.byKey(Key(key))).data!;

final _display = DateFormat('dd/MM/yyyy');
DateTime displayDate(String s) => _display.parseStrict(s);

Future<void> go(String location) async {
  ProviderScope.containerOf(t.element(find.byType(GymApp)))
      .read(routerProvider)
      .go(location);
  await t.pumpAndSettle();
}

/// New member through the stepper; returns the temporary password.
Future<String> createMember(String firstName, String lastName) async {
  await go('/admin/members');
  await tapKey('members.new');
  await type('member.firstName', firstName);
  await type('member.lastName', lastName);
  await type('member.phone', uniquePhone());
  await tapKey('newMember.next');
  await tapKey('newMember.next'); // BASIC, 1 month, today
  await waitFor(find.byKey(const Key('preview.period')));
  await tapKey('newMember.next');
  await tapKey('newMember.confirm');
  await waitFor(find.byKey(const Key('tempPassword.value')));
  final password = t
      .widget<SelectableText>(find.byKey(const Key('tempPassword.value')))
      .data!;
  await tapKey('tempPassword.done');
  await waitFor(find.byKey(const Key('memberDetail.endDate')));
  return password;
}

Future<void> openTab(String label) async {
  await tapOn(find.text(label));
  await t.pumpAndSettle();
}

/// Renews 1 month at the suggested amount; returns the previewed start.
Future<DateTime> renew() async {
  await tapKey('memberDetail.renew');
  await waitFor(find.byKey(const Key('preview.period')));
  final period = textOf('preview.period');
  final start = displayDate(
    RegExp(r'\d{2}/\d{2}/\d{4}').firstMatch(period)![0]!,
  );
  await tapKey('renew.confirm');
  await waitFor(find.text(l10n.renewDone));
  await waitFor(find.byKey(const Key('memberDetail.endDate')));
  return start;
}

Future<void> voidPaymentOfKind(String kindLabel) async {
  await openTab(l10n.memberTabPayments);
  final tile = find.ancestor(
    of: find.textContaining(kindLabel),
    matching: find.byType(PaymentTile),
  );
  await tapOn(find.descendant(of: tile, matching: find.byIcon(Icons.block)));
  await type('dialog.reason', 'QA: pago de prueba');
  await tapKey('dialog.confirm');
  await waitFor(find.text(l10n.voidDone));
  await t.pumpAndSettle();
  await openTab(l10n.memberTabMembership);
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('D5 admin flow against the real backend', (tester) async {
    t = tester;
    expect(adminPassword, isNotEmpty, reason: 'Pass QA_ADMIN_PASSWORD');
    app.main();
    await waitFor(find.byKey(const Key('login.phone')));
    l10n = AppLocalizations.of(tester.element(find.byType(Scaffold).first));

    // Seeded admin: login → forced password change.
    await type('login.phone', adminPhone);
    await type('login.password', adminPassword);
    await tapKey('login.submit');
    await type('changePassword.current', adminPassword);
    await type('changePassword.new', newAdminPassword);
    await type('changePassword.confirm', newAdminPassword);
    await tapKey('changePassword.submit');
    await waitFor(find.byKey(const Key('nav.members')));

    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final run = _rand.nextInt(90000) + 10000;

    // --- Member A: create, renew early, upgrade, downgrade, void.
    final lastA = 'Activo$run';
    final password = await createMember('QA', lastA);
    expect(password, hasLength(8));
    final endA = displayDate(textOf('memberDetail.endDate'));

    // [R-07] Renewing while active starts the day after endDate.
    final earlyStart = await renew();
    expect(earlyStart, endA.add(const Duration(days: 1)));
    final endA2 = displayDate(textOf('memberDetail.endDate'));
    expect(endA2.isAfter(endA), isTrue);

    // [R-13] Upgrade shows the prorated suggestion.
    await tapKey('memberDetail.changeTier');
    await tapKey('tier.plus');
    await waitFor(find.byKey(const Key('tierChange.upgradeInfo')));
    await tapKey('tierChange.confirm');
    await waitFor(find.text(l10n.tierChangeDone));
    await waitFor(find.text('PLUS'));

    // [R-14] Downgrade shows the warning.
    await tapKey('memberDetail.changeTier');
    await tapKey('tier.basic');
    await waitFor(find.byKey(const Key('tierChange.downgradeWarning')));
    await tapKey('tierChange.confirm');
    await waitFor(find.text(l10n.tierChangeDone));

    // [R-12] Voiding the renewal restores the previous endDate.
    await voidPaymentOfKind(l10n.paymentKindRenewal);
    await waitFor(find.text(formatDate(endA)));
    expect(textOf('memberDetail.endDate'), formatDate(endA));

    // --- Member B: expired → renew late, reset password, deactivate.
    final lastB = 'Vencido$run';
    await createMember('QA', lastB);
    // Voiding the only payment leaves it expired (endDate = start − 1).
    await voidPaymentOfKind(l10n.paymentKindNew);
    await waitFor(find.text(l10n.changeTierExpiredHint));

    // [R-08] Renewing while expired starts today.
    final lateStart = await renew();
    expect(lateStart, todayDate);

    // [R-44] Reset password.
    await openTab(l10n.memberTabProfile);
    await tapKey('memberDetail.resetPassword');
    await tapKey('dialog.confirm');
    await waitFor(find.byKey(const Key('tempPassword.value')));
    await tapKey('tempPassword.done');

    // [R-43] Deactivate (back on the Profile tab).
    await tapKey('memberDetail.deactivate');
    await tapKey('dialog.confirm');
    await waitFor(find.text(l10n.memberDeactivated));
    await waitFor(find.byKey(const Key('memberDetail.reactivate')));

    // --- List: search and filters against the backend.
    await go('/admin/members');
    await type('members.search', lastA);
    await waitFor(find.text('QA $lastA'));
    expect(find.text('QA $lastB'), findsNothing);

    await type('members.search', 'QA');
    await tapKey('members.filter.inactive');
    await waitFor(find.text('QA $lastB'));
    expect(find.text('QA $lastA'), findsNothing);
    await tapKey('members.filter.inactive'); // clear
    await tapKey('members.filter.active');
    await waitFor(find.text('QA $lastA'));
    expect(find.text('QA $lastB'), findsNothing);
    await tapKey('members.filter.active'); // clear
    await tapKey('members.filter.plus');
    await waitFor(find.text(l10n.membersEmpty));
    await tapKey('members.filter.plus'); // clear
    await tapKey('members.filter.basic');
    await waitFor(find.text('QA $lastA'));

    // --- Staff: a TRAINER and a KIOSK account.
    for (final role in [l10n.roleTrainer, l10n.roleKiosk]) {
      await go('/admin/more/staff');
      await tapKey('staff.new');
      await tapOn(find.text(role));
      await type('staff.firstName', role);
      await type('staff.lastName', 'QA$run');
      await type('staff.phone', uniquePhone());
      await tapKey('staff.create');
      await waitFor(find.byKey(const Key('tempPassword.value')));
      await tapKey('tempPassword.done');
      await waitFor(find.text('$role QA$run'));
    }
  });
}
