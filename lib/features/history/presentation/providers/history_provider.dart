import 'package:flutter_riverpod/flutter_riverpod.dart';

class AttendanceRecord {
  final String id;
  final String status;
  final String? submissionMethod;
  final bool? geofencePassed;
  final DateTime markedAt;
  final SessionInfo session;
  
  AttendanceRecord({
    required this.id,
    required this.status,
    this.submissionMethod,
    this.geofencePassed,
    required this.markedAt,
    required this.session,
  });
}

class SessionInfo {
  final String sessionCode;
  final CourseInfo course;
  final ClassroomInfo classroom;
  final DateTime startedAt;
  
  SessionInfo({
    required this.sessionCode,
    required this.course,
    required this.classroom,
    required this.startedAt,
  });
}

class CourseInfo {
  final String code;
  final String name;
  
  CourseInfo({required this.code, required this.name});
}

class ClassroomInfo {
  final String name;
  
  ClassroomInfo({required this.name});
}

class HistoryState {
  final List<AttendanceRecord> records;
  final bool isLoading;
  
  HistoryState({this.records = const [], this.isLoading = false});
  
  HistoryState copyWith({List<AttendanceRecord>? records, bool? isLoading}) {
    return HistoryState(
      records: records ?? this.records,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

final historyProvider = StateNotifierProvider<HistoryNotifier, HistoryState>((ref) {
  return HistoryNotifier();
});

class HistoryNotifier extends StateNotifier<HistoryState> {
  HistoryNotifier() : super(HistoryState()) {
    loadHistory();
  }
  
  Future<void> loadHistory() async {
    state = state.copyWith(isLoading: true);
    
    await Future.delayed(const Duration(milliseconds: 500));
    
    final mockRecords = [
      AttendanceRecord(
        id: '1',
        status: 'present',
        submissionMethod: 'app',
        geofencePassed: true,
        markedAt: DateTime.now().subtract(const Duration(days: 1)),
        session: SessionInfo(
          sessionCode: 'AB3X9K',
          course: CourseInfo(code: 'CS301', name: 'Advanced Databases'),
          classroom: ClassroomInfo(name: 'LT-3'),
          startedAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
      ),
      AttendanceRecord(
        id: '2',
        status: 'absent',
        submissionMethod: null,
        geofencePassed: null,
        markedAt: DateTime.now().subtract(const Duration(days: 8)),
        session: SessionInfo(
          sessionCode: 'XY7K2P',
          course: CourseInfo(code: 'CS301', name: 'Advanced Databases'),
          classroom: ClassroomInfo(name: 'LT-3'),
          startedAt: DateTime.now().subtract(const Duration(days: 8)),
        ),
      ),
    ];
    
    state = HistoryState(records: mockRecords, isLoading: false);
  }
}