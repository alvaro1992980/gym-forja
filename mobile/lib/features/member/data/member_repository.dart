import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/models/paginated.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../auth/domain/current_user.dart';
import '../checkin/domain/checkin_result.dart';

part 'member_repository.g.dart';

/// Member endpoints: check-in and own data (docs/PLAN.md 8.3/8.4). Every
/// method throws [ApiException].
class MemberRepository {
  MemberRepository(this._dio);

  final Dio _dio;

  /// `POST /checkins` with the scanned kiosk QR.
  Future<CheckinResponse> checkIn(String qrToken) => apiCall(() async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/checkins',
      data: {'qrToken': qrToken},
    );
    return CheckinResponse.fromJson(res.data!);
  });

  Future<MembershipSummary> membership() => apiCall(() async {
    final res = await _dio.get<Map<String, dynamic>>('/me/membership');
    return MembershipSummary.fromJson(res.data!);
  });

  /// Instants (ISO-8601) of the member's check-ins between two gym-local
  /// dates, both inclusive.
  Future<List<String>> checkinTimes({
    required String from,
    required String to,
  }) => apiCall(() async {
    final res = await _dio.get<Map<String, dynamic>>(
      '/me/checkins',
      queryParameters: {'from': from, 'to': to, 'pageSize': 100},
    );
    return Paginated.fromJson(res.data!, (e) => e['createdAt'] as String).items;
  });
}

@Riverpod(keepAlive: true)
MemberRepository memberRepository(Ref ref) =>
    MemberRepository(ref.watch(dioProvider));
