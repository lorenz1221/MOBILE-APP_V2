import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/user.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  User? _user;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;
  bool get isAdmin => _user?.role.toLowerCase() == 'admin';
  bool get isStaff => _user?.role.toLowerCase() == 'staff';
  bool get isUser => _user?.role.toLowerCase() == 'user';

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.login(email, password);
      if (response.status == 'Success') {
        await fetchUser();
        _isLoading = false;
        notifyListeners();
        return true;
      }

      _error = response.message.isNotEmpty ? response.message : 'Login failed. Please verify your credentials.';
    } catch (e) {
      _error = 'Login failed: $e';
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> register(
    String name,
    String email,
    String password,
    String passwordConfirmation,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.register(name, email, password, passwordConfirmation);
      if (response.status == 'Success') {
        await fetchUser();
        _isLoading = false;
        notifyListeners();
        return true;
      }

      _error = response.message.isNotEmpty ? response.message : 'Registration failed. Please try again.';
    } catch (e) {
      _error = 'Registration failed: $e';
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<void> fetchUser() async {
    _error = null;
    try {
      final response = await _apiService.getMe();
      if (response.status == 'Success' && response.data != null) {
        _user = response.data;
      } else {
        _user = null;
        _error = response.message;
        await _apiService.removeToken();
      }
    } catch (e) {
      _user = null;
      _error = 'Failed to fetch user: $e';
      await _apiService.removeToken();
    }
    notifyListeners();
  }

  Future<void> logout() async {
    await _apiService.logout();
    _user = null;
    _error = null;
    notifyListeners();
  }

  Future<bool> checkAuth() async {
    try {
      final token = await _apiService.getToken();
      if (token != null) {
        await fetchUser();
        return _user != null;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}