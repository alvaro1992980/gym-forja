import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import '../../features/auth/data/auth_repository.dart';
import '../auth/session_controller.dart';
import '../auth/token_storage.dart';
import '../config/app_config.dart';
import '../models/enums.dart';
import '../network/api_exception.dart';

part 'realtime_client.g.dart';

/// Events of the Socket.IO namespace `/realtime` (docs/PLAN.md 8.5).
sealed class RealtimeEvent {
  const RealtimeEvent();
}

/// The server accepted the socket and joined its rooms. Sent on every
/// (re)connection: listeners reload their data to fill any gap.
final class RealtimeReady extends RealtimeEvent {
  const RealtimeReady();
}

final class RealtimeDisconnected extends RealtimeEvent {
  const RealtimeDisconnected();
}

/// `{id, firstName, lastName}` of the member in an event.
class EventMember {
  const EventMember({
    required this.id,
    required this.firstName,
    required this.lastName,
  });

  factory EventMember.fromJson(Map<String, dynamic> json) => EventMember(
    id: json['id'] as String,
    firstName: json['firstName'] as String,
    lastName: json['lastName'] as String,
  );

  final String id;
  final String firstName;
  final String lastName;

  String get fullName => '$firstName $lastName';
}

/// `checkin.created`.
final class CheckinCreated extends RealtimeEvent {
  const CheckinCreated({
    required this.checkinId,
    required this.member,
    required this.tier,
    required this.daysLeft,
    required this.createdAt,
  });

  factory CheckinCreated.fromJson(Map<String, dynamic> json) => CheckinCreated(
    checkinId: json['checkinId'] as String,
    member: EventMember.fromJson(json['member'] as Map<String, dynamic>),
    tier: Tier.fromApi(json['tier'] as String),
    daysLeft: json['daysLeft'] as int,
    createdAt: json['createdAt'] as String,
  );

  final String checkinId;
  final EventMember member;
  final Tier tier;
  final int daysLeft;

  /// ISO-8601 instant.
  final String createdAt;
}

/// `checkin.denied`: `reason` is `EXPIRED` or `INACTIVE`.
final class CheckinDenied extends RealtimeEvent {
  const CheckinDenied({
    required this.member,
    required this.reason,
    required this.endDate,
    required this.createdAt,
  });

  factory CheckinDenied.fromJson(Map<String, dynamic> json) => CheckinDenied(
    member: EventMember.fromJson(json['member'] as Map<String, dynamic>),
    reason: json['reason'] as String,
    endDate: json['endDate'] as String?,
    createdAt: json['createdAt'] as String,
  );

  final EventMember member;
  final String reason;
  final String? endDate;
  final String createdAt;

  bool get isExpired => reason == 'EXPIRED';
}

/// A live connection to `/realtime`. Replaced by a fake in tests.
abstract class RealtimeConnection {
  Stream<RealtimeEvent> get events;
  void dispose();
}

/// Socket.IO implementation. The access token is read from storage on every
/// (re)connection. When the server refuses it (`unauthorized`, usually an
/// expired access token), one authenticated REST call lets the HTTP client
/// refresh the session, then the socket connects again.
class SocketRealtimeConnection implements RealtimeConnection {
  SocketRealtimeConnection({
    required String origin,
    required Future<String?> Function() accessToken,
    required this._refreshSession,
  }) {
    _socket = io.io(
      '$origin/realtime',
      io.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .enableReconnection()
          .enableForceNew()
          .setAuthFn((callback) {
            unawaited(accessToken().then((t) => callback({'token': t ?? ''})));
          })
          .build(),
    );
    _socket
      ..on('ready', (_) => _add(const RealtimeReady()))
      ..on('unauthorized', (_) => unawaited(_reauthenticate()))
      ..on('disconnect', (_) => _add(const RealtimeDisconnected()))
      ..on('checkin.created', (data) => _parse(data, CheckinCreated.fromJson))
      ..on('checkin.denied', (data) => _parse(data, CheckinDenied.fromJson))
      ..connect();
  }

  late final io.Socket _socket;
  final Future<void> Function() _refreshSession;
  final _controller = StreamController<RealtimeEvent>.broadcast();
  bool _disposed = false;
  int _failedAuth = 0;

  @override
  Stream<RealtimeEvent> get events => _controller.stream;

  void _add(RealtimeEvent event) {
    if (event is RealtimeReady) _failedAuth = 0;
    if (!_disposed) _controller.add(event);
  }

  void _parse(
    Object? data,
    RealtimeEvent Function(Map<String, dynamic> json) fromJson,
  ) {
    if (data is Map) _add(fromJson(Map<String, dynamic>.from(data)));
  }

  /// The server disconnects refused sockets and Socket.IO does not retry
  /// those, so this does, with a growing delay.
  Future<void> _reauthenticate() async {
    _failedAuth++;
    try {
      await _refreshSession();
    } on ApiException {
      // Offline or signed out: the delay below and the session handle it.
    }
    await Future<void>.delayed(Duration(seconds: _failedAuth.clamp(1, 30)));
    if (!_disposed) _socket.connect();
  }

  @override
  void dispose() {
    _disposed = true;
    _socket.dispose();
    unawaited(_controller.close());
  }
}

/// The admin's live connection, open while an ADMIN is signed in (other
/// roles get null: the server only sends events to admins).
@Riverpod(keepAlive: true)
RealtimeConnection? realtimeConnection(Ref ref) {
  final session = ref.watch(sessionControllerProvider);
  final isAdmin =
      session is SessionSignedIn &&
      session.user.role == Role.admin &&
      !session.user.mustChangePassword;
  if (!isAdmin) return null;
  final storage = ref.read(tokenStorageProvider);
  final connection = SocketRealtimeConnection(
    origin: ref.read(appConfigProvider).apiOrigin,
    accessToken: () async => (await storage.read())?.accessToken,
    refreshSession: () => ref.read(authRepositoryProvider).me(),
  );
  ref.onDispose(connection.dispose);
  return connection;
}

/// Every realtime event for the signed-in admin.
@Riverpod(keepAlive: true)
Stream<RealtimeEvent> realtimeEvents(Ref ref) =>
    ref.watch(realtimeConnectionProvider)?.events ?? const Stream.empty();
