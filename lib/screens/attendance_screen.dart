import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_colors.dart';
import '../models/attendance.dart';
import '../services/attendance_service.dart';
import '../services/location_service.dart';
import '../widgets/odoo_card.dart';
import '../widgets/status_badge.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  AttendanceRecord? _today;
  bool _loading = true;
  bool _busy = false;
  String? _error;
  String? _lastCoords;
  String? _successMessage; // متغير لتخزين رسالة النجاح داخل التطبيق

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final today = await context.read<AttendanceService>().today();
      setState(() => _today = today);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _punch({required bool checkIn}) async {
    setState(() {
      _busy = true;
      _error = null;
      _successMessage = null;
    });
    try {
      final position = await context.read<LocationService>().currentPosition();
      final payload = AttendancePayload(
        latitude: position.latitude,
        longitude: position.longitude,
        timestamp: DateTime.now(),
      );
      final service = context.read<AttendanceService>();
      final result = checkIn
          ? await service.checkIn(payload)
          : await service.checkOut(payload);

      setState(() {
        _today = result;
        _lastCoords =
            '${payload.latitude.toStringAsFixed(6)}, ${payload.longitude.toStringAsFixed(6)}';
        // تخزين رسالة النجاح لتظهر داخل الإطار بدلاً من SnackBar
        _successMessage = checkIn
            ? 'Checked in at ${DateFormat.Hm().format(payload.timestamp)}'
            : 'Checked out at ${DateFormat.Hm().format(payload.timestamp)}';
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    final record = _today;
    final canCheckIn =
        record == null || (!record.isCheckedIn && !record.isCheckedOut);
    final canCheckOut = record != null && record.isCheckedIn;

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          OdooCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        "Today's attendance",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                    ),
                    StatusBadge(
                        status: record?.displayStatus ?? 'Not checked in'),
                  ],
                ),
                const SizedBox(height: 16),
                _InfoRow(
                  label: 'Check-in',
                  value: record?.checkIn == null
                      ? '—'
                      : DateFormat('HH:mm · d MMM')
                          .format(record!.checkIn!.toLocal()),
                ),
                _InfoRow(
                  label: 'Check-out',
                  value: record?.checkOut == null
                      ? '—'
                      : DateFormat('HH:mm · d MMM')
                          .format(record!.checkOut!.toLocal()),
                ),
                if (record?.checkInLatitude != null)
                  _InfoRow(
                    label: 'Check-in GPS',
                    value:
                        '${record!.checkInLatitude!.toStringAsFixed(5)}, ${record.checkInLongitude!.toStringAsFixed(5)}',
                  ),
                if (record?.checkOutLatitude != null)
                  _InfoRow(
                    label: 'Check-out GPS',
                    value:
                        '${record!.checkOutLatitude!.toStringAsFixed(5)}, ${record.checkOutLongitude!.toStringAsFixed(5)}',
                  ),
                if (_lastCoords != null)
                  _InfoRow(label: 'Last punch GPS', value: _lastCoords!),
              ],
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            OdooCard(
              child: Text(_error!,
                  style: const TextStyle(color: AppColors.danger)),
            ),
          ],
          // عرض رسالة النجاح بشكل شيك داخل إطار التطبيق
          if (_successMessage != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.success),
              ),
              child: Text(
                _successMessage!,
                style: const TextStyle(
                  color: AppColors.success,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed:
                (!_busy && canCheckIn) ? () => _punch(checkIn: true) : null,
            icon: const Icon(Icons.login),
            label: const Text('Check in'),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed:
                (!_busy && canCheckOut) ? () => _punch(checkIn: false) : null,
            icon: const Icon(Icons.logout),
            label: const Text('Check out'),
          ),
          if (_busy) ...[
            const SizedBox(height: 16),
            const Center(child: CircularProgressIndicator()),
            const SizedBox(height: 8),
            const Center(
              child: Text(
                'Fetching GPS and sending to ERP…',
                style: TextStyle(color: AppColors.muted),
              ),
            ),
          ],
          const SizedBox(height: 16),
          const Text(
            'Check-in and check-out send latitude, longitude, and timestamp to the ERP REST API.',
            style: TextStyle(color: AppColors.muted, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: const TextStyle(color: AppColors.muted)),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
