import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';

class CheckinApi {
  final Dio _dio = ApiClient().dio;

  Future<Response> checkIn(String sessionId, Map<String, dynamic> data) {
    return _dio.post('/sessions/$sessionId/checkin', data: data);
  }
}