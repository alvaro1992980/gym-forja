import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'push_service.g.dart';

/// A push received while the app is open.
class PushMessage {
  const PushMessage({this.title, this.body, this.data = const {}});

  final String? title;
  final String? body;
  final Map<String, String> data;
}

enum PushPermission { granted, denied, notDetermined }

/// Push notifications on the device (section 9.8), behind an interface so
/// tests and builds without Firebase config use a fake / disabled one.
abstract class PushService {
  /// False when Firebase is not configured (no `google-services.json`).
  bool get available;

  /// Initializes Firebase and the local banners. Never throws.
  Future<void> init();

  Future<PushPermission> permission();
  Future<PushPermission> requestPermission();

  /// The FCM token of this install, or null when unavailable.
  Future<String?> token();
  Stream<String> get tokenRefresh;

  /// Pushes received in the foreground.
  Stream<PushMessage> get foreground;

  /// Data of a notification the user tapped (system or in-app banner)
  /// while the app was running in the background or foreground.
  Stream<Map<String, String>> get opened;

  /// Data of the notification that launched the app from terminated.
  Future<Map<String, String>?> launchData();

  /// In-app banner for a foreground push.
  Future<void> showBanner(PushMessage message);

  String get platform;
}

/// Without Firebase configuration: nothing to receive, inbox only.
class DisabledPushService implements PushService {
  const DisabledPushService();

  @override
  bool get available => false;
  @override
  Future<void> init() async {}
  @override
  Future<PushPermission> permission() async => PushPermission.denied;
  @override
  Future<PushPermission> requestPermission() async => PushPermission.denied;
  @override
  Future<String?> token() async => null;
  @override
  Stream<String> get tokenRefresh => const Stream.empty();
  @override
  Stream<PushMessage> get foreground => const Stream.empty();
  @override
  Stream<Map<String, String>> get opened => const Stream.empty();
  @override
  Future<Map<String, String>?> launchData() async => null;
  @override
  Future<void> showBanner(PushMessage message) async {}
  @override
  String get platform => 'android';
}

/// Firebase Cloud Messaging + flutter_local_notifications for banners.
class FirebasePushService implements PushService {
  static const _channel = AndroidNotificationChannel(
    'gym_default',
    'Notificaciones',
    description: 'Ingresos, pagos y vencimientos',
    importance: Importance.high,
  );

  final _local = FlutterLocalNotificationsPlugin();
  final _opened = StreamController<Map<String, String>>.broadcast();
  bool _available = false;
  int _nextId = 0;

  @override
  bool get available => _available;

  @override
  String get platform => Platform.isIOS ? 'ios' : 'android';

  @override
  Future<void> init() async {
    try {
      await Firebase.initializeApp();
    } on Object catch (e) {
      debugPrint('Push disabled: Firebase is not configured ($e)');
      return;
    }
    await _local.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
      onDidReceiveNotificationResponse: (r) {
        final data = _decode(r.payload);
        if (data != null) _opened.add(data);
      },
    );
    await _local
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(_channel);
    FirebaseMessaging.onMessageOpenedApp.listen(
      (m) => _opened.add(m.data.cast()),
    );
    _available = true;
  }

  @override
  Future<PushPermission> permission() async => _map(
    (await FirebaseMessaging.instance.getNotificationSettings())
        .authorizationStatus,
  );

  @override
  Future<PushPermission> requestPermission() async => _map(
    (await FirebaseMessaging.instance.requestPermission()).authorizationStatus,
  );

  static PushPermission _map(AuthorizationStatus s) => switch (s) {
    AuthorizationStatus.authorized ||
    AuthorizationStatus.provisional => PushPermission.granted,
    AuthorizationStatus.denied ||
    AuthorizationStatus.deniedPermanently => PushPermission.denied,
    AuthorizationStatus.notDetermined => PushPermission.notDetermined,
  };

  @override
  Future<String?> token() async {
    try {
      // The classic FCM registration token: what firebase-admin's
      // sendEachForMulticast targets (see DECISIONS).
      // ignore: deprecated_member_use
      return await FirebaseMessaging.instance.getToken();
    } on Object catch (e) {
      debugPrint('No FCM token: $e');
      return null;
    }
  }

  @override
  // ignore: deprecated_member_use
  Stream<String> get tokenRefresh => FirebaseMessaging.instance.onTokenRefresh;

  @override
  Stream<PushMessage> get foreground => FirebaseMessaging.onMessage.map(
    (m) => PushMessage(
      title: m.notification?.title,
      body: m.notification?.body,
      data: m.data.cast(),
    ),
  );

  @override
  Stream<Map<String, String>> get opened => _opened.stream;

  @override
  Future<Map<String, String>?> launchData() async {
    final initial = await FirebaseMessaging.instance.getInitialMessage();
    if (initial != null) return initial.data.cast();
    final details = await _local.getNotificationAppLaunchDetails();
    if (details?.didNotificationLaunchApp ?? false) {
      return _decode(details!.notificationResponse?.payload);
    }
    return null;
  }

  @override
  Future<void> showBanner(PushMessage message) => _local.show(
    id: _nextId++,
    title: message.title,
    body: message.body,
    notificationDetails: NotificationDetails(
      android: AndroidNotificationDetails(
        _channel.id,
        _channel.name,
        channelDescription: _channel.description,
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: const DarwinNotificationDetails(),
    ),
    payload: jsonEncode(message.data),
  );

  static Map<String, String>? _decode(String? payload) {
    if (payload == null || payload.isEmpty) return null;
    try {
      return (jsonDecode(payload) as Map<String, dynamic>).map(
        (k, v) => MapEntry(k, '$v'),
      );
    } on FormatException {
      return null;
    }
  }
}

@Riverpod(keepAlive: true)
PushService pushService(Ref ref) => FirebasePushService();
