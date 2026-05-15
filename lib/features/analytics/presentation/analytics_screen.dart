import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/analytics_provider.dart';
import 'widgets/attendance_trend_chart.dart';
import '../../../../shared/widgets/main_bottom_nav.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analyticsState = ref.watch(analyticsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
      ),
      bottomNavigationBar: const MainBottomNav(currentIndex: 2),
      body: analyticsState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () =>
                  ref.read(analyticsProvider.notifier).loadAnalytics(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            const Text(
                              'Overall Attendance Rate',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${analyticsState.overallRate?.toInt() ?? 0}%',
                              style: const TextStyle(
                                  fontSize: 48, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            LinearProgressIndicator(
                              value: (analyticsState.overallRate ?? 0) / 100,
                              backgroundColor: Colors.grey.shade200,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                (analyticsState.overallRate ?? 0) >= 75
                                    ? Colors.green
                                    : Colors.orange,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    const Text(
                      'Attendance Trend',
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 200,
                      child: AttendanceTrendChart(
                          data: analyticsState.trendData),
                    ),

                    const SizedBox(height: 24),

                    const Text(
                      'Course Breakdown',
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 12),
                    ...analyticsState.courseStats.map((course) => Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  course.name,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  course.code,
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Expanded(
                                      child: LinearProgressIndicator(
                                        value: course.attendanceRate / 100,
                                        backgroundColor:
                                            Colors.grey.shade200,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                          course.attendanceRate >= 75
                                              ? Colors.green
                                              : Colors.orange,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${course.attendanceRate.toInt()}%',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '${course.presentSessions} / ${course.totalSessions} sessions present',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600),
                                ),
                              ],
                            ),
                          ),
                        )),
                  ],
                ),
              ),
            ),
    );
  }
}
