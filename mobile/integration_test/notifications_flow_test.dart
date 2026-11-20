// End-to-end QA of D8 (notifications inbox) against a real backend started
// with PUSH_ENABLED=false (README "Integration test"). Pushes themselves need
// the owner's Firebase project (docs/FIREBASE_SETUP.md); this checks that the
// app runs without it and that every notification reaches the inbox and opens
// the right screen.
//
//   flutter test integration_test/notifications_flow_test.dart -d <device> \
//     --dart-define-from-file=config/dev.json \
//     --dart-define=QA_ADMIN_PHONE=70000000 \
//     --dart-define=QA_ADMIN_PASSWORD=<seed password>
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_app/app.dart';
import 'package:gym_app/core/config/app_config.dart';
import 'package:gym_app/features/admin/members/presentation/member_detail_screen.dart';
import 'package:gym_app/features/member/home/presentation/member_home_screen.dart';
import 'package:gym_app/features/notifications/presentation/inbox_screen.dart';
import 'package:gym_app/l10n/generated/app_localizations.dart';
import 'package:gym_app/main.dart' show noRetry;
import 'package:integration_test/integration_test.dart';
import 'package:material_ui/material_ui.dart';

import 'qa_support.dart';

Finder bellWith(String count) => find.descendant(
  of: find.byKey(const Key('notifications.bell')),
  matching: find.text(count),
);

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('D8: inbox, bell and opening notifications', (tester) async {
    t = tester;
    final api = Api(AppConfig.fromEnvironment().apiUrl);

    final admin = await api.adminToken();
    final kioskPhone = await api.createKiosk(admin);
    final anaPhone = await api.createMember(admin, 'Ana');
    final kiosk = await api.login(kioskPhone, userPassword);
    final ana = await api.login(anaPhone, userPassword);

    // Check-in (CHECKIN_ADMIN + CHECKIN_MEMBER), then a renewal (PAYMENT_RECORDED).
    await api.checkIn(ana, await api.qrToken(kiosk));
    await api.renew(admin, api.memberIds[anaPhone]!);
    // The daily job answers on a non-production server (nothing due today).
    final job = await api.runJob(admin, 'daily-expiry');
    expect(job['date'], isA<String>());

    await tester.pumpWidget(
      const ProviderScope(retry: noRetry, child: GymApp()),
    );
    l10n = lookupAppLocalizations(
      Localizations.localeOf(t.element(find.byType(Navigator).first)),
    );

    // --- Member: badge 2 → inbox newest first → tap opens home ---
    await uiLogin(anaPhone, userPassword);
    await waitFor(bellWith('2'));
    await tapKey('notifications.bell');
    await waitFor(find.byType(InboxScreen));
    await waitFor(find.text('Pago registrado'));
    expect(find.text('¡Bienvenido, Ana!'), findsOneWidget);
    expect(
      t.getTopLeft(find.text('Pago registrado')).dy,
      lessThan(t.getTopLeft(find.text('¡Bienvenido, Ana!')).dy),
    );
    await tapOn(find.text('Pago registrado'));
    await waitFor(find.byType(MemberHomeScreen));
    await waitFor(bellWith('1'));

    await tapKey('notifications.bell');
    await tapKey('inbox.readAll');
    await wait(const Duration(seconds: 1));
    await t.pageBack();
    await waitFor(find.byType(MemberHomeScreen));
    await wait(const Duration(seconds: 1));
    expect(bellWith('1'), findsNothing);

    // --- Admin: "Ingreso" opens the member detail ---
    await tapOn(find.byTooltip(l10n.logout));
    await uiLogin(adminPhone, adminPassword);
    await tapKey('notifications.bell');
    await waitFor(find.textContaining('Ana QA'));
    await tapOn(find.textContaining('Ana QA').first);
    await waitFor(find.byType(MemberDetailScreen));
    expect(find.text('Ana QA'), findsWidgets);
  });
}
