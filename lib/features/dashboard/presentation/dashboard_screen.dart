import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/dashboard_provider.dart';
import 'widgets/active_session_card.dart';
import 'widgets/attendance_summary_card.dart';
import '../../../../shared/widgets/main_bottom_nav.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardState = ref.watch(dashboardProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => Navigator.pushNamed(context, '/profile'),
          ),
        ],
      ),
      body: dashboardState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => ref.read(dashboardProvider.notifier).refresh(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hello, ${dashboardState.profile?.fullName.split(' ').first ?? 'Student'}!',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Reg: ${dashboardState.profile?.regNumber ?? 'N/A'}',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 24),
                    
                    AttendanceSummaryCard(
                      rate: dashboardState.overallAttendanceRate ?? 0,
                    ),
                    const SizedBox(height: 24),
                    
                    if (dashboardState.todaySessions.isNotEmpty) ...[
                      const Text(
                        'Active Sessions',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 12),
                      ...dashboardState.todaySessions.map((session) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: ActiveSessionCard(session: session),
                      )),
                    ] else ...[
                      _buildEmptySessionsCard(),
                    ],
                    
                    const SizedBox(height: 24),
                    
                    _buildStatsRow(dashboardState),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: const MainBottomNav(currentIndex: 0),
    );
  }

  Widget _buildEmptySessionsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(Icons.event_busy, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text(
              'No active sessions',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 4),
            Text(
              'Check back during class time',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatsRow(DashboardState state) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Enrolled Courses',
            '${state.profile?.enrolledCourses ?? 0}',
            Icons.book,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Attendance',
            '${state.overallAttendanceRate?.toInt() ?? 0}%',
            Icons.trending_up,
            Colors.green,
          ),
        ),
      ],
    );
  }
  
  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              title,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
  
}