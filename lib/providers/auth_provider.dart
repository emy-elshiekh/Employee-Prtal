import 'package:flutter/foundation.dart';

import '../models/employee.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider({required AuthService authService}) : _authService = authService;

  final AuthService _authService;

  Employee? employee;
  bool bootstrapping = true;
  bool loading = false;
  String? error;

  bool get isAuthenticated => employee != null;

  Future<void> bootstrap() async {
    bootstrapping = true;
    notifyListeners();
    employee = await _authService.restoreSession();
    bootstrapping = false;
    notifyListeners();
  }

  Future<bool> login(String employeeId, String password) async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      final result = await _authService.login(
        employeeId: employeeId,
        password: password,
      );
      employee = result.employee;
      loading = false;
      notifyListeners();
      return true;
    } catch (e) {
      error = e.toString();
      loading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    employee = null;
    notifyListeners();
  }
}
