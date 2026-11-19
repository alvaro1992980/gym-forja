import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_app/core/network/api_exception.dart';
import 'package:gym_app/core/network/error_messages.dart';
import 'package:gym_app/l10n/generated/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

import '../../helpers/fakes.dart';

/// Every code in backend/src/common/errors/error-codes.ts.
const backendCodes = [
  'VALIDATION_ERROR',
  'BAD_REQUEST',
  'UNAUTHORIZED',
  'FORBIDDEN',
  'NOT_FOUND',
  'METHOD_NOT_ALLOWED',
  'CONFLICT',
  'PAYLOAD_TOO_LARGE',
  'TOO_MANY_REQUESTS',
  'INTERNAL_ERROR',
  'SERVICE_UNAVAILABLE',
  'INVALID_CREDENTIALS',
  'PASSWORD_CHANGE_REQUIRED',
  'ACCOUNT_INACTIVE',
  'PHONE_ALREADY_EXISTS',
  'EMAIL_ALREADY_EXISTS',
  'INVALID_REFRESH_TOKEN',
  'WRONG_CURRENT_PASSWORD',
  'PASSWORD_UNCHANGED',
  'LAST_ACTIVE_ADMIN',
  'AMOUNT_NOTE_REQUIRED',
  'MEMBERSHIP_EXPIRED',
  'START_DATE_OUT_OF_RANGE',
  'TIER_UNCHANGED',
  'PAYMENT_ALREADY_VOIDED',
  'PAYMENT_METHOD_REQUIRED',
  'DOWNGRADE_HAS_NO_CHARGE',
  'NO_MEMBERSHIP',
  'QR_TOKEN_INVALID',
  'QR_TOKEN_EXPIRED',
  'TIER_REQUIRED',
  'SESSION_ALREADY_OPEN',
];

DioException _badResponse(int status, Object? data) {
  final options = RequestOptions(path: '/x');
  return DioException(
    requestOptions: options,
    type: DioExceptionType.badResponse,
    response: Response<Object?>(
      requestOptions: options,
      statusCode: status,
      data: data,
    ),
  );
}

void main() {
  test('every backend error code has a message in both languages', () {
    final es = lookupAppLocalizations(const Locale('es'));
    for (final code in backendCodes) {
      expect(messageForCode(es, code), isNotNull, reason: code);
      expect(messageForCode(en, code), isNotNull, reason: code);
    }
  });

  test('login errors: wrong credentials, inactive account, no connection', () {
    expect(
      errorMessage(en, apiError(401, 'INVALID_CREDENTIALS')),
      en.errorInvalidCredentials,
    );
    expect(
      errorMessage(en, apiError(403, 'ACCOUNT_INACTIVE')),
      en.errorAccountInactive,
    );
    expect(
      errorMessage(en, const ApiException(code: ClientErrorCode.network)),
      en.errorNetwork,
    );
  });

  test('unknown codes fall back to the HTTP status', () {
    expect(errorMessage(en, apiError(409, 'SOMETHING_NEW')), en.errorConflict);
    expect(errorMessage(en, apiError(502, 'SOMETHING_NEW')), en.errorServer);
    expect(errorMessage(en, StateError('x')), en.errorUnknown);
  });

  group('ApiException.fromDio', () {
    test('reads the backend error body', () {
      final e = ApiException.fromDio(
        _badResponse(401, {
          'statusCode': 401,
          'code': 'INVALID_CREDENTIALS',
          'message': 'Teléfono o contraseña incorrectos.',
        }),
      );
      expect(e.code, 'INVALID_CREDENTIALS');
      expect(e.statusCode, 401);
      expect(e.isUnauthorized, isTrue);
    });

    test('connection errors and timeouts', () {
      final options = RequestOptions(path: '/x');
      expect(
        ApiException.fromDio(
          DioException.connectionError(requestOptions: options, reason: 'x'),
        ).code,
        ClientErrorCode.network,
      );
      expect(
        ApiException.fromDio(
          DioException(
            requestOptions: options,
            type: DioExceptionType.receiveTimeout,
          ),
        ).isNetwork,
        isTrue,
      );
    });

    test('a non-JSON error body keeps the status', () {
      final e = ApiException.fromDio(_badResponse(502, '<html>'));
      expect(e.code, ClientErrorCode.unknown);
      expect(e.statusCode, 502);
    });
  });
}
