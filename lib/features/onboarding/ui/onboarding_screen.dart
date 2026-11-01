import 'package:dubai_trip_planner/app/router/main_scaffold.dart';
import 'package:dubai_trip_planner/app/theme/app_theme.dart';
import 'package:dubai_trip_planner/core/constants/app_color.dart';
import 'package:dubai_trip_planner/core/widgets/glass_button.dart';
import 'package:dubai_trip_planner/core/widgets/photo_message.dart';
import 'package:dubai_trip_planner/features/onboarding/services/onboarding_service.dart';
import 'package:dubai_trip_planner/l10n/l10n.dart';
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

const _photos = [
  'assets/images/onboarding_1.webp',
  'assets/images/onboarding_2.webp',
  'assets/images/onboarding_3.webp',
];

List<_OnboardingPage> _pagesIn(AppLocalizations l10n) => [
      _OnboardingPage(
        image: _photos[0],
        label: l10n.onboardingDiscoverLabel,
        title: l10n.onboardingDiscoverTitle,
        text: l10n.onboardingDiscoverText,
      ),
      _OnboardingPage(
        image: _photos[1],
        label: l10n.onboardingExploreLabel,
        title: l10n.onboardingExploreTitle,
        text: l10n.onboardingExploreText,
      ),
      _OnboardingPage(
        image: _photos[2],
        label: l10n.onboardingPlanLabel,
        title: l10n.onboardingPlanTitle,
        text: l10n.onboardingPlanText,
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
  bool _finishing = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // So that no page shows up empty while its photo is decoded.
    for (final photo in _photos) {
      precacheImage(AssetImage(photo), context);
    }
  }

  void _onNext() {
    if (_currentPage < _photos.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _finish();
    }
  }

  Future<void> _finish() async {
    // A second tap during the fade must not open the main app again.
    if (_finishing) return;
    _finishing = true;
    await OnboardingService.completeOnboarding();
    if (mounted) Navigator.pushReplacement(context, MainScaffold.fadeInRoute());
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final pages = _pagesIn(l10n);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppTheme.statusBarOnDark,
      child: Scaffold(
        backgroundColor: AppColors.darkNavy,
        body: Stack(
          fit: StackFit.expand,
          children: [
            PageView.builder(
              controller: _pageController,
              onPageChanged: (index) => setState(() => _currentPage = index),
              itemCount: pages.length,
              itemBuilder: (context, index) {
                final page = pages[index];
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
                    label: _currentPage == pages.length - 1 ? l10n.onboardingGetStarted : l10n.next,
                    onPressed: _onNext,
                  ),
                  const SizedBox(height: 28),
                  _PageDots(count: pages.length, current: _currentPage),
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
