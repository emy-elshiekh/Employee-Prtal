import '../models/attendance.dart';
import '../models/dashboard_summary.dart';
import '../models/employee.dart';
import '../models/leave_request.dart';
import '../models/payslip.dart';

/// In-memory ERP stand-in so the app is fully usable before the live API is wired.
class MockBackend {
  MockBackend._();
  static final MockBackend instance = MockBackend._();

  static const demoEmployeeId = 'EMP001';
  static const demoPassword = 'password';

  Employee employee = const Employee(
    id: '1',
    employeeId: demoEmployeeId,
    name: 'Amina Hassan',
    email: 'amina.hassan@company.com',
    jobTitle: 'HR Officer',
    department: 'Human Resources',
  );

  AttendanceRecord today = AttendanceRecord(id: 'att-today');

  LeaveBalance balance = const LeaveBalance(
    annualRemaining: 14,
    annualTotal: 21,
    sickRemaining: 8,
  );

  final List<LeaveRequest> leaves = [
    LeaveRequest(
      id: 'lv-1',
      type: 'Annual Leave',
      fromDate: DateTime(2026, 8, 4),
      toDate: DateTime(2026, 8, 8),
      reason: 'Family travel',
      status: 'Approved',
      createdAt: DateTime(2026, 7, 20),
    ),
    LeaveRequest(
      id: 'lv-2',
      type: 'Sick Leave',
      fromDate: DateTime(2026, 9, 15),
      toDate: DateTime(2026, 9, 16),
      reason: 'Medical appointment',
      status: 'Pending',
      createdAt: DateTime(2026, 9, 14),
    ),
    LeaveRequest(
      id: 'lv-3',
      type: 'Unpaid Leave',
      fromDate: DateTime(2026, 6, 2),
      toDate: DateTime(2026, 6, 2),
      reason: 'Personal matter',
      status: 'Rejected',
      createdAt: DateTime(2026, 5, 28),
    ),
  ];

  final List<Payslip> payslips = const [
    Payslip(
      id: 'ps-2026-09',
      periodLabel: 'September 2026',
      month: 9,
      year: 2026,
      netPay: 4280,
      grossPay: 5100,
      currency: 'USD',
      status: 'Done',
    ),
    Payslip(
      id: 'ps-2026-08',
      periodLabel: 'August 2026',
      month: 8,
      year: 2026,
      netPay: 4280,
      grossPay: 5100,
      currency: 'USD',
      status: 'Done',
    ),
    Payslip(
      id: 'ps-2026-07',
      periodLabel: 'July 2026',
      month: 7,
      year: 2026,
      netPay: 4150,
      grossPay: 5000,
      currency: 'USD',
      status: 'Done',
    ),
  ];

  DashboardSummary dashboard() {
    return DashboardSummary(
      leaveBalance: balance,
      todayAttendance: today,
      latestPayslip: payslips.first,
      notification: payslips.isEmpty
          ? 'No payslip yet'
          : 'Payslip for ${payslips.first.periodLabel} is available',
    );
  }

  AttendanceRecord checkIn(AttendancePayload payload) {
    today = AttendanceRecord(
      id: 'att-today',
      checkIn: payload.timestamp,
      checkInLatitude: payload.latitude,
      checkInLongitude: payload.longitude,
      status: 'checked_in',
    );
    return today;
  }

  AttendanceRecord checkOut(AttendancePayload payload) {
    today = AttendanceRecord(
      id: today.id,
      checkIn: today.checkIn ?? payload.timestamp,
      checkOut: payload.timestamp,
      checkInLatitude: today.checkInLatitude,
      checkInLongitude: today.checkInLongitude,
      checkOutLatitude: payload.latitude,
      checkOutLongitude: payload.longitude,
      status: 'checked_out',
    );
    return today;
  }

  LeaveRequest addLeave({
    required String type,
    required DateTime from,
    required DateTime to,
    required String reason,
  }) {
    final request = LeaveRequest(
      id: 'lv-${DateTime.now().millisecondsSinceEpoch}',
      type: type,
      fromDate: from,
      toDate: to,
      reason: reason,
      status: 'Pending',
      createdAt: DateTime.now(),
    );
    leaves.insert(0, request);
    return request;
  }
}
