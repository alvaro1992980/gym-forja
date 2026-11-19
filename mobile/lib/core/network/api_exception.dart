import 'package:dio/dio.dart';

/// Client-side codes for failures that never reached the API.
abstract final class ClientErrorCode {
  static const network = 'NETWORK_ERROR';
  static const timeout = 'TIMEOUT';
  static const unknown = 'UNKNOWN_ERROR';
}

/// A failed API call. [code] is the backend error `code`
/// (`backend/src/common/errors/error-codes.ts`) or a [ClientErrorCode].
class ApiException implements Exception {
  const ApiException({
    required this.code,
    this.statusCode,
    this.message,
    this.details,
  });

  /// Maps a dio failure to the backend error format
  /// `{statusCode, code, message, details?}`.
  factory ApiException.fromDio(DioException e) {
    if (_timeouts.contains(e.type)) {
      return const ApiException(code: ClientErrorCode.timeout);
    }
    if (e.type == DioExceptionType.connectionError) {
      return const ApiException(code: ClientErrorCode.network);
    }
    final response = e.response;
    if (response == null) {
      return const ApiException(code: ClientErrorCode.network);
    }
    final data = response.data;
    if (data is Map<String, dynamic> && data['code'] is String) {
      return ApiException(
        code: data['code'] as String,
        statusCode: response.statusCode,
        message: data['message'] is String ? data['message'] as String : null,
        details: data['details'],
      );
    }
    return ApiException(
      code: ClientErrorCode.unknown,
      statusCode: response.statusCode,
    );
  }

  static const _timeouts = {
    DioExceptionType.connectionTimeout,
    DioExceptionType.sendTimeout,
    DioExceptionType.receiveTimeout,
  };

  final String code;
  final int? statusCode;

  /// Spanish message from the server; the UI shows a localized one instead.
  final String? message;
  final Object? details;

  bool get isUnauthorized => statusCode == 401;
  bool get isNetwork =>
      code == ClientErrorCode.network || code == ClientErrorCode.timeout;

  @override
  String toString() => 'ApiException($statusCode $code)';
}

/// Runs an API call and turns dio failures into [ApiException]s.
Future<T> apiCall<T>(Future<T> Function() call) async {
  try {
    return await call();
  } on DioException catch (e) {
    throw ApiException.fromDio(e);
  }
}
