import 'dart:ui' show ImageFilter;

import 'package:dubai_trip_planner/core/constants/app_color.dart';
import 'package:dubai_trip_planner/core/constants/app_palette.dart';
import 'package:dubai_trip_planner/core/models/place.dart';
import 'package:dubai_trip_planner/core/repositories/category_repository.dart';
import 'package:dubai_trip_planner/core/widgets/favorite_button.dart';
import 'package:dubai_trip_planner/core/widgets/glass_card.dart';
import 'package:dubai_trip_planner/core/widgets/place_image.dart';
import 'package:material_ui/material_ui.dart';

/// A place: a small round photo and the favorite button at the top, then the
/// name and category, and the large photo.
class PlacePhotoCard extends StatelessWidget {
  static const fullHeight = 360.0;
  static const compactHeight = 300.0;

  final Place place;
  final bool isFavorite;
  final VoidCallback onFavoriteToggle;

  /// The smaller card of the Categories screen: smaller text and no rating.
  /// Its height is [compactHeight], otherwise [fullHeight].
  final bool compact;

  const PlacePhotoCard({
    super.key,
    required this.place,
    required this.isFavorite,
    required this.onFavoriteToggle,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final category = CategoryRepository.getCategoryName(place.categoryId);

    return GlassCard(
      width: compact ? 230 : 270,
      margin: const EdgeInsets.only(right: 16),
      padding: EdgeInsets.all(compact ? 10 : 12),
      radius: compact ? 30 : 34,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ClipOval(child: SizedBox.square(dimension: compact ? 38 : 44, child: PlaceImage(place.imageUrl))),
              FavoriteButton(
                radius: compact ? 19 : 22,
                iconSize: compact ? 19 : 22,
                backgroundColor: palette.tile,
                iconColor: palette.ink,
                isFavorite: isFavorite,
                onPressed: onFavoriteToggle,
              ),
            ],
          ),
          SizedBox(height: compact ? 8 : 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  place.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: palette.ink, fontSize: compact ? 17 : 22, height: 1.2),
                ),
                if (category != null) ...[
                  SizedBox(height: compact ? 4 : 6),
                  Text(
                    category.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: palette.muted, fontSize: compact ? 9 : 11, letterSpacing: compact ? 4 : 5),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(height: compact ? 10 : 12),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(compact ? 22 : 24),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  PlaceImage(place.imageUrl),
                  if (!compact)
                    Positioned(
                      left: 10,
                      bottom: 10,
                      child: _RatingOnPhoto(summary: place.reviewSummary ?? 'No reviews yet'),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The rating on a piece of frosted glass over the photo.
class _RatingOnPhoto extends StatelessWidget {
  const _RatingOnPhoto({required this.summary});

  final String summary;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.28),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.star_rounded, size: 18, color: AppColors.sand),
              const SizedBox(width: 4),
              Text(summary, style: const TextStyle(color: Colors.white, fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}
