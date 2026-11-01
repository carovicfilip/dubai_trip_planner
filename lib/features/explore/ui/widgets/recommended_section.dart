import 'package:dubai_trip_planner/core/models/place.dart';
import 'package:dubai_trip_planner/core/repositories/place_repository.dart';
import 'package:dubai_trip_planner/core/widgets/place_photo_card.dart';
import 'package:dubai_trip_planner/features/favorites/cubit/favorites_cubit.dart';
import 'package:dubai_trip_planner/features/place_details/ui/place_details_screen.dart';
import 'package:dubai_trip_planner/l10n/l10n.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RecommendedSection extends StatelessWidget {
  const RecommendedSection({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Place> featuredPlaces = PlaceRepository.getTopRatedPlaces(limit: 10);
    final favoritesState = context.watch<FavoritesCubit>().state;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(context.l10n.recommendedTitle, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        SizedBox(
          // A little more than the cards, to leave room for their shadow.
          height: PlacePhotoCard.fullHeight + 14,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(bottom: 14),
            itemCount: featuredPlaces.length,
            itemBuilder: (context, index) {
              final place = featuredPlaces[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PlaceDetailsScreen(
                        place: place,
                      ),
                    ),
                  );
                },
                child: PlacePhotoCard(
                  place: place,
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
}
