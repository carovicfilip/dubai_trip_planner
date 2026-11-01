import 'package:dubai_trip_planner/app/theme/app_theme.dart';
import 'package:dubai_trip_planner/core/constants/app_palette.dart';
import 'package:dubai_trip_planner/features/explore/ui/widgets/category_section.dart';
import 'package:dubai_trip_planner/features/explore/ui/widgets/hack_and_tips.dart';
import 'package:dubai_trip_planner/features/explore/ui/widgets/most_popular_section.dart';
import 'package:dubai_trip_planner/features/explore/ui/widgets/recommended_section.dart';
import 'package:dubai_trip_planner/features/my_trip/ui/widgets/promo_banner.dart';
import 'package:dubai_trip_planner/features/onboarding/services/onboarding_service.dart';
import 'package:dubai_trip_planner/features/onboarding/ui/onboarding_screen.dart';
import 'package:dubai_trip_planner/features/weather/ui/weather_forecast_section.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = context.palette;
    final safeArea = MediaQuery.paddingOf(context);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppTheme.statusBarFor(context),
      child: Theme(
        data: theme.copyWith(
          textTheme: theme.textTheme.copyWith(
            titleMedium: theme.textTheme.titleMedium?.copyWith(fontSize: 20, fontWeight: FontWeight.w400),
          ),
        ),
        child: Scaffold(
          backgroundColor: palette.surface,
          body: Stack(
            fit: StackFit.expand,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: palette.pageGradient,
                  ),
                ),
              ),
              ListView(
                // The list runs on under the status bar and the floating
                // navigation bar.
                padding: EdgeInsets.fromLTRB(10, safeArea.top + 10, 10, safeArea.bottom + 16),
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
                          backgroundColor: palette.tile,
                          foregroundColor: palette.muted,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
                  const PromoBanner(),
                  const SizedBox(height: 24),
                  const MostPopularSection(),
                  const SizedBox(height: 24),
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
              // What scrolls under the status bar fades away, so the clock stays
              // readable.
              Align(
                alignment: Alignment.topCenter,
                child: IgnorePointer(
                  child: Container(
                    height: safeArea.top + 12,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [palette.pageGradient.first, palette.pageGradient.first.withValues(alpha: 0)],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
