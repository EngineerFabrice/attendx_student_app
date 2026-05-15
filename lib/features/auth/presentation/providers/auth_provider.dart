import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/auth_repository.dart';
import '../../domain/user_model.dart';
import '../../domain/auth_state.dart';

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

class AuthNotifier extends StateNotifier<AuthState> {
  final _repository = AuthRepository();

  AuthNotifier() : super(const AuthInitial());

  Future<void> login(String email, String password) async {
    state = const AuthLoading();
    try {
      final data = await _repository.login(email, password);
      final user = UserModel.fromJson(data['user'] as Map<String, dynamic>);
      final tokens = data['tokens'] as Map<String, dynamic>;
      await _repository.saveUserData(
        user,
        tokens['accessToken'] as String,
        tokens['refreshToken'] as String,
      );
      state = AuthAuthenticated(user);
    } catch (e) {
      state = const AuthError('Login failed. Please check your credentials.');
    }
  }

  Future<void> logout() async {
    state = const AuthLoading();
    await _repository.logout();
    state = const AuthUnauthenticated();
  }

  Future<void> checkAuthStatus() async {
    state = const AuthLoading();
    final user = await _repository.getCurrentUser();
    if (user != null) {
      state = AuthAuthenticated(user);
    } else {
      state = const AuthUnauthenticated();
    }
  }
}
