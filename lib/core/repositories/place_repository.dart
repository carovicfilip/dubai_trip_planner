import 'package:dubai_trip_planner/core/constants/dummy_places.dart';
import 'package:dubai_trip_planner/core/models/place.dart';

class PlaceRepository {
  const PlaceRepository._();

  // Built once: the data never changes, and widgets ask for it on every build.
  static final Map<String, List<Place>> _placesByCategory = {
    for (final entry in dummyPlacesByCategory.entries)
      entry.key: List.unmodifiable([
        for (final dummy in entry.value)
          Place(
            id: placeId(entry.key, dummy.name ?? ''),
            categoryId: entry.key,
            name: dummy.name ?? '',
            description: dummy.description ?? '',
            imageUrl: dummy.imageUrl ?? '',
            openingHours: dummy.openingHours,
            location: dummy.location,
            reviewSummary: dummy.reviewSummary,
          ),
      ]),
  };

  static final List<Place> _allPlaces = List.unmodifiable(_placesByCategory.values.expand((places) => places));

  /// Made from the category and the name rather than the position in the
  /// list, so adding or reordering places never moves a saved favorite onto
  /// a different place.
  static String placeId(String categoryId, String name) {
    final slug = name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-').replaceAll(RegExp(r'^-|-$'), '');
    return '${categoryId}_$slug';
  }

  static List<Place> getPlacesByCategory(String categoryId) => _placesByCategory[categoryId] ?? const [];

  static List<Place> getFeaturedPlaces() => getPlacesByCategory('must_see');

  static List<Place> getAllPlaces() => _allPlaces;

  /// The best rated places first; places without a rating come last.
  static List<Place> getTopRatedPlaces({int limit = 10}) {
    final sorted = List<Place>.of(_allPlaces)..sort((a, b) => b.rating.compareTo(a.rating));
    return List.unmodifiable(sorted.take(limit));
  }
}
