import 'dart:math' show cos, pi, sin;

import 'package:dubai_trip_planner/core/constants/app_color.dart';
import 'package:dubai_trip_planner/features/my_trip/ui/my_trip_screen.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:material_ui/material_ui.dart';

/// The card on Explore and Profile that leads to the trip planner: liquid glass
/// with warm light slowly flowing under it, and a white button that breathes.
/// The motion is slow and soft on purpose, to hold the eye without flashing.
/// It is the same in both themes.
class PromoBanner extends StatefulWidget {
  const PromoBanner({super.key});

  @override
  State<PromoBanner> createState() => _PromoBannerState();
}

class _PromoBannerState extends State<PromoBanner> with SingleTickerProviderStateMixin {
  static const _radius = BorderRadius.all(Radius.circular(24));

  // One long loop drives everything, and each motion repeats a whole number of
  // times in it, so nothing jumps when the loop starts over.
  late final AnimationController _controller = AnimationController(
    duration: const Duration(seconds: 15),
    vsync: this,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _navigateToMyTrip() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const MyTripScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      child: GestureDetector(
        onTap: _navigateToMyTrip,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: _radius,
            // Outer only: the glass is see-through, so a glow under it would
            // cloud it.
            boxShadow: [
              BoxShadow(
                color: AppColors.heroOrange.withValues(alpha: 0.35),
                blurRadius: 24,
                blurStyle: BlurStyle.outer,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: _radius,
            child: Stack(
              children: [
                Positioned.fill(
                  child: RepaintBoundary(
                    child: AnimatedBuilder(
                      animation: _controller,
                      builder: (context, _) => _FlowingLight(progress: _controller.value),
                    ),
                  ),
                ),
                const Positioned.fill(child: CustomPaint(painter: _GlassPainter())),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SvgPicture.asset(
                            'assets/icons/my_trip.svg',
                            height: 20,
                            colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                          ),
                          const Icon(Icons.auto_awesome, size: 16, color: Colors.white),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Your perfect Dubai trip,\nplanned in minutes',
                        style: TextStyle(color: Colors.white, fontSize: 18, height: 1.2),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Dates, hotel, interests.\nWe do the rest.',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.8),
                                fontSize: 11,
                                height: 1.3,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          AnimatedBuilder(
                            animation: _controller,
                            builder: (context, _) => _BreathingButton(progress: _controller.value),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Soft patches of warm light drifting around under the glass, and a sweep of
/// white light crossing it every few seconds.
class _FlowingLight extends StatelessWidget {
  const _FlowingLight({required this.progress});

  /// Where in the animation loop this frame is, from 0 to 1.
  final double progress;

  Widget _patch(Alignment center, double radius, Color color, double alpha) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: center,
          radius: radius,
          colors: [color.withValues(alpha: alpha), color.withValues(alpha: 0)],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final turn = progress * 2 * pi;
    // Three sweeps per loop, each taking the first 28% of its share of the time.
    final sweepTime = (progress * 3) % 1;
    final sweep = Curves.easeInOut.transform((sweepTime / 0.28).clamp(0.0, 1.0));

    return Stack(
      fit: StackFit.expand,
      children: [
        _patch(Alignment(0.95 * cos(turn), 0.9 * sin(turn)), 1.9, AppColors.heroOrange, 0.85),
        _patch(Alignment(0.9 * cos(2 * turn + 2), 0.8 * sin(turn + 1)), 1.2, AppColors.heroAmber, 0.5),
        _patch(Alignment(-0.9 * cos(turn + 4), -0.9 * sin(2 * turn)), 1.4, AppColors.heroBrown, 0.8),
        FractionalTranslation(
          translation: Offset(-1.2 + 2.4 * sweep, 0),
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: const [0.32, 0.5, 0.68],
                colors: [
                  Colors.white.withValues(alpha: 0),
                  Colors.white.withValues(alpha: 0.28),
                  Colors.white.withValues(alpha: 0),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// The white button: it slowly swells with a warm glow, its arrow leaning
/// forward, about every two and a half seconds.
class _BreathingButton extends StatelessWidget {
  const _BreathingButton({required this.progress});

  /// Where in the animation loop this frame is, from 0 to 1.
  final double progress;

  @override
  Widget build(BuildContext context) {
    final breath = 0.5 - 0.5 * cos(progress * 2 * pi * 6);

    return Transform.scale(
      scale: 1 + 0.035 * breath,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.heroOrange.withValues(alpha: 0.35 + 0.5 * breath),
              blurRadius: 8 + 14 * breath,
              spreadRadius: 2 * breath,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Plan My Trip',
              style: TextStyle(color: AppColors.heroDeep, fontSize: 13, fontWeight: FontWeight.w600),
            ),
            const SizedBox(width: 4),
            Transform.translate(
              offset: Offset(2.5 * breath, 0),
              child: const Icon(Icons.arrow_forward_rounded, size: 16, color: AppColors.heroDeep),
            ),
          ],
        ),
      ),
    );
  }
}

/// What makes it look like glass: a thin wet sheen, highlights where the light
/// catches it, and a bright rim that is strongest at two opposite corners.
class _GlassPainter extends CustomPainter {
  const _GlassPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.white.withValues(alpha: 0.16), Colors.white.withValues(alpha: 0.05)],
        ).createShader(rect),
    );
    canvas.drawRect(
      rect,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.55, -1.2),
          radius: 1.3,
          colors: [Colors.white.withValues(alpha: 0.42), Colors.white.withValues(alpha: 0)],
        ).createShader(rect),
    );
    canvas.drawRect(
      rect,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(1.05, 1.3),
          radius: 1.1,
          colors: [Colors.white.withValues(alpha: 0.26), Colors.white.withValues(alpha: 0)],
        ).createShader(rect),
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(rect.deflate(0.75), const Radius.circular(23.25)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: const [0, 0.4, 0.65, 1],
          colors: [
            Colors.white.withValues(alpha: 0.95),
            Colors.white.withValues(alpha: 0.18),
            Colors.white.withValues(alpha: 0.12),
            Colors.white.withValues(alpha: 0.7),
          ],
        ).createShader(rect),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect.deflate(2.25), const Radius.circular(21.75)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8
        ..color = Colors.white.withValues(alpha: 0.14),
    );
  }

  @override
  bool shouldRepaint(_GlassPainter oldDelegate) => false;
}
