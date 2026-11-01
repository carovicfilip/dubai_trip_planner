import 'dart:ui' show Locale, PlatformDispatcher;

import 'package:dubai_trip_planner/app/language/app_language.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The language of the app: the one the user picked on the Explore tab. Until
/// then it is the first of the device's languages that the app has, or English.
class LanguageCubit extends Cubit<AppLanguage> {
  LanguageCubit(this._prefs, {List<Locale>? deviceLocales})
      : super(_initial(_prefs, deviceLocales ?? PlatformDispatcher.instance.locales));

  final SharedPreferences _prefs;
  static const _languageKey = 'app_language';

  static AppLanguage _initial(SharedPreferences prefs, List<Locale> deviceLocales) {
    final picked = AppLanguage.fromCode(prefs.getString(_languageKey));
    if (picked != null) return picked;
    for (final locale in deviceLocales) {
      final language = AppLanguage.fromCode(locale.languageCode);
      if (language != null) return language;
    }
    return AppLanguage.en;
  }

  Future<void> select(AppLanguage language) async {
    emit(language);
    await _prefs.setString(_languageKey, language.code);
  }
}
