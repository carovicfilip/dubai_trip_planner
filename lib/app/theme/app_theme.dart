import 'package:dubai_trip_planner/app/language/app_language.dart';
import 'package:dubai_trip_planner/core/constants/app_color.dart';
import 'package:dubai_trip_planner/core/constants/app_palette.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Neither status bar style sets the system navigation bar, so leaving a
  // screen never leaves that screen's navigation bar color behind on Android.
  static const statusBarOnLight = SystemUiOverlayStyle(
    statusBarBrightness: Brightness.light,
    statusBarIconBrightness: Brightness.dark,
  );
  static const statusBarOnDark = SystemUiOverlayStyle(
    statusBarBrightness: Brightness.dark,
    statusBarIconBrightness: Brightness.light,
  );

  /// The status bar for a screen with the background of the current theme.
  static SystemUiOverlayStyle statusBarFor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? statusBarOnDark : statusBarOnLight;

  static final _lightThemes = <AppLanguage, ThemeData>{};
  static final _darkThemes = <AppLanguage, ThemeData>{};
  static final _textThemes = <AppLanguage, TextTheme>{};

  // Built once per language: a theme is costly to build, and these are asked
  // for every time the app rebuilds above MaterialApp.
  static ThemeData lightFor(AppLanguage language) =>
      _lightThemes[language] ??= _build(AppPalette.light, const ColorScheme.light(), language);
  static ThemeData darkFor(AppLanguage language) =>
      _darkThemes[language] ??= _build(AppPalette.dark, const ColorScheme.dark(), language);

  static ThemeData get lightTheme => lightFor(AppLanguage.en);
  static ThemeData get darkTheme => darkFor(AppLanguage.en);

  /// Poppins has no Arabic or Cyrillic letters, so those languages get a font
  /// with the same round, geometric look that has them.
  static TextTheme textThemeFor(AppLanguage language) => _textThemes[language] ??= switch (language) {
        AppLanguage.ar => GoogleFonts.tajawalTextTheme(),
        AppLanguage.ru => GoogleFonts.montserratTextTheme(),
        AppLanguage.en || AppLanguage.de || AppLanguage.fr => GoogleFonts.poppinsTextTheme(),
      };

  static ThemeData _build(AppPalette palette, ColorScheme scheme, AppLanguage language) {
    return ThemeData(
      fontFamily: 'Montserrat',
      scaffoldBackgroundColor: palette.surface,
      extensions: [palette],
      colorScheme: scheme.copyWith(
        primary: palette.accent,
        onPrimary: palette.onAccent,
        secondary: palette.accent,
        onSecondary: palette.onAccent,
        surface: palette.card,
        onSurface: palette.ink,
      ),
      textTheme: textThemeFor(language).apply(bodyColor: palette.ink, displayColor: palette.ink),

      // Definisanje boja za selekciju teksta i input polja
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: palette.ink,
        selectionColor: palette.hairline,
        selectionHandleColor: palette.accent,
      ),

      // Definisanje boja za input polja
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: palette.tile,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: palette.accent, width: 2),
        ),
      ),

      // Boja za highlight i selektovane elemente
      highlightColor: palette.tile,
      splashColor: palette.tile,

      // Boja za floating action button i druge primarne elemente
      primaryColor: palette.accent,
      primaryColorLight: AppColors.primaryUpdate,
      primaryColorDark: AppColors.primaryBlue,

      // Boja za progress indicator
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: palette.accent,
      ),

      // Text button theme za Cancel i OK dugmad
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all(palette.accent),
          foregroundColor: WidgetStateProperty.all(palette.onAccent),
          overlayColor: WidgetStateProperty.all(palette.onAccent.withValues(alpha: 0.1)),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
      ),

      // Date picker theme
      datePickerTheme: DatePickerThemeData(
        backgroundColor: palette.card,
        dayForegroundColor: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
          if (states.contains(WidgetState.selected)) {
            return palette.onAccent;
          }
          return null; // default boja za ostale dane
        }),
        dayBackgroundColor: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
          if (states.contains(WidgetState.selected)) {
            return palette.accent;
          }
          return null; // transparentna pozadina za ostale dane
        }),
        headerBackgroundColor: palette.heroCard,
        headerForegroundColor: Colors.white,
        rangeSelectionBackgroundColor: palette.accent,
        rangeSelectionOverlayColor: WidgetStateProperty.all(palette.accent.withValues(alpha: 0.1)),
        todayForegroundColor: WidgetStateProperty.all(palette.accent),
        todayBackgroundColor: WidgetStateProperty.all(palette.accent.withValues(alpha: 0.1)),
      ),

      // Checkbox, radio i switch u boji aplikacije kada su selektovani
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
          if (states.contains(WidgetState.disabled)) { return null; }
          if (states.contains(WidgetState.selected)) { return palette.accent; }
          return null;
        }),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
          if (states.contains(WidgetState.disabled)) { return null; }
          if (states.contains(WidgetState.selected)) { return palette.accent; }
          return null;
        }),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
          if (states.contains(WidgetState.disabled)) { return null; }
          if (states.contains(WidgetState.selected)) { return palette.onAccent; }
          return null;
        }),
        trackColor: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
          if (states.contains(WidgetState.disabled)) { return null; }
          if (states.contains(WidgetState.selected)) { return palette.accent; }
          return null;
        }),
      ),
    );
  }
}
