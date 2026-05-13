import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'mock_interceptor.dart';

class ApiClient {
  static const String baseUrl = 'https://api.attendx.ac.rw/v1';
  static const bool useMocks = true;
  
  late Dio _dio;

  ApiClient() {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Content-Type': 'application/json'},
    ));

    if (kDebugMode && useMocks) {
      _dio.interceptors.add(MockInterceptor());
    }
  }

  Dio get dio => _dio;
}