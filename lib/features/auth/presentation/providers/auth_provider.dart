import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/auth_repository.dart';
import '../../domain/user_model.dart';
import '../../domain/auth_state.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/services/socket_service.dart';
import '../../../../core/services/notification_service.dart';
import '../../../dashboard/presentation/providers/dashboard_provider.dart';
import '../../../history/presentation/providers/history_provider.dart';
import '../../../analytics/presentation/providers/analytics_provider.dart';
import '../../../checkin/presentation/providers/checkin_provider.dart';

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref);
});

class AuthNotifier extends StateNotifier<AuthState> {
  final Ref _ref;
  final _repository = AuthRepository();

  AuthNotifier(this._ref) : super(const AuthInitial()) {
    ApiClient.onForceLogout = () {
      SocketService().disconnect();
      state = const AuthUnauthenticated();
    };
  }

  Future<void> login(String email, String password) async {
    state = const AuthLoading();
    try {
      final data = await _repository.login(email, password);
      final user = UserModel.fromJson(data['user'] as Map<String, dynamic>);
      final tokens = data['tokens'] as Map<String, dynamic>;
      final accessToken = tokens['accessToken'] as String;
      final refreshToken = tokens['refreshToken'] as String;

      await _repository.saveUserData(user, accessToken, refreshToken);

      SocketService().connect(accessToken);
      _wireSocketEvents();

      final fcmToken = await NotificationService.getToken();
      if (fcmToken != null) await _repository.registerDeviceToken(fcmToken);

      _registerTokenRefreshCallback();
      state = AuthAuthenticated(user);
    } catch (e) {
      state = const AuthError('Login failed. Please check your credentials.');
    }
  }

  Future<void> logout() async {
    state = const AuthLoading();
    SocketService().disconnect();
    await _repository.logout();
    // Clear cached data so a subsequent login shows fresh data, not the
    // previous user's records.
    _ref.invalidate(dashboardProvider);
    _ref.invalidate(historyProvider);
    _ref.invalidate(analyticsProvider);
    _ref.invalidate(checkinProvider);
    state = const AuthUnauthenticated();
  }

  Future<void> checkAuthStatus() async {
    state = const AuthLoading();
    try {
      final user = await _repository.getCurrentUser();
      if (user != null) {
        final token = await _repository.getAccessToken();
        if (token != null) {
          SocketService().connect(token);
          _wireSocketEvents();
        }

        final fcmToken = await NotificationService.getToken();
        if (fcmToken != null) await _repository.registerDeviceToken(fcmToken);

        _registerTokenRefreshCallback();
        state = AuthAuthenticated(user);
      } else {
        state = const AuthUnauthenticated();
      }
    } catch (_) {
      state = const AuthUnauthenticated();
    }
  }

  // ── Socket → UI wiring ────────────────────────────────────────────────────

  void _wireSocketEvents() {
    final socket = SocketService();

    socket.onSessionStarted((data) {
      // Refresh dashboard so the new active session card appears immediately.
      _ref.read(dashboardProvider.notifier).loadDashboard();

      final courseMap = data['course'] as Map<String, dynamic>?;
      final classMap  = data['classroom'] as Map<String, dynamic>?;
      final courseName = courseMap?['name'] as String? ?? 'a class';
      final room       = classMap?['name'] as String? ?? '';
      NotificationService.showSessionStarted(courseName, room);
    });

    socket.onSessionClosed((_) {
      _ref.read(dashboardProvider.notifier).loadDashboard();
    });

    socket.onAttendanceUpdate((_) {
      // Keep dashboard attendance rate in sync after any update.
      _ref.read(dashboardProvider.notifier).loadDashboard();
    });
  }

  void _registerTokenRefreshCallback() {
    NotificationService.setTokenRefreshCallback((newToken) {
      _repository.registerDeviceToken(newToken);
    });
  }
}
