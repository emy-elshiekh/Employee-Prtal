import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_colors.dart';
import '../models/payslip.dart';
import '../providers/auth_provider.dart';
import '../services/payslip_pdf_builder.dart';
import '../services/payslip_service.dart';

class PayslipViewerScreen extends StatelessWidget {
  const PayslipViewerScreen({super.key, required this.payslip});

  final Payslip payslip;

  Future<List<int>> _bytes(BuildContext context) async {
    final employee = context.read<AuthProvider>().employee!;
    final remote = await context.read<PayslipService>().downloadPdf(payslip);
    if (remote != null && remote.isNotEmpty) return remote;
    return PayslipPdfBuilder.build(payslip: payslip, employee: employee);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(payslip.periodLabel)),
      body: PdfPreview(
        build: (format) async => Uint8List.fromList(await _bytes(context)),
        pdfFileName: 'payslip_${payslip.id}.pdf',
        canChangePageFormat: false,
        canChangeOrientation: false,
        canDebug: false,
        allowSharing: false,
        actions: [
          PdfPreviewAction(
            icon: const Icon(Icons.arrow_downward),
            onPressed: (context, build, pageFormat) async {
              final bytes = await build(pageFormat);
              await Printing.sharePdf(
                bytes: Uint8List.fromList(bytes),
                filename: 'payslip_${payslip.id}.pdf',
              );
            },
          ),
        ],
      ),
    );
  }
}
