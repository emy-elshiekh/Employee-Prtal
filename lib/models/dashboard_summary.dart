import 'attendance.dart';
import 'leave_request.dart';
import 'payslip.dart';

class DashboardSummary {
  const DashboardSummary({
    required this.leaveBalance,
    required this.todayAttendance,
    this.latestPayslip,
    this.notification = '',
  });

  final LeaveBalance leaveBalance;
  final AttendanceRecord todayAttendance;
  final Payslip? latestPayslip;
  final String notification;

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    return DashboardSummary(
      leaveBalance: LeaveBalance.fromJson(
        Map<String, dynamic>.from(json['leave_balance'] as Map? ?? {}),
      ),
      todayAttendance: AttendanceRecord.fromJson(
        Map<String, dynamic>.from(json['today_attendance'] as Map? ?? {'id': ''}),
      ),
      latestPayslip: json['latest_payslip'] is Map
          ? Payslip.fromJson(Map<String, dynamic>.from(json['latest_payslip'] as Map))
          : null,
      notification: '${json['notification'] ?? ''}',
    );
  }
}
