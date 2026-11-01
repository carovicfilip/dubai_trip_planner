import 'package:dubai_trip_planner/core/constants/app_color.dart';
import 'package:material_ui/material_ui.dart';

/// What makes it look like glass: a surface lit along the top and in shade along
/// the bottom, an edge that gathers the light, and a bright rim that is strongest
/// at two opposite corners. Almost no white on the surface itself: that would
/// wash the warm light out into beige.
class LiquidGlassPainter extends CustomPainter {
  const LiquidGlassPainter({required this.radius, this.light = AppColors.heroAmber, this.shade = AppColors.heroDeep});

  /// The radius of the corners of what it is painted on.
  final double radius;

  /// The tint of the light along the top and of the shade along the bottom.
  final Color light;
  final Color shade;

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
            light.withValues(alpha: 0.34),
            light.withValues(alpha: 0.05),
            light.withValues(alpha: 0.02),
            shade.withValues(alpha: 0.22),
          ],
        ).createShader(rect),
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(radius)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 7
        ..color = Colors.white.withValues(alpha: 0.2)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(rect.deflate(0.75), Radius.circular(radius - 0.75)),
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
      RRect.fromRectAndRadius(rect.deflate(2.25), Radius.circular(radius - 2.25)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8
        ..color = Colors.white.withValues(alpha: 0.14),
    );
  }

  @override
  bool shouldRepaint(LiquidGlassPainter oldDelegate) =>
      radius != oldDelegate.radius || light != oldDelegate.light || shade != oldDelegate.shade;
}
