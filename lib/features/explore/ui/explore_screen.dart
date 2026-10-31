import 'package:dubai_trip_planner/core/widgets/hack_and_tips.dart';
import 'package:dubai_trip_planner/core/widgets/weather_forecast_section.dart';
import 'package:material_ui/material_ui.dart';
import '../../../core/widgets/category_section.dart';
import '../../../core/widgets/most_popular_section.dart';
import '../../../core/widgets/recommended_section.dart';
import '../../../core/widgets/promo_banner.dart';
import '../../onboarding/ui/onboarding_screen.dart';
import '../../onboarding/services/onboarding_service.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<ExploreScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // floatingActionButton: AnimatedBuilder(
      //   animation: _controller,
      //   builder: (context, child) {
      //     return Container(
      //       decoration: BoxDecoration(
      //         gradient: LinearGradient(
      //           colors: [
      //             _color1.value ?? Colors.cyan,
      //             _color2.value ?? Colors.purple,
      //           ],
      //         ),
      //         borderRadius: BorderRadius.circular(30),
      //         boxShadow: [
      //           BoxShadow(
      //             color: Colors.black26,
      //             blurRadius: 6,
      //             offset: Offset(0, 2),
      //           ),
      //         ],
      //       ),
      //       child: FloatingActionButton.extended(
      //         onPressed: () {
      //           Navigator.push(
      //             context,
      //             MaterialPageRoute(builder: (_) => const MyTripScreen()),
      //           );
      //         },
      //         backgroundColor: Colors.transparent,
      //         elevation: 0,
      //         label: const Text(
      //           "Plan My Trip",
      //         ),
      //         icon: const Icon(Icons.travel_explore),
      //       ),
      //     );
      //   },
      // ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(10),
          children: [
            // TEST BUTTON - DELETE LATER
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
                label: const Text('Test Onboarding (DELETE LATER)'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                ),
              ),
            ),
            // HeaderWidget(name: "Filip", savings: "AED 520"),
            const SizedBox(height: 16),
            const PromoBanner(),
            SizedBox(height: 24),
            MostPopularSection(),
            SizedBox(height: 36),
            CategorySection(),
            SizedBox(height: 30),
            RecommendedSection(),
            SizedBox(height: 30),
            WeatherForecastSection(),
            SizedBox(height: 30),
            HackAndTips(),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
