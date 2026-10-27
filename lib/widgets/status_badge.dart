import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';

class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.status});

  final String status;

  Color get _color {
    switch (status.toLowerCase()) {
      case 'approved':
      case 'done':
      case 'checked in':
      case 'checked_in':
        return AppColors.success;
      case 'pending':
        return AppColors.pending;
      case 'rejected':
      case 'checked out':
      case 'checked_out':
        return status.toLowerCase().contains('rejected')
            ? AppColors.danger
            : AppColors.muted;
      default:
        return AppColors.muted;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _color;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
