import 'dart:convert';

import '../core/constants/api_constants.dart';
import '../models/employee.dart';
import 'api_client.dart';
import 'mock_backend.dart';
import 'secure_storage_service.dart';

class AuthResult {
  const AuthResult({required this.token, required this.employee});

  final String token;
  final Employee employee;
}

class AuthService {
  AuthService({required ApiClient api, required SecureStorageService storage})
      : _api = api,
        _storage = storage;

  final ApiClient _api;
  final SecureStorageService _storage;

  Future<AuthResult> login({
    required String employeeId,
    required String password,
  }) async {
    if (ApiConstants.useMock) {
      await Future<void>.delayed(const Duration(milliseconds: 400));
      if (employeeId.trim().toUpperCase() != MockBackend.demoEmployeeId ||
          password != MockBackend.demoPassword) {
        throw ApiException('Invalid employee ID or password');
      }
      const token = 'mock-jwt-token';
      final employee = MockBackend.instance.employee;
      await _persist(token, employee);
      return AuthResult(token: token, employee: employee);
    }

    final data = await _api.post(
      ApiConstants.login,
      auth: false,
      body: {
        'employee_id': employeeId.trim(),
        'password': password,
      },
    ) as Map<String, dynamic>;

    final token = '${data['token'] ?? data['access_token'] ?? ''}';
    if (token.isEmpty) {
      throw ApiException('Login succeeded but no token was returned');
    }
    final employee = Employee.fromJson(
      Map<String, dynamic>.from(data['employee'] as Map? ?? data),
    );
    await _persist(token, employee);
    return AuthResult(token: token, employee: employee);
  }

  Future<Employee?> restoreSession() async {
    final token = await _storage.readToken();
    if (token == null || token.isEmpty) return null;

    if (ApiConstants.useMock) {
      final json = await _storage.readEmployeeJson();
      if (json == null) return MockBackend.instance.employee;
      return Employee.fromJson(jsonDecode(json) as Map<String, dynamic>);
    }

    try {
      final data = await _api.get(ApiConstants.me) as Map<String, dynamic>;
      final employee = Employee.fromJson(data);
      await _storage.saveEmployeeJson(jsonEncode(employee.toJson()));
      return employee;
    } catch (_) {
      await logout();
      return null;
    }
  }

  Future<void> logout() => _storage.clear();

  Future<void> _persist(String token, Employee employee) async {
    await _storage.saveToken(token);
    await _storage.saveEmployeeJson(jsonEncode(employee.toJson()));
  }
}
