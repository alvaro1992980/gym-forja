import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/auth/session_controller.dart';
import '../data/notifications_repository.dart';
import '../domain/app_notification.dart';

part 'inbox_providers.g.dart';

/// Unread notifications of the signed-in user (the bell badge).
@Riverpod(keepAlive: true)
Future<int> unreadCount(Ref ref) async {
  final session = ref.watch(sessionControllerProvider);
  if (session is! SessionSignedIn || session.user.mustChangePassword) return 0;
  final page = await ref.read(notificationsRepositoryProvider).inbox(size: 1);
  return page.unreadCount;
}

class InboxState {
  const InboxState({
    required this.items,
    required this.page,
    required this.hasMore,
    this.loadingMore = false,
  });

  final List<AppNotification> items;
  final int page;
  final bool hasMore;
  final bool loadingMore;

  InboxState copyWith({List<AppNotification>? items, bool? loadingMore}) =>
      InboxState(
        items: items ?? this.items,
        page: page,
        hasMore: hasMore,
        loadingMore: loadingMore ?? this.loadingMore,
      );
}

/// Pages of `GET /me/notifications`, newest first.
@riverpod
class Inbox extends _$Inbox {
  NotificationsRepository get _repo =>
      ref.read(notificationsRepositoryProvider);

  @override
  Future<InboxState> build() async {
    final page = await _repo.inbox();
    return InboxState(items: page.items, page: 1, hasMore: page.hasMore);
  }

  Future<void> loadMore() async {
    final current = state.value;
    if (current == null || !current.hasMore || current.loadingMore) return;
    state = AsyncData(current.copyWith(loadingMore: true));
    try {
      final next = await _repo.inbox(page: current.page + 1);
      state = AsyncData(
        InboxState(
          items: [...current.items, ...next.items],
          page: current.page + 1,
          hasMore: next.hasMore,
        ),
      );
    } on Object {
      state = AsyncData(current.copyWith(loadingMore: false));
    }
  }

  /// Marks one as read on screen at once, then on the server.
  Future<void> markRead(String id) async {
    _setRead((n) => n.id == id);
    await _repo.markRead(id);
    ref.invalidate(unreadCountProvider);
  }

  Future<void> markAllRead() async {
    _setRead((_) => true);
    await _repo.markAllRead();
    ref.invalidate(unreadCountProvider);
  }

  void _setRead(bool Function(AppNotification) which) {
    final current = state.value;
    if (current == null) return;
    final now = DateTime.now().toUtc().toIso8601String();
    state = AsyncData(
      current.copyWith(
        items: [
          for (final n in current.items)
            which(n) && !n.isRead ? n.copyWith(readAt: now) : n,
        ],
      ),
    );
  }
}
