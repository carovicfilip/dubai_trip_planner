import 'package:dubai_trip_planner/app/theme/app_theme.dart';
import 'package:dubai_trip_planner/core/constants/app_palette.dart';
import 'package:dubai_trip_planner/core/widgets/gradient_hero.dart';
import 'package:dubai_trip_planner/features/app_rating/services/app_rating_service.dart';
import 'package:dubai_trip_planner/features/explore/ui/widgets/category_section.dart';
import 'package:dubai_trip_planner/features/explore/ui/widgets/hack_and_tips.dart';
import 'package:dubai_trip_planner/features/explore/ui/widgets/language_switcher.dart';
import 'package:dubai_trip_planner/features/explore/ui/widgets/most_popular_section.dart';
import 'package:dubai_trip_planner/features/explore/ui/widgets/recommended_section.dart';
import 'package:dubai_trip_planner/features/my_trip/ui/widgets/promo_banner.dart';
import 'package:dubai_trip_planner/features/onboarding/services/onboarding_service.dart';
import 'package:dubai_trip_planner/features/onboarding/ui/onboarding_screen.dart';
import 'package:dubai_trip_planner/features/weather/ui/weather_forecast_section.dart';
import 'package:dubai_trip_planner/l10n/l10n.dart';
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
    final l10n = context.l10n;
    Widget section(Widget child) => Padding(padding: const EdgeInsets.symmetric(horizontal: 10), child: child);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      // Over the dark header, in both themes.
      value: AppTheme.statusBarOnDark,
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
              HeroListView(
                statusBarOverPage: AppTheme.statusBarFor(context),
                // The list runs on under the status bar and the floating
                // navigation bar.
                padding: EdgeInsets.only(bottom: safeArea.bottom + 16),
                children: [
                  GradientHero(
                    lightTitle: l10n.exploreHeroLight,
                    boldTitle: l10n.exploreHeroBold,
                    trailing: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (kDebugMode) _RestartOnboardingButton(),
                        LanguageSwitcher(),
                      ],
                    ),
                    child: const PromoBanner(),
                  ),
                  const SizedBox(height: 24),
                  section(const MostPopularSection()),
                  const SizedBox(height: 24),
                  section(const CategorySection()),
                  const SizedBox(height: 30),
                  section(const RecommendedSection()),
                  const SizedBox(height: 30),
                  section(const WeatherForecastSection()),
                  const SizedBox(height: 30),
                  section(const HackAndTips()),
                  const SizedBox(height: 16),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Debug builds only: lets the developer go through onboarding again. Release
/// builds leave it out.
class _RestartOnboardingButton extends StatelessWidget {
  const _RestartOnboardingButton();

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Restart onboarding',
      onPressed: () async {
        await OnboardingService.resetOnboarding();
        // Starts over as a new user, so the question can be seen again too.
        await AppRatingService.resetAsked();
        if (context.mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => const OnboardingScreen(),
            ),
          );
        }
      },
      color: Colors.white,
      iconSize: 18,
      visualDensity: VisualDensity.compact,
      icon: const Icon(Icons.refresh),
    );
  }
}
