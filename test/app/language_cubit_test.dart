import 'dart:ui' show Locale;

import 'package:dubai_trip_planner/app/language/app_language.dart';
import 'package:dubai_trip_planner/app/language/language_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  Future<LanguageCubit> cubit(List<Locale> device) async =>
      LanguageCubit(await SharedPreferences.getInstance(), deviceLocales: device);

  test('starts in the first language of the device that the app has', () async {
    final languages = await cubit(const [Locale('sr'), Locale('de', 'AT'), Locale('fr')]);
    expect(languages.state, AppLanguage.de);
  });

  test('starts in English when the app has none of the languages of the device', () async {
    expect((await cubit(const [Locale('sr'), Locale('ja')])).state, AppLanguage.en);
  });

  test('the language the user picked is remembered, and beats the one of the device', () async {
    final languages = await cubit(const [Locale('de')]);
    await languages.select(AppLanguage.ar);
    expect(languages.state, AppLanguage.ar);

    expect((await cubit(const [Locale('de')])).state, AppLanguage.ar);
  });

  test('a stored language the app does not have is ignored', () async {
    SharedPreferences.setMockInitialValues({'app_language': 'xx'});
    expect((await cubit(const [Locale('ru')])).state, AppLanguage.ru);
  });
}
