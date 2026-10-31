import 'package:dubai_trip_planner/core/models/place.dart';
import 'package:material_ui/material_ui.dart';

class PopularPlaceCard extends StatelessWidget {
  final Place place;
  final int index;

  const PopularPlaceCard({
    super.key,
    required this.place,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 320,
          height: double.infinity,
          margin: const EdgeInsets.only(right: 16),
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.white,
              width: 6,
            ),
            borderRadius: BorderRadius.circular(30),
            color: Colors.grey[300],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: place.imageUrl.isNotEmpty
                ? Image.asset(
                    place.imageUrl,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      debugPrint('Error loading image: ${place.imageUrl}');
                      debugPrint('Error: $error');
                      return Container(
                        width: double.infinity,
                        height: double.infinity,
                        color: Colors.grey[300],
                        child: const Center(
                          child: Icon(
                            Icons.image_not_supported,
                            size: 50,
                            color: Colors.grey,
                          ),
                        ),
                      );
                    },
                  )
                : const Center(
                    child: Icon(
                      Icons.image_not_supported,
                      size: 50,
                      color: Colors.grey,
                    ),
                  ),
          ),
        ),
        Positioned(
          bottom: 4,
          child: Container(
            width: 320,
            padding: const EdgeInsets.only(left: 22, bottom: 12),
            // decoration: BoxDecoration(
            //   color: Colors.black26,
            //   borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
            // ),
            child: Text(
              place.name,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
          ),
        ),
        Positioned(
          left: -38,
          bottom: 38,
          child: Stack(
            children: [
              Text(
                '${index + 1}',
                style: TextStyle(
                  fontSize: 160,
                  fontWeight: FontWeight.bold,
                  foreground: Paint()
                    ..shader = const LinearGradient(
                      colors: [
                        Color(0xFF101A26),
                        Color(0xFF003398),
                        Color(0xFFA3C8F8),
                      ],
                    ).createShader(const Rect.fromLTWH(0, 0, 120, 120))
                    ..style = PaintingStyle.stroke
                    ..strokeWidth = 5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}