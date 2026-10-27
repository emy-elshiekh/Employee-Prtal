import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_colors.dart';
import '../providers/auth_provider.dart';
import 'attendance_screen.dart';
import 'dashboard_screen.dart';
import 'leaves_screen.dart';
import 'payslips_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  static const _titles = ['Dashboard', 'Attendance', 'Leaves', 'Payslips'];

  @override
  Widget build(BuildContext context) {
    final screens = const [
      DashboardScreen(),
      AttendanceScreen(),
      LeavesScreen(),
      PayslipsScreen(),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_titles[_index]),
        actions: [
          IconButton(
            tooltip: 'Log out',
            onPressed: () => context.read<AuthProvider>().logout(),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: screens[_index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.fingerprint), label: 'Attendance'),
          BottomNavigationBarItem(icon: Icon(Icons.event_note_outlined), label: 'Leaves'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long_outlined), label: 'Payslips'),
        ],
      ),
    );
  }
}
