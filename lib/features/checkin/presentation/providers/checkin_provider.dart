import 'package:flutter_riverpod/flutter_riverpod.dart';

final checkinProvider = StateNotifierProvider<CheckinNotifier, CheckinState>((ref) {
  return CheckinNotifier();
});

class CheckinState {
  final bool isCheckingIn;
  final String? error;
  
  CheckinState({this.isCheckingIn = false, this.error});
  
  CheckinState copyWith({bool? isCheckingIn, String? error}) {
    return CheckinState(
      isCheckingIn: isCheckingIn ?? this.isCheckingIn,
      error: error ?? this.error,
    );
  }
}

class CheckinNotifier extends StateNotifier<CheckinState> {
  CheckinNotifier() : super(CheckinState());

  Future<bool> checkIn({
    required String sessionId,
    required double latitude,
    required double longitude,
  }) async {
    state = state.copyWith(isCheckingIn: true, error: null);
    
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    
    // Mock success
    state = state.copyWith(isCheckingIn: false);
    return true;
  }
}