import 'dart:io';

import 'package:dubai_trip_planner/app/theme/theme_cubit.dart';
import 'package:dubai_trip_planner/features/onboarding/ui/onboarding_screen.dart';
import 'package:dubai_trip_planner/features/profile/ui/profile_screen.dart';
import 'package:dubai_trip_planner/features/weather/services/weather_forecast_service.dart';
import 'package:dubai_trip_planner/main.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  final weatherFixture = File('test/fixtures/openweather_forecast_dubai.json').readAsStringSync();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    WeatherForecastService.clearMemoryCache();
  });

  /// Opens the real app on its first screen and passes it to [body].
  Future<void> withRealApp(WidgetTester tester, Future<void> Function() body) async {
    // Large surface on purpose: the test font draws every glyph 1em wide, far
    // wider than Poppins, so phone-size layout is checked on a real device.
    tester.view.physicalSize = const Size(1200, 2400) * 3;
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    final reportError = FlutterError.onError!;
    FlutterError.onError = (details) {
      if (!details.exceptionAsString().contains('A RenderFlex overflowed')) reportError(details);
    };
    final prefs = await SharedPreferences.getInstance();
    try {
      await http.runWithClient(
        () async {
          await tester.pumpWidget(MyApp(prefs: prefs, onboardingCompleted: false));
          await body();
        },
        () => MockClient((_) async => http.Response(weatherFixture, 200)),
      );
    } finally {
      FlutterError.onError = reportError;
    }
  }

  Future<void> showProfile(WidgetTester tester, BuildContext appContext) async {
    Navigator.of(appContext).push(MaterialPageRoute(builder: (_) => const ProfileScreen()));
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
  }

  Brightness brightness(WidgetTester tester) => Theme.of(tester.element(find.byType(ProfileScreen))).brightness;

  testWidgets('the Profile switch turns the whole app dark and back, and is remembered', (tester) async {
    await withRealApp(tester, () async {
      await showProfile(tester, tester.element(find.byType(OnboardingScreen)));
      expect(find.text('Dark theme'), findsOneWidget);
      expect(tester.widget<SwitchListTile>(find.byType(SwitchListTile)).value, isFalse);
      expect(brightness(tester), Brightness.light);

      await tester.tap(find.text('Dark theme'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(tester.widget<SwitchListTile>(find.byType(SwitchListTile)).value, isTrue);
      expect(brightness(tester), Brightness.dark);
      final prefs = await SharedPreferences.getInstance();
      expect(ThemeCubit(prefs).state, ThemeMode.dark);

      await tester.tap(find.text('Dark theme'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(brightness(tester), Brightness.light);
    });
  });

  testWidgets('a screen without an app bar gets white status bar icons in the dark theme', (tester) async {
    SharedPreferences.setMockInitialValues({'dark_theme': true});
    await withRealApp(tester, () async {
      Navigator.of(tester.element(find.byType(OnboardingScreen))).push(
        MaterialPageRoute(builder: (_) => const Scaffold()),
      );
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));

      final view = tester.binding.renderViews.first;
      final style = view.debugLayer!.find<SystemUiOverlayStyle>(Offset(view.paintBounds.center.dx, 1));
      expect(style?.statusBarIconBrightness, Brightness.light);
    });
  });
}
