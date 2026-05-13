import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/storage/secure_storage.dart';
import '../../../core/utils/device_fingerprint.dart';
import '../domain/user_model.dart';

class AuthRepository {
  final Dio _dio = ApiClient().dio;
  final SecureStorage _storage = SecureStorage();

  Future<Map<String, dynamic>> login(String email, String password) async {
    final fingerprint = await _storage.getOrCreateDeviceFingerprint();
    
    final response = await _dio.post(ApiEndpoints.login, data: {
      'email': email,
      'password': password,
      'deviceFingerprint': fingerprint,
    });
    
    return response.data['data'];
  }

  Future<void> logout() async {
    await _storage.clearTokens();
  }

  Future<UserModel?> getCurrentUser() async {
    final userJson = await _storage.getUser();
    if (userJson == null) return null;
    // Parse JSON here
    return null;
  }
}