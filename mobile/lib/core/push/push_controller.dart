import 'dart:async';

import 'package:flutter/scheduler.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/admin/members/presentation/members_providers.dart';
import '../../features/notifications/data/notifications_repository.dart';
import '../../features/notifications/presentation/inbox_providers.dart';
import '../auth/session_controller.dart';
import '../models/enums.dart';
import '../network/api_exception.dart';
import '../router/app_router.dart';
import '../utils/preferences.dart';
import 'notification_routing.dart';
import 'push_permission_dialog.dart';
import 'push_service.dart';
import 'push_token.dart';

part 'push_controller.g.dart';

/// Push notifications on the device (section 9.8):
///  - after login, a short explanation and then the system permission
///    request (asked once per install);
///  - registers the FCM token (`POST /me/devices`) on login and on refresh;
///  - foreground pushes show an in-app banner and refresh the inbox badge;
///  - taps (background, terminated or banner) open the screen from `data`.
/// The state is whether push works on this build (Firebase configured).
@Riverpod(keepAlive: true)
class PushController extends _$PushController {
  static const askedKey = 'push.permissionAsked';

  Map<String, String>? _pending;
  final _subs = <StreamSubscription<Object?>>[];
  bool _initialized = false;
  String? _registeredFor;

  PushService get _push => ref.read(pushServiceProvider);

  @override
  bool build() {
    ref.onDispose(() {
      for (final s in _subs) {
        unawaited(s.cancel());
      }
    });
    ref.listen(sessionControllerProvider, (_, s) => unawaited(_onSession(s)));
    unawaited(_init());
    return false;
  }

  Future<void> _init() async {
    await _push.init();
    _initialized = true;
    if (!ref.mounted) return;
    state = _push.available;
    if (_push.available) {
      _subs
        ..add(_push.foreground.listen(_onForeground))
        ..add(_push.opened.listen(open))
        ..add(_push.tokenRefresh.listen((t) => unawaited(_register(t))));
      _pending = await _push.launchData();
    }
    await _onSession(ref.read(sessionControllerProvider));
  }

  CurrentRole? get _role {
    final s = ref.read(sessionControllerProvider);
    return s is SessionSignedIn && !s.user.mustChangePassword
        ? CurrentRole(s.user.id, s.user.role)
        : null;
  }

  Future<void> _onSession(SessionState session) async {
    if (!_initialized) return;
    final role = _role;
    if (role == null) {
      _registeredFor = null;
      ref.read(registeredPushTokenProvider.notifier).set(null);
      return;
    }
    // Let the router replace the splash/login page with the role home first:
    // a dialog or route added before that would be dropped with the old page.
    await SchedulerBinding.instance.endOfFrame;
    await SchedulerBinding.instance.endOfFrame;
    if (!ref.mounted) return;
    if (_registeredFor != role.userId) {
      _registeredFor = role.userId;
      await _setUp();
    }
    final pending = _pending;
    if (pending != null) {
      _pending = null;
      open(pending);
    }
  }

  Future<void> _setUp() async {
    if (!_push.available) return;
    var permission = await _push.permission();
    if (permission == PushPermission.notDetermined) {
      final prefs = ref.read(preferencesProvider);
      if (await prefs.getBool(askedKey) ?? false) return;
      await prefs.setBool(askedKey, true);
      final accepted = await showPushExplanation();
      if (!accepted) return;
      permission = await _push.requestPermission();
    }
    if (permission != PushPermission.granted) return;
    final token = await _push.token();
    if (token != null) await _register(token);
  }

  Future<void> _register(String token) async {
    if (_role == null) return;
    try {
      await ref
          .read(notificationsRepositoryProvider)
          .registerDevice(token, _push.platform);
      ref.read(registeredPushTokenProvider.notifier).set(token);
    } on ApiException {
      // Retried on the next login or token refresh.
    }
  }

  void _onForeground(PushMessage message) {
    unawaited(_push.showBanner(message));
    ref.invalidate(unreadCountProvider);
    ref.invalidate(inboxProvider);
  }

  /// Opens the screen for a notification's [data] (also used by the
  /// inbox). Before login it waits until the user is signed in.
  void open(Map<String, dynamic> data) {
    final role = _role;
    if (role == null) {
      _pending = data.map((k, v) => MapEntry(k, '$v'));
      return;
    }
    final id = data['notificationId'];
    if (id is String) unawaited(_markRead(id));
    final target = targetFor(role.role, data);
    if (target.membersFilter case final filter?) {
      ref.read(memberFiltersControllerProvider.notifier).show(filter);
    }
    final router = ref.read(routerProvider);
    final home = Routes.homeFor(role.role);
    router.go(home);
    if (target.location != home) {
      if (target.location.startsWith('/admin/members/')) {
        unawaited(router.push(target.location));
      } else {
        router.go(target.location);
      }
    }
  }

  Future<void> _markRead(String id) async {
    try {
      await ref.read(notificationsRepositoryProvider).markRead(id);
      ref.invalidate(unreadCountProvider);
    } on ApiException {
      // Best effort.
    }
  }
}

class CurrentRole {
  const CurrentRole(this.userId, this.role);
  final String userId;
  final Role role;
}
