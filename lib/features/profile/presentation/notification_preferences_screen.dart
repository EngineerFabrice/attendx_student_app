import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/profile_api.dart';

class _Prefs {
  final bool sessionStart;
  final bool absenceAlert;
  final bool lowAttendance;
  final bool weeklyReport;

  _Prefs({
    required this.sessionStart,
    required this.absenceAlert,
    required this.lowAttendance,
    required this.weeklyReport,
  });

  factory _Prefs.defaults() => _Prefs(
        sessionStart: true,
        absenceAlert: true,
        lowAttendance: true,
        weeklyReport: false,
      );

  factory _Prefs.fromJson(Map<String, dynamic> j) => _Prefs(
        sessionStart: j['sessionStart'] as bool? ?? true,
        absenceAlert: j['absenceAlert'] as bool? ?? true,
        lowAttendance: j['lowAttendance'] as bool? ?? true,
        weeklyReport: j['weeklyReport'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
        'sessionStart': sessionStart,
        'absenceAlert': absenceAlert,
        'lowAttendance': lowAttendance,
        'weeklyReport': weeklyReport,
      };

  _Prefs copyWith({
    bool? sessionStart,
    bool? absenceAlert,
    bool? lowAttendance,
    bool? weeklyReport,
  }) =>
      _Prefs(
        sessionStart: sessionStart ?? this.sessionStart,
        absenceAlert: absenceAlert ?? this.absenceAlert,
        lowAttendance: lowAttendance ?? this.lowAttendance,
        weeklyReport: weeklyReport ?? this.weeklyReport,
      );
}

class NotificationPreferencesScreen extends ConsumerStatefulWidget {
  const NotificationPreferencesScreen({super.key});

  @override
  ConsumerState<NotificationPreferencesScreen> createState() =>
      _NotificationPreferencesScreenState();
}

class _NotificationPreferencesScreenState
    extends ConsumerState<NotificationPreferencesScreen> {
  final _api = ProfileApi();
  _Prefs _prefs = _Prefs.defaults();
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final res = await _api.getNotificationPreferences();
      if (mounted) {
        setState(() {
          _prefs = _Prefs.fromJson(res.data['data'] as Map<String, dynamic>);
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await _api.updateNotificationPreferences(_prefs.toJson());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Preferences saved'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to save. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Preferences'),
        actions: [
          if (_saving)
            const Padding(
              padding: EdgeInsets.all(14),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            TextButton(onPressed: _save, child: const Text('Save')),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                _PrefTile(
                  icon: Icons.notifications_active_outlined,
                  title: 'Session Started',
                  subtitle: 'Alert when your lecturer starts a class session',
                  value: _prefs.sessionStart,
                  onChanged: (v) =>
                      setState(() => _prefs = _prefs.copyWith(sessionStart: v)),
                ),
                _PrefTile(
                  icon: Icons.check_circle_outline,
                  title: 'Attendance Confirmed',
                  subtitle: 'Alert when your check-in is recorded',
                  value: _prefs.absenceAlert,
                  onChanged: (v) =>
                      setState(() => _prefs = _prefs.copyWith(absenceAlert: v)),
                ),
                _PrefTile(
                  icon: Icons.warning_amber_outlined,
                  title: 'Low Attendance Warning',
                  subtitle: 'Alert when your rate falls below 75%',
                  value: _prefs.lowAttendance,
                  onChanged: (v) =>
                      setState(() => _prefs = _prefs.copyWith(lowAttendance: v)),
                ),
                _PrefTile(
                  icon: Icons.summarize_outlined,
                  title: 'Weekly Summary',
                  subtitle: 'Receive a weekly attendance digest',
                  value: _prefs.weeklyReport,
                  onChanged: (v) =>
                      setState(() => _prefs = _prefs.copyWith(weeklyReport: v)),
                ),
              ],
            ),
    );
  }
}

class _PrefTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _PrefTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      secondary: Icon(icon, color: Theme.of(context).primaryColor),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      value: value,
      onChanged: onChanged,
    );
  }
}
