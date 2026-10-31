import 'package:dubai_trip_planner/core/models/place.dart';
import 'package:dubai_trip_planner/core/widgets/favorite_button.dart';
import 'package:material_ui/material_ui.dart';

class PlacesCard extends StatelessWidget {
  final Place place;
  final int index;
  final VoidCallback? onFavoriteToggle;
  final bool isFavorite;

  const PlacesCard({
    super.key,
    required this.place,
    required this.index,
    this.onFavoriteToggle,
    required this.isFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      margin: const EdgeInsets.only(right: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Slika + Favorite button u Stack-u
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.white,
                      width: 1,
                    ),
                    color: Colors.grey[300],
                  ),
                  child: place.imageUrl.isNotEmpty
                      ? Image.asset(
                          place.imageUrl,
                          width: double.infinity,
                          height: 200,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            debugPrint('Error loading image: ${place.imageUrl}');
                            debugPrint('Error: $error');
                            return Container(
                              width: double.infinity,
                              height: 200,
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
              // Favorite button - top right
              Positioned(
                top: 10,
                right: 10,
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
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  place.name,
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                // Kratak opis
                // Text(
                //   place.description,
                //   style: const TextStyle(
                //     color: Colors.black54,
                //     fontSize: 13,
                //   ),
                //   maxLines: 1,
                //   overflow: TextOverflow.ellipsis,
                // ),
                // const SizedBox(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        place.reviewSummary ?? 'No reviews yet',
                        style: const TextStyle(
                          color: Colors.grey,
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
