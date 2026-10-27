import '../core/constants/api_constants.dart';
import '../models/leave_request.dart';
import 'api_client.dart';
import 'mock_backend.dart';

class LeaveService {
  LeaveService({required ApiClient api}) : _api = api;

  final ApiClient _api;

  Future<List<LeaveRequest>> list() async {
    if (ApiConstants.useMock) {
      return List<LeaveRequest>.from(MockBackend.instance.leaves);
    }
    final data = await _api.get(ApiConstants.leaves);
    final items = data is List ? data : (data['results'] as List? ?? []);
    return items
        .map((e) => LeaveRequest.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<LeaveRequest> submit({
    required String type,
    required DateTime from,
    required DateTime to,
    required String reason,
  }) async {
    if (ApiConstants.useMock) {
      await Future<void>.delayed(const Duration(milliseconds: 350));
      return MockBackend.instance.addLeave(
        type: type,
        from: from,
        to: to,
        reason: reason,
      );
    }
    final data = await _api.post(
      ApiConstants.leaves,
      body: {
        'type': type,
        'from_date': from.toIso8601String().split('T').first,
        'to_date': to.toIso8601String().split('T').first,
        'reason': reason,
      },
    ) as Map<String, dynamic>;
    return LeaveRequest.fromJson(data);
  }
}
