import 'dart:ui' show ImageFilter;

import 'package:dubai_trip_planner/core/constants/app_color.dart';
import 'package:dubai_trip_planner/core/constants/app_palette.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

/// The dark blue header with a soft gray glow at the top of the Explore and
/// Profile tabs, the same in the light and the dark theme. It starts behind the status
/// bar; put it first in a [HeroListView].
class GradientHero extends StatelessWidget {
  const GradientHero({
    super.key,
    required this.lightTitle,
    required this.boldTitle,
    this.trailing,
    required this.child,
  });

  final String lightTitle;
  final String boldTitle;

  /// Shown at the end of the first title line.
  final Widget? trailing;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    const titleSize = 30.0;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(36)),
      child: HeroGlow(
        child: Padding(
          padding: EdgeInsets.fromLTRB(16, MediaQuery.paddingOf(context).top + 14, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      lightTitle,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: titleSize,
                        fontWeight: FontWeight.w300,
                        height: 1.2,
                      ),
                    ),
                  ),
                  ?trailing,
                ],
              ),
              Text(
                boldTitle,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: titleSize,
                  fontWeight: FontWeight.w600,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 18),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

/// The dark blue background with a soft gray glow coming in from the side, the
/// look of the header on the Explore and Profile tabs.
class HeroGlow extends StatelessWidget {
  const HeroGlow({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.darkNavy, Color(0xFF1A2532), AppColors.primaryBlue],
        ),
      ),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(-1.1, 0.5),
            radius: 1.25,
            stops: [0, 0.5, 1],
            colors: [Color(0xAAA3AEBA), Color(0x44A3AEBA), Color(0x00A3AEBA)],
          ),
        ),
        child: child,
      ),
    );
  }
}

/// A list that starts with a [GradientHero]. Over the header the status bar is
/// up to the screen, and needs white icons in both themes. Once the header has
/// scrolled away, a band of frosted glass comes in behind the status bar, as on
/// the screens with a frosted app bar, and [statusBarOverPage] takes over.
class HeroListView extends StatefulWidget {
  const HeroListView({super.key, required this.statusBarOverPage, this.padding, required this.children});

  static const statusBarBandKey = ValueKey('hero-status-bar-band');

  final SystemUiOverlayStyle statusBarOverPage;
  final EdgeInsetsGeometry? padding;
  final List<Widget> children;

  @override
  State<HeroListView> createState() => _HeroListViewState();
}

class _HeroListViewState extends State<HeroListView> {
  final _scrollController = ScrollController();
  final _headerKey = GlobalKey();

  // Remembered because a header far out of view is no longer built.
  double? _headerHeight;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// How far the band has come in, from 0 to 1, while the bottom of the header
  /// passes under the status bar.
  double _bandShown(double statusBarHeight) {
    final header = _headerKey.currentContext?.findRenderObject() as RenderBox?;
    if (header != null && header.hasSize) _headerHeight = header.size.height;
    final headerHeight = _headerHeight;
    if (headerHeight == null || !_scrollController.hasClients) return 0;

    final headerBottom = headerHeight - _scrollController.offset;
    return ((statusBarHeight - headerBottom) / 40).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.paddingOf(context).top;
    final bandColor = context.palette.card;

    return Stack(
      fit: StackFit.expand,
      children: [
        ListView(
          controller: _scrollController,
          padding: widget.padding,
          children: [
            KeyedSubtree(key: _headerKey, child: widget.children.first),
            ...widget.children.skip(1),
          ],
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: statusBarHeight,
          child: IgnorePointer(
            child: AnimatedBuilder(
              animation: _scrollController,
              builder: (context, _) {
                final shown = _bandShown(statusBarHeight);
                if (shown == 0) return const SizedBox.shrink();

                // The blur and the color fade in, not the whole band: under an
                // Opacity the blur would have nothing behind it to work on.
                final band = ClipRect(
                  key: HeroListView.statusBarBandKey,
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 20 * shown, sigmaY: 20 * shown),
                    child: ColoredBox(color: bandColor.withValues(alpha: 0.72 * shown)),
                  ),
                );
                return shown < 0.5
                    ? band
                    : AnnotatedRegion<SystemUiOverlayStyle>(value: widget.statusBarOverPage, child: band);
              },
            ),
          ),
        ),
      ],
    );
  }
}
