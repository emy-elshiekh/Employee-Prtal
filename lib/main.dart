import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'providers/auth_provider.dart';
import 'services/api_client.dart';
import 'services/attendance_service.dart';
import 'services/auth_service.dart';
import 'services/dashboard_service.dart';
import 'services/leave_service.dart';
import 'services/location_service.dart';
import 'services/payslip_service.dart';
import 'services/secure_storage_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final storage = SecureStorageService();
  final api = ApiClient(storage: storage);
  final authService = AuthService(api: api, storage: storage);
  final authProvider = AuthProvider(authService: authService)..bootstrap();

  runApp(
    MultiProvider(
      providers: [
        Provider<ApiClient>.value(value: api),
        Provider<AuthService>.value(value: authService),
        Provider<DashboardService>(create: (_) => DashboardService(api: api)),
        Provider<AttendanceService>(create: (_) => AttendanceService(api: api)),
        Provider<LeaveService>(create: (_) => LeaveService(api: api)),
        Provider<PayslipService>(create: (_) => PayslipService(api: api)),
        Provider<LocationService>(create: (_) => LocationService()),
        ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
      ],
      child: const EmployeePortalApp(),
    ),
  );
}
