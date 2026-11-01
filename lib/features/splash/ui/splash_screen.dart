import 'dart:async';
import 'package:material_ui/material_ui.dart';
import '../../../app/router/main_scaffold.dart';
import '../../onboarding/ui/onboarding_screen.dart';
import '../../onboarding/services/onboarding_service.dart';

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
    _redirectTimer = Timer(const Duration(seconds: 2), () async {
      if (!mounted) return;
      
      final isOnboardingCompleted = await OnboardingService.isOnboardingCompleted();
      
      if (!mounted) return;
      
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => isOnboardingCompleted 
              ? MainScaffold() 
              : const OnboardingScreen(),
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
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        child: Image.asset(
          'assets/images/splash_screen.jpg',
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
