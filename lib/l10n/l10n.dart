import 'package:dubai_trip_planner/l10n/generated/app_localizations.dart';
import 'package:flutter/foundation.dart' show SynchronousFuture;
import 'package:intl/intl.dart' show DateFormat;
import 'package:material_ui/material_ui.dart';

export 'package:dubai_trip_planner/l10n/content_localizations.dart';
export 'package:dubai_trip_planner/l10n/generated/app_localizations.dart';

/// What a MaterialApp needs. Not AppLocalizations.localizationsDelegates: that
/// generated list has the Material texts of flutter_localizations, which the
/// widgets of material_ui do not read, so the calendar and the tooltips would
/// stay in English.
const appLocalizationsDelegates = <LocalizationsDelegate<dynamic>>[
  _LatinDigitsInArabic(),
  AppLocalizations.delegate,
  ...GlobalMaterialLocalizations.delegates,
];

/// The Emirates write Arabic with the digits 0-9, and so do the texts of this
/// app, but intl would write dates with ٠-٩. Comes before the Material texts,
/// which make their date formats as they load.
class _LatinDigitsInArabic extends LocalizationsDelegate<_LatinDigitsInArabic> {
  const _LatinDigitsInArabic();

  // For every language, or Flutter warns that the language has no such delegate.
  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<_LatinDigitsInArabic> load(Locale locale) {
    DateFormat.useNativeDigitsByDefaultFor('ar', false);
    return SynchronousFuture(this);
  }

  @override
  bool shouldReload(_LatinDigitsInArabic old) => false;
}

extension AppLocalizationsOf on BuildContext {
  /// The texts of the app in the current language.
  AppLocalizations get l10n => AppLocalizations.of(this);

  /// The letter spacing of a widely spaced label. Arabic letters join up, and
  /// spacing would tear the words apart.
  double labelSpacing(double spacing) => Localizations.localeOf(this).languageCode == 'ar' ? 0 : spacing;
}
