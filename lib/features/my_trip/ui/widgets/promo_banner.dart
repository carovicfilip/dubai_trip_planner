import 'dart:math' show cos, pi, sin;

import 'package:dubai_trip_planner/core/constants/app_color.dart';
import 'package:dubai_trip_planner/features/my_trip/ui/my_trip_screen.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:material_ui/material_ui.dart';

/// The card on Explore and Profile that leads to the trip planner: liquid glass
/// with warm light flowing under it, and a white button that breathes and sends
/// slow ripples through the glass. The motion is slow and soft on purpose, to
/// hold the eye without flashing. It is the same in both themes.
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
            // Smoke behind the text: the glow of the header is at its brightest
            // right there, too bright for white text to stay legible.
            gradient: LinearGradient(
              stops: const [0.35, 0.8],
              colors: [AppColors.heroDeep.withValues(alpha: 0.38), AppColors.heroDeep.withValues(alpha: 0)],
            ),
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
                  child: RepaintBoundary(child: CustomPaint(painter: _FlowingLightPainter(_controller))),
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
                                color: Colors.white.withValues(alpha: 0.9),
                                fontSize: 11,
                                height: 1.3,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          _PlanButton(progress: _controller, ripples: _controller.isAnimating),
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

/// How far the button has swollen, from 0 to 1, with four slow breaths per loop.
double _breath(double progress) => 0.5 - 0.5 * cos(progress * 2 * pi * 4);

/// The white button, the strongest contrast on the card: it swells with a warm
/// glow, its arrow leaning forward, and ripples spread from it.
class _PlanButton extends StatelessWidget {
  const _PlanButton({required this.progress, required this.ripples});

  final Animation<double> progress;

  /// Frozen in place, the ripples would only look like stray lines.
  final bool ripples;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        painter: _ButtonLightPainter(progress, ripples: ripples),
        child: AnimatedBuilder(
          animation: progress,
          builder: (context, _) {
            final breath = _breath(progress.value);
            return Transform.scale(
              scale: 1 + 0.03 * breath,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
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
          },
        ),
      ),
    );
  }
}

/// The glow around the button and the ripples spreading from it. Both reach
/// past the button; the card clips them at its edge, like waves in a glass.
class _ButtonLightPainter extends CustomPainter {
  _ButtonLightPainter(this.progress, {required this.ripples}) : super(repaint: progress);

  final Animation<double> progress;
  final bool ripples;

  @override
  void paint(Canvas canvas, Size size) {
    final button = Offset.zero & size;
    final breath = _breath(progress.value);

    canvas.drawRRect(
      RRect.fromRectAndRadius(button.inflate(2 * breath), Radius.circular(size.height / 2 + 2 * breath)),
      Paint()
        ..color = AppColors.heroAmber.withValues(alpha: 0.45 + 0.45 * breath)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 6 + 9 * breath),
    );

    if (!ripples) return;
    for (final delay in const [0.0, 0.5]) {
      final age = (progress.value * 4 + delay) % 1;
      final spread = 3 + 36 * age;
      canvas.drawRRect(
        RRect.fromRectAndRadius(button.inflate(spread), Radius.circular(size.height / 2 + spread)),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          // Comes in softly and is gone before it reaches the text.
          ..color = Colors.white.withValues(alpha: 0.7 * (1 - age) * sin(age * pi))
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1),
      );
    }
  }

  @override
  bool shouldRepaint(_ButtonLightPainter oldDelegate) => progress != oldDelegate.progress || ripples != oldDelegate.ripples;
}

/// Patches of warm light drifting under the glass, and a glint travelling round
/// its edge. Painted without rebuilding anything, so it stays cheap.
class _FlowingLightPainter extends CustomPainter {
  _FlowingLightPainter(this.progress) : super(repaint: progress);

  final Animation<double> progress;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final turn = progress.value * 2 * pi;

    void patch(double x, double y, double radius, Color color, double alpha) {
      canvas.drawRect(
        rect,
        Paint()
          ..shader = RadialGradient(
            center: Alignment(x, y),
            radius: radius,
            stops: const [0, 0.4, 1],
            colors: [
              color.withValues(alpha: alpha),
              color.withValues(alpha: alpha * 0.6),
              color.withValues(alpha: 0),
            ],
          ).createShader(rect),
      );
    }

    // The brightest light stays on the right, around the button and off the text.
    patch(0.9 + 0.3 * cos(turn), 0.3 + 0.7 * sin(turn), 1.35, AppColors.heroOrange, 0.95);
    patch(0.8 + 0.25 * cos(2 * turn + 2), -0.3 + 0.6 * sin(turn + 1), 0.7, AppColors.heroAmber, 0.5);
    patch(-0.35 + 0.55 * cos(turn + 4), 0.9 * sin(2 * turn), 1.1, AppColors.heroEmber, 0.7);

    final glint = SweepGradient(
      transform: GradientRotation(2 * turn),
      stops: const [0, 0.09, 0.18],
      colors: [Colors.white.withValues(alpha: 0), Colors.white, Colors.white.withValues(alpha: 0)],
    ).createShader(rect);
    final edge = RRect.fromRectAndRadius(rect.deflate(1), const Radius.circular(23));
    canvas.drawRRect(edge, Paint()..style = PaintingStyle.stroke..strokeWidth = 2..shader = glint);
  }

  @override
  bool shouldRepaint(_FlowingLightPainter oldDelegate) => progress != oldDelegate.progress;
}

/// What makes it look like glass: a surface lit along the top and in shade along
/// the bottom, an edge that gathers the light, and a bright rim that is strongest
/// at two opposite corners. Almost no white on the surface itself: that would
/// wash the warm light out into beige.
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
          stops: const [0, 0.22, 0.7, 1],
          colors: [
            AppColors.heroAmber.withValues(alpha: 0.34),
            AppColors.heroAmber.withValues(alpha: 0.05),
            AppColors.heroAmber.withValues(alpha: 0.02),
            AppColors.heroDeep.withValues(alpha: 0.22),
          ],
        ).createShader(rect),
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(24)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 7
        ..color = Colors.white.withValues(alpha: 0.2)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
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
