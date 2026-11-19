import 'dart:async';

import 'package:dio/dio.dart';

import '../auth/auth_tokens.dart';
import '../auth/token_storage.dart';

/// Request `extra` flags used by [AuthInterceptor].
abstract final class AuthExtra {
  /// The request must not carry a token nor trigger a refresh (login, refresh).
  static const skipAuth = 'auth.skip';

  /// Set on the retried request so a second 401 is not refreshed again.
  static const retried = 'auth.retried';
}

/// Attaches the access token to every request and refreshes it on `401`
/// (docs/PLAN.md section 9.1 #5):
///  - the refresh runs once; concurrent requests that fail, or start while it
///    runs, wait for it and are retried with the new token;
///  - each request is retried at most once;
///  - when the server rejects the refresh token, the stored tokens are
///    cleared and [onSessionExpired] is called (log out). A network failure
///    during the refresh keeps the session, so being offline never logs out.
class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required this._storage,
    required this._refresh,
    required this._retry,
    required this._onSessionExpired,
  });

  final TokenStorage _storage;
  final Future<AuthTokens> Function(String refreshToken) _refresh;
  final Future<Response<dynamic>> Function(RequestOptions options) _retry;
  final void Function() _onSessionExpired;

  Future<AuthTokens?>? _refreshing;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (options.extra[AuthExtra.skipAuth] == true) {
      return handler.next(options);
    }
    final pending = _refreshing;
    if (pending != null) {
      // Queue behind the running refresh; its failure is handled by onError.
      await pending.then((_) {}, onError: (Object _) {});
    }
    final tokens = await _storage.read();
    if (tokens != null) {
      options.headers['Authorization'] = 'Bearer ${tokens.accessToken}';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final request = err.requestOptions;
    if (err.response?.statusCode != 401 ||
        request.extra[AuthExtra.skipAuth] == true ||
        request.extra[AuthExtra.retried] == true) {
      return handler.next(err);
    }

    final AuthTokens? tokens;
    try {
      tokens = await _refreshOnce(_bearerOf(request));
    } on DioException catch (e) {
      return handler.next(e);
    }
    if (tokens == null) return handler.next(err);

    try {
      final response = await _retry(
        request.copyWith(
          headers: {
            ...request.headers,
            'Authorization': 'Bearer ${tokens.accessToken}',
          },
          extra: {...request.extra, AuthExtra.retried: true},
        ),
      );
      handler.resolve(response);
    } on DioException catch (e) {
      handler.next(e);
    }
  }

  /// Starts a refresh, or joins the one already running.
  Future<AuthTokens?> _refreshOnce(String? usedAccessToken) {
    return _refreshing ??= _doRefresh(usedAccessToken)
        .whenComplete(() => _refreshing = null);
  }

  Future<AuthTokens?> _doRefresh(String? usedAccessToken) async {
    final current = await _storage.read();
    if (current == null) return null;
    // Another request already refreshed after this one was sent.
    if (usedAccessToken != null && current.accessToken != usedAccessToken) {
      return current;
    }
    try {
      final fresh = await _refresh(current.refreshToken);
      await _storage.save(fresh);
      return fresh;
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      if (status != null && status >= 400 && status < 500) {
        await _storage.clear();
        _onSessionExpired();
        return null;
      }
      rethrow;
    }
  }

  static String? _bearerOf(RequestOptions request) {
    final header = request.headers['Authorization'];
    if (header is String && header.startsWith('Bearer ')) {
      return header.substring('Bearer '.length);
    }
    return null;
  }
}
