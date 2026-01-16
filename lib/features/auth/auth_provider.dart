import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../core/api_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

class AuthState {
  final bool isAuthenticated;
  final bool isLoading;
  final String? error;
  final Map<String, dynamic>? user;

  AuthState({
    this.isAuthenticated = false,
    this.isLoading = false,
    this.error,
    this.user,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    String? error,
    Map<String, dynamic>? user,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      user: user ?? this.user,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState()) {
    checkAuth();
  }

  final _api = ApiClient();

  Future<void> checkAuth() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token != null) {
      state = state.copyWith(isAuthenticated: true);
    }
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _api.client.post('/auth/login', data: {
        'email': email,
        'password': password,
      });

      final token = response.data['token'];
      final user = response.data['user'];

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token);

      state = state.copyWith(
        isLoading: false, 
        isAuthenticated: true,
        user: user,
      );
      return true;
    } on DioException catch (e) {
      print('LOGIN ERROR: ${e.response?.data ?? e.message}');
      final msg = e.response?.data['message'] ?? 'Invalid credentials or Connection Error';
      state = state.copyWith(isLoading: false, error: msg);
      return false;
    } catch (e) {
      print('LOGIN ERROR: $e');
      state = state.copyWith(isLoading: false, error: 'An unexpected error occurred');
      return false;
    }
  }

  Future<bool> register(String name, String email, String password, String confirmPassword) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _api.client.post('/auth/register', data: {
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': confirmPassword,
      });

      final token = response.data['token'];
      final user = response.data['user'];

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token);

      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        user: user,
      );
      return true;
    } on DioException catch (e) {
      print('REGISTER ERROR: ${e.response?.data ?? e.message}');
      final msg = e.response?.data['message'] ?? 'Registration failed. Check details.';
      state = state.copyWith(isLoading: false, error: msg);
      return false;
    } catch (e) {
      print('REGISTER ERROR: $e');
      state = state.copyWith(isLoading: false, error: 'An unexpected error occurred');
      return false;
    }
  }

  Future<void> refreshProfile() async {
    try {
      final response = await _api.client.get('/profile');
      state = state.copyWith(user: response.data);
    } catch (e) {
      print('REFRESH PROFILE ERROR: $e');
    }
  }

  void updateUser(Map<String, dynamic> user) {
    state = state.copyWith(user: user);
  }

  Future<void> logout() async {
    try {
      await _api.client.post('/auth/logout');
    } catch (_) {}
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    state = AuthState();
  }
}
