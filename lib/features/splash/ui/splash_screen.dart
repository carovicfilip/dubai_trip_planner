import 'dart:async';

import 'package:dubai_trip_planner/app/router/main_scaffold.dart';
import 'package:dubai_trip_planner/app/theme/app_theme.dart';
import 'package:dubai_trip_planner/core/constants/app_color.dart';
import 'package:dubai_trip_planner/core/widgets/photo_message.dart';
import 'package:dubai_trip_planner/l10n/l10n.dart';
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
      Navigator.pushReplacement(context, MainScaffold.fadeInRoute());
    });
  }

  @override
  void dispose() {
    _redirectTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppTheme.statusBarOnDark,
      child: Scaffold(
        backgroundColor: AppColors.darkNavy,
        body: PhotoMessage(
          image: 'assets/images/splash.webp',
          title: l10n.splashTitle,
          label: l10n.dubaiLabel,
          text: l10n.splashText,
          bottomSpace: 72,
        ),
      ),
    );
  }
}
