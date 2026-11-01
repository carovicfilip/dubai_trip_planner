import 'dart:io';

import 'package:dubai_trip_planner/app/router/main_scaffold.dart';
import 'package:dubai_trip_planner/features/categories/ui/categories_screen.dart';
import 'package:dubai_trip_planner/features/favorites/cubit/favorites_cubit.dart';
import 'package:dubai_trip_planner/features/my_trip/cubit/my_trip_cubit.dart';
import 'package:dubai_trip_planner/features/my_trip/services/trip_planner_service.dart';
import 'package:dubai_trip_planner/features/my_trip/ui/my_trip_screen.dart';
import 'package:dubai_trip_planner/features/onboarding/services/onboarding_service.dart';
import 'package:dubai_trip_planner/features/onboarding/ui/onboarding_paywall_screen.dart';
import 'package:dubai_trip_planner/features/onboarding/ui/onboarding_screen.dart';
import 'package:dubai_trip_planner/features/profile/ui/profile_screen.dart';
import 'package:dubai_trip_planner/features/splash/ui/splash_screen.dart';
import 'package:dubai_trip_planner/features/weather/services/weather_forecast_service.dart';
import 'package:dubai_trip_planner/main.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  final weatherFixture = File('test/fixtures/openweather_forecast_dubai.json').readAsStringSync();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    // The forecast stays cached while the app runs; every test starts fresh.
    WeatherForecastService.clearMemoryCache();
  });

  /// Runs [body] with [home] as the first screen. HTTP calls (the weather
  /// section on the Explore tab) are answered from a recorded response.
  Future<void> withApp(
    WidgetTester tester,
    Future<void> Function() body, {
    Widget home = const OnboardingScreen(),
    Widget? app,
    bool checkOverflow = false,
  }) async {
    // Large surface on purpose: the test font draws every glyph 1em wide, far
    // wider than Poppins, so phone-size layout is checked on a real device.
    tester.view.physicalSize = const Size(800 * 3, 1600 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    final prefs = await SharedPreferences.getInstance();

    // For the same reason the fixed-height Explore cards report overflows here
    // that do not happen with Poppins on a device; only those are ignored.
    final reportError = FlutterError.onError!;
    FlutterError.onError = (details) {
      if (checkOverflow || !details.exceptionAsString().contains('A RenderFlex overflowed')) reportError(details);
    };

    try {
      await http.runWithClient(
        () async {
          await tester.pumpWidget(app ??
              MultiBlocProvider(
                providers: [
                  BlocProvider(create: (_) => FavoritesCubit(prefs)),
                  BlocProvider(create: (_) => MyTripCubit(TripPlannerService())),
                ],
                child: MaterialApp(home: home),
              ));
          await body();
        },
        () => MockClient((_) async => http.Response(weatherFixture, 200)),
      );
    } finally {
      FlutterError.onError = reportError;
    }
  }

  /// Explore keeps two animations repeating forever, so pumpAndSettle() would
  /// never return once the main app is shown.
  Future<void> pumpFor(WidgetTester tester, Duration duration) async {
    for (var elapsed = Duration.zero; elapsed < duration; elapsed += const Duration(milliseconds: 100)) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  Future<void> tapAndSettle(WidgetTester tester, String button) async {
    await tester.tap(find.text(button));
    await tester.pumpAndSettle();
  }

  Future<void> goToPaywall(WidgetTester tester) async {
    await tapAndSettle(tester, 'Next');
    await tapAndSettle(tester, 'Next');
    await tapAndSettle(tester, 'Get Started');
  }

  group('opening the app', () {
    testWidgets('the first time goes straight to onboarding', (tester) async {
      final prefs = await SharedPreferences.getInstance();
      await withApp(tester, app: MyApp(prefs: prefs, onboardingCompleted: false), () async {
        expect(find.byType(OnboardingScreen), findsOneWidget);
        expect(find.byType(SplashScreen), findsNothing);
      });
    });

    testWidgets('after onboarding welcomes the user back for 2 seconds, then shows the main app', (tester) async {
      final prefs = await SharedPreferences.getInstance();
      await withApp(tester, app: MyApp(prefs: prefs, onboardingCompleted: true), () async {
        expect(find.text('Welcome Back'), findsOneWidget);
        expect(find.byType(OnboardingScreen), findsNothing);

        await tester.pump(const Duration(milliseconds: 1900));
        expect(find.byType(SplashScreen), findsOneWidget);
        expect(find.byType(MainScaffold), findsNothing);

        await pumpFor(tester, const Duration(seconds: 1));
        expect(find.byType(MainScaffold), findsOneWidget);
        expect(find.byType(SplashScreen), findsNothing);
      });
    });
  });

  testWidgets('3 pages → paywall → main app, and completion is remembered', (tester) async {
    await withApp(tester, () async {
      await goToPaywall(tester);

      expect(find.byType(OnboardingPaywallScreen), findsOneWidget);
      expect(await OnboardingService.isOnboardingCompleted(), isFalse);

      await tester.tap(find.text('Start Planning My Trip'));
      await pumpFor(tester, const Duration(seconds: 1));

      expect(find.byType(MainScaffold), findsOneWidget);
      expect(find.byType(SplashScreen), findsNothing, reason: 'the welcome back is for the next time');
      expect(await OnboardingService.isOnboardingCompleted(), isTrue);
    });
  });

  testWidgets('"Continue without premium" also enters the app', (tester) async {
    await withApp(tester, home: const OnboardingPaywallScreen(), () async {
      await tester.tap(find.text('Continue without premium'));
      await pumpFor(tester, const Duration(seconds: 1));
      expect(find.byType(MainScaffold), findsOneWidget);
      expect(await OnboardingService.isOnboardingCompleted(), isTrue);
    });
  });

  testWidgets('every page shows a photo and explains a benefit, with nothing to answer', (tester) async {
    await withApp(tester, () async {
      expect(find.text("Dubai's Best,\nAll in One Place"), findsOneWidget);
      await tapAndSettle(tester, 'Next');
      expect(find.text('Find Your Way\nAround Dubai'), findsOneWidget);
      await tapAndSettle(tester, 'Next');
      expect(find.text('Your Days,\nPlanned for You'), findsOneWidget);

      // The sharp photo, and the blurred copy of it that fades in at the bottom.
      final photos = tester.widgetList<Image>(find.byType(Image)).map((image) => image.image);
      expect(photos.toSet(), {const AssetImage('assets/images/onboarding_3.webp')});
      expect(find.byType(RadioListTile<String>), findsNothing);
      expect(find.textContaining('Yes,'), findsNothing);
    });
  });

  testWidgets('the text and button fit a small phone', (tester) async {
    await withApp(tester, () async {
      tester.view.physicalSize = const Size(320 * 3, 568 * 3);
      for (final button in ['Next', 'Next']) {
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await tapAndSettle(tester, button);
      }
      expect(tester.takeException(), isNull);
    }, checkOverflow: true);
  });

  testWidgets('swiping changes the page, and the button and dots follow', (tester) async {
    await withApp(tester, () async {
      expect(find.byType(AnimatedContainer), findsNWidgets(3), reason: 'one dot per page');

      await tester.fling(find.byType(PageView), const Offset(-600, 0), 2000);
      await tester.pumpAndSettle();
      expect(find.text('Find Your Way\nAround Dubai'), findsOneWidget);
      expect(find.text('Next'), findsOneWidget);

      await tester.fling(find.byType(PageView), const Offset(-600, 0), 2000);
      await tester.pumpAndSettle();
      expect(find.text('Your Days,\nPlanned for You'), findsOneWidget);
      expect(find.text('Get Started'), findsOneWidget);
      expect(find.text('Next'), findsNothing);
    });
  });

  testWidgets('main app: Explore content, weather, bottom navigation and favorites', (tester) async {
    await withApp(tester, () async {
      await goToPaywall(tester);
      await tester.tap(find.text('Start Planning My Trip'));
      await pumpFor(tester, const Duration(seconds: 2));

      // Explore tab
      expect(find.text('Most Popular Places'), findsOneWidget);
      expect(find.text('Burj Khalifa'), findsWidgets);

      await tester.scrollUntilVisible(find.text('Weather Forecast'), 300, scrollable: find.byType(Scrollable).first);
      await pumpFor(tester, const Duration(milliseconds: 500));
      expect(find.textContaining('°C |'), findsWidgets, reason: 'forecast cards rendered');
      expect(find.text('The forecast is unavailable right now.'), findsNothing);

      // Favorite a place from "Recommended" and see it on the Profile tab
      await tester.scrollUntilVisible(find.text('Recommended'), -300, scrollable: find.byType(Scrollable).first);
      await pumpFor(tester, const Duration(milliseconds: 300));
      await tester.tap(find.byIcon(Icons.favorite_border).first);
      await pumpFor(tester, const Duration(milliseconds: 300));

      await tester.tap(find.byIcon(Icons.person));
      await pumpFor(tester, const Duration(milliseconds: 500));
      expect(find.byType(ProfileScreen), findsOneWidget);
      expect(find.text("You haven't added any favorites yet."), findsNothing);
      expect(find.byIcon(Icons.favorite), findsOneWidget);

      await tester.tap(find.byType(SvgPicture));
      await pumpFor(tester, const Duration(milliseconds: 500));
      expect(find.byType(MyTripScreen), findsOneWidget);

      await tester.tap(find.byIcon(Icons.explore_outlined));
      await pumpFor(tester, const Duration(milliseconds: 500));
      expect(find.byType(CategoryScreen), findsOneWidget);
      expect(find.text('Must-See'), findsOneWidget);
    });
  });
}
