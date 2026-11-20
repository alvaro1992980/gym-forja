import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_app/core/auth/token_storage.dart';
import 'package:gym_app/core/models/enums.dart';
import 'package:gym_app/core/models/paginated.dart';
import 'package:gym_app/core/utils/clock.dart';
import 'package:gym_app/core/utils/device_actions.dart';
import 'package:gym_app/features/admin/members/data/members_repository.dart';
import 'package:gym_app/features/admin/members/domain/member_models.dart';
import 'package:gym_app/features/admin/settings/data/gym_admin_repository.dart';
import 'package:gym_app/features/auth/domain/current_user.dart';
import 'package:mocktail/mocktail.dart';

import 'fakes.dart';

class MockMembersRepository extends Mock implements MembersRepository {}

class MockGymAdminRepository extends Mock implements GymAdminRepository {}

class MockDeviceActions extends Mock implements DeviceActions {}

/// Tests run on 2026-11-19 10:00.
final testClock = Clock(() => DateTime(2026, 11, 19, 10));

const admin = PersonRef(id: 'a1', firstName: 'Ana', lastName: 'Rojas');

MemberListItem listItem({
  String id = 'm1',
  String firstName = 'Juan',
  String lastName = 'Pérez',
  Tier tier = Tier.plus,
  MemberStatus status = MemberStatus.active,
  int daysLeft = 12,
  String endDate = '2026-11-30',
  String? lastCheckinAt,
}) => MemberListItem(
  id: id,
  firstName: firstName,
  lastName: lastName,
  phone: '+59171234567',
  isActive: status != MemberStatus.inactive,
  tier: tier,
  endDate: endDate,
  daysLeft: daysLeft,
  status: status,
  lastCheckinAt: lastCheckinAt,
);

Paginated<MemberListItem> page(List<MemberListItem> items, {int total = -1}) =>
    Paginated(
      items: items,
      page: 1,
      pageSize: 20,
      total: total < 0 ? items.length : total,
    );

Payment payment({
  String id = 'p1',
  PaymentKind kind = PaymentKind.newMembership,
  Tier tier = Tier.plus,
  int months = 1,
  String amount = '250.00',
  String? voidedAt,
  String? voidReason,
}) => Payment(
  id: id,
  memberId: 'm1',
  kind: kind,
  tier: tier,
  months: months,
  periodStart: '2026-11-01',
  periodEnd: '2026-11-30',
  amount: amount,
  suggestedAmount: amount,
  currency: 'BOB',
  method: PaymentMethod.cash,
  recordedBy: admin,
  paidAt: '2026-11-01T14:00:00.000Z',
  voidedAt: voidedAt,
  voidReason: voidReason,
);

MemberDetail detail({
  Tier tier = Tier.plus,
  MembershipStatus status = MembershipStatus.active,
  int daysLeft = 12,
  String endDate = '2026-11-30',
  bool isActive = true,
  List<Payment>? payments,
}) => MemberDetail(
  id: 'm1',
  firstName: 'Juan',
  lastName: 'Pérez',
  phone: '+59171234567',
  isActive: isActive,
  mustChangePassword: true,
  createdAt: '2026-11-01T14:00:00.000Z',
  membership: MembershipSummary(
    tier: tier,
    startDate: '2026-11-01',
    endDate: endDate,
    daysLeft: daysLeft,
    status: status,
  ),
  payments: payments ?? [payment()],
);

const prices = [
  TierPrice(tier: Tier.basic, monthlyCents: 15000, currency: 'BOB'),
  TierPrice(tier: Tier.plus, monthlyCents: 25000, currency: 'BOB'),
  TierPrice(tier: Tier.premium, monthlyCents: 40000, currency: 'BOB'),
];

/// Registers mocktail fallbacks for the admin repositories.
void registerAdminFallbacks() {
  registerFallbackValue(const MemberFilters());
  registerFallbackValue(Tier.basic);
  registerFallbackValue(PaymentMethod.cash);
  registerFallbackValue(StaffRole.trainer);
  registerFallbackValue(
    const NewMemberInput(
      firstName: '',
      lastName: '',
      phone: '',
      tier: Tier.basic,
      months: 1,
      amountCents: 0,
      method: PaymentMethod.cash,
    ),
  );
}

/// Fakes behind an admin session.
class AdminHarness {
  AdminHarness() {
    when(auth.me).thenAnswer((_) async => fakeUser());
    when(admin.prices).thenAnswer((_) async => prices);
    when(() => device.copy(any())).thenAnswer((_) async {});
    when(() => device.share(any())).thenAnswer((_) async {});
    when(device.alert).thenAnswer((_) async {});
  }

  final auth = MockAuthRepository();
  final members = MockMembersRepository();
  final admin = MockGymAdminRepository();
  final device = MockDeviceActions();
  final checkins = emptyCheckins();
  final realtime = FakeRealtime();
  final preferences = FakePreferences();

  /// Starts the app signed in as an admin and opens [location].
  Future<void> open(WidgetTester tester, String location) async {
    await pumpGymApp(
      tester,
      repo: auth,
      storage: MemoryTokenStorage(storedTokens),
      checkins: checkins,
      realtime: realtime,
      preferences: preferences,
      overrides: <Override>[
        membersRepositoryProvider.overrideWithValue(members),
        gymAdminRepositoryProvider.overrideWithValue(admin),
        deviceActionsProvider.overrideWithValue(device),
        clockProvider.overrideWithValue(testClock),
      ],
    );
    await goTo(tester, location);
  }
}
