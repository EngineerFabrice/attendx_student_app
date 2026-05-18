import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/dashboard_provider.dart';
import 'widgets/active_session_card.dart';
import 'widgets/attendance_summary_card.dart';
import '../../../../shared/widgets/main_bottom_nav.dart';
import '../../../../core/services/notification_service.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Handle deep-link from a notification tap (app was launched or brought to foreground).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final pending = NotificationService.consumePendingRoute();
      if (pending != null && mounted) {
        Navigator.pushNamed(context, pending.route);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(dashboardProvider);

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
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.error != null && state.profile == null
              ? _ErrorView(
                  message: state.error!,
                  onRetry: () =>
                      ref.read(dashboardProvider.notifier).loadDashboard(),
                )
              : RefreshIndicator(
              onRefresh: () => ref.read(dashboardProvider.notifier).refresh(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Greeting
                    Text(
                      'Hello, ${state.profile?.fullName.split(' ').first ?? 'Student'}!',
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Reg: ${state.profile?.regNumber ?? 'N/A'}',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 24),

                    // Attendance summary
                    AttendanceSummaryCard(
                      rate: state.overallAttendanceRate ?? 0,
                    ),
                    const SizedBox(height: 24),

                    // Stats row
                    Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            title: 'Courses',
                            value: '${state.profile?.enrolledCourses ?? 0}',
                            icon: Icons.book_outlined,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatCard(
                            title: 'Attendance',
                            value:
                                '${state.overallAttendanceRate?.toInt() ?? 0}%',
                            icon: Icons.trending_up,
                            color: (state.overallAttendanceRate ?? 0) >= 75
                                ? Colors.green
                                : Colors.orange,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Today's Classes
                    const Text(
                      "Today's Classes",
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 12),

                    if (state.todaySessions.isEmpty)
                      _EmptyClassesCard()
                    else
                      ...state.todaySessions.map((session) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: ActiveSessionCard(session: session),
                          )),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: const MainBottomNav(currentIndex: 0),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wifi_off_rounded, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyClassesCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(Icons.event_busy, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text('No classes today',
                style: TextStyle(color: Colors.grey.shade600)),
            const SizedBox(height: 4),
            Text('Check back during class time',
                style:
                    TextStyle(fontSize: 12, color: Colors.grey.shade500)),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 12),
            Text(value,
                style: const TextStyle(
                    fontSize: 24, fontWeight: FontWeight.bold)),
            Text(title,
                style: TextStyle(
                    color: Colors.grey.shade600, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
