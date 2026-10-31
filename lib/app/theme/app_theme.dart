import 'package:dubai_trip_planner/core/constants/app_color.dart';
import 'package:material_ui/material_ui.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    fontFamily: 'Montserrat',
    scaffoldBackgroundColor: const Color(0xFFF8F8F8),
    textTheme: GoogleFonts.poppinsTextTheme(),
    
    // Definisanje boja za selekciju teksta i input polja
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: AppColors.black500,
      selectionColor: AppColors.gray50,
      selectionHandleColor: AppColors.primaryNavigation,
    ),
    
    // Definisanje boja za input polja
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey.shade100,
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
        borderSide: BorderSide(color: AppColors.primaryNavigation, width: 2),
      ),
    ),
    
    // Boja za highlight i selektovane elemente
    highlightColor: AppColors.primaryUpdate,
    splashColor: AppColors.primaryUpdate,
    
    // Boja za floating action button i druge primarne elemente
    primaryColor: AppColors.primaryNavigation,
    primaryColorLight: AppColors.primaryUpdate,
    primaryColorDark: AppColors.primaryBlue,
    
    // Boja za progress indicator
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.primaryNavigation,
    ),
    
    // Text button theme za Cancel i OK dugmad
    textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(const Color(0xFFE8D2B8)),
        foregroundColor: WidgetStateProperty.all(Colors.white),
        overlayColor: WidgetStateProperty.all(Colors.white.withValues(alpha: 0.1)),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    ),
    
    // Date picker theme
    datePickerTheme: DatePickerThemeData(
      backgroundColor: Colors.white, // bela pozadina celog date picker dialog-a
      dayForegroundColor: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
        if (states.contains(WidgetState.selected)) {
          return Colors.white; // bela boja teksta za selektovani dan
        }
        return null; // default boja za ostale dane
      }),
      dayBackgroundColor: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
        if (states.contains(WidgetState.selected)) {
          return const Color(0xFFE8D2B8);// vaša željena boja za pozadinu selektovanog dana
        }
        return null; // transparentna pozadina za ostale dane
      }),
      // Zamenjujemo ljubičaste elemente sa Color(0xFFE8D2B8)
      headerBackgroundColor: const Color(0xFFE8D2B8),
      headerForegroundColor: Colors.white,
      rangeSelectionBackgroundColor: const Color(0xFFE8D2B8),
      rangeSelectionOverlayColor: WidgetStateProperty.all(const Color(0xFFE8D2B8).withValues(alpha: 0.12)),
      todayForegroundColor: WidgetStateProperty.all(const Color(0xFFE8D2B8)),
      todayBackgroundColor: WidgetStateProperty.all(const Color(0xFFE8D2B8).withValues(alpha: 0.12)),
    ),

    // Checkbox, radio i switch u boji aplikacije kada su selektovani
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
        if (states.contains(WidgetState.disabled)) { return null; }
        if (states.contains(WidgetState.selected)) { return AppColors.primaryNavigation; }
        return null;
      }),
    ),
    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
        if (states.contains(WidgetState.disabled)) { return null; }
        if (states.contains(WidgetState.selected)) { return AppColors.primaryNavigation; }
        return null;
      }),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
        if (states.contains(WidgetState.disabled)) { return null; }
        if (states.contains(WidgetState.selected)) { return AppColors.primaryNavigation; }
        return null;
      }),
      trackColor: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
        if (states.contains(WidgetState.disabled)) { return null; }
        if (states.contains(WidgetState.selected)) { return AppColors.primaryNavigation; }
        return null;
      }),
    ),
  );
}
