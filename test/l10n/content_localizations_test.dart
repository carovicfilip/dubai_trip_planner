import 'dart:ui' show Locale;

import 'package:dubai_trip_planner/core/models/place.dart';
import 'package:dubai_trip_planner/core/repositories/category_repository.dart';
import 'package:dubai_trip_planner/core/repositories/place_repository.dart';
import 'package:dubai_trip_planner/features/my_trip/ui/trip_labels.dart';
import 'package:dubai_trip_planner/l10n/l10n.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart' show DateFormat;

void main() {
  setUpAll(initializeDateFormatting);

  AppLocalizations l10n(String language) => lookupAppLocalizations(Locale(language));

  Place reviewed(String summary) =>
      Place(id: 'x', categoryId: 'must_see', name: 'X', description: 'Y', imageUrl: 'z', reviewSummary: summary);

  group('a review summary', () {
    test('stays as it is written in the data in English', () {
      expect(l10n('en').reviewSummaryText(reviewed('4.7 (166k reviews)')), '4.7 (166k reviews)');
      expect(l10n('en').reviewSummaryText(reviewed('4.6 (53.7k reviews)')), '4.6 (53.7k reviews)');
      expect(l10n('en').reviewSummaryText(reviewed('4.7 (407 reviews)')), '4.7 (407 reviews)');
    });

    test('uses the number format and the plurals of each language', () {
      final place = reviewed('4.7 (166k reviews)');
      expect(l10n('de').reviewSummaryText(place), '4,7 (166.000 Bewertungen)');
      expect(l10n('fr').reviewSummaryText(place), contains('4,7 (166'));
      expect(l10n('fr').reviewSummaryText(place), endsWith('avis)'));
      expect(l10n('ru').reviewSummaryText(place), contains('отзывов'));
      expect(l10n('ar').reviewSummaryText(place), '4.7 (166\u00A0ألف تقييم)');
    });

    test('follows the Arabic and Russian plural rules for small numbers', () {
      expect(l10n('ar').reviewsText(reviewed('4 (5 reviews)')), '5 تقييمات');
      expect(l10n('ar').reviewsText(reviewed('4 (50 reviews)')), '50 تقييمًا');
      expect(l10n('ar').reviewsText(reviewed('4 (300 reviews)')), '300 تقييم');
      expect(l10n('ru').reviewsText(reviewed('4 (271 reviews)')), '271 отзыв');
      expect(l10n('ru').reviewsText(reviewed('4 (232 reviews)')), '232 отзыва');
      expect(l10n('ru').reviewsText(reviewed('4 (407 reviews)')), '407 отзывов');
    });

    test('says so when a place has no reviews', () {
      const place = Place(id: 'x', categoryId: 'must_see', name: 'X', description: 'Y', imageUrl: 'z');
      expect(l10n('de').reviewSummaryText(place), 'Noch keine Bewertungen');
      expect(l10n('de').reviewsText(place), isNull);
    });

    test('every place in the data has a count that can be read', () {
      for (final place in PlaceRepository.getAllPlaces().where((place) => place.reviewSummary != null)) {
        expect(place.reviewCount, isNotNull, reason: '${place.name}: "${place.reviewSummary}"');
      }
    });
  });

  test('a stay is counted with the plurals of each language', () {
    expect([for (final days in [1, 2, 3, 11, 15]) l10n('en').tripDays(days)], ['1 day', '2 days', '3 days', '11 days', '15 days']);
    expect([for (final days in [1, 2, 5, 11]) l10n('ru').tripDays(days)], ['1 день', '2 дня', '5 дней', '11 дней']);
    expect([for (final days in [1, 2, 3, 11]) l10n('ar').tripDays(days)], ['يوم واحد', 'يومان', '3 أيام', '11 يومًا']);
  });

  // Several languages end their short months with a dot of their own.
  test('a short date in the middle of a text does not end in two dots', () {
    for (final language in const ['en', 'ar', 'de', 'fr', 'ru']) {
      final date = DateFormat.MMMd(language).format(DateTime(2026, 12, 13));
      expect(l10n(language).tripStayingLonger(15, date), isNot(contains('..')), reason: language);
    }
  });

  group('a place', () {
    final burj = PlaceRepository.getPlacesByCategory('must_see').first;

    test('is shown in the language of the app, and as it is in English', () {
      expect(l10n('en').placeText(burj).description, burj.description);
      expect(l10n('ru').placeText(burj).name, 'Бурдж-Халифа');
      expect(l10n('de').placeText(burj).description, isNot(burj.description));
    });

    // A favorite is stored with the English texts it was saved with.
    test('saved as a favorite in English is shown in the language of the app', () {
      final stored = Place.fromJson(burj.toJson());
      expect(l10n('ar').placeText(stored).name, l10n('ar').placeText(burj).name);
    });

    test('that has no translation stays readable in English', () {
      const unknown = Place(id: 'new-place', categoryId: 'must_see', name: 'New', description: 'Text', imageUrl: 'z');
      expect(l10n('de').placeText(unknown).name, 'New');
      expect(l10n('de').placeText(unknown).description, 'Text');
    });
  });

  test('every category has a name in every language', () {
    for (final language in const ['en', 'ar', 'de', 'fr', 'ru']) {
      for (final category in CategoryRepository.allCategories) {
        expect(l10n(language).categoryName(category.id), isNot(category.id), reason: '$language: ${category.id}');
      }
    }
    expect([for (final category in CategoryRepository.allCategories) l10n('en').categoryName(category.id)],
        [for (final category in CategoryRepository.allCategories) category.name]);
  });

  test('an address stays readable inside Arabic text, and is untouched elsewhere', () {
    expect(l10n('en').bidiIsolated('1 Sheikh Zayed Road'), '1 Sheikh Zayed Road');
    expect(l10n('ar').bidiIsolated('1 Sheikh Zayed Road'), '\u20681 Sheikh Zayed Road\u2069');
  });

  group('the values of the trip form', () {
    test('have a label for every interest and area in every language', () {
      const interests = [
        'Restaurants', 'Attractions', 'Cafes', 'Breakfast and brunch', 'Bakeries', 'Bars', 'Shopping', 'Nightlife',
        'Museums', 'Art museums', 'Science & space museums', 'Theme parks', 'Arts and culture', 'Parks and gardens',
        'Beaches', 'Pools', 'Asian food', 'Sushi', 'Pizzas', 'Gelato', 'Desserts', 'Rooftops', 'Fun things to do', 'Spas',
      ];
      for (final interest in interests) {
        expect(l10n('en').interestLabel(interest), interest);
        expect(l10n('ar').interestLabel(interest), isNot(interest));
      }
      expect(l10n('ru').areaLabel('Deira'), 'Дейра');
    });

    test('leave what the user typed as it is', () {
      expect(l10n('ru').areaLabel('Hotel Atlantis'), 'Hotel Atlantis');
      expect(l10n('ru').interestLabel('Something old'), 'Something old');
    });
  });
}
