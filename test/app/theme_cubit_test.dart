import 'package:dubai_trip_planner/app/theme/theme_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('the app is light until the user picks the dark theme', () async {
    SharedPreferences.setMockInitialValues({});
    final cubit = ThemeCubit(await SharedPreferences.getInstance());
    expect(cubit.state, ThemeMode.light);
  });

  test('the picked theme is remembered the next time the app opens', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await ThemeCubit(prefs).setDark(true);
    expect(ThemeCubit(prefs).state, ThemeMode.dark);

    await ThemeCubit(prefs).setDark(false);
    expect(ThemeCubit(prefs).state, ThemeMode.light);
  });
}
