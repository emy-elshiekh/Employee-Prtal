import '../core/constants/api_constants.dart';
import '../models/payslip.dart';
import 'api_client.dart';
import 'mock_backend.dart';

class PayslipService {
  PayslipService({required ApiClient api}) : _api = api;

  final ApiClient _api;

  Future<List<Payslip>> list() async {
    if (ApiConstants.useMock) {
      return List<Payslip>.from(MockBackend.instance.payslips);
    }
    final data = await _api.get(ApiConstants.payslips);
    final items = data is List ? data : (data['results'] as List? ?? []);
    return items
        .map((e) => Payslip.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<List<int>?> downloadPdf(Payslip payslip) async {
    if (ApiConstants.useMock) return null;
    return _api.getBytes(ApiConstants.payslipPdf(payslip.id));
  }
}
