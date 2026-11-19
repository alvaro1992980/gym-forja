import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../auth/auth_tokens.dart';
import '../auth/session_controller.dart';
import '../auth/token_storage.dart';
import '../config/app_config.dart';
import 'auth_interceptor.dart';

part 'api_client.g.dart';

BaseOptions _baseOptions(AppConfig config) => BaseOptions(
  baseUrl: config.apiUrl,
  connectTimeout: const Duration(seconds: 10),
  receiveTimeout: const Duration(seconds: 20),
  contentType: Headers.jsonContentType,
  responseType: ResponseType.json,
);

/// Calls `POST /auth/refresh` with a bare client, so it never goes through
/// [AuthInterceptor] itself.
Future<AuthTokens> refreshTokens(Dio bare, String refreshToken) async {
  final response = await bare.post<Map<String, dynamic>>(
    '/auth/refresh',
    data: {'refreshToken': refreshToken},
  );
  return AuthTokens.fromJson(response.data!);
}

/// The REST client used by every repository.
@Riverpod(keepAlive: true)
Dio dio(Ref ref) {
  final options = _baseOptions(ref.watch(appConfigProvider));
  final bare = Dio(options);
  final dio = Dio(options);
  dio.interceptors.add(
    AuthInterceptor(
      storage: ref.watch(tokenStorageProvider),
      refresh: (token) => refreshTokens(bare, token),
      retry: dio.fetch,
      onSessionExpired: () =>
          ref.read(sessionControllerProvider.notifier).expire(),
    ),
  );
  ref.onDispose(() {
    dio.close();
    bare.close();
  });
  return dio;
}
