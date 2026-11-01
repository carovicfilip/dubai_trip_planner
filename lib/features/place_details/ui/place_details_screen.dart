import 'dart:math' show max;
import 'dart:ui' show ImageFilter;

import 'package:dubai_trip_planner/app/theme/app_theme.dart';
import 'package:dubai_trip_planner/core/constants/app_color.dart';
import 'package:dubai_trip_planner/core/models/place.dart';
import 'package:dubai_trip_planner/core/repositories/category_repository.dart';
import 'package:dubai_trip_planner/core/widgets/custom_back_button.dart';
import 'package:dubai_trip_planner/core/widgets/glass_button.dart';
import 'package:dubai_trip_planner/core/widgets/place_image.dart';
import 'package:dubai_trip_planner/features/app_rating/ui/app_rating_prompt.dart';
import 'package:dubai_trip_planner/features/favorites/cubit/favorites_cubit.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

final _softWhite = Colors.white.withValues(alpha: 0.85);
final _dimWhite = Colors.white.withValues(alpha: 0.65);

class PlaceDetailsScreen extends StatelessWidget {
  final Place place;

  const PlaceDetailsScreen({super.key, required this.place});

  @override
  Widget build(BuildContext context) {
    final favoritesCubit = context.watch<FavoritesCubit>();
    final isFavorite = favoritesCubit.state.isFavorite(place.id);
    final screenHeight = MediaQuery.sizeOf(context).height;
    final titleAreaHeight = max(screenHeight * 0.46, 300.0);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppTheme.statusBarOnDark,
      child: Scaffold(
        backgroundColor: AppColors.darkNavy,
        body: Stack(
          fit: StackFit.expand,
          children: [
            const AppRatingPrompt(),
            _PhotoBackground(image: place.imageUrl),
            // Stays in place, so the panel slides over it when scrolling
            // rather than pushing it under the status bar.
            Positioned(
              left: 28,
              right: 28,
              top: 0,
              height: titleAreaHeight - 24,
              child: OverflowBox(
                minHeight: 0,
                maxHeight: double.infinity,
                alignment: Alignment.bottomCenter,
                child: _PlaceTitle(name: place.name),
              ),
            ),
            SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: titleAreaHeight),
                  ConstrainedBox(
                    constraints: BoxConstraints(minHeight: screenHeight - titleAreaHeight),
                    child: _GlassPanel(
                      // The button stays over the end of the panel.
                      bottomSpace: 110 + MediaQuery.paddingOf(context).bottom,
                      child: _PlaceInfo(place: place),
                    ),
                  ),
                ],
              ),
            ),
            // Text scrolling under the button fades away instead of crossing it.
            Align(
              alignment: Alignment.bottomCenter,
              child: IgnorePointer(
                child: Container(
                  height: 140,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, AppColors.darkNavy.withValues(alpha: 0.94)],
                    ),
                  ),
                ),
              ),
            ),
            const SafeArea(
              child: Align(alignment: Alignment.topLeft, child: CustomBackButton()),
            ),
            SafeArea(
              minimum: const EdgeInsets.only(bottom: 16),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: GlassButton(
                  label: isFavorite ? 'Saved to Favorites' : 'Add to Favorites',
                  icon: isFavorite ? Icons.favorite : Icons.favorite_border,
                  width: 260,
                  onPressed: () => favoritesCubit.toggleFavorite(place),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The photo fading into dark at the bottom, like the onboarding and splash
/// screens. Most place photos are too small to fill a screen sharply, so the
/// photo itself covers only the top part, over a blurred copy of it.
class _PhotoBackground extends StatelessWidget {
  const _PhotoBackground({required this.image});

  final String image;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: 30, sigmaY: 30, tileMode: TileMode.clamp),
          child: PlaceImage(image),
        ),
        Align(
          alignment: Alignment.topCenter,
          child: FractionallySizedBox(
            heightFactor: 0.56,
            child: ShaderMask(
              blendMode: BlendMode.dstIn,
              shaderCallback: (bounds) => const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.7, 1],
                colors: [Colors.white, Colors.transparent],
              ).createShader(bounds),
              child: PlaceImage(image),
            ),
          ),
        ),
        // Keeps the status bar, the title and the panel legible on any photo.
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: const [0, 0.14, 0.24, 0.44, 0.68, 1],
              colors: [
                Colors.black.withValues(alpha: 0.28),
                Colors.transparent,
                Colors.transparent,
                AppColors.darkNavy.withValues(alpha: 0.6),
                AppColors.darkNavy.withValues(alpha: 0.72),
                AppColors.darkNavy.withValues(alpha: 0.94),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _PlaceTitle extends StatelessWidget {
  const _PlaceTitle({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    // The title sits on the photo, which can be bright.
    final shadows = [Shadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 14)];
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          name,
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white, fontSize: 36, height: 1.2, shadows: shadows),
        ),
        const SizedBox(height: 14),
        Text(
          'DUBAI',
          style: TextStyle(color: _softWhite, fontSize: 13, letterSpacing: 7, shadows: shadows),
        ),
      ],
    );
  }
}

class _GlassPanel extends StatelessWidget {
  const _GlassPanel({required this.bottomSpace, required this.child});

  final double bottomSpace;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    const shape = BorderRadius.vertical(top: Radius.circular(36));
    return ClipRRect(
      borderRadius: shape,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(16, 16, 16, bottomSpace),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: shape,
            border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
          ),
          child: child,
        ),
      ),
    );
  }
}

/// Everything the app knows about the place. A place may lack its location,
/// reviews or opening hours; whatever is missing is left out.
class _PlaceInfo extends StatelessWidget {
  const _PlaceInfo({required this.place});

  final Place place;

  @override
  Widget build(BuildContext context) {
    final reviewSummary = place.reviewSummary;
    final openingHours = place.openingHours;
    final hasReviews = reviewSummary != null && reviewSummary.isNotEmpty;
    final hasHours = openingHours != null && openingHours.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SummaryCard(place: place),
        if (hasReviews || hasHours) ...[
          const SizedBox(height: 22),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (hasReviews)
                    Expanded(
                      flex: 2,
                      child: _Rating(rating: place.rating, summary: reviewSummary),
                    ),
                  if (hasReviews && hasHours)
                    VerticalDivider(width: 28, thickness: 1, color: Colors.white.withValues(alpha: 0.2)),
                  if (hasHours)
                    Expanded(
                      flex: 3,
                      child: _OpeningHours(hours: openingHours),
                    ),
                ],
              ),
            ),
          ),
        ],
        if (place.description.isNotEmpty) ...[
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _SmallHeading('About'),
                const SizedBox(height: 8),
                Text(
                  place.description,
                  style: TextStyle(color: _softWhite, fontSize: 15, height: 1.45),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

/// The photo with the place's category and where to find it.
class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.place});

  final Place place;

  @override
  Widget build(BuildContext context) {
    final category = CategoryRepository.getCategoryName(place.categoryId);
    final location = place.location;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: SizedBox.square(dimension: 100, child: PlaceImage(place.imageUrl)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (category != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      category.toUpperCase(),
                      style: TextStyle(color: _softWhite, fontSize: 10, letterSpacing: 1.5),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
                if (location != null && location.isNotEmpty)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.location_on_outlined, size: 18, color: _softWhite),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          location,
                          style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.35),
                        ),
                      ),
                    ],
                  )
                else
                  Text(
                    place.name,
                    style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.35),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Rating extends StatelessWidget {
  const _Rating({required this.rating, required this.summary});

  final double rating;

  /// E.g. "4.7 (166k reviews)".
  final String summary;

  @override
  Widget build(BuildContext context) {
    final reviews = RegExp(r'\((.+)\)').firstMatch(summary)?.group(1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SmallHeading('Rating'),
        const SizedBox(height: 6),
        Row(
          children: [
            const Icon(Icons.star_rounded, size: 22, color: AppColors.sand),
            const SizedBox(width: 4),
            Text('$rating', style: const TextStyle(color: Colors.white, fontSize: 20)),
          ],
        ),
        if (reviews != null) Text(reviews, style: TextStyle(color: _dimWhite, fontSize: 12)),
      ],
    );
  }
}

class _OpeningHours extends StatelessWidget {
  const _OpeningHours({required this.hours});

  final String hours;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SmallHeading('Opening hours'),
        const SizedBox(height: 6),
        Text(
          // One line per group of days.
          hours.replaceAll(', ', '\n'),
          style: TextStyle(color: _softWhite, fontSize: 13, height: 1.45),
        ),
      ],
    );
  }
}

class _SmallHeading extends StatelessWidget {
  const _SmallHeading(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text, style: TextStyle(color: _dimWhite, fontSize: 13));
  }
}
