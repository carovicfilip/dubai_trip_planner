import 'package:dubai_trip_planner/core/constants/app_color.dart';
import 'package:dubai_trip_planner/core/constants/app_palette.dart';
import 'package:material_ui/material_ui.dart';

/// A card with a thin edge and a soft shadow for the home screen. It has no
/// real blur: over that even background it would look the same, and on every
/// card of a long screen it would cost smooth scrolling.
class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.width,
    this.margin,
    this.padding,
    this.radius = 24,
  });

  final Widget child;
  final double? width;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      margin: margin,
      padding: padding,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: context.palette.card,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: context.palette.hairline),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkNavy.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}
