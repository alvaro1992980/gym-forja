import 'package:flutter_test/flutter_test.dart';
import 'package:gym_app/core/models/enums.dart';
import 'package:gym_app/core/models/paginated.dart';
import 'package:gym_app/features/admin/members/domain/member_models.dart';
import 'package:gym_app/features/admin/members/presentation/member_detail_screen.dart';
import 'package:gym_app/features/admin/members/presentation/new_member_screen.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/admin_fixtures.dart';
import '../../helpers/fakes.dart';

Future<void> tapChip(WidgetTester tester, String name) async {
  final chip = find.byKey(Key('members.filter.$name'));
  await tester.ensureVisible(chip);
  await tester.tap(chip);
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(registerAdminFallbacks);

  late AdminHarness h;
  setUp(() => h = AdminHarness());

  void stubList(Paginated<MemberListItem> Function(MemberFilters f) answer) {
    when(() => h.members.list(any(), page: any(named: 'page'))).thenAnswer(
      (inv) async => answer(inv.positionalArguments[0] as MemberFilters),
    );
  }

  testWidgets('rows show name, tier, days left or how long ago it expired', (
    tester,
  ) async {
    stubList(
      (_) => page([
        listItem(lastCheckinAt: '2026-11-18T22:05:00.000Z'),
        listItem(
          id: 'm2',
          firstName: 'Luis',
          status: MemberStatus.expired,
          daysLeft: 0,
          endDate: '2026-11-16',
        ),
        listItem(id: 'm3', firstName: 'Eva', status: MemberStatus.inactive),
      ]),
    );
    await h.open(tester, '/admin/members');

    expect(find.text('Juan Pérez'), findsOneWidget);
    expect(find.text(en.memberDaysLeftShort(12)), findsOneWidget);
    // Today is 2026-11-19 and it ended on the 16th.
    expect(find.text(en.memberExpiredAgo(3)), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(const Key('member.m3')),
        matching: find.text(en.memberInactive),
      ),
      findsOneWidget,
    );
    expect(find.text(en.memberNoCheckins), findsNWidgets(2));
    expect(find.textContaining('Last check-in'), findsOneWidget);
    expect(find.text('PLUS'), findsNWidgets(3));
  });

  testWidgets('filter chips and search are sent to the backend', (
    tester,
  ) async {
    stubList((_) => page([listItem()]));
    await h.open(tester, '/admin/members');

    await tapChip(tester, 'expiring');
    await tapChip(tester, 'premium');
    await tester.enterText(find.byKey(const Key('members.search')), 'juan');
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();

    final calls = verify(
      () => h.members.list(captureAny(), page: any(named: 'page')),
    ).captured.cast<MemberFilters>();
    expect(
      calls.last,
      const MemberFilters(
        query: 'juan',
        status: MemberStatusFilter.expiring,
        tier: Tier.premium,
      ),
    );

    // Tapping a selected chip clears it.
    await tapChip(tester, 'expiring');
    final last =
        verify(() => h.members.list(captureAny(), page: any(named: 'page')))
                .captured
                .last
            as MemberFilters;
    expect(last.status, isNull);
  });

  for (final status in MemberStatusFilter.values) {
    testWidgets('the ${status.name} chip filters by status', (tester) async {
      stubList((_) => page([listItem()]));
      await h.open(tester, '/admin/members');
      await tapChip(tester, status.name);
      final last =
          verify(() => h.members.list(captureAny(), page: any(named: 'page')))
                  .captured
                  .last
              as MemberFilters;
      expect(last.status, status);
    });
  }

  testWidgets('empty and error states', (tester) async {
    var fail = true;
    stubList((_) {
      if (fail) throw apiError(500, 'INTERNAL_ERROR');
      return page([]);
    });
    await h.open(tester, '/admin/members');
    expect(find.text(en.errorServer), findsOneWidget);

    fail = false;
    await tester.tap(find.text(en.commonRetry));
    await tester.pumpAndSettle();
    expect(find.text(en.membersEmpty), findsOneWidget);
  });

  testWidgets('tapping a row opens the detail; the FAB opens the stepper', (
    tester,
  ) async {
    stubList((_) => page([listItem()]));
    when(() => h.members.detail('m1')).thenAnswer((_) async => detail());
    await h.open(tester, '/admin/members');

    await tester.tap(find.text('Juan Pérez'));
    await tester.pumpAndSettle();
    expect(find.byType(MemberDetailScreen), findsOneWidget);

    await goTo(tester, '/admin/members');
    await tester.tap(find.byKey(const Key('members.new')));
    await tester.pumpAndSettle();
    expect(find.byType(NewMemberScreen), findsOneWidget);
  });
}
