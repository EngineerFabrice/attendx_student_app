import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/user_model.dart';
import '../../domain/auth_state.dart';

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthInitial());

  // Login with email and password
  Future<void> login(String email, String password) async {
    state = const AuthLoading();
    
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    
    // Mock user data - In real app, this comes from API
    final user = UserModel(
      id: '550e8400-e29b-41d4-a716-446655440000',
      fullName: 'Fabrice NDAYISABA',
      email: email,
      phone: '+250788000000',
      role: 'student',
      regNumber: '223008047',
      isActive: true,
      createdAt: DateTime.now(),
    );
    
    state = AuthAuthenticated(user);
  }

  // Register new user
  Future<void> register(UserModel user, String password) async {
    state = const AuthLoading();
    
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    
    state = AuthAuthenticated(user);
  }

  // Logout user
  Future<void> logout() async {
    state = const AuthLoading();
    
    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 500));
    
    state = const AuthUnauthenticated();
  }

  // Check if user is already logged in
  Future<void> checkAuthStatus() async {
    state = const AuthLoading();
    
    // Simulate checking stored token
    await Future.delayed(const Duration(milliseconds: 500));
    
    // For demo, we'll return unauthenticated
    // In real app, check stored token and validate with backend
    state = const AuthUnauthenticated();
  }
}