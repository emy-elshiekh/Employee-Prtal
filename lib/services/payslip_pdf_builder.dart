import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../models/employee.dart';
import '../models/payslip.dart';

class PayslipPdfBuilder {
  static Future<List<int>> build({
    required Payslip payslip,
    required Employee employee,
  }) async {
    final doc = pw.Document();
    final currency = NumberFormat.currency(symbol: '${payslip.currency} ');
    final deductions = payslip.grossPay - payslip.netPay;

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(16),
                color: PdfColor.fromHex('2C6ECB'),
                child: pw.Text(
                  'EMPLOYEE PAYSLIP',
                  style: pw.TextStyle(
                    color: PdfColors.white,
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Text(payslip.periodLabel, style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 12),
              pw.Text('Employee: ${employee.name}'),
              pw.Text('Employee ID: ${employee.employeeId}'),
              pw.Text('Department: ${employee.department}'),
              pw.Text('Job Title: ${employee.jobTitle}'),
              pw.SizedBox(height: 20),
              pw.TableHelper.fromTextArray(
                headers: ['Description', 'Amount'],
                data: [
                  ['Gross Pay', currency.format(payslip.grossPay)],
                  ['Deductions', currency.format(deductions)],
                  ['Net Pay', currency.format(payslip.netPay)],
                ],
                headerDecoration: pw.BoxDecoration(color: PdfColor.fromHex('E8F0FC')),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                cellAlignments: {
                  1: pw.Alignment.centerRight,
                },
              ),
              pw.SizedBox(height: 24),
              pw.Text(
                'This document is generated from the Employee Portal for preview and download.',
                style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
              ),
            ],
          );
        },
      ),
    );

    return doc.save();
  }
}
