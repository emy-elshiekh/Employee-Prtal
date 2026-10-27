import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../models/payslip.dart';
import '../services/payslip_service.dart';
import '../widgets/odoo_card.dart';
import '../widgets/section_header.dart';
import '../widgets/status_badge.dart';
import 'payslip_viewer_screen.dart';

class PayslipsScreen extends StatefulWidget {
  const PayslipsScreen({super.key});

  @override
  State<PayslipsScreen> createState() => _PayslipsScreenState();
}

class _PayslipsScreenState extends State<PayslipsScreen> {
  Payslip? _selectedPayslip;
  late Future<List<Payslip>> _future;

  @override
  void initState() {
    super.initState();
    _future = context.read<PayslipService>().list();
  }

  Future<void> _refresh() async {
    setState(() => _future = context.read<PayslipService>().list());
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    if (_selectedPayslip != null) {
      return Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () => setState(() => _selectedPayslip = null),
              icon: const Icon(Icons.arrow_back, color: AppColors.primary),
              label: const Text('Back to Payslips',
                  style: TextStyle(color: AppColors.primary)),
            ),
          ),
          Expanded(child: PayslipViewerScreen(payslip: _selectedPayslip!)),
        ],
      );
    }
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _refresh,
      child: FutureBuilder<List<Payslip>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text('Could not load payslips: ${snapshot.error}'),
                ),
              ],
            );
          }
          final items = snapshot.data ?? [];
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              const SectionHeader(title: 'Monthly payslips'),
              if (items.isEmpty)
                const OdooCard(child: Text('No payslips available.')),
              ...items.map((slip) {
                final money =
                    NumberFormat.currency(symbol: '${slip.currency} ');
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: OdooCard(
                    onTap: () {
                      setState(() {
                        _selectedPayslip = slip;
                      });
                    },
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.picture_as_pdf_outlined,
                              color: AppColors.primary),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                slip.periodLabel,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Net ${money.format(slip.netPay)}',
                                style: const TextStyle(
                                    color: AppColors.muted, fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                        StatusBadge(status: slip.status),
                        const SizedBox(width: 6),
                        const Icon(Icons.chevron_right, color: AppColors.muted),
                      ],
                    ),
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }
}
