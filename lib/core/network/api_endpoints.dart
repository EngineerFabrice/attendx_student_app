class ApiEndpoints {
  // Auth
  static const String login = '/auth/login';
  static const String refresh = '/auth/refresh';
  static const String logout = '/auth/logout';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String changePassword = '/auth/change-password';
  
  // Student
  static const String studentDashboard = '/students/dashboard';
  static const String studentHistory = '/students/attendance/history';
  static const String studentTrends = '/students/attendance/trends';
  static const String studentCourses = '/students/courses';
  static const String activeSessions = '/students/sessions/active';
  
  // Check-in
  static String checkin(String sessionId) => '/sessions/$sessionId/checkin';
  
  // Session
  static const String sessions = '/sessions';
  static String sessionDetails(String sessionId) => '/sessions/$sessionId';
  static String closeSession(String sessionId) => '/sessions/$sessionId/close';
  static String sessionCheckins(String sessionId) => '/sessions/$sessionId/checkins';
  
  // Analytics
  static String courseSummary(String courseId) => '/analytics/courses/$courseId/summary';
  static String courseStudents(String courseId) => '/analytics/courses/$courseId/students';
  static const String atRisk = '/analytics/at-risk';
  static const String lecturerDashboard = '/analytics/lecturer/dashboard';
  
  // Profile
  static const String profile = '/users/me';
  static const String notificationPreferences = '/users/me/notification-preferences';
  static const String devices = '/devices';
}