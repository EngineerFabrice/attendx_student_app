import 'package:dio/dio.dart';

class MockInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Auth mock
    if (options.path.contains('/auth/login')) {
      return handler.resolve(Response(
        requestOptions: options,
        statusCode: 200,
        data: {
          'success': true,
          'data': {
            'user': {
              'id': '550e8400-e29b-41d4-a716-446655440000',
              'fullName': 'Fabrice NDAYISABA',
              'email': 'student@attendx.com',
              'role': 'student',
              'regNumber': '223008047',
              'isActive': true,
              'createdAt': DateTime.now().toIso8601String(),
            },
            'tokens': {
              'accessToken': 'mock-access-token',
              'refreshToken': 'mock-refresh-token',
              'expiresIn': 3600,
            },
          },
        },
      ));
    }

    // Dashboard mock
    if (options.path.contains('/students/dashboard')) {
      return handler.resolve(Response(
        requestOptions: options,
        statusCode: 200,
        data: {
          'success': true,
          'data': {
            'profile': {
              'id': 'student-1',
              'fullName': 'Fabrice NDAYISABA',
              'email': 'student@attendx.com',
              'role': 'student',
              'regNumber': '223008047',
              'enrolledCourses': 5,
              'attendanceRate': 87.5,
            },
            'overallAttendanceRate': 87.5,
            'todaySessions': [
              {
                'id': 'session-1',
                'sessionCode': 'AB3X9K',
                'status': 'active',
                'checkinOpen': true,
                'course': {'code': 'CS301', 'name': 'Advanced Databases'},
                'classroom': {
                  'name': 'LT-3',
                  'latitude': -1.9441,
                  'longitude': 30.0619,
                  'radiusM': 30.0,
                },
                'startedAt': DateTime.now().toIso8601String(),
                'expiresAt': DateTime.now().add(const Duration(minutes: 90)).toIso8601String(),
              },
            ],
            'recentAttendance': [],
          },
        },
      ));
    }

    // Check-in mock
    if (options.path.contains('/checkin')) {
      return handler.resolve(Response(
        requestOptions: options,
        statusCode: 200,
        data: {
          'success': true,
          'data': {
            'status': 'checked_in',
            'distanceM': 18.4,
            'checkedInAt': DateTime.now().toIso8601String(),
            'message': 'You have been checked in successfully.',
          },
        },
      ));
    }

    // History mock
    if (options.path.contains('/attendance/history')) {
      return handler.resolve(Response(
        requestOptions: options,
        statusCode: 200,
        data: {
          'success': true,
          'data': [
            {
              'id': 'att-1',
              'status': 'present',
              'submissionMethod': 'app',
              'geofencePassed': true,
              'markedAt': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
              'session': {
                'sessionCode': 'AB3X9K',
                'course': {'code': 'CS301', 'name': 'Advanced Databases'},
                'classroom': {'name': 'LT-3'},
                'startedAt': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
              },
            },
          ],
          'meta': {'page': 1, 'limit': 20, 'total': 45},
        },
      ));
    }

    // Analytics trends mock
    if (options.path.contains('/attendance/trends')) {
      return handler.resolve(Response(
        requestOptions: options,
        statusCode: 200,
        data: {
          'success': true,
          'data': [
            {'sessionDate': '2026-03-10', 'status': 'present', 'courseName': 'Advanced Databases'},
            {'sessionDate': '2026-03-17', 'status': 'absent', 'courseName': 'Advanced Databases'},
            {'sessionDate': '2026-03-24', 'status': 'present', 'courseName': 'Advanced Databases'},
          ],
        },
      ));
    }

    // Courses mock
    if (options.path.contains('/students/courses')) {
      return handler.resolve(Response(
        requestOptions: options,
        statusCode: 200,
        data: {
          'success': true,
          'data': [
            {'id': 'c1', 'code': 'CS301', 'name': 'Advanced Databases', 'credits': 3},
            {'id': 'c2', 'code': 'CS201', 'name': 'Data Structures', 'credits': 3},
          ],
        },
      ));
    }

    // Active sessions mock
    if (options.path.contains('/students/sessions/active')) {
      return handler.resolve(Response(
        requestOptions: options,
        statusCode: 200,
        data: {
          'success': true,
          'data': [
            {
              'id': 'session-1',
              'sessionCode': 'AB3X9K',
              'status': 'active',
              'checkinOpen': true,
              'course': {'code': 'CS301', 'name': 'Advanced Databases'},
              'classroom': {'name': 'LT-3', 'latitude': -1.9441, 'longitude': 30.0619, 'radiusM': 30.0},
              'startedAt': DateTime.now().toIso8601String(),
              'expiresAt': DateTime.now().add(const Duration(minutes: 90)).toIso8601String(),
            },
          ],
        },
      ));
    }

    handler.next(options);
  }
}