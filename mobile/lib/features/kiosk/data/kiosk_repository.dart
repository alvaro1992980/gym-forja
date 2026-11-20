import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/network/auth_interceptor.dart';

part 'kiosk_repository.g.dart';

/// `GET /kiosk/qr-token` [R-18].
class QrToken {
  const QrToken({
    required this.token,
    required this.validFor,
    required this.refreshIn,
    required this.gymName,
  });

  factory QrToken.fromJson(Map<String, dynamic> json) {
    final token = json['token'] as String;
    return QrToken(
      token: token,
      validFor: _lifetime(token) ?? const Duration(seconds: 45),
      refreshIn: Duration(seconds: json['refreshInSeconds'] as int),
      gymName: json['gymName'] as String? ?? '',
    );
  }

  final String token;

  /// How long the token is accepted, from `exp − iat` of the JWT. Measured
  /// from when it was received, so the kiosk never relies on its own clock
  /// matching the server's.
  final Duration validFor;
  final Duration refreshIn;
  final String gymName;

  static Duration? _lifetime(String jwt) {
    try {
      final payload = jwt.split('.')[1];
      final claims = jsonDecode(
        utf8.decode(base64Url.decode(base64Url.normalize(payload))),
      ) as Map<String, dynamic>;
      return Duration(seconds: (claims['exp'] as int) - (claims['iat'] as int));
    } on Object {
      return null;
    }
  }
}

class KioskRepository {
  KioskRepository(this._dio);

  final Dio _dio;

  Future<QrToken> qrToken() => apiCall(() async {
    final res = await _dio.get<Map<String, dynamic>>('/kiosk/qr-token');
    return QrToken.fromJson(res.data!);
  });

  /// Hidden exit (section 9.4): checks an ADMIN's phone (any format, the
  /// server normalizes it [R-40]) and password with a login, then revokes
  /// the session it created. True for an active admin's credentials.
  Future<bool> verifyAdmin({required String phone, required String password}) =>
      apiCall(() async {
        final public = Options(extra: {AuthExtra.skipAuth: true});
        try {
          final res = await _dio.post<Map<String, dynamic>>(
            '/auth/login',
            data: {'phone': phone, 'password': password},
            options: public,
          );
          final data = res.data!;
          final refreshToken = data['refreshToken'] as String;
          final role = (data['user'] as Map<String, dynamic>)['role'];
          await _dio.post<void>(
            '/auth/logout',
            data: {'refreshToken': refreshToken},
            options: Options(
              extra: {AuthExtra.skipAuth: true},
              headers: {'Authorization': 'Bearer ${data['accessToken']}'},
            ),
          );
          return role == 'ADMIN';
        } on DioException catch (e) {
          final status = e.response?.statusCode;
          if (status == 401 || status == 403) return false;
          rethrow;
        }
      });
}

@Riverpod(keepAlive: true)
KioskRepository kioskRepository(Ref ref) =>
    KioskRepository(ref.watch(dioProvider));
