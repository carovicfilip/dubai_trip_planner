import 'package:dubai_trip_planner/core/models/place.dart';
import 'package:dubai_trip_planner/core/repositories/place_repository.dart';
import 'package:dubai_trip_planner/features/favorites/cubit/favorites_cubit.dart';
import 'package:dubai_trip_planner/features/explore/ui/widgets/places_card.dart';
import 'package:dubai_trip_planner/features/place_details/screens/more_details_screen.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RecommendedSection extends StatelessWidget {
  final bool isCategoryScreen;

  const RecommendedSection({
    super.key,
    this.isCategoryScreen = false,
  });

  @override
  Widget build(BuildContext context) {
    // Get all places and sort by reviewSummary rating (best first)
    final List<Place> allPlaces = PlaceRepository.getAllPlaces();
    final List<Place> featuredPlaces = _getTopRatedPlaces(allPlaces, limit: 10);
    final favoritesState = context.watch<FavoritesCubit>().state;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        if (!isCategoryScreen)
        Text("Recommended", style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        SizedBox(
          height: 280,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: featuredPlaces.length,
            itemBuilder: (context, index) {
              final place = featuredPlaces[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MoreDetailsScreen(
                        place: place,
                      ),
                    ),
                  );
                },
                child: PlacesCard(
                  place: place,
                  index: index,
                  isFavorite: favoritesState.isFavorite(place.id),
                  onFavoriteToggle: () =>
                      context.read<FavoritesCubit>().toggleFavorite(place),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  /// Extracts rating from reviewSummary string (e.g., "4.7 (169k reviews)" -> 4.7)
  /// Returns 0.0 if reviewSummary is null or cannot be parsed
  double _extractRating(String? reviewSummary) {
    if (reviewSummary == null || reviewSummary.isEmpty) return 0.0;
    final match = RegExp(r'^(\d+\.?\d*)').firstMatch(reviewSummary);
    if (match != null) {
      return double.tryParse(match.group(1) ?? '0') ?? 0.0;
    }
    return 0.0;
  }

  /// Returns top rated places sorted by rating extracted from reviewSummary (best first)
  List<Place> _getTopRatedPlaces(List<Place> places, {int limit = 10}) {
    final sorted = List<Place>.from(places)
      ..sort((a, b) {
        final ratingA = _extractRating(a.reviewSummary);
        final ratingB = _extractRating(b.reviewSummary);
        // Sort descending (highest rating first)
        return ratingB.compareTo(ratingA);
      });
    return sorted.take(limit).toList();
  }
}
