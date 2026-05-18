import 'dart:async';
import 'package:dio/dio.dart';
import '../storage/secure_storage.dart';
import 'api_endpoints.dart';

/// Intercepts 401 responses, silently refreshes the access token using the
/// stored refresh token, and retries the original request.
///
/// Concurrent requests that 401 simultaneously all wait on the same
/// [Completer] so only one refresh call is made.
///
/// If the refresh itself fails the storage is cleared and [onForceLogout]
/// is called so the UI can redirect to the login screen.
class TokenRefreshInterceptor extends Interceptor {
  final Dio _dio;
  final SecureStorage _storage;
  final String _baseUrl;

  /// Called when a refresh fails (expired or revoked refresh token).
  void Function()? onForceLogout;

  Completer<String>? _refreshing;

  TokenRefreshInterceptor({
    required Dio dio,
    required SecureStorage storage,
    required String baseUrl,
    this.onForceLogout,
  })  : _dio = dio,
        _storage = storage,
        _baseUrl = baseUrl;

  @override
  Future<void> onError(
      DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode != 401) {
      handler.next(err);
      return;
    }

    // The refresh call itself 401'd → refresh token is invalid → force logout.
    if (err.requestOptions.path.contains(ApiEndpoints.refreshToken)) {
      await _clearAndLogout();
      handler.next(err);
      return;
    }

    // Already retried once — don't loop.
    if (err.requestOptions.extra['_retried'] == true) {
      handler.next(err);
      return;
    }

    if (_refreshing != null) {
      // A refresh is already in flight — wait for it, then retry.
      try {
        final newToken = await _refreshing!.future;
        handler.resolve(await _retry(err.requestOptions, newToken));
      } catch (_) {
        handler.next(err);
      }
      return;
    }

    _refreshing = Completer<String>();
    try {
      final storedRefresh = await _storage.getRefreshToken();
      if (storedRefresh == null) throw Exception('no refresh token stored');

      // Use a fresh Dio so this request bypasses the interceptor chain.
      final freshDio = Dio(BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {'Content-Type': 'application/json'},
      ));
      final res = await freshDio.post(
        ApiEndpoints.refreshToken,
        data: {'refreshToken': storedRefresh},
      );

      final newAccess = res.data['data']['accessToken'] as String;
      final newRefresh =
          res.data['data']['refreshToken'] as String? ?? storedRefresh;
      await _storage.saveTokens(newAccess, newRefresh);

      _refreshing!.complete(newAccess);
      handler.resolve(await _retry(err.requestOptions, newAccess));
    } catch (e) {
      _refreshing!.completeError(e);
      await _clearAndLogout();
      handler.next(err);
    } finally {
      _refreshing = null;
    }
  }

  Future<Response<dynamic>> _retry(RequestOptions opts, String token) {
    opts.headers['Authorization'] = 'Bearer $token';
    opts.extra['_retried'] = true;
    return _dio.fetch(opts);
  }

  Future<void> _clearAndLogout() async {
    await _storage.clearTokens();
    onForceLogout?.call();
  }
}
