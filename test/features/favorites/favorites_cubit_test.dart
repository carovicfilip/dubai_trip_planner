import 'dart:convert';

import 'package:dubai_trip_planner/core/models/place.dart';
import 'package:dubai_trip_planner/features/favorites/cubit/favorites_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  const burj = Place(
    id: 'must_see_0',
    categoryId: 'must_see',
    name: 'Burj Khalifa',
    description: 'Tallest building in the world',
    imageUrl: 'assets/places_images/must_see_1.jpg',
    reviewSummary: '4.7 (166k reviews)',
  );
  const mall = Place(
    id: 'shopping_0',
    categoryId: 'shopping',
    name: 'The Dubai Mall',
    description: 'Huge mall',
    imageUrl: 'assets/places_images/shopping_1.webp',
  );

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

    expect(after.state.favoritesList.map((p) => p.id), ['must_see_0', 'shopping_0']);
    expect(after.state.favorites['must_see_0']!.reviewSummary, '4.7 (166k reviews)');
  });

  test('skips corrupt stored entries and keeps the valid ones', () async {
    SharedPreferences.setMockInitialValues({
      'favorites_places': ['{broken', jsonEncode(burj.toJson()), '{"id": 1}'],
    });
    prefs = await SharedPreferences.getInstance();

    final cubit = FavoritesCubit(prefs);

    expect(cubit.state.favoritesList.map((p) => p.id), ['must_see_0']);
  });

  test('clear() removes all favorites', () async {
    final cubit = FavoritesCubit(prefs);
    await cubit.toggleFavorite(burj);

    await cubit.clear();

    expect(cubit.state.favoritesList, isEmpty);
    expect(FavoritesCubit(prefs).state.favoritesList, isEmpty);
  });
}
