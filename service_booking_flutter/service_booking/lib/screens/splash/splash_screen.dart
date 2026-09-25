import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../home/root_shell.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Guests go straight into browsing — auth is only required at booking
    // time, not at launch.
    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const RootShell()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.calendar_month_rounded, size: 56, color: AppColors.primary),
            SizedBox(height: 16),
            Text(
              'Service Booking',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 22, color: AppColors.textDark),
            ),
          ],
        ),
      ),
    );
  }
}
