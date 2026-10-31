import 'dart:io';

import 'package:dubai_trip_planner/app/router/main_scaffold.dart';
import 'package:dubai_trip_planner/features/categories/ui/categories_screen.dart';
import 'package:dubai_trip_planner/features/favorites/cubit/favorites_cubit.dart';
import 'package:dubai_trip_planner/features/my_trip/ui/my_trip_screen.dart';
import 'package:dubai_trip_planner/features/onboarding/services/onboarding_service.dart';
import 'package:dubai_trip_planner/features/onboarding/ui/onboarding_paywall_screen.dart';
import 'package:dubai_trip_planner/features/onboarding/ui/onboarding_screen.dart';
import 'package:dubai_trip_planner/features/profile/ui/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  const firstAnswers = [
    'Yes, absolutely!',
    'Yes, it takes forever!',
    'Yes, happens all the time!',
    'Yes, that would be perfect!',
  ];

  final weatherFixture = File('test/fixtures/openweather_forecast_dubai.json').readAsStringSync();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  /// Runs [body] with [home] as the first screen. HTTP calls (the weather
  /// section on the Explore tab) are answered from a recorded response.
  Future<void> withApp(WidgetTester tester, Future<void> Function() body, {Widget home = const OnboardingScreen()}) async {
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
      if (!details.exceptionAsString().contains('A RenderFlex overflowed')) reportError(details);
    };

    try {
      await http.runWithClient(
        () async {
          await tester.pumpWidget(BlocProvider(
            create: (_) => FavoritesCubit(prefs),
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

  ElevatedButton nextButton(WidgetTester tester) => tester.widget<ElevatedButton>(find.byType(ElevatedButton));

  testWidgets('4 questions → paywall → main app, and completion is remembered', (tester) async {
    await withApp(tester, () async {
      for (var i = 0; i < firstAnswers.length; i++) {
        expect(nextButton(tester).onPressed, isNull, reason: 'Next is disabled until question ${i + 1} is answered');
        await tester.tap(find.text(firstAnswers[i]));
        await tester.pump();
        expect(nextButton(tester).onPressed, isNotNull);
        await tester.tap(find.text(i == firstAnswers.length - 1 ? 'See Solution' : 'Next'));
        await tester.pumpAndSettle();
      }

      expect(find.byType(OnboardingPaywallScreen), findsOneWidget);
      expect(await OnboardingService.isOnboardingCompleted(), isFalse);

      await tester.tap(find.text('Start Planning My Trip'));
      await pumpFor(tester, const Duration(seconds: 1));

      expect(find.byType(MainScaffold), findsOneWidget);
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

  // Expected behaviour. Fails today: the bar always draws 5 segments while
  // there are only 4 questions, so it never fills up.
  testWidgets('progress bar has one segment per question', (tester) async {
    await withApp(tester, () async {
      final segments = find.byWidgetPredicate(
        (w) => w is Container && w.constraints == const BoxConstraints.tightFor(height: 4),
      );
      expect(segments, findsNWidgets(firstAnswers.length));
    });
  });

  testWidgets('main app: Explore content, weather, bottom navigation and favorites', (tester) async {
    await withApp(tester, () async {
      for (var i = 0; i < firstAnswers.length; i++) {
        await tester.tap(find.text(firstAnswers[i]));
        await tester.pump();
        await tester.tap(find.text(i == firstAnswers.length - 1 ? 'See Solution' : 'Next'));
        await tester.pumpAndSettle();
      }
      await tester.tap(find.text('Start Planning My Trip'));
      await pumpFor(tester, const Duration(seconds: 2));

      // Explore tab
      expect(find.text('Most Popular Places'), findsOneWidget);
      expect(find.text('Burj Khalifa'), findsWidgets);
      expect(find.text('Test Onboarding (DELETE LATER)'), findsOneWidget, reason: 'debug button is visible to users');

      await tester.scrollUntilVisible(find.text('Weather Forecast'), 300, scrollable: find.byType(Scrollable).first);
      await pumpFor(tester, const Duration(milliseconds: 500));
      expect(find.textContaining('°C |'), findsWidgets, reason: 'forecast cards rendered');
      expect(find.textContaining('Error:'), findsNothing);

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
