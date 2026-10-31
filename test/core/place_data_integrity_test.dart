import 'dart:io';

import 'package:dubai_trip_planner/core/constants/dummy_places.dart';
import 'package:dubai_trip_planner/core/models/category.dart';
import 'package:dubai_trip_planner/core/repositories/place_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final categories = CategoryRepository.allCategories;
  final places = PlaceRepository.getAllPlaces();

  test('every category has places and all data belongs to a known category', () {
    final ids = categories.map((c) => c.id).toSet();
    expect(dummyPlacesByCategory.keys.toSet(), ids);
    for (final category in categories) {
      expect(PlaceRepository.getPlacesByCategory(category.id), isNotEmpty, reason: category.id);
    }
  });

  test('place ids are unique', () {
    final ids = places.map((p) => p.id).toList();
    expect(ids.toSet(), hasLength(ids.length));
  });

  test('every place has a name, a description and an image file that exists', () {
    for (final place in places) {
      expect(place.name, isNotEmpty, reason: place.id);
      expect(place.description, isNotEmpty, reason: place.name);
      expect(File(place.imageUrl).existsSync(), isTrue, reason: '${place.name}: missing ${place.imageUrl}');
    }
  });

  test('image files really are in the format their extension says', () {
    bool startsWith(List<int> bytes, List<int> prefix) =>
        bytes.length >= prefix.length && List.generate(prefix.length, (i) => bytes[i] == prefix[i]).every((ok) => ok);

    for (final place in places) {
      final bytes = File(place.imageUrl).openSync().readSync(12);
      final ext = place.imageUrl.split('.').last.toLowerCase();
      final ok = switch (ext) {
        'jpg' || 'jpeg' => startsWith(bytes, [0xFF, 0xD8, 0xFF]),
        'png' => startsWith(bytes, [0x89, 0x50, 0x4E, 0x47]),
        'webp' => String.fromCharCodes(bytes.sublist(0, 4)) == 'RIFF' &&
            String.fromCharCodes(bytes.sublist(8, 12)) == 'WEBP',
        _ => false,
      };
      expect(ok, isTrue, reason: '${place.imageUrl} content does not match .$ext');
    }
  });

  test('every category icon exists', () {
    for (final category in categories) {
      expect(File(category.iconPath).existsSync(), isTrue, reason: category.iconPath);
    }
  });

  test('review summaries start with a 0–5 rating (used to sort "Recommended")', () {
    for (final place in places.where((p) => p.reviewSummary != null)) {
      final rating = double.tryParse(RegExp(r'^(\d+\.?\d*)').firstMatch(place.reviewSummary!)?.group(1) ?? '');
      expect(rating, isNotNull, reason: '${place.name}: "${place.reviewSummary}"');
      expect(rating, inInclusiveRange(0, 5), reason: place.name);
    }
  });
}
