import 'package:dubai_trip_planner/core/constants/app_palette.dart';
import 'package:dubai_trip_planner/features/my_trip/ui/my_trip_screen.dart';
import 'package:material_ui/material_ui.dart';

/// The animated "Plan a Trip" banner on Explore and Profile.
class PromoBanner extends StatefulWidget {
  const PromoBanner({super.key});

  @override
  State<PromoBanner> createState() => _PromoBannerState();
}

class _PromoBannerState extends State<PromoBanner> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
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
    final palette = context.palette;
    return GestureDetector(
      onTap: _navigateToMyTrip,
      child: AnimatedBuilder(
        animation: _controller,
        // Only the gradient changes from frame to frame, so the text and the
        // button are built once instead of on every frame.
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: palette.hairline),
              gradient: LinearGradient(
                stops: const [0.35, 1],
                colors: [
                  Color.lerp(palette.card, palette.surface, _controller.value)!,
                  Color.lerp(palette.tile, palette.hairline, _controller.value)!,
                ],
              ),
            ),
            padding: const EdgeInsets.all(16),
            child: child,
          );
        },
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Discover Dubai",
                    style: TextStyle(
                      fontSize: 19,
                      color: palette.ink,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Create your perfect itinerary with AI-powered trip planning",
                    style: TextStyle(
                      fontSize: 12,
                      color: palette.muted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: _navigateToMyTrip,
              style: ElevatedButton.styleFrom(
                backgroundColor: palette.accent,
                foregroundColor: palette.onAccent,
                elevation: 0,
                shape: const StadiumBorder(),
              ),
              child: const Text(
                "Plan a Trip",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
