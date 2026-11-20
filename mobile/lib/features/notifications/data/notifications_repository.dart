import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../domain/app_notification.dart';

part 'notifications_repository.g.dart';

/// Devices and inbox (docs/PLAN.md 8.6). Every method throws [ApiException].
class NotificationsRepository {
  NotificationsRepository(this._dio);

  final Dio _dio;

  static const pageSize = 30;

  Future<InboxPage> inbox({int page = 1, int size = pageSize}) =>
      apiCall(() async {
        final res = await _dio.get<Map<String, dynamic>>(
          '/me/notifications',
          queryParameters: {'page': page, 'pageSize': size},
        );
        final json = res.data!;
        return InboxPage(
          items: [
            for (final e in json['items'] as List<dynamic>)
              AppNotification.fromJson(e as Map<String, dynamic>),
          ],
          page: json['page'] as int,
          hasMore: page * size < (json['total'] as int),
          unreadCount: json['unreadCount'] as int,
        );
      });

  Future<void> markRead(String id) =>
      apiCall(() => _dio.post<void>('/me/notifications/$id/read'));

  Future<void> markAllRead() =>
      apiCall(() => _dio.post<void>('/me/notifications/read-all'));

  /// `POST /me/devices` (upsert by token).
  Future<void> registerDevice(String fcmToken, String platform) => apiCall(
    () => _dio.post<void>(
      '/me/devices',
      data: {'fcmToken': fcmToken, 'platform': platform},
    ),
  );
}

@Riverpod(keepAlive: true)
NotificationsRepository notificationsRepository(Ref ref) =>
    NotificationsRepository(ref.watch(dioProvider));
