import 'dart:convert';

import 'package:dubai_trip_planner/core/models/place.dart';
import 'package:dubai_trip_planner/core/repositories/place_repository.dart';
import 'package:dubai_trip_planner/features/favorites/cubit/favorites_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  Place placeNamed(String categoryId, String name) =>
      PlaceRepository.getPlacesByCategory(categoryId).firstWhere((p) => p.name == name);

  final burj = placeNamed('must_see', 'Burj Khalifa');
  final mall = placeNamed('shopping', 'Dubai Mall');

  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  test('starts with no favorites', () {
    expect(FavoritesCubit(prefs).state.favoritesList, isEmpty);
  });

  test('toggleFavorite adds a place, a second toggle removes it', () async {
    final cubit = FavoritesCubit(prefs);

    await cubit.toggleFavorite(burj);
    expect(cubit.state.isFavorite(burj.id), isTrue);

    await cubit.toggleFavorite(burj);
    expect(cubit.state.isFavorite(burj.id), isFalse);
    expect(prefs.getStringList('favorites_places'), isEmpty);
  });

  test('favorites survive an app restart', () async {
    final before = FavoritesCubit(prefs);
    await before.toggleFavorite(burj);
    await before.toggleFavorite(mall);

    final after = FavoritesCubit(prefs);

    expect(after.state.favoritesList.map((p) => p.id), [burj.id, mall.id]);
    expect(after.state.favorites[burj.id]!.reviewSummary, burj.reviewSummary);
  });

  // Older versions used the place's position in its list as the id, which
  // pointed at a different place as soon as places were added or reordered.
  test('a favorite saved with an old position-based id gets the stable id', () async {
    SharedPreferences.setMockInitialValues({
      'favorites_places': [jsonEncode({...burj.toJson(), 'id': 'must_see_0'})],
    });
    prefs = await SharedPreferences.getInstance();

    final cubit = FavoritesCubit(prefs);

    expect(cubit.state.favoritesList.map((p) => p.id), [burj.id]);
    expect(cubit.state.isFavorite(burj.id), isTrue);
  });

  test('skips corrupt stored entries and keeps the valid ones', () async {
    SharedPreferences.setMockInitialValues({
      'favorites_places': ['{broken', jsonEncode(burj.toJson()), '{"id": 1}'],
    });
    prefs = await SharedPreferences.getInstance();

    final cubit = FavoritesCubit(prefs);

    expect(cubit.state.favoritesList.map((p) => p.id), [burj.id]);
  });

  test('clear() removes all favorites', () async {
    final cubit = FavoritesCubit(prefs);
    await cubit.toggleFavorite(burj);

    await cubit.clear();

    expect(cubit.state.favoritesList, isEmpty);
    expect(FavoritesCubit(prefs).state.favoritesList, isEmpty);
  });
}
