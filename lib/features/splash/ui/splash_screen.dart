import 'dart:async';

import 'package:dubai_trip_planner/app/router/main_scaffold.dart';
import 'package:dubai_trip_planner/core/constants/app_color.dart';
import 'package:dubai_trip_planner/core/widgets/photo_message.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

/// Welcomes back a user who has already been through onboarding, on the way
/// to the main app.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _redirectTimer;

  @override
  void initState() {
    super.initState();
    _redirectTimer = Timer(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 400),
          pageBuilder: (_, _, _) => const MainScaffold(),
          transitionsBuilder: (_, animation, _, child) => FadeTransition(opacity: animation, child: child),
        ),
      );
    });
  }

  @override
  void dispose() {
    _redirectTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.darkNavy,
        body: PhotoMessage(
          image: 'assets/images/splash.webp',
          title: 'Welcome Back',
          label: 'DUBAI',
          text: "Your next adventure is waiting. Let's pick up where you left off.",
          bottomSpace: 72,
        ),
      ),
    );
  }
}
