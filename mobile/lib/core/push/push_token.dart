import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'push_token.g.dart';

/// FCM token registered for the signed-in user (`POST /me/devices`). Sent on
/// logout so the server deletes the device. Kept apart from the push
/// controller so the session can read it without a provider cycle.
@Riverpod(keepAlive: true)
class RegisteredPushToken extends _$RegisteredPushToken {
  @override
  String? build() => null;

  void set(String? token) => state = token;
}
