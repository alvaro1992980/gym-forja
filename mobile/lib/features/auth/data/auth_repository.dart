import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/auth/auth_tokens.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/network/auth_interceptor.dart';
import '../domain/current_user.dart';

part 'auth_repository.g.dart';

/// Auth endpoints (docs/PLAN.md section 8.1). Every method throws
/// [ApiException] on failure.
class AuthRepository {
  AuthRepository(this._dio);

  final Dio _dio;

  static final _public = Options(extra: {AuthExtra.skipAuth: true});

  /// `phone` may be in any format; the server normalizes it [R-40].
  Future<AuthTokens> login({required String phone, required String password}) =>
      apiCall(() async {
        final res = await _dio.post<Map<String, dynamic>>(
          '/auth/login',
          data: {'phone': phone, 'password': password},
          options: _public,
        );
        return AuthTokens.fromJson(res.data!);
      });

  Future<CurrentUser> me() => apiCall(() async {
    final res = await _dio.get<Map<String, dynamic>>('/me');
    return CurrentUser.fromJson(res.data!);
  });

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) => apiCall(
    () => _dio.post<void>(
      '/auth/change-password',
      data: {'currentPassword': currentPassword, 'newPassword': newPassword},
    ),
  );

  /// Revokes the refresh token on the server and, with [fcmToken], deletes
  /// this device's push registration (section 9.1 #4).
  Future<void> logout(String refreshToken, {String? fcmToken}) => apiCall(
    () => _dio.post<void>(
      '/auth/logout',
      data: {'refreshToken': refreshToken, 'fcmToken': ?fcmToken},
    ),
  );
}

@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) =>
    AuthRepository(ref.watch(dioProvider));
