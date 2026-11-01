import 'package:dubai_trip_planner/core/constants/app_color.dart';
import 'package:dubai_trip_planner/core/widgets/glass_button.dart';
import 'package:dubai_trip_planner/core/widgets/photo_message.dart';
import 'package:dubai_trip_planner/features/onboarding/ui/onboarding_paywall_screen.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

class _OnboardingPage {
  const _OnboardingPage({
    required this.image,
    required this.label,
    required this.title,
    required this.text,
  });

  final String image;
  final String label;
  final String title;
  final String text;
}

const _pages = [
  _OnboardingPage(
    image: 'assets/images/onboarding_1.webp',
    label: 'DISCOVER',
    title: "Dubai's Best,\nAll in One Place",
    text: 'No more endless searching. Top places, handpicked and ready to explore.',
  ),
  _OnboardingPage(
    image: 'assets/images/onboarding_2.webp',
    label: 'EXPLORE',
    title: 'Find Your Way\nAround Dubai',
    text: 'Opening hours, locations, your favorites and the weather, all at hand.',
  ),
  _OnboardingPage(
    image: 'assets/images/onboarding_3.webp',
    label: 'PLAN',
    title: 'Your Days,\nPlanned for You',
    text: 'A day-by-day itinerary built around your hotel and your interests.',
  ),
];

/// The height of the button and dots at the bottom of the screen; the text of
/// every page stays above them.
const _controlsHeight = 136.0;

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // So that no page shows up empty while its photo is decoded.
    for (final page in _pages) {
      precacheImage(AssetImage(page.image), context);
    }
  }

  void _onNext() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      // Navigate to paywall screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const OnboardingPaywallScreen()),
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.darkNavy,
        body: Stack(
          fit: StackFit.expand,
          children: [
            PageView.builder(
              controller: _pageController,
              onPageChanged: (index) => setState(() => _currentPage = index),
              itemCount: _pages.length,
              itemBuilder: (context, index) {
                final page = _pages[index];
                return PhotoMessage(
                  image: page.image,
                  title: page.title,
                  label: page.label,
                  text: page.text,
                  bottomSpace: _controlsHeight,
                );
              },
            ),
            // Stays in place while the pages slide underneath.
            SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GlassButton(
                    label: _currentPage == _pages.length - 1 ? 'Get Started' : 'Next',
                    onPressed: _onNext,
                  ),
                  const SizedBox(height: 28),
                  _PageDots(count: _pages.length, current: _currentPage),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PageDots extends StatelessWidget {
  const _PageDots({required this.count, required this.current});

  final int count;
  final int current;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < count; i++)
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: i == current ? 22 : 6,
            height: 6,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: i == current ? 0.9 : 0.4),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
      ],
    );
  }
}
