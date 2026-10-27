class Payslip {
  const Payslip({
    required this.id,
    required this.periodLabel,
    required this.month,
    required this.year,
    required this.netPay,
    required this.grossPay,
    required this.currency,
    required this.status,
    this.pdfUrl,
  });

  final String id;
  final String periodLabel;
  final int month;
  final int year;
  final double netPay;
  final double grossPay;
  final String currency;
  final String status;
  final String? pdfUrl;

  factory Payslip.fromJson(Map<String, dynamic> json) {
    return Payslip(
      id: '${json['id']}',
      periodLabel: '${json['period_label'] ?? json['period'] ?? ''}',
      month: (json['month'] as num?)?.toInt() ?? 1,
      year: (json['year'] as num?)?.toInt() ?? DateTime.now().year,
      netPay: (json['net_pay'] as num?)?.toDouble() ?? 0,
      grossPay: (json['gross_pay'] as num?)?.toDouble() ?? 0,
      currency: '${json['currency'] ?? 'USD'}',
      status: '${json['status'] ?? 'Done'}',
      pdfUrl: json['pdf_url'] as String?,
    );
  }
}
