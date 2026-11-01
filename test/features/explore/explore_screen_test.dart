import 'dart:io';

import 'package:dubai_trip_planner/app/router/main_scaffold.dart';
import 'package:dubai_trip_planner/app/theme/theme_cubit.dart';
import 'package:dubai_trip_planner/core/repositories/category_repository.dart';
import 'package:dubai_trip_planner/core/repositories/place_repository.dart';
import 'package:dubai_trip_planner/core/widgets/gradient_hero.dart';
import 'package:dubai_trip_planner/features/explore/ui/explore_screen.dart';
import 'package:dubai_trip_planner/features/explore/ui/widgets/popular_place_card.dart';
import 'package:dubai_trip_planner/features/favorites/cubit/favorites_cubit.dart';
import 'package:dubai_trip_planner/features/my_trip/cubit/my_trip_cubit.dart';
import 'package:dubai_trip_planner/features/my_trip/services/trip_planner_service.dart';
import 'package:dubai_trip_planner/features/my_trip/ui/my_trip_screen.dart';
import 'package:dubai_trip_planner/features/place_details/ui/place_details_screen.dart';
import 'package:dubai_trip_planner/features/weather/services/weather_forecast_service.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

  /// Runs [body] on the main app. Explore keeps animations running forever,
  /// so time is moved with [pumpFor] rather than pumpAndSettle().
  Future<void> withMainApp(WidgetTester tester, Future<void> Function() body) async {
    // Large surface on purpose: the test font draws every glyph 1em wide, far
    // wider than Poppins, so phone-size layout is checked on a real device.
    tester.view.physicalSize = const Size(800 * 3, 2400 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    final prefs = await SharedPreferences.getInstance();

    // For the same reason the fixed-height cards report overflows here that do
    // not happen with Poppins on a device; only those are ignored.
    final reportError = FlutterError.onError!;
    FlutterError.onError = (details) {
      if (!details.exceptionAsString().contains('A RenderFlex overflowed')) reportError(details);
    };

    try {
      await http.runWithClient(
        () async {
          await tester.pumpWidget(MultiBlocProvider(
            providers: [
              BlocProvider(create: (_) => FavoritesCubit(prefs)),
              BlocProvider(create: (_) => MyTripCubit(TripPlannerService())),
              BlocProvider(create: (_) => ThemeCubit(prefs)),
            ],
            child: const MaterialApp(home: MainScaffold()),
          ));
          await body();
        },
        () => MockClient((_) async => http.Response(weatherFixture, 200)),
      );
    } finally {
      FlutterError.onError = reportError;
    }
  }

  Future<void> pumpFor(WidgetTester tester, Duration duration) async {
    for (var elapsed = Duration.zero; elapsed < duration; elapsed += const Duration(milliseconds: 100)) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  testWidgets('keeps its sections, in their order, with the same data', (tester) async {
    await withMainApp(tester, () async {
      await pumpFor(tester, const Duration(seconds: 1));

      final titles = ['Welcome to', 'Most Popular Places', 'Categories', 'Recommended', 'Weather Forecast', 'Hack & Tips'];
      final tops = [for (final title in titles) tester.getTopLeft(find.text(title).first).dy];
      expect(tops, [...tops]..sort(), reason: 'sections appear in this order: $titles');

      expect(find.text('Welcome to'), findsOneWidget);
      expect(find.text('Plan My Trip'), findsOneWidget);
      expect(find.byType(PopularPlaceCard), findsWidgets);
      expect(find.text(PlaceRepository.getFeaturedPlaces().first.name), findsWidgets);
      for (final category in CategoryRepository.allCategories.take(3)) {
        expect(find.text(category.name), findsOneWidget);
      }
      expect(find.text(PlaceRepository.getTopRatedPlaces().first.name), findsWidgets);
      expect(find.textContaining('°C |'), findsWidgets);
      expect(find.text('Use Nol Card for Transport'), findsOneWidget);
    });
  });

  testWidgets('the status bar icons are white over the dark header', (tester) async {
    await withMainApp(tester, () async {
      await pumpFor(tester, const Duration(milliseconds: 300));

      final view = tester.binding.renderViews.first;
      final style = view.debugLayer!.find<SystemUiOverlayStyle>(Offset(view.paintBounds.center.dx, 1));

      expect(style?.statusBarIconBrightness, Brightness.light);
    });
  });

  testWidgets('a band for the status bar appears only once the header has scrolled away', (tester) async {
    await withMainApp(tester, () async {
      // Short enough for the list to scroll.
      tester.view.physicalSize = const Size(800 * 3, 1000 * 3);
      await pumpFor(tester, const Duration(milliseconds: 300));
      double bandOpacity() => tester
          .widget<Opacity>(find.ancestor(of: find.byKey(HeroListView.statusBarBandKey), matching: find.byType(Opacity)))
          .opacity;
      expect(bandOpacity(), 0);

      await tester.drag(find.byType(Scrollable).first, const Offset(0, -300));
      await pumpFor(tester, const Duration(milliseconds: 500));

      expect(bandOpacity(), 1);
    });
  });

  testWidgets('tapping a popular place opens its details', (tester) async {
    await withMainApp(tester, () async {
      await pumpFor(tester, const Duration(milliseconds: 300));

      await tester.tapAt(tester.getCenter(find.byType(PopularPlaceCard).last));
      await pumpFor(tester, const Duration(seconds: 1));

      expect(find.byType(PlaceDetailsScreen), findsOneWidget);
    });
  });

  group('the floating navigation bar', () {
    testWidgets('names the four tabs and marks the open one for screen readers', (tester) async {
      final semantics = tester.ensureSemantics();
      await withMainApp(tester, () async {
        await pumpFor(tester, const Duration(milliseconds: 300));

        final explore = tester.getSemantics(find.bySemanticsLabel('Explore'));
        expect(explore.flagsCollection.isSelected, isNotNull);
        expect(find.bySemanticsLabel('My Trip'), findsOneWidget);
        expect(find.bySemanticsLabel('Profile'), findsOneWidget);
      });
      semantics.dispose();
    });

    testWidgets('Explore runs on under it', (tester) async {
      await withMainApp(tester, () async {
        await pumpFor(tester, const Duration(milliseconds: 300));

        expect(tester.getBottomLeft(find.byType(ExploreScreen)).dy, tester.view.physicalSize.height / 3);
      });
    });

    // Regression guard: My Trip pins "Show Results" to the bottom of its
    // screen, which must stay above the bar.
    testWidgets('the other tabs stay above it', (tester) async {
      await withMainApp(tester, () async {
        await tester.tap(find.text('My Trip'));
        await pumpFor(tester, const Duration(milliseconds: 500));

        expect(find.byType(MyTripScreen), findsOneWidget);
        final buttonBottom = tester.getBottomLeft(find.text('Show Results')).dy;
        final barTop = tester.getTopLeft(find.byIcon(Icons.person)).dy;
        expect(buttonBottom, lessThan(barTop));
      });
    });
  });
}
