import 'dart:convert';

import 'package:dubai_trip_planner/core/models/place.dart';
import 'package:dubai_trip_planner/core/repositories/place_repository.dart';
import 'package:flutter/foundation.dart' show immutable;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'favorites_state.dart';

class FavoritesCubit extends Cubit<FavoritesState> {
  FavoritesCubit(this._prefs) : super(const FavoritesState()) {
    _loadFavorites();
  }

  final SharedPreferences _prefs;
  static const _favoritesKey = 'favorites_places';

  Future<void> toggleFavorite(Place place) async {
    final updated = Map<String, Place>.from(state.favorites);
    if (updated.containsKey(place.id)) {
      updated.remove(place.id);
    } else {
      updated[place.id] = place;
    }
    await _persistFavorites(updated);
    emit(state.copyWith(favorites: updated));
  }

  Future<void> clear() async {
    await _prefs.remove(_favoritesKey);
    emit(state.copyWith(favorites: const {}));
  }

  void _loadFavorites() {
    final stored = _prefs.getStringList(_favoritesKey);
    if (stored == null || stored.isEmpty) return;

    final map = <String, Place>{};
    for (final item in stored) {
      try {
        final decoded = jsonDecode(item) as Map<String, dynamic>;
        // The id is worked out again because favorites saved by older
        // versions used the place's position in its list as the id.
        final place = Place.fromJson({
          ...decoded,
          'id': PlaceRepository.placeId(decoded['categoryId'] as String, decoded['name'] as String),
        });
        map[place.id] = place;
      } catch (_) {
        // ignore corrupt entries
      }
    }

    if (map.isNotEmpty) {
      emit(state.copyWith(favorites: map));
    }
  }

  Future<void> _persistFavorites(Map<String, Place> favorites) async {
    final serialized = favorites.values
        .map((place) => jsonEncode(place.toJson()))
        .toList(growable: false);
    await _prefs.setStringList(_favoritesKey, serialized);
  }
}
