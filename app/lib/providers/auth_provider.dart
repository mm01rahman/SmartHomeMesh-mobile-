import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/api_service.dart';

class AuthState {
  final bool isAuthenticated;
  final String? email;
  const AuthState({required this.isAuthenticated, this.email});
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState(isAuthenticated: false));
  final _storage = const FlutterSecureStorage();
  final _api = ApiService();
  final _controller = StreamController<AuthState>.broadcast();
  Stream<AuthState> get stream => _controller.stream;

  Future<void> init() async {
    final token = await _storage.read(key: 'accessToken');
    if (token != null) state = const AuthState(isAuthenticated: true);
  }

  Future<void> signup(String email, String password, String name) async {
    final res = await _api.post('/auth/signup', {'email': email, 'password': password, 'name': name});
    await _handleAuthResponse(email, res.data);
  }

  Future<void> signin(String email, String password) async {
    final res = await _api.post('/auth/signin', {'email': email, 'password': password});
    await _handleAuthResponse(email, res.data);
  }

  Future<void> logout() async {
    await _storage.deleteAll();
    state = const AuthState(isAuthenticated: false);
    _controller.add(state);
  }

  Future<void> _handleAuthResponse(String email, Map data) async {
    await _storage.write(key: 'accessToken', value: data['accessToken']);
    await _storage.write(key: 'refreshToken', value: data['refreshToken']);
    state = AuthState(isAuthenticated: true, email: email);
    _controller.add(state);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final notifier = AuthNotifier();
  notifier.init();
  return notifier;
});
