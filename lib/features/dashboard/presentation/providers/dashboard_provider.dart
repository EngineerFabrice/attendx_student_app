import 'package:flutter_riverpod/flutter_riverpod.dart';

class DashboardProfile {
  final String id;
  final String fullName;
  final String? regNumber;
  final int enrolledCourses;
  final double attendanceRate;
  
  DashboardProfile({
    required this.id,
    required this.fullName,
    this.regNumber,
    required this.enrolledCourses,
    required this.attendanceRate,
  });
}

class TodaySession {
  final String id;
  final String sessionCode;
  final String status;
  final bool checkinOpen;
  final Course course;
  final Classroom classroom;
  final DateTime startedAt;
  final DateTime expiresAt;
  
  TodaySession({
    required this.id,
    required this.sessionCode,
    required this.status,
    required this.checkinOpen,
    required this.course,
    required this.classroom,
    required this.startedAt,
    required this.expiresAt,
  });
}

class Course {
  final String code;
  final String name;
  
  Course({required this.code, required this.name});
}

class Classroom {
  final String name;
  final double latitude;
  final double longitude;
  final double radiusM;
  
  Classroom({
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.radiusM,
  });
}

class DashboardState {
  final DashboardProfile? profile;
  final List<TodaySession> todaySessions;
  final double? overallAttendanceRate;
  final bool isLoading;
  
  DashboardState({
    this.profile,
    this.todaySessions = const [],
    this.overallAttendanceRate,
    this.isLoading = false,
  });
  
  DashboardState copyWith({
    DashboardProfile? profile,
    List<TodaySession>? todaySessions,
    double? overallAttendanceRate,
    bool? isLoading,
  }) {
    return DashboardState(
      profile: profile ?? this.profile,
      todaySessions: todaySessions ?? this.todaySessions,
      overallAttendanceRate: overallAttendanceRate ?? this.overallAttendanceRate,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

final dashboardProvider = StateNotifierProvider<DashboardNotifier, DashboardState>((ref) {
  return DashboardNotifier();
});

class DashboardNotifier extends StateNotifier<DashboardState> {
  DashboardNotifier() : super(DashboardState()) {
    loadDashboard();
  }
  
  Future<void> loadDashboard() async {
    state = state.copyWith(isLoading: true);
    
    // Mock data - will replace with API call later
    await Future.delayed(const Duration(milliseconds: 500));
    
    final mockProfile = DashboardProfile(
      id: '1',
      fullName: 'Fabrice NDAYISABA',
      regNumber: '223008047',
      enrolledCourses: 5,
      attendanceRate: 87.5,
    );
    
    final mockSession = TodaySession(
      id: 'session-1',
      sessionCode: 'AB3X9K',
      status: 'active',
      checkinOpen: true,
      course: Course(code: 'CS301', name: 'Advanced Databases'),
      classroom: Classroom(
        name: 'LT-3',
        latitude: -1.9441,
        longitude: 30.0619,
        radiusM: 30.0,
      ),
      startedAt: DateTime.now(),
      expiresAt: DateTime.now().add(const Duration(minutes: 90)),
    );
    
    state = DashboardState(
      profile: mockProfile,
      todaySessions: [mockSession],
      overallAttendanceRate: 87.5,
      isLoading: false,
    );
  }
  
  Future<void> refresh() async {
    await loadDashboard();
  }
}