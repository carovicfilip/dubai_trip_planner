import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The theme the user picked on the Profile tab. The app is light until then.
class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit(this._prefs) : super(_prefs.getBool(_darkThemeKey) ?? false ? ThemeMode.dark : ThemeMode.light);

  final SharedPreferences _prefs;
  static const _darkThemeKey = 'dark_theme';

  Future<void> setDark(bool dark) async {
    emit(dark ? ThemeMode.dark : ThemeMode.light);
    await _prefs.setBool(_darkThemeKey, dark);
  }
}
