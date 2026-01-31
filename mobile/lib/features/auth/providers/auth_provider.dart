import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/constants/app_constants.dart';

/// Auth state enum
enum AuthStatus {
  initial,
  authenticated,
  unauthenticated,
  loading,
}

/// Auth state class
class AuthState {
  final AuthStatus status;
  final String? userId;
  final String? accessToken;
  final bool onboardingComplete;
  final String? error;

  const AuthState({
    this.status = AuthStatus.initial,
    this.userId,
    this.accessToken,
    this.onboardingComplete = false,
    this.error,
  });

  AuthState copyWith({
    AuthStatus? status,
    String? userId,
    String? accessToken,
    bool? onboardingComplete,
    String? error,
  }) {
    return AuthState(
      status: status ?? this.status,
      userId: userId ?? this.userId,
      accessToken: accessToken ?? this.accessToken,
      onboardingComplete: onboardingComplete ?? this.onboardingComplete,
      error: error,
    );
  }

  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isLoading => status == AuthStatus.loading;
}

/// Auth provider notifier
class AuthNotifier extends StateNotifier<AuthState> {
  final FlutterSecureStorage _storage;

  AuthNotifier(this._storage) : super(const AuthState()) {
    _checkAuthStatus();
  }

  /// Check if user is authenticated
  Future<void> _checkAuthStatus() async {
    state = state.copyWith(status: AuthStatus.loading);

    try {
      final accessToken = await _storage.read(key: AppConstants.accessTokenKey);
      final userId = await _storage.read(key: AppConstants.userIdKey);
      final onboarding = await _storage.read(key: AppConstants.onboardingCompleteKey);

      if (accessToken != null && userId != null) {
        state = AuthState(
          status: AuthStatus.authenticated,
          userId: userId,
          accessToken: accessToken,
          onboardingComplete: onboarding == 'true',
        );
      } else {
        state = const AuthState(status: AuthStatus.unauthenticated);
      }
    } catch (e) {
      state = AuthState(
        status: AuthStatus.unauthenticated,
        error: e.toString(),
      );
    }
  }

  /// Sign in with email and password
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, error: null);

    try {
      // TODO: Call actual API
      await Future.delayed(const Duration(seconds: 1));

      // Mock successful login
      const mockUserId = 'user_123';
      const mockToken = 'mock_access_token';

      await _storage.write(key: AppConstants.accessTokenKey, value: mockToken);
      await _storage.write(key: AppConstants.userIdKey, value: mockUserId);

      state = const AuthState(
        status: AuthStatus.authenticated,
        userId: mockUserId,
        accessToken: mockToken,
        onboardingComplete: true,
      );
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        error: e.toString(),
      );
    }
  }

  /// Sign up with email and password
  Future<void> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, error: null);

    try {
      // TODO: Call actual API
      await Future.delayed(const Duration(seconds: 1));

      // Mock successful registration
      const mockUserId = 'user_123';
      const mockToken = 'mock_access_token';

      await _storage.write(key: AppConstants.accessTokenKey, value: mockToken);
      await _storage.write(key: AppConstants.userIdKey, value: mockUserId);
      await _storage.write(key: AppConstants.onboardingCompleteKey, value: 'false');

      state = const AuthState(
        status: AuthStatus.authenticated,
        userId: mockUserId,
        accessToken: mockToken,
        onboardingComplete: false,
      );
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        error: e.toString(),
      );
    }
  }

  /// Sign out
  Future<void> signOut() async {
    state = state.copyWith(status: AuthStatus.loading);

    await _storage.delete(key: AppConstants.accessTokenKey);
    await _storage.delete(key: AppConstants.refreshTokenKey);
    await _storage.delete(key: AppConstants.userIdKey);

    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  /// Complete onboarding
  Future<void> completeOnboarding() async {
    await _storage.write(key: AppConstants.onboardingCompleteKey, value: 'true');
    state = state.copyWith(onboardingComplete: true);
  }
}

/// Secure storage provider
final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

/// Auth provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final storage = ref.watch(secureStorageProvider);
  return AuthNotifier(storage);
});
