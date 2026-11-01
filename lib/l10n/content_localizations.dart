import 'package:dubai_trip_planner/core/models/place.dart';
import 'package:dubai_trip_planner/l10n/generated/app_localizations.dart';
import 'package:dubai_trip_planner/l10n/place_text.dart';
import 'package:dubai_trip_planner/l10n/places/place_text_ar.dart';
import 'package:dubai_trip_planner/l10n/places/place_text_de.dart';
import 'package:dubai_trip_planner/l10n/places/place_text_fr.dart';
import 'package:dubai_trip_planner/l10n/places/place_text_ru.dart';
import 'package:intl/intl.dart' show NumberFormat;

export 'package:dubai_trip_planner/l10n/place_text.dart';

/// The texts of the places in the languages other than English, in which they
/// are written in the place data itself. They are looked up by place id, also
/// for a saved favorite, whose stored copy of the texts is in English.
const placeTextsByLanguage = <String, Map<String, PlaceText>>{
  'ar': placeTextsAr,
  'de': placeTextsDe,
  'fr': placeTextsFr,
  'ru': placeTextsRu,
};

/// The texts that come with the app's data rather than from its screens.
extension ContentLocalizations on AppLocalizations {
  String categoryName(String categoryId) => switch (categoryId) {
        'must_see' => categoryMustSee,
        'restaurants' => categoryRestaurants,
        'nightlife' => categoryNightlife,
        'beaches_pools' => categoryBeachesPools,
        'culture_museums' => categoryCultureMuseums,
        'shopping' => categoryShopping,
        'desert_adventure' => categoryDesertAdventure,
        'family_fun' => categoryFamilyFun,
        _ => categoryId,
      };

  PlaceText placeText(Place place) =>
      placeTextsByLanguage[localeName]?[place.id] ??
      PlaceText(name: place.name, description: place.description, openingHours: place.openingHours);

  /// E.g. "4.7", or "4,7" in German.
  String ratingText(double rating) => NumberFormat('0.0', localeName).format(rating);

  /// E.g. "166k reviews", or null when the place does not say how many it has.
  String? reviewsText(Place place) {
    final count = place.reviewCount;
    if (count == null) return null;
    // German has no short form of thousands, and intl then leaves out the dot.
    final format = localeName == 'de' ? NumberFormat.decimalPattern(localeName) : NumberFormat.compact(locale: localeName);
    final short = format.format(count);
    // English writes these as 166k in this app, where intl would say 166K.
    return reviewCount(count, localeName == 'en' ? short.toLowerCase() : short);
  }

  /// E.g. "4.7 (166k reviews)".
  String reviewSummaryText(Place place) {
    if (place.reviewSummary == null) return noReviews;
    final rating = ratingText(place.rating);
    final reviews = reviewsText(place);
    return reviews == null ? rating : reviewSummary(rating, reviews);
  }

  /// Keeps an address or another text in Latin letters readable inside Arabic
  /// text: without this its numbers and punctuation change places.
  String bidiIsolated(String text) => localeName == 'ar' ? '\u2068$text\u2069' : text;
}
