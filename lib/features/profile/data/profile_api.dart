import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';

class ProfileApi {
  final Dio _dio = ApiClient().dio;

  Future<Response> getNotificationPreferences() =>
      _dio.get(ApiEndpoints.notificationPreferences);

  Future<Response> updateNotificationPreferences(Map<String, dynamic> data) =>
      _dio.put(ApiEndpoints.notificationPreferences, data: data);
}
