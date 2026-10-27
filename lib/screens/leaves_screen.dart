import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_colors.dart';
import '../models/leave_request.dart';
import '../services/leave_service.dart';
import '../widgets/odoo_card.dart';
import '../widgets/section_header.dart';
import '../widgets/status_badge.dart';

class LeavesScreen extends StatefulWidget {
  const LeavesScreen({super.key});

  @override
  State<LeavesScreen> createState() => _LeavesScreenState();
}

class _LeavesScreenState extends State<LeavesScreen> {
  late Future<List<LeaveRequest>> _future;
  bool _showForm = false;

  static const types = [
    'Annual Leave',
    'Sick Leave',
    'Unpaid Leave',
    'Maternity Leave'
  ];

  @override
  void initState() {
    super.initState();
    _future = context.read<LeaveService>().list();
  }

  Future<void> _refresh() async {
    setState(() => _future = context.read<LeaveService>().list());
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        onPressed: () => setState(() => _showForm = true),
        icon: const Icon(Icons.add),
        label: const Text('New request'),
      ),
      body: Stack(
        children: [
          RefreshIndicator(
            color: AppColors.primary,
            onRefresh: _refresh,
            child: FutureBuilder<List<LeaveRequest>>(
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
                        child: Text('Could not load leaves: ${snapshot.error}'),
                      ),
                    ],
                  );
                }
                final items = snapshot.data ?? [];
                return ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 88),
                  children: [
                    const SectionHeader(title: 'Leave requests'),
                    if (items.isEmpty)
                      const OdooCard(child: Text('No leave requests yet.')),
                    ...items.map((leave) {
                      final range =
                          '${DateFormat('d MMM yyyy').format(leave.fromDate)} – ${DateFormat('d MMM yyyy').format(leave.toDate)}';
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: OdooCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      leave.type,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                  StatusBadge(status: leave.status),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(range,
                                  style:
                                      const TextStyle(color: AppColors.muted)),
                              const SizedBox(height: 6),
                              Text(leave.reason),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                );
              },
            ),
          ),
          if (_showForm)
            Container(
              color: Colors.black54.withOpacity(0.5),
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 380),
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: _LeaveFormSheet(
                    types: types,
                    onClose: () => setState(() => _showForm = false),
                    onSuccess: () {
                      setState(() => _showForm = false);
                      _refresh();
                    },
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _LeaveFormSheet extends StatefulWidget {
  const _LeaveFormSheet({
    required this.types,
    required this.onClose,
    required this.onSuccess,
  });

  final List<String> types;
  final VoidCallback onClose;
  final VoidCallback onSuccess;

  @override
  State<_LeaveFormSheet> createState() => _LeaveFormSheetState();
}

class _LeaveFormSheetState extends State<_LeaveFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _reason = TextEditingController();
  final _fromController = TextEditingController();
  final _toController = TextEditingController();
  String _type = 'Annual Leave';
  bool _saving = false;

  @override
  void dispose() {
    _reason.dispose();
    _fromController.dispose();
    _toController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await context.read<LeaveService>().submit(
            type: _type,
            from: DateTime.parse(_fromController.text.trim()),
            to: DateTime.parse(_toController.text.trim()),
            reason: _reason.text.trim(),
          );
      widget.onSuccess();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid date format (Use YYYY-MM-DD)'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'New leave request',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: widget.onClose,
              ),
            ],
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _type,
            items: widget.types
                .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                .toList(),
            onChanged: (v) => setState(() => _type = v ?? _type),
            decoration: const InputDecoration(labelText: 'Leave type'),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _fromController,
            decoration: const InputDecoration(
              labelText: 'From Date (YYYY-MM-DD)',
              hintText: '2026-11-01',
            ),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Enter start date' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _toController,
            decoration: const InputDecoration(
              labelText: 'To Date (YYYY-MM-DD)',
              hintText: '2026-11-05',
            ),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Enter end date' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _reason,
            maxLines: 3,
            decoration: const InputDecoration(labelText: 'Reason'),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Enter a reason' : null,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _saving ? null : _submit,
            child: _saving
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : const Text('Submit request'),
          ),
        ],
      ),
    );
  }
}
