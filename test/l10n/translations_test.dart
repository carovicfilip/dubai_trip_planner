import 'dart:convert';
import 'dart:io';
import 'dart:ui' show Locale;

import 'package:dubai_trip_planner/core/repositories/place_repository.dart';
import 'package:dubai_trip_planner/l10n/l10n.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const languages = ['ar', 'de', 'fr', 'ru'];

  Map<String, dynamic> arb(String language) =>
      jsonDecode(File('lib/l10n/arb/app_$language.arb').readAsStringSync()) as Map<String, dynamic>;

  /// The texts of a file without its metadata.
  Map<String, String> messages(String language) => {
        for (final entry in arb(language).entries)
          if (!entry.key.startsWith('@')) entry.key: entry.value as String,
      };

  Set<String> placeholders(String message) =>
      RegExp(r'\{(\w+)[,}]').allMatches(message).map((match) => match.group(1)!).toSet();

  final english = messages('en');
  final places = PlaceRepository.getAllPlaces();

  group('the texts of the screens', () {
    for (final language in languages) {
      test('$language has every text of English, with the same placeholders', () {
        final translated = messages(language);
        expect(translated.keys.toSet(), english.keys.toSet());
        for (final key in english.keys) {
          expect(placeholders(translated[key]!), placeholders(english[key]!), reason: key);
          expect(translated[key], isNotEmpty, reason: key);
        }
      });
    }

    // These two use another alphabet, so a text left in English stands out.
    for (final language in const ['ar', 'ru']) {
      test('$language has no text left in English', () {
        const sameEverywhere = {'reviewSummary', 'weatherDatePattern', 'listSeparator'};
        final translated = messages(language);
        final left = [
          for (final key in english.keys)
            if (!sameEverywhere.contains(key) && translated[key] == english[key]) key,
        ];
        expect(left, isEmpty);
      });
    }

    test('the generated code is up to date with the ARB files', () {
      for (final language in ['en', ...languages]) {
        final l10n = lookupAppLocalizations(Locale(language));
        final message = messages(language)['promoButton'];
        expect(l10n.promoButton, message, reason: 'run flutter gen-l10n');
      }
    });
  });

  group('the texts of the places', () {
    /// The numbers in a text, whichever way the language groups its thousands.
    Set<String> numbers(String text) => RegExp(r'\d{1,3}(?:[,.  ]\d{3})+|\d+')
        .allMatches(text)
        .map((match) => match.group(0)!.replaceAll(RegExp(r'\D'), ''))
        .toSet();

    /// The times in opening hours as 24-hour times, e.g. 21:00 for 9:00 PM.
    Set<String> times(String text) => RegExp(r'(\d{1,2}):(\d{2})\s*(AM|PM)?').allMatches(text).map((match) {
          var hour = int.parse(match.group(1)!);
          final period = match.group(3);
          if (period != null) hour = hour % 12 + (period == 'PM' ? 12 : 0);
          return '${hour.toString().padLeft(2, '0')}:${match.group(2)}';
        }).toSet();

    // Fails when the English text of a place changes, so that the translations
    // cannot silently fall behind. Translate the change in lib/l10n/places/, then
    // copy the new English into this file.
    test('the translations are of the current English texts', () {
      final translatedFrom = jsonDecode(File('test/fixtures/place_texts_en.json').readAsStringSync()) as Map<String, dynamic>;
      for (final place in places) {
        final english = {
          'name': place.name,
          'description': place.description,
          if (place.openingHours != null) 'openingHours': place.openingHours,
        };
        expect(translatedFrom[place.id], english, reason: '${place.id} changed in English');
      }
      expect(translatedFrom.keys.toSet(), places.map((place) => place.id).toSet());
    });

    for (final language in languages) {
      final texts = placeTextsByLanguage[language]!;

      test('$language has every place, and nothing else', () {
        expect(texts.keys.toSet(), places.map((place) => place.id).toSet());
      });

      test('$language keeps the numbers of every description', () {
        for (final place in places) {
          final translated = texts[place.id]!;
          expect(translated.name, isNotEmpty, reason: place.id);
          expect(translated.description, isNot(place.description), reason: place.id);
          expect(numbers(translated.description), containsAll(numbers(place.description)), reason: place.id);
        }
      });

      // Also fails when the hours of a place are changed in English only.
      test('$language has the same opening hours as English', () {
        for (final place in places) {
          final hours = texts[place.id]!.openingHours;
          expect(hours != null, place.openingHours != null, reason: place.id);
          if (hours == null) continue;
          expect(times(hours), times(place.openingHours!), reason: '${place.id}: $hours');
          // The details screen starts a new line at each comma.
          expect(RegExp('[,،] ').allMatches(hours).length, ', '.allMatches(place.openingHours!).length, reason: place.id);
        }
      });
    }

    test('Arabic is written with the digits used in the Emirates', () {
      for (final text in placeTextsByLanguage['ar']!.values) {
        expect(RegExp('[٠-٩]').hasMatch('${text.description}${text.openingHours}'), isFalse, reason: text.name);
      }
    });
  });
}
