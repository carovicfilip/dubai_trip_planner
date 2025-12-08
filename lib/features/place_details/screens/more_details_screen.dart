import 'package:dubai_trip_planner/core/models/place.dart';
import 'package:dubai_trip_planner/core/widgets/custom_back_button.dart';
import 'package:dubai_trip_planner/core/widgets/favorite_button.dart';
import 'package:dubai_trip_planner/features/favorites/cubit/favorites_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MoreDetailsScreen extends StatelessWidget {
  final Place place;

  const MoreDetailsScreen({super.key, required this.place});

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
                child: place.imageUrl.isNotEmpty
                    ? Image.asset(
                        place.imageUrl,
                        width: double.infinity,
                        height: 300,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          debugPrint('Error loading image: ${place.imageUrl}');
                          debugPrint('Error: $error');
                          return Container(
                            width: double.infinity,
                            height: 300,
                            color: Colors.grey[300],
                            child: const Icon(Icons.image_not_supported, size: 50),
                          );
                        },
                      )
                    : Container(
                        width: double.infinity,
                        height: 300,
                        color: Colors.grey[300],
                        child: const Icon(Icons.image_not_supported, size: 50),
                      ),
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
              // 👇 Tvoj container u donjem desnom uglu, koji prelazi ispod sadržaja
              // Positioned(
              //   bottom: -60,
              //   right: 28,
              //   child: Container(
              //     width: 130,
              //     height: 130,
              //     decoration: BoxDecoration(
              //       shape: BoxShape.circle,
              //       border: Border.all(
              //         color: Colors.white, // 👈 beli border
              //         width: 2,
              //       ),
              //       image: DecorationImage(
              //         image: NetworkImage(place.imageUrl),
              //         fit: BoxFit.cover, // 👈 da lepo popuni krug
              //       ),
              //     ),
              //   ),
              // ),

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
              children: [
                if (place.reviewSummary != null && place.reviewSummary!.isNotEmpty)
                  _InfoChip(
                    icon: Icons.star_rounded,
                    label: place.reviewSummary!,
                  ),
                if (place.reviewSummary != null && place.reviewSummary!.isNotEmpty && place.openingHours != null && place.openingHours!.isNotEmpty) const SizedBox(height: 10),
                if (place.openingHours != null && place.openingHours!.isNotEmpty)
                  _InfoChip(
                    icon: Icons.access_time_rounded,
                    label: place.openingHours!,
                  ),
                if ((place.reviewSummary != null && place.reviewSummary!.isNotEmpty || place.openingHours != null && place.openingHours!.isNotEmpty) && place.location != null && place.location!.isNotEmpty) const SizedBox(height: 10),
                if (place.location != null && place.location!.isNotEmpty)
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