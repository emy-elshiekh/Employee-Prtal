import '../core/constants/api_constants.dart';
import '../models/dashboard_summary.dart';
import 'api_client.dart';
import 'mock_backend.dart';

class DashboardService {
  DashboardService({required ApiClient api}) : _api = api;

  final ApiClient _api;

  Future<DashboardSummary> fetch() async {
    if (ApiConstants.useMock) {
      return MockBackend.instance.dashboard();
    }
    final data = await _api.get(ApiConstants.dashboard) as Map<String, dynamic>;
    return DashboardSummary.fromJson(data);
  }
}
