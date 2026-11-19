import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_app/core/models/enums.dart';
import 'package:gym_app/core/network/api_exception.dart';
import 'package:gym_app/features/admin/members/data/members_repository.dart';
import 'package:gym_app/features/admin/members/domain/member_models.dart';

import '../../core/network/auth_interceptor_test.dart'
    show FakeAdapter, jsonBody;

const detailJson = {
  'id': 'm1',
  'firstName': 'Juan',
  'lastName': 'Pérez',
  'phone': '+59171234567',
  'email': null,
  'birthDate': null,
  'gender': null,
  'emergencyContact': null,
  'medicalNotes': 'Asma',
  'isActive': true,
  'mustChangePassword': true,
  'createdAt': '2026-11-19T14:00:00.000Z',
  'membership': {
    'tier': 'PLUS',
    'startDate': '2026-11-19',
    'endDate': '2026-12-18',
    'daysLeft': 30,
    'status': 'active',
    'nextTier': null,
    'nextTierStartDate': null,
  },
  'trainer': null,
  'recentCheckins': <Object>[],
  'payments': [
    {
      'id': 'p1',
      'memberId': 'm1',
      'kind': 'NEW',
      'tier': 'PLUS',
      'months': 1,
      'periodStart': '2026-11-19',
      'periodEnd': '2026-12-18',
      'amount': '250.00',
      'suggestedAmount': '250.00',
      'currency': 'BOB',
      'method': 'CASH',
      'note': null,
      'recordedBy': {'id': 'a1', 'firstName': 'Ana', 'lastName': 'Rojas'},
      'paidAt': '2026-11-19T14:00:00.000Z',
      'voidedAt': null,
      'voidedById': null,
      'voidReason': null,
    },
  ],
  'assignment': null,
};

void main() {
  late FakeAdapter adapter;
  late MembersRepository repo;

  void serve(ResponseBody Function(RequestOptions o) handler) {
    adapter = FakeAdapter(handler);
    repo = MembersRepository(
      Dio(BaseOptions(baseUrl: 'http://api.test/api/v1'))
        ..httpClientAdapter = adapter,
    );
  }

  test('list sends the filters as query parameters', () async {
    serve(
      (_) => jsonBody(200, {
        'items': <Object>[],
        'page': 1,
        'pageSize': 20,
        'total': 0,
      }),
    );
    await repo.list(
      const MemberFilters(
        query: ' juan ',
        status: MemberStatusFilter.expiring,
        tier: Tier.premium,
      ),
      page: 2,
    );
    expect(adapter.requests.single.uri.queryParameters, {
      'page': '2',
      'pageSize': '20',
      'q': 'juan',
      'status': 'expiring',
      'tier': 'PREMIUM',
      'sort': 'endDate',
    });
  });

  test('create posts the member and returns the temporary password', () async {
    serve(
      (_) => jsonBody(201, {...detailJson, 'temporaryPassword': 'Ab3dEf7h'}),
    );
    final (member, password) = await repo.create(
      const NewMemberInput(
        firstName: 'Juan',
        lastName: 'Pérez',
        phone: '+59171234567',
        tier: Tier.plus,
        months: 1,
        amountCents: 25050,
        method: PaymentMethod.qr,
        note: 'Redondeo',
      ),
    );
    expect(password, 'Ab3dEf7h');
    expect(member.membership.tier, Tier.plus);
    expect(member.payments.single.kind, PaymentKind.newMembership);
    expect(member.medicalNotes, 'Asma');
    final body = adapter.requests.single.data as Map<String, dynamic>;
    expect(body, {
      'firstName': 'Juan',
      'lastName': 'Pérez',
      'phone': '+59171234567',
      'tier': 'PLUS',
      'months': 1,
      'amount': 250.5,
      'method': 'QR',
      'note': 'Redondeo',
    });
  });

  test('tier change sends the amount only for upgrades', () async {
    serve((_) => jsonBody(200, {'membership': <String, Object>{}}));
    await repo.changeTier('m1', toTier: Tier.basic);
    expect(adapter.requests.single.data, {'toTier': 'BASIC'});
  });

  test('errors become ApiException with the backend code', () async {
    serve(
      (_) => jsonBody(409, {
        'statusCode': 409,
        'code': 'PAYMENT_ALREADY_VOIDED',
        'message': 'x',
      }),
    );
    await expectLater(
      repo.voidPayment('p1', 'x'),
      throwsA(
        isA<ApiException>().having(
          (e) => e.code,
          'code',
          'PAYMENT_ALREADY_VOIDED',
        ),
      ),
    );
  });
}
