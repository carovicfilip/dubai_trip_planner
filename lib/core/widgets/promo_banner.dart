import 'package:dubai_trip_planner/features/my_trip/ui/my_trip_screen.dart';
import 'package:flutter/material.dart';

class PromoBanner extends StatefulWidget {
  const PromoBanner({super.key});

  @override
  State<PromoBanner> createState() => _PromoBannerState();
}

class _PromoBannerState extends State<PromoBanner> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _color1;
  late Animation<Color?> _color2;
  late Animation<Color?> _color3;
  late Animation<Color?> _color4;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    // Custom color palette: Warm browns and deep navy
    // _color1 = ColorTween(
    //   begin: const Color(0xFFE6BB93), // Light brown/beige
    //   end: const Color(0xFFAC6A04),
    // ).animate(_controller);

    _color1 = ColorTween(
      begin: const Color(0xFFB2FEFA),
      end: const Color(0xFF00C9FF),
    ).animate(_controller);

    _color2 = ColorTween(
      begin: const Color(0xFF02CAF3),
      end: const Color(0xFF540183),
    ).animate(_controller);

    // _color4 = ColorTween(
    //   begin: const Color(0xFF1A4678),
    //   end: const Color(0xFF032063),
    // ).animate(_controller);
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
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return GestureDetector(
          onTap: _navigateToMyTrip,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: [
                              _color1.value ?? Colors.cyan,
                              _color2.value ?? Colors.purple,
                  // _color3.value ?? const Color(0xFF0E83F7),
                  // _color4.value ?? const Color(0xFF032063),
                ],
              ),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "Discover Dubai",
                        style: TextStyle(
                          fontSize: 19,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              blurRadius: 4,
                              color: Colors.black45,
                              offset: Offset(1, 1),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Create your perfect itinerary with AI-powered trip planning",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              blurRadius: 4,
                              color: Colors.black45,
                              offset: Offset(1, 1),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _navigateToMyTrip,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF101A26),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Plan a Trip",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
