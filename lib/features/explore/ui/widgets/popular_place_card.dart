import 'package:dubai_trip_planner/core/constants/app_color.dart';
import 'package:dubai_trip_planner/core/constants/app_palette.dart';
import 'package:dubai_trip_planner/core/models/place.dart';
import 'package:dubai_trip_planner/core/widgets/bottom_blur.dart';
import 'package:dubai_trip_planner/core/widgets/place_image.dart';
import 'package:material_ui/material_ui.dart';

/// A card like a small onboarding page: a photo that melts into the place's
/// name at the bottom. It takes the size its parent gives it.
class PopularPlaceCard extends StatelessWidget {
  /// The width of the card in the middle, which the name is laid out for, so
  /// that it does not wrap differently while a card grows or shrinks.
  static const fullWidth = 190.0;

  final Place place;

  /// 1 in the middle of the carousel, where the card shows its name over the
  /// melting photo, and 0 at the sides, where it shows just the photo.
  final double focus;

  const PopularPlaceCard({
    super.key,
    required this.place,
    this.focus = 1,
  });

  @override
  Widget build(BuildContext context) {
    final photo = PlaceImage(place.imageUrl);

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: context.palette.tile,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: context.palette.hairline),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkNavy.withValues(alpha: 0.1),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // A blur is costly while the carousel moves, so only the card in the
          // middle has one.
          if (focus > 0) BottomBlur(photo: photo, sigma: 7, begin: 0.42, end: 0.68) else photo,
          Opacity(
            opacity: focus,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Keeps the name legible on any photo.
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: const [0.4, 0.7, 1],
                      colors: [
                        Colors.transparent,
                        AppColors.darkNavy.withValues(alpha: 0.72),
                        AppColors.darkNavy.withValues(alpha: 0.94),
                      ],
                    ),
                  ),
                ),
                OverflowBox(
                  minWidth: fullWidth,
                  maxWidth: fullWidth,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          place.name,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white, fontSize: 18, height: 1.2),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'DUBAI',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontSize: 9,
                            letterSpacing: 4.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
