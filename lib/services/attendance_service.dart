import '../core/constants/api_constants.dart';
import '../models/attendance.dart';
import 'api_client.dart';
import 'mock_backend.dart';

class AttendanceService {
  AttendanceService({required ApiClient api}) : _api = api;

  final ApiClient _api;

  Future<AttendanceRecord> today() async {
    if (ApiConstants.useMock) {
      return MockBackend.instance.today;
    }
    final data = await _api.get(ApiConstants.attendanceToday) as Map<String, dynamic>;
    return AttendanceRecord.fromJson(data);
  }

  Future<AttendanceRecord> checkIn(AttendancePayload payload) async {
    if (ApiConstants.useMock) {
      await Future<void>.delayed(const Duration(milliseconds: 350));
      return MockBackend.instance.checkIn(payload);
    }
    final data = await _api.post(ApiConstants.checkIn, body: payload.toJson())
        as Map<String, dynamic>;
    return AttendanceRecord.fromJson(data);
  }

  Future<AttendanceRecord> checkOut(AttendancePayload payload) async {
    if (ApiConstants.useMock) {
      await Future<void>.delayed(const Duration(milliseconds: 350));
      return MockBackend.instance.checkOut(payload);
    }
    final data = await _api.post(ApiConstants.checkOut, body: payload.toJson())
        as Map<String, dynamic>;
    return AttendanceRecord.fromJson(data);
  }
}
