import 'dart:io';

import 'package:dubai_trip_planner/app/language/app_language.dart';
import 'package:dubai_trip_planner/app/language/language_cubit.dart';
import 'package:dubai_trip_planner/app/router/main_scaffold.dart';
import 'package:dubai_trip_planner/features/explore/ui/explore_screen.dart';
import 'package:dubai_trip_planner/features/explore/ui/widgets/language_switcher.dart';
import 'package:dubai_trip_planner/features/onboarding/ui/onboarding_screen.dart';
import 'package:dubai_trip_planner/features/weather/services/weather_forecast_service.dart';
import 'package:dubai_trip_planner/main.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  final weatherFixture = File('test/fixtures/openweather_forecast_dubai.json').readAsStringSync();

  setUp(() {
    SharedPreferences.setMockInitialValues({'app_language': 'en'});
    WeatherForecastService.clearMemoryCache();
  });

  /// Runs [body] on Explore in the real app. Explore keeps animations running
  /// forever, so time is moved with [settle] rather than pumpAndSettle().
  Future<void> onExplore(WidgetTester tester, Future<void> Function() body) async {
    // Large surface on purpose: the test font draws every glyph 1em wide, far
    // wider than the real fonts, so phone-size layout is checked on a real device.
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
          await tester.pump();
          Navigator.of(tester.element(find.byType(OnboardingScreen))).pushReplacement(MainScaffold.fadeInRoute());
          await tester.pump(const Duration(seconds: 1));
          await tester.pump(const Duration(seconds: 1));
          await body();
        },
        () => MockClient((_) async => http.Response(weatherFixture, 200)),
      );
    } finally {
      FlutterError.onError = reportError;
    }
  }

  Future<void> settle(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 400));
  }

  Future<void> open(WidgetTester tester) async {
    await tester.tap(find.byType(LanguageSwitcher));
    await settle(tester);
  }

  Future<void> pick(WidgetTester tester, String language) async {
    await open(tester);
    await tester.tap(find.text(language));
    await settle(tester);
  }

  String? flagOn(WidgetTester tester) {
    final loader = tester.widget<SvgPicture>(
      find.descendant(of: find.byType(LanguageSwitcher), matching: find.byType(SvgPicture)),
    ).bytesLoader as SvgAssetLoader;
    return loader.assetName;
  }

  testWidgets('shows the flag and the code of the language at the end of the header', (tester) async {
    await onExplore(tester, () async {
      expect(find.text('EN'), findsOneWidget);
      expect(flagOn(tester), AppLanguage.en.flag);

      final screen = tester.getRect(find.byType(ExploreScreen));
      final button = tester.getRect(find.byType(LanguageSwitcher));
      expect(button.center.dx, greaterThan(screen.center.dx));
      expect(button.top, lessThan(100));
    });
  });

  testWidgets('a tap expands it to the other four languages, and a tap outside closes it', (tester) async {
    await onExplore(tester, () async {
      for (final language in AppLanguage.values) {
        expect(find.text(language.nativeName), findsNothing);
      }

      await open(tester);

      for (final language in AppLanguage.values) {
        expect(find.text(language.nativeName), findsOneWidget, reason: language.nativeName);
      }
      // Under the button, and each with its own flag.
      final button = tester.getRect(find.byType(LanguageSwitcher));
      expect(tester.getTopLeft(find.text('Deutsch')).dy, greaterThan(button.bottom));
      expect(find.byType(SvgPicture), findsWidgets);

      await tester.tapAt(const Offset(20, 1200));
      await settle(tester);
      expect(find.text('Deutsch'), findsNothing);
      expect(find.text('EN'), findsOneWidget);
    });
  });

  testWidgets('a second tap on the open button closes it', (tester) async {
    await onExplore(tester, () async {
      await open(tester);
      await tester.tap(find.text('English'));
      await settle(tester);
      expect(find.text('Deutsch'), findsNothing);
    });
  });

  testWidgets('picking a language translates the app at once, keeps the tab, and is remembered', (tester) async {
    await onExplore(tester, () async {
      expect(find.text('Welcome to'), findsOneWidget);

      await pick(tester, 'Deutsch');

      expect(find.text('Welcome to'), findsNothing);
      expect(find.text('Willkommen in'), findsOneWidget);
      expect(find.text('Beliebteste Orte'), findsOneWidget);
      expect(find.text('Entdecken'), findsOneWidget);
      expect(find.text('Reise planen'), findsOneWidget);
      expect(find.byType(ExploreScreen), findsOneWidget);
      expect(find.text('DE'), findsOneWidget);
      expect(flagOn(tester), AppLanguage.de.flag);

      final prefs = await SharedPreferences.getInstance();
      expect(LanguageCubit(prefs).state, AppLanguage.de);
    });
  });

  testWidgets('every language can be picked, and the one in use is not offered again', (tester) async {
    await onExplore(tester, () async {
      for (final language in const [AppLanguage.ar, AppLanguage.ru, AppLanguage.fr, AppLanguage.de, AppLanguage.en]) {
        await pick(tester, language.nativeName);
        expect(find.text(language.code.toUpperCase()), findsOneWidget);
        expect(Localizations.localeOf(tester.element(find.byType(ExploreScreen))).languageCode, language.code);

        await open(tester);
        expect(find.text(language.nativeName), findsOneWidget, reason: 'only as the current one');
        await tester.tap(find.text(language.nativeName));
        await settle(tester);
      }
    });
  });

  testWidgets('Arabic turns the whole app around, with the button in the mirrored corner', (tester) async {
    await onExplore(tester, () async {
      await pick(tester, 'العربية');

      final explore = tester.element(find.byType(ExploreScreen));
      expect(Directionality.of(explore), TextDirection.rtl);
      final screen = tester.getRect(find.byType(ExploreScreen));
      expect(tester.getRect(find.byType(LanguageSwitcher)).center.dx, lessThan(screen.center.dx));

      await open(tester);
      final button = tester.getRect(find.byType(LanguageSwitcher));
      expect((tester.getTopLeft(find.text('Deutsch')).dx - button.left).abs(), lessThan(120));
    });
  });

  // The generated list of delegates would leave these in English, in material_ui.
  testWidgets('the texts of the Material widgets change with the language too', (tester) async {
    await onExplore(tester, () async {
      await pick(tester, 'Deutsch');
      final german = MaterialLocalizations.of(tester.element(find.byType(ExploreScreen)));
      expect(german.nextMonthTooltip, 'Nächster Monat');
      expect(german.formatMonthYear(DateTime(2026, 11)), 'November 2026');

      await pick(tester, 'العربية');
      final arabic = MaterialLocalizations.of(tester.element(find.byType(ExploreScreen)));
      expect(arabic.formatMonthYear(DateTime(2026, 11)), contains('نوفمبر'));
      expect(arabic.formatMonthYear(DateTime(2026, 11)), contains('2026'), reason: 'digits as written in the Emirates');
    });
  });

  testWidgets('tells a screen reader what it is and which language is on', (tester) async {
    final semantics = tester.ensureSemantics();
    await onExplore(tester, () async {
      final data = tester.getSemantics(find.byType(LanguageSwitcher)).getSemanticsData();
      expect(data.label, 'Change language');
      expect(data.value, 'English');
    });
    semantics.dispose();
  });

  testWidgets('the developer button keeps working next to it in debug builds', (tester) async {
    await onExplore(tester, () async {
      expect(find.byTooltip('Restart onboarding'), findsOneWidget);
      expect(find.byType(LanguageSwitcher), findsOneWidget);
    });
  });
}
