import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/models/paginated.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_exception.dart';
import '../domain/checkin_models.dart';

part 'checkins_repository.g.dart';

/// Admin check-in endpoints (docs/PLAN.md 8.4). Dates are gym-local
/// `yyyy-MM-dd`, both inclusive. Every method throws [ApiException].
class CheckinsRepository {
  CheckinsRepository(this._dio);

  final Dio _dio;

  Future<Paginated<CheckinItem>> list({
    String? from,
    String? to,
    String? memberId,
    int page = 1,
    int pageSize = 100,
  }) => apiCall(() async {
    final res = await _dio.get<Map<String, dynamic>>(
      '/admin/checkins',
      queryParameters: {
        'page': page,
        'pageSize': pageSize,
        'from': ?from,
        'to': ?to,
        'memberId': ?memberId,
      },
    );
    return Paginated.fromJson(res.data!, CheckinItem.fromJson);
  });

  Future<InsideNow> inside() => apiCall(() async {
    final res = await _dio.get<Map<String, dynamic>>('/admin/checkins/inside');
    return InsideNow.fromJson(res.data!);
  });

  /// Denied and invalid scans.
  Future<Paginated<CheckinAttempt>> attempts({
    String? from,
    String? to,
    String? memberId,
    int pageSize = 100,
  }) => apiCall(() async {
    final res = await _dio.get<Map<String, dynamic>>(
      '/admin/checkins/attempts',
      queryParameters: {
        'pageSize': pageSize,
        'from': ?from,
        'to': ?to,
        'memberId': ?memberId,
      },
    );
    return Paginated.fromJson(res.data!, CheckinAttempt.fromJson);
  });
}

@Riverpod(keepAlive: true)
CheckinsRepository checkinsRepository(Ref ref) =>
    CheckinsRepository(ref.watch(dioProvider));
