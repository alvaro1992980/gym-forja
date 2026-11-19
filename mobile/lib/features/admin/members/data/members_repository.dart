import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/models/enums.dart';
import '../../../../core/models/money.dart';
import '../../../../core/models/paginated.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_exception.dart';
import '../domain/member_models.dart';

part 'members_repository.g.dart';

/// Admin member, payment and tier endpoints (docs/PLAN.md 8.2/8.3). Every
/// method throws [ApiException] on failure.
class MembersRepository {
  MembersRepository(this._dio);

  final Dio _dio;

  static const pageSize = 20;

  Future<Paginated<MemberListItem>> list(
    MemberFilters filters, {
    int page = 1,
  }) => apiCall(() async {
    final res = await _dio.get<Map<String, dynamic>>(
      '/admin/members',
      queryParameters: {
        'page': page,
        'pageSize': pageSize,
        if (filters.query.trim().isNotEmpty) 'q': filters.query.trim(),
        if (filters.status != null) 'status': filters.status!.name,
        if (filters.tier != null) 'tier': filters.tier!.api,
        // Expiring soon first is the most useful order for reception.
        'sort': filters.status == MemberStatusFilter.expiring
            ? 'endDate'
            : 'name',
      },
    );
    return Paginated.fromJson(res.data!, MemberListItem.fromJson);
  });

  Future<MemberDetail> detail(String id) => apiCall(() async {
    final res = await _dio.get<Map<String, dynamic>>('/admin/members/$id');
    return MemberDetail.fromJson(res.data!);
  });

  /// Suggested period and amount for a new member.
  Future<PaymentPreview> previewNew({
    required Tier tier,
    required int months,
    String? startDate,
  }) => apiCall(() async {
    final res = await _dio.get<Map<String, dynamic>>(
      '/admin/members/preview',
      queryParameters: {
        'tier': tier.api,
        'months': months,
        'startDate': ?startDate,
      },
    );
    return PaymentPreview.fromJson(res.data!);
  });

  /// Returns the member and the temporary password (shown once [R-41]).
  Future<(MemberDetail, String)> create(NewMemberInput input) => apiCall(
    () async {
      final res = await _dio.post<Map<String, dynamic>>(
        '/admin/members',
        data: {
          'firstName': input.firstName,
          'lastName': input.lastName,
          'phone': input.phone,
          'email': ?input.email,
          'birthDate': ?input.birthDate,
          'gender': ?input.gender,
          'emergencyContact': ?input.emergencyContact,
          'medicalNotes': ?input.medicalNotes,
          'tier': input.tier.api,
          'months': input.months,
          'startDate': ?input.startDate,
          'amount': Money.toApi(input.amountCents),
          'method': input.method.api,
          'note': ?input.note,
        },
      );
      final json = res.data!;
      return (MemberDetail.fromJson(json), json['temporaryPassword'] as String);
    },
  );

  Future<MemberDetail> update(String id, MemberProfileInput input) =>
      apiCall(() async {
        final res = await _dio.patch<Map<String, dynamic>>(
          '/admin/members/$id',
          data: input.toJson(),
        );
        return MemberDetail.fromJson(res.data!);
      });

  Future<MemberDetail> setActive(String id, {required bool active}) =>
      apiCall(() async {
        final res = await _dio.post<Map<String, dynamic>>(
          '/admin/members/$id/${active ? 'reactivate' : 'deactivate'}',
        );
        return MemberDetail.fromJson(res.data!);
      });

  /// [R-44] New temporary password; the member's sessions are revoked.
  Future<String> resetPassword(String id) => apiCall(() async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/admin/members/$id/reset-password',
    );
    return res.data!['temporaryPassword'] as String;
  });

  Future<PaymentPreview> previewRenewal(
    String id, {
    required Tier tier,
    required int months,
  }) => apiCall(() async {
    final res = await _dio.get<Map<String, dynamic>>(
      '/admin/members/$id/payments/preview',
      queryParameters: {'tier': tier.api, 'months': months},
    );
    return PaymentPreview.fromJson(res.data!);
  });

  Future<void> renew(
    String id, {
    required Tier tier,
    required int months,
    required int amountCents,
    required PaymentMethod method,
    String? note,
    bool applyTierNow = false,
  }) => apiCall(
    () => _dio.post<void>(
      '/admin/members/$id/payments',
      data: {
        'tier': tier.api,
        'months': months,
        'amount': Money.toApi(amountCents),
        'method': method.api,
        'note': ?note,
        'applyTierNow': applyTierNow,
      },
    ),
  );

  Future<TierChangePreview> previewTierChange(String id, Tier toTier) =>
      apiCall(() async {
        final res = await _dio.post<Map<String, dynamic>>(
          '/admin/members/$id/tier-change/preview',
          data: {'toTier': toTier.api},
        );
        return TierChangePreview.fromJson(res.data!);
      });

  Future<void> changeTier(
    String id, {
    required Tier toTier,
    int? amountCents,
    PaymentMethod? method,
    String? note,
  }) => apiCall(
    () => _dio.post<void>(
      '/admin/members/$id/tier-change',
      data: {
        'toTier': toTier.api,
        if (amountCents != null) 'amount': Money.toApi(amountCents),
        'method': ?method?.api,
        'note': ?note,
      },
    ),
  );

  /// [R-12] Voids a payment; the membership dates are recalculated.
  Future<void> voidPayment(String paymentId, String reason) => apiCall(
    () => _dio.post<void>(
      '/admin/payments/$paymentId/void',
      data: {'reason': reason},
    ),
  );
}

@Riverpod(keepAlive: true)
MembersRepository membersRepository(Ref ref) =>
    MembersRepository(ref.watch(dioProvider));
