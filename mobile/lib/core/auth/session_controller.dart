import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/auth/data/auth_repository.dart';
import '../../features/auth/domain/current_user.dart';
import '../network/api_exception.dart';
import '../push/push_token.dart';
import 'token_storage.dart';

part 'session_controller.g.dart';

/// Where the app stands with the signed-in user.
sealed class SessionState {
  const SessionState();
}

/// Reading the stored session (splash).
final class SessionLoading extends SessionState {
  const SessionLoading();
}

/// The stored session could not be checked (e.g. offline); the splash
/// offers a retry. The tokens are kept.
final class SessionRestoreFailed extends SessionState {
  const SessionRestoreFailed(this.error);
  final Object error;
}

final class SessionSignedOut extends SessionState {
  const SessionSignedOut();
}

final class SessionSignedIn extends SessionState {
  const SessionSignedIn(this.user);
  final CurrentUser user;
}

/// Owns the session: restores it at launch, signs in and out, and is told by
/// the HTTP client when the refresh token is rejected.
@Riverpod(keepAlive: true)
class SessionController extends _$SessionController {
  TokenStorage get _storage => ref.read(tokenStorageProvider);
  AuthRepository get _repo => ref.read(authRepositoryProvider);

  @override
  SessionState build() {
    unawaited(Future.microtask(restore));
    return const SessionLoading();
  }

  /// Splash: stored tokens → `GET /me` → signed in. No tokens → signed out.
  Future<void> restore() async {
    state = const SessionLoading();
    if (await _storage.read() == null) {
      state = const SessionSignedOut();
      return;
    }
    try {
      state = SessionSignedIn(await _repo.me());
    } on ApiException catch (e) {
      if (e.isUnauthorized) {
        await _storage.clear();
        state = const SessionSignedOut();
      } else {
        state = SessionRestoreFailed(e);
      }
    }
  }

  /// Throws [ApiException] (e.g. `INVALID_CREDENTIALS`) for the login form.
  Future<void> signIn({required String phone, required String password}) async {
    final tokens = await _repo.login(phone: phone, password: password);
    await _storage.save(tokens);
    try {
      state = SessionSignedIn(await _repo.me());
    } on ApiException {
      await _storage.clear();
      rethrow;
    }
  }

  /// Throws [ApiException] (e.g. `WRONG_CURRENT_PASSWORD`) for the form.
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await _repo.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
    state = SessionSignedIn(await _repo.me());
  }

  /// Revokes the refresh token (best effort) and clears the device.
  Future<void> signOut() async {
    final tokens = await _storage.read();
    if (tokens != null) {
      try {
        await _repo.logout(
          tokens.refreshToken,
          fcmToken: ref.read(registeredPushTokenProvider),
        );
      } on ApiException {
        // Offline or already revoked: signing out locally is what matters.
      }
    }
    await _storage.clear();
    state = const SessionSignedOut();
  }

  /// Called by the HTTP client after the server rejected the refresh token.
  /// The tokens are already cleared.
  void expire() {
    if (state is! SessionSignedOut) state = const SessionSignedOut();
  }
}
