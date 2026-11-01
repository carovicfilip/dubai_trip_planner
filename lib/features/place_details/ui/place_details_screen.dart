import 'package:dubai_trip_planner/core/models/place.dart';
import 'package:dubai_trip_planner/core/widgets/custom_back_button.dart';
import 'package:dubai_trip_planner/core/widgets/favorite_button.dart';
import 'package:dubai_trip_planner/core/widgets/place_image.dart';
import 'package:dubai_trip_planner/features/favorites/cubit/favorites_cubit.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PlaceDetailsScreen extends StatelessWidget {
  final Place place;

  const PlaceDetailsScreen({super.key, required this.place});

  @override
  Widget build(BuildContext context) {
    final favoritesCubit = context.watch<FavoritesCubit>();
    final isFavorite = favoritesCubit.state.isFavorite(place.id);

    return Scaffold(
      body: ListView(
        children: [
          Stack(
            clipBehavior: Clip.none, // 👈 bitno da omogući prelaženje van Stack-a
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
                child: PlaceImage(place.imageUrl, height: 300),
              ),
              Positioned(
                top: 2,
                left: 2,
                child: CustomBackButton(),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: FavoriteButton(
                  isFavorite: isFavorite,
                  onPressed: () => context.read<FavoritesCubit>().toggleFavorite(place),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              place.name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 10,
              children: [
                if (place.reviewSummary?.isNotEmpty ?? false)
                  _InfoChip(
                    icon: Icons.star_rounded,
                    label: place.reviewSummary!,
                  ),
                if (place.openingHours?.isNotEmpty ?? false)
                  _InfoChip(
                    icon: Icons.access_time_rounded,
                    label: place.openingHours!,
                  ),
                if (place.location?.isNotEmpty ?? false)
                  _InfoChip(
                    icon: Icons.pin_drop,
                    label: place.location!,
                  ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              place.description,
              style: const TextStyle(fontSize: 15, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.black38),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }
}
