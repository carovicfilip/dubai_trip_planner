import 'dart:ui' show ImageFilter;

import 'package:dubai_trip_planner/core/constants/app_palette.dart';
import 'package:dubai_trip_planner/features/categories/ui/categories_screen.dart';
import 'package:dubai_trip_planner/features/explore/ui/explore_screen.dart';
import 'package:dubai_trip_planner/features/my_trip/ui/my_trip_screen.dart';
import 'package:dubai_trip_planner/features/profile/ui/profile_screen.dart';
import 'package:dubai_trip_planner/l10n/l10n.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  /// The way in from the full-screen photos of onboarding and the splash.
  static Route<void> fadeInRoute() => PageRouteBuilder(
    transitionDuration: const Duration(milliseconds: 400),
    pageBuilder: (_, _, _) => const MainScaffold(),
    transitionsBuilder: (_, animation, _, child) => FadeTransition(opacity: animation, child: child),
  );

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;

  // Only the selected tab is built, so switching tabs starts each screen
  // over. State that has to survive that lives in cubits above the app
  // (FavoritesCubit, MyTripCubit) or in caches (the weather forecast).
  static const _screens = [ExploreScreen(), MyTripScreen(), CategoryScreen(), ProfileScreen()];

  Widget _buildNavItem({required Widget icon, required int index, required String label}) {
    final bool isSelected = _currentIndex == index;
    final palette = context.palette;
    // The icons say nothing to a screen reader; the label names the tab.
    return Expanded(
      child: Semantics(
        label: label,
        button: true,
        selected: isSelected,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => setState(() => _currentIndex = index),
          child: Container(
            decoration: isSelected
                ? BoxDecoration(color: palette.accent, borderRadius: BorderRadius.circular(29))
                : null,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconTheme(
                  data: IconThemeData(color: isSelected ? palette.onAccent : palette.ink, size: 24),
                  child: icon,
                ),
                const SizedBox(height: 2),
                ExcludeSemantics(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    // Some languages have long words for these.
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        label,
                        style: TextStyle(color: isSelected ? palette.onAccent : palette.muted, fontSize: 11),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      // Only Explore runs on under the floating bar. The other tabs stay above
      // it: My Trip pins a button to the bottom of its screen.
      extendBody: _currentIndex == 0,
      body: _screens[_currentIndex],
      bottomNavigationBar: SafeArea(
        top: false,
        minimum: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(34),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.16), blurRadius: 18, offset: const Offset(0, 6)),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(34),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: Container(
                height: 68,
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: context.palette.card.withValues(alpha: 0.82),
                  borderRadius: BorderRadius.circular(34),
                ),
                child: Row(
                  children: [
                    _buildNavItem(icon: const Icon(Icons.home_filled), index: 0, label: l10n.navExplore),
                    _buildNavItem(
                      icon: SvgPicture.asset(
                        'assets/icons/my_trip.svg',
                        height: 26,
                        colorFilter: ColorFilter.mode(
                          _currentIndex == 1 ? context.palette.onAccent : context.palette.ink,
                          BlendMode.srcIn,
                        ),
                      ),
                      index: 1,
                      label: l10n.navMyTrip,
                    ),
                    _buildNavItem(icon: const Icon(Icons.explore_outlined), index: 2, label: l10n.navCategories),
                    _buildNavItem(icon: const Icon(Icons.person), index: 3, label: l10n.navProfile),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
