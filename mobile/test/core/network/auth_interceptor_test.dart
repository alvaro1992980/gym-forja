import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_app/core/auth/auth_tokens.dart';
import 'package:gym_app/core/auth/token_storage.dart';
import 'package:gym_app/core/network/auth_interceptor.dart';

/// Serves every request with [handler] and records what was sent.
class FakeAdapter implements HttpClientAdapter {
  FakeAdapter(this.handler);

  final ResponseBody Function(RequestOptions options) handler;
  final requests = <RequestOptions>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    await Future<void>.delayed(Duration.zero);
    return handler(options);
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody jsonBody(int status, Object body) => ResponseBody.fromString(
  jsonEncode(body),
  status,
  headers: {
    Headers.contentTypeHeader: [Headers.jsonContentType],
  },
);

DioException refreshRejected() {
  final options = RequestOptions(path: '/auth/refresh');
  return DioException(
    requestOptions: options,
    type: DioExceptionType.badResponse,
    response: Response<void>(requestOptions: options, statusCode: 401),
  );
}

const oldTokens = AuthTokens(accessToken: 'old', refreshToken: 'r1');
const newTokens = AuthTokens(accessToken: 'new', refreshToken: 'r2');

void main() {
  late MemoryTokenStorage storage;
  late FakeAdapter adapter;
  late Dio dio;
  late int refreshCalls;
  late int expiredCalls;
  late Future<AuthTokens> Function(String refreshToken) refresh;

  /// The API accepts only the token named [valid].
  ResponseBody api(RequestOptions o, {String valid = 'new'}) =>
      o.headers['Authorization'] == 'Bearer $valid'
      ? jsonBody(200, {'ok': true})
      : jsonBody(401, {'statusCode': 401, 'code': 'UNAUTHORIZED'});

  setUp(() {
    storage = MemoryTokenStorage(oldTokens);
    refreshCalls = 0;
    expiredCalls = 0;
    refresh = (token) async {
      refreshCalls++;
      expect(token, 'r1');
      await Future<void>.delayed(const Duration(milliseconds: 10));
      return newTokens;
    };
    adapter = FakeAdapter(api);
    dio = Dio(BaseOptions(baseUrl: 'http://api.test/api/v1'))
      ..httpClientAdapter = adapter;
    dio.interceptors.add(
      AuthInterceptor(
        storage: storage,
        refresh: (t) => refresh(t),
        retry: dio.fetch,
        onSessionExpired: () => expiredCalls++,
      ),
    );
  });

  test('attaches the stored access token', () async {
    storage.tokens = newTokens;
    await dio.get<void>('/me');
    expect(adapter.requests.single.headers['Authorization'], 'Bearer new');
    expect(refreshCalls, 0);
  });

  test('skipAuth requests carry no token and are never refreshed', () async {
    adapter = FakeAdapter(
      (_) => jsonBody(401, {'code': 'INVALID_CREDENTIALS'}),
    );
    dio.httpClientAdapter = adapter;
    await expectLater(
      dio.post<void>(
        '/auth/login',
        options: Options(extra: {AuthExtra.skipAuth: true}),
      ),
      throwsA(isA<DioException>()),
    );
    expect(adapter.requests.single.headers['Authorization'], isNull);
    expect(refreshCalls, 0);
  });

  test(
    'an expired access token is refreshed and the request retried',
    () async {
      final res = await dio.get<Map<String, dynamic>>('/me');
      expect(res.data, {'ok': true});
      expect(refreshCalls, 1);
      expect(storage.tokens, newTokens);
      expect(adapter.requests.map((r) => r.headers['Authorization']), [
        'Bearer old',
        'Bearer new',
      ]);
    },
  );

  test('concurrent 401s share a single refresh', () async {
    final results = await Future.wait([
      dio.get<void>('/a'),
      dio.get<void>('/b'),
      dio.get<void>('/c'),
    ]);
    expect(results.map((r) => r.statusCode), [200, 200, 200]);
    expect(refreshCalls, 1);
  });

  test(
    'a request started during the refresh waits and uses the new token',
    () async {
      final first = dio.get<void>('/a');
      // Let the first request fail with 401 and start the refresh.
      await Future<void>.delayed(const Duration(milliseconds: 2));
      final second = dio.get<void>('/b');
      await Future.wait([first, second]);
      expect(refreshCalls, 1);
      final toB = adapter.requests.where((r) => r.path == '/b');
      expect(toB.single.headers['Authorization'], 'Bearer new');
    },
  );

  test('a rejected refresh token clears the session and logs out', () async {
    refresh = (_) async {
      refreshCalls++;
      throw refreshRejected();
    };
    await expectLater(
      dio.get<void>('/me'),
      throwsA(
        isA<DioException>().having(
          (e) => e.response?.statusCode,
          'status',
          401,
        ),
      ),
    );
    expect(refreshCalls, 1);
    expect(expiredCalls, 1);
    expect(storage.tokens, isNull);
  });

  test('a network failure during the refresh keeps the session', () async {
    refresh = (_) async {
      refreshCalls++;
      throw DioException.connectionError(
        requestOptions: RequestOptions(path: '/auth/refresh'),
        reason: 'offline',
      );
    };
    await expectLater(
      dio.get<void>('/me'),
      throwsA(
        isA<DioException>().having(
          (e) => e.type,
          'type',
          DioExceptionType.connectionError,
        ),
      ),
    );
    expect(expiredCalls, 0);
    expect(storage.tokens, oldTokens);
  });

  test('a request is retried at most once', () async {
    adapter = FakeAdapter((o) => api(o, valid: 'never'));
    dio.httpClientAdapter = adapter;
    await expectLater(dio.get<void>('/me'), throwsA(isA<DioException>()));
    expect(refreshCalls, 1);
    expect(adapter.requests, hasLength(2));
  });

  test('without stored tokens a 401 is returned as is', () async {
    storage.tokens = null;
    await expectLater(dio.get<void>('/me'), throwsA(isA<DioException>()));
    expect(refreshCalls, 0);
    expect(expiredCalls, 0);
  });
}
