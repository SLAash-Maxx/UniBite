import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _service = AuthService();

  UserModel? _currentUser;
  bool       _isLoading  = false;
  String?    _errorMessage;

  UserModel? get currentUser  => _currentUser;
  bool       get isLoading    => _isLoading;
  bool       get isLoggedIn   => _currentUser != null;
  String?    get errorMessage => _errorMessage;

  void _setLoading(bool v) {
    _isLoading = v;
    notifyListeners();
  }

  void _setError(String? msg) {
    _errorMessage = msg;
    notifyListeners();
  }

  /// Check existing token on app launch
  Future<void> checkSession() async {
    try {
      _currentUser = await _service.getStoredUser();
      notifyListeners();
    } catch (_) {
      _currentUser = null;
    }
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _setError(null);
    try {
      _currentUser = await _service.login(
          email: email, password: password);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> register({
    required String fullName,
    required String studentId,
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _setError(null);
    try {
      _currentUser = await _service.register(
        fullName:  fullName,
        studentId: studentId,
        email:     email,
        password:  password,
      );
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    await _service.logout();
    _currentUser = null;
    notifyListeners();
  }
}
