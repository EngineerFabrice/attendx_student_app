import 'package:flutter_riverpod/flutter_riverpod.dart';

class TrendDataPoint {
  final DateTime date;
  final String status;
  final String courseName;
  
  TrendDataPoint({required this.date, required this.status, required this.courseName});
}

class CourseStat {
  final String id;
  final String code;
  final String name;
  final double attendanceRate;
  final int totalSessions;
  final int presentSessions;
  
  CourseStat({
    required this.id,
    required this.code,
    required this.name,
    required this.attendanceRate,
    required this.totalSessions,
    required this.presentSessions,
  });
}

class AnalyticsState {
  final double? overallRate;
  final List<TrendDataPoint> trendData;
  final List<CourseStat> courseStats;
  final bool isLoading;
  
  AnalyticsState({
    this.overallRate,
    this.trendData = const [],
    this.courseStats = const [],
    this.isLoading = false,
  });
  
  AnalyticsState copyWith({
    double? overallRate,
    List<TrendDataPoint>? trendData,
    List<CourseStat>? courseStats,
    bool? isLoading,
  }) {
    return AnalyticsState(
      overallRate: overallRate ?? this.overallRate,
      trendData: trendData ?? this.trendData,
      courseStats: courseStats ?? this.courseStats,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

final analyticsProvider = StateNotifierProvider<AnalyticsNotifier, AnalyticsState>((ref) {
  return AnalyticsNotifier();
});

class AnalyticsNotifier extends StateNotifier<AnalyticsState> {
  AnalyticsNotifier() : super(AnalyticsState()) {
    loadAnalytics();
  }
  
  Future<void> loadAnalytics() async {
    state = state.copyWith(isLoading: true);
    
    await Future.delayed(const Duration(milliseconds: 500));
    
    final mockTrendData = [
      TrendDataPoint(date: DateTime(2026, 3, 10), status: 'present', courseName: 'Advanced Databases'),
      TrendDataPoint(date: DateTime(2026, 3, 17), status: 'absent', courseName: 'Advanced Databases'),
      TrendDataPoint(date: DateTime(2026, 3, 24), status: 'present', courseName: 'Advanced Databases'),
      TrendDataPoint(date: DateTime(2026, 4, 1), status: 'present', courseName: 'Data Structures'),
      TrendDataPoint(date: DateTime(2026, 4, 8), status: 'present', courseName: 'Data Structures'),
      TrendDataPoint(date: DateTime(2026, 4, 15), status: 'absent', courseName: 'Data Structures'),
    ];
    
    final mockCourseStats = [
      CourseStat(
        id: '1',
        code: 'CS301',
        name: 'Advanced Databases',
        attendanceRate: 83.3,
        totalSessions: 12,
        presentSessions: 10,
      ),
      CourseStat(
        id: '2',
        code: 'CS201',
        name: 'Data Structures',
        attendanceRate: 71.4,
        totalSessions: 14,
        presentSessions: 10,
      ),
    ];
    
    state = AnalyticsState(
      overallRate: 77.5,
      trendData: mockTrendData,
      courseStats: mockCourseStats,
      isLoading: false,
    );
  }
}