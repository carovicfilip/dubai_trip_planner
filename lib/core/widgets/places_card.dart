import 'package:dubai_trip_planner/core/constants/app_palette.dart';
import 'package:dubai_trip_planner/core/models/place.dart';
import 'package:dubai_trip_planner/core/widgets/favorite_button.dart';
import 'package:dubai_trip_planner/core/widgets/place_image.dart';
import 'package:dubai_trip_planner/l10n/l10n.dart';
import 'package:material_ui/material_ui.dart';

class PlacesCard extends StatelessWidget {
  final Place place;
  final VoidCallback? onFavoriteToggle;
  final bool isFavorite;

  const PlacesCard({
    super.key,
    required this.place,
    this.onFavoriteToggle,
    required this.isFavorite,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final l10n = context.l10n;
    return Container(
      width: 250,
      margin: const EdgeInsetsDirectional.only(end: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Slika + Favorite button u Stack-u
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(color: palette.tile),
                  child: PlaceImage(place.imageUrl, height: 200),
                ),
              ),
              // Favorite button - top right
              PositionedDirectional(
                top: 10,
                end: 10,
                child: FavoriteButton(
                  isFavorite: isFavorite,
                  onPressed: onFavoriteToggle,
                ),
              ),
            ],
          ),

          // Beli deo ispod slike
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: palette.card,
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(24),
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x12101A26),
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.placeText(place).name,
                  style: TextStyle(
                    color: palette.ink,
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        l10n.reviewSummaryText(place),
                        style: TextStyle(
                          color: palette.muted,
                          fontSize: 13,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
