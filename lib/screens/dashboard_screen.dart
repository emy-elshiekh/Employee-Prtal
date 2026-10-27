import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_colors.dart';
import '../models/dashboard_summary.dart';
import '../providers/auth_provider.dart';
import '../services/dashboard_service.dart';
import '../widgets/odoo_card.dart';
import '../widgets/quick_stat_card.dart';
import '../widgets/section_header.dart';
import '../widgets/status_badge.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Future<DashboardSummary> _future;

  @override
  void initState() {
    super.initState();
    _future = context.read<DashboardService>().fetch();
  }

  Future<void> _refresh() async {
    setState(() {
      _future = context.read<DashboardService>().fetch();
    });
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    final employee = context.watch<AuthProvider>().employee!;
    final time = DateFormat('EEEE, d MMM yyyy').format(DateTime.now());

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _refresh,
      child: FutureBuilder<DashboardSummary>(
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
                  child: Text('Could not load dashboard: ${snapshot.error}'),
                ),
              ],
            );
          }
          final data = snapshot.data!;
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              OdooCard(
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 26,
                      backgroundColor: AppColors.primaryLight,
                      child: Text(
                        employee.name.isNotEmpty ? employee.name[0] : 'E',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome, ${employee.name.split(' ').first}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${employee.jobTitle} · ${employee.department}',
                            style: const TextStyle(color: AppColors.muted, fontSize: 13),
                          ),
                          Text(time, style: const TextStyle(color: AppColors.muted, fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SectionHeader(title: 'Overview'),
              QuickStatCard(
                title: 'Leave balance',
                value: '${data.leaveBalance.annualRemaining.toStringAsFixed(0)} days',
                subtitle:
                    '${data.leaveBalance.annualRemaining.toStringAsFixed(0)} / ${data.leaveBalance.annualTotal.toStringAsFixed(0)} annual',
                icon: Icons.event_available_outlined,
                accent: AppColors.primary,
              ),
              const SizedBox(height: 12),
              QuickStatCard(
                title: "Today's attendance",
                value: data.todayAttendance.displayStatus,
                subtitle: data.todayAttendance.checkIn == null
                    ? 'No check-in recorded'
                    : 'In ${DateFormat.Hm().format(data.todayAttendance.checkIn!.toLocal())}'
                        '${data.todayAttendance.checkOut != null ? ' · Out ${DateFormat.Hm().format(data.todayAttendance.checkOut!.toLocal())}' : ''}',
                icon: Icons.fingerprint,
                accent: data.todayAttendance.isCheckedIn ? AppColors.success : AppColors.warning,
              ),
              const SizedBox(height: 12),
              QuickStatCard(
                title: 'Latest payslip',
                value: data.latestPayslip?.periodLabel ?? 'None',
                subtitle: data.notification,
                icon: Icons.receipt_long_outlined,
                accent: AppColors.pending,
              ),
              const SectionHeader(title: 'Notifications'),
              OdooCard(
                child: Row(
                  children: [
                    const Icon(Icons.notifications_none, color: AppColors.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        data.notification.isEmpty ? 'You are all caught up.' : data.notification,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                    if (data.latestPayslip != null)
                      const StatusBadge(status: 'New'),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
