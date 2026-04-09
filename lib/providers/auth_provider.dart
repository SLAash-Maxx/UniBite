import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _service = AuthService();

  UserModel? _currentUser;
  bool    _isLoading    = false;
  String? _errorMessage;

  UserModel? get currentUser   => _currentUser;
  bool       get isLoading     => _isLoading;
  bool       get isLoggedIn    => _currentUser != null;
  String?    get errorMessage  => _errorMessage;

  Future<void> checkSession() async {
    try { _currentUser = await _service.getStoredUser(); notifyListeners(); }
    catch (_) { _currentUser = null; }
  }

  Future<bool> login({required String email, required String password}) async {
    _isLoading = true; _errorMessage = null; notifyListeners();
    try { _currentUser = await _service.login(email: email, password: password); notifyListeners(); return true; }
    catch (e) { _errorMessage = e.toString().replaceAll('Exception: ', ''); return false; }
    finally { _isLoading = false; notifyListeners(); }
  }

  Future<bool> register({required String fullName, required String studentId, required String email, required String password}) async {
    _isLoading = true; _errorMessage = null; notifyListeners();
    try { _currentUser = await _service.register(fullName: fullName, studentId: studentId, email: email, password: password); notifyListeners(); return true; }
    catch (e) { _errorMessage = e.toString().replaceAll('Exception: ', ''); return false; }
    finally { _isLoading = false; notifyListeners(); }
  }

  Future<bool> sendPasswordReset(String email) async {
    _isLoading = true; _errorMessage = null; notifyListeners();
    try { await _service.sendPasswordResetEmail(email); return true; }
    catch (e) { _errorMessage = e.toString().replaceAll('Exception: ', ''); return false; }
    finally { _isLoading = false; notifyListeners(); }
  }
