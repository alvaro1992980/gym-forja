import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_config.g.dart';

/// Build-time configuration, passed with `--dart-define` (or
/// `--dart-define-from-file=config/<env>.json`, see the README).
class AppConfig {
  const AppConfig({required this.environment, required this.apiBaseUrl});

  /// Reads the compile-time values. The defaults are the dev values: the
  /// Android emulator reaches the host machine at 10.0.2.2.
  factory AppConfig.fromEnvironment() => const AppConfig(
    environment: String.fromEnvironment('APP_ENV', defaultValue: 'dev'),
    apiBaseUrl: String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: 'http://10.0.2.2:3000',
    ),
  );

  /// `dev`, `staging` or `prod`.
  final String environment;

  /// Server origin without the API prefix, e.g. `http://10.0.2.2:3000`.
  final String apiBaseUrl;

  /// Base URL of every REST call (`/api/v1`, docs/PLAN.md section 8).
  String get apiUrl => '$apiOrigin/api/v1';

  /// Server origin for Socket.IO (`<origin>/realtime`, section 8.5).
  String get apiOrigin => _trimTrailingSlash(apiBaseUrl);

  bool get isProduction => environment == 'prod';

  static String _trimTrailingSlash(String url) =>
      url.endsWith('/') ? url.substring(0, url.length - 1) : url;
}

@Riverpod(keepAlive: true)
AppConfig appConfig(Ref ref) => AppConfig.fromEnvironment();
