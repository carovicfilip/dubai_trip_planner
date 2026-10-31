import 'package:dubai_trip_planner/core/models/place.dart';
import 'package:dubai_trip_planner/core/repositories/place_repository.dart';
import 'package:dubai_trip_planner/features/explore/ui/widgets/popular_place_card.dart';
import 'package:dubai_trip_planner/features/place_details/screens/more_details_screen.dart';
import 'package:flutter/material.dart';

class MostPopularSection extends StatelessWidget {
  const MostPopularSection({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Place> popularPlaces = PlaceRepository.getFeaturedPlaces().take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Most Popular Places", style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        SizedBox(
          height: 300,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: popularPlaces.length,
            itemBuilder: (context, index) {
              final place = popularPlaces[index];
              return Padding(
                padding: const EdgeInsets.only(left: 30.0),
                child: GestureDetector(
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
                  child: PopularPlaceCard(
                    place: place,
                    index: index,
                  ),
                ),
              );
            },
            separatorBuilder: (_, _) => const SizedBox(width: 12),
          ),
        ),
      ],
    );
  }
}