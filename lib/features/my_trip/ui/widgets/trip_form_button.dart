import 'package:dubai_trip_planner/core/constants/app_color.dart';
import 'package:dubai_trip_planner/core/constants/app_palette.dart';
import 'package:material_ui/material_ui.dart';

/// The button under the trip form, in the colors of the card on Explore that
/// leads here. Until the step is filled in, it is plain gray with a lock.
class TripFormButton extends StatelessWidget {
  const TripFormButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
    this.isLoading = false,
  });

  /// The colors of the button once it is open.
  static const gradient = LinearGradient(
    begin: AlignmentDirectional.centerStart,
    end: AlignmentDirectional.centerEnd,
    stops: [0, 0.62, 1],
    colors: [AppColors.heroBrown, AppColors.heroEmber, AppColors.heroOrange],
  );

  static const _height = 58.0;
  static const _fade = Duration(milliseconds: 250);

  final String label;
  final IconData icon;

  /// Null keeps the button locked, unless it [isLoading].
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final isLocked = onPressed == null && !isLoading;
    final palette = context.palette;

    return SizedBox(
      height: _height,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          AnimatedOpacity(duration: _fade, opacity: isLocked ? 0 : 1, child: const _LitSurface(radius: _height / 2)),
          AnimatedOpacity(
            duration: _fade,
            opacity: isLocked ? 1 : 0,
            child: DecoratedBox(
              decoration: ShapeDecoration(
                color: palette.tile,
                shape: StadiumBorder(side: BorderSide(color: palette.hairline)),
              ),
            ),
          ),
          TextButton(
            onPressed: onPressed,
            style: TextButton.styleFrom(
              // The theme paints its buttons, which would hide the surfaces above.
              backgroundColor: Colors.transparent,
              disabledBackgroundColor: Colors.transparent,
              foregroundColor: Colors.white,
              disabledForegroundColor: isLocked ? palette.muted : Colors.white,
              shape: const StadiumBorder(),
            ),
            child: AnimatedSwitcher(
              duration: _fade,
              child: Row(
                key: ValueKey('$label $isLocked $isLoading'),
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isLoading) ...[
                    const SizedBox.square(
                      dimension: 20,
                      child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                  ] else if (isLocked) ...[
                    const Icon(Icons.lock_outline_rounded, size: 18),
                    const SizedBox(width: 8),
                  ],
                  Flexible(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                  if (!isLocked && !isLoading) ...[
                    const SizedBox(width: 10),
                    Icon(icon, size: 18),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LitSurface extends StatelessWidget {
  const _LitSurface({required this.radius});

  final double radius;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: TripFormButton.gradient,
        boxShadow: [
          BoxShadow(color: AppColors.heroEmber.withValues(alpha: 0.35), blurRadius: 14, offset: const Offset(0, 6)),
        ],
      ),
      // The light along the top. A bright rim as on the Explore card would melt
      // into a light page and leave the edge looking blurred.
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.center,
            colors: [Colors.white.withValues(alpha: 0.22), Colors.white.withValues(alpha: 0)],
          ),
        ),
      ),
    );
  }
}
