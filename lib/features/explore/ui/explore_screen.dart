import 'package:dubai_trip_planner/features/explore/ui/widgets/category_section.dart';
import 'package:dubai_trip_planner/features/explore/ui/widgets/hack_and_tips.dart';
import 'package:dubai_trip_planner/features/explore/ui/widgets/most_popular_section.dart';
import 'package:dubai_trip_planner/features/explore/ui/widgets/recommended_section.dart';
import 'package:dubai_trip_planner/features/my_trip/ui/widgets/promo_banner.dart';
import 'package:dubai_trip_planner/features/onboarding/services/onboarding_service.dart';
import 'package:dubai_trip_planner/features/onboarding/ui/onboarding_screen.dart';
import 'package:dubai_trip_planner/features/weather/ui/weather_forecast_section.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:material_ui/material_ui.dart';

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(10),
          children: [
            // Debug builds only: lets the developer go through onboarding
            // again. Release builds leave it out.
            if (kDebugMode)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await OnboardingService.resetOnboarding();
                    if (context.mounted) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const OnboardingScreen(),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Restart onboarding (debug only)'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  ),
                ),
              ),
            const SizedBox(height: 16),
            const PromoBanner(),
            const SizedBox(height: 24),
            const MostPopularSection(),
            const SizedBox(height: 36),
            const CategorySection(),
            const SizedBox(height: 30),
            const RecommendedSection(),
            const SizedBox(height: 30),
            const WeatherForecastSection(),
            const SizedBox(height: 30),
            const HackAndTips(),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
