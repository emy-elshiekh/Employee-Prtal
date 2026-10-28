import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'screens/login_screen.dart';
import 'screens/main_shell.dart';

class EmployeePortalApp extends StatelessWidget {
  const EmployeePortalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Employee Portal',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      // تم إزالة إطار الموبايل والـ Container، وأصبح التطبيق يملى الشاشة بالكامل
      home: const _AuthGate(),
    );
  }
}

class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    if (auth.bootstrapping) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (auth.isAuthenticated) {
      return const MainShell();
    }
    return const LoginScreen();
  }
}
