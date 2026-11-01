import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:dubai_trip_planner/core/constants/dummy_places.dart';
import 'package:dubai_trip_planner/core/repositories/category_repository.dart';
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

  // An image is decoded at its full size however small it is shown: a
  // 6720x4480 photo takes about 120 MB of memory, and every pixel also makes
  // the download bigger. Place photos are at most a screen wide (1290 px on
  // the largest phones; 1920 px leaves room for well-compressed sources),
  // category icons at most 60 dp (180 px).
  test('images are no larger than the app shows them', () async {
    Future<int> longEdge(String path) async {
      final buffer = await ui.ImmutableBuffer.fromUint8List(File(path).readAsBytesSync());
      final descriptor = await ui.ImageDescriptor.encoded(buffer);
      final edge = max(descriptor.width, descriptor.height);
      descriptor.dispose();
      buffer.dispose();
      return edge;
    }

    for (final place in places) {
      expect(await longEdge(place.imageUrl), lessThanOrEqualTo(1920), reason: place.imageUrl);
    }
    for (final category in categories) {
      expect(await longEdge(category.iconPath), lessThanOrEqualTo(256), reason: category.iconPath);
    }
  });

  test('review summaries start with a 0–5 rating (used to sort "Recommended")', () {
    for (final place in places.where((p) => p.reviewSummary != null)) {
      expect(place.rating, inExclusiveRange(0, 5.01), reason: '${place.name}: "${place.reviewSummary}"');
    }
  });

  test('"Recommended" lists the best rated places first', () {
    final top = PlaceRepository.getTopRatedPlaces(limit: 10);
    expect(top, hasLength(10));
    for (var i = 1; i < top.length; i++) {
      expect(top[i - 1].rating, greaterThanOrEqualTo(top[i].rating), reason: '${top[i - 1].name} before ${top[i].name}');
    }
    final best = places.map((p) => p.rating).reduce(max);
    expect(top.first.rating, best);
  });

  // Saved favorites are keyed by id. An id made from the position in the list
  // pointed at another place as soon as places were added or reordered.
  test('a place id comes from its category and name, not its position', () {
    expect(PlaceRepository.getFeaturedPlaces().first.id, 'must_see_burj-khalifa');
    expect(PlaceRepository.placeId('culture_museums', 'Dubai Aquarium & Underwater Zoo'),
        'culture_museums_dubai-aquarium-underwater-zoo');
    for (final place in places) {
      expect(place.id, PlaceRepository.placeId(place.categoryId, place.name));
    }
  });
}
