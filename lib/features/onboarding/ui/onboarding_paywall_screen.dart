import 'package:material_ui/material_ui.dart';
import 'package:dubai_trip_planner/core/constants/app_color.dart';
import 'package:dubai_trip_planner/features/onboarding/services/onboarding_service.dart';
import 'package:dubai_trip_planner/app/router/main_scaffold.dart';

class OnboardingPaywallScreen extends StatelessWidget {
  const OnboardingPaywallScreen({super.key});

  Future<void> _completeOnboarding(BuildContext context) async {
    await OnboardingService.completeOnboarding();
    if (context.mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => MainScaffold()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            children: [
              const Spacer(),
              
              // Solution Icon/Image
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.primaryNavigation.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.celebration,
                  size: 64,
                  color: AppColors.primaryNavigation,
                ),
              ),
              
              const SizedBox(height: 48),
              
              // Main Solution Text
              const Text(
                'Your Perfect Dubai Trip\nStarts Here',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black500,
                  height: 1.3,
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Benefits List
              _buildBenefit(
                icon: Icons.explore,
                text: 'Discover the best places curated just for you',
              ),
              const SizedBox(height: 16),
              _buildBenefit(
                icon: Icons.route,
                text: 'Get personalized itineraries in seconds',
              ),
              const SizedBox(height: 16),
              _buildBenefit(
                icon: Icons.favorite,
                text: 'Save your favorites and plan your perfect trip',
              ),
              const SizedBox(height: 16),
              _buildBenefit(
                icon: Icons.access_time,
                text: 'Save hours of research and planning',
              ),
              
              const Spacer(),
              
              // CTA Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () => _completeOnboarding(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryNavigation,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Start Planning My Trip',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Skip option (optional - you can remove this)
              TextButton(
                onPressed: () => _completeOnboarding(context),
                child: const Text(
                  'Continue without premium',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.gray500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBenefit({required IconData icon, required String text}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primaryNavigation.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: AppColors.primaryNavigation,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.black500,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}

