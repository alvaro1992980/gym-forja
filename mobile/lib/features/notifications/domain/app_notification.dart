import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_notification.freezed.dart';
part 'app_notification.g.dart';

/// Inbox item (`GET /me/notifications`, docs/PLAN.md 8.6).
@freezed
abstract class AppNotification with _$AppNotification {
  const factory AppNotification({
    required String id,
    required String type,
    required String title,
    required String body,

    /// Routing data: `screen` and/or `memberId` (section 9.8).
    @Default(<String, dynamic>{}) Map<String, dynamic> data,
    String? readAt,
    required String createdAt,
  }) = _AppNotification;

  const AppNotification._();

  factory AppNotification.fromJson(Map<String, dynamic> json) =>
      _$AppNotificationFromJson(json);

  bool get isRead => readAt != null;
}

/// One page of the inbox plus the unread count.
class InboxPage {
  const InboxPage({
    required this.items,
    required this.page,
    required this.hasMore,
    required this.unreadCount,
  });

  final List<AppNotification> items;
  final int page;
  final bool hasMore;
  final int unreadCount;
}
