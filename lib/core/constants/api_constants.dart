class ApiConstants {
  /// Set to false and update [baseUrl] to talk to a live ERP REST API.
  static const bool useMock = true;

  /// Example: https://erp.company.com
  static const String baseUrl = String.fromEnvironment(
    'ERP_BASE_URL',
    defaultValue: 'https://erp.example.com',
  );

  static const String login = '/api/hr/login';
  static const String me = '/api/hr/me';
  static const String dashboard = '/api/hr/dashboard';
  static const String attendanceToday = '/api/hr/attendance/today';
  static const String checkIn = '/api/hr/attendance/check-in';
  static const String checkOut = '/api/hr/attendance/check-out';
  static const String leaves = '/api/hr/leaves';
  static const String payslips = '/api/hr/payslips';

  static String payslipPdf(String id) => '/api/hr/payslips/$id/pdf';
}
