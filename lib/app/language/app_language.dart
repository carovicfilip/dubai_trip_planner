import 'package:material_ui/material_ui.dart';

/// The languages of the app, in the order the language switcher lists them.
enum AppLanguage {
  en('English', 'assets/flags/gb.svg'),
  // The flag of the Emirates rather than of another Arab country: the app is
  // about Dubai.
  ar('العربية', 'assets/flags/ae.svg'),
  ru('Русский', 'assets/flags/ru.svg'),
  de('Deutsch', 'assets/flags/de.svg'),
  fr('Français', 'assets/flags/fr.svg');

  const AppLanguage(this.nativeName, this.flag);

  /// Written in the language itself, so that people can find their language
  /// when they cannot read the one on screen.
  final String nativeName;
  final String flag;

  String get code => name;

  Locale get locale => Locale(code);

  /// The language with this code, or null when the app does not have it.
  static AppLanguage? fromCode(String? code) {
    for (final language in values) {
      if (language.code == code) return language;
    }
    return null;
  }

  /// The language the app is showing right now.
  static AppLanguage of(BuildContext context) =>
      fromCode(Localizations.localeOf(context).languageCode) ?? AppLanguage.en;
}
