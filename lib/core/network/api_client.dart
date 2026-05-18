import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../storage/secure_storage.dart';
import 'mock_interceptor.dart';
import 'token_refresh_interceptor.dart';

class ApiClient {
  // Pass --dart-define=USE_MOCKS=false to disable mock mode.
  // Defaults to true in debug builds so the app works without a running server.
  static const bool _useMocks =
      bool.fromEnvironment('USE_MOCKS', defaultValue: kDebugMode);

  static const String _realBaseUrl = 'https://api.attendx.ac.rw/v1';
  static const String _mockBaseUrl = 'http://mock.local';

  /// Set this from auth_provider so the token-refresh interceptor can
  /// trigger a force-logout when the refresh token itself has expired.
  static void Function()? onForceLogout;

  late Dio _dio;
  final SecureStorage _storage = SecureStorage();

  ApiClient() {
    _dio = Dio(BaseOptions(
      baseUrl: _useMocks ? _mockBaseUrl : _realBaseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Content-Type': 'application/json'},
    ));

    if (_useMocks) {
      // Short-circuit all requests with mock data — no network needed.
      _dio.interceptors.add(MockInterceptor());
    } else {
      // 1. Inject Bearer token on every request.
      _dio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.getAccessToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
      ));

      // 2. On 401: silently refresh the access token and retry.
      _dio.interceptors.add(TokenRefreshInterceptor(
        dio: _dio,
        storage: _storage,
        baseUrl: _realBaseUrl,
        onForceLogout: () => ApiClient.onForceLogout?.call(),
      ));
    }
  }

  Dio get dio => _dio;

  static bool get isMockMode => _useMocks;
}
