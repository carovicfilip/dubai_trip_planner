// Full user journey on a simulator/device: onboarding, Explore, place details,
// My Trip with a real AI call, saved itinerary, Profile, Categories, and the
// splash shown the next time the app opens. Collects layout overflows and
// screenshots into $E2E_OUT (default ./e2e_out).
// Clears the app's local data (SharedPreferences) first.
//
//   E2E_OUT=e2e_out flutter drive --driver=test_driver/integration_test.dart \
//     --target=integration_test/app_e2e_test.dart -d <simulator id>

import 'dart:io' show Platform;

import 'package:dubai_trip_planner/app/router/main_scaffold.dart';
import 'package:dubai_trip_planner/features/explore/ui/widgets/popular_place_card.dart';
import 'package:dubai_trip_planner/features/my_trip/models/trip_plan.dart';
import 'package:dubai_trip_planner/features/my_trip/services/trip_plan_storage.dart';
import 'package:dubai_trip_planner/features/my_trip/ui/itinerary_screen.dart';
import 'package:dubai_trip_planner/main.dart' as app;
import 'package:material_ui/material_ui.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('full user journey on a real device', (tester) async {
    final notes = <String>[];
    final overflows = <String>{};

    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    Future<void> pumpFor(Duration duration) async {
      final end = DateTime.now().add(duration);
      while (DateTime.now().isBefore(end)) {
        await tester.pump(const Duration(milliseconds: 100));
      }
    }

    Future<bool> waitFor(Finder finder, {Duration timeout = const Duration(seconds: 30)}) async {
      final end = DateTime.now().add(timeout);
      while (DateTime.now().isBefore(end)) {
        await tester.pump(const Duration(milliseconds: 200));
        if (finder.evaluate().isNotEmpty) return true;
      }
      return false;
    }

    Future<void> shot(String name) async {
      await tester.pump();
      await binding.takeScreenshot(name);
    }

    Future<void> tapAndWait(Finder finder, {Duration wait = const Duration(milliseconds: 900)}) async {
      await tester.tap(finder);
      await pumpFor(wait);
    }

    final previousOnError = FlutterError.onError;
    FlutterError.onError = (details) {
      final text = details.exceptionAsString();
      if (text.contains('overflowed by')) {
        final where = RegExp(r'lib/[\w/]+\.dart:\d+').firstMatch(details.toString())?.group(0) ?? '?';
        overflows.add('${text.split('\n').first}  <-  $where');
        return;
      }
      previousOnError?.call(details);
    };

    try {
      await app.main();
      // Android can only screenshot an image-backed Flutter surface.
      if (Platform.isAndroid) await binding.convertFlutterSurfaceToImage();
      expect(await waitFor(find.text('Next')), isTrue, reason: 'the app should open on onboarding');
      // Let the first photo fade in so the screenshot is the same on every run.
      await pumpFor(const Duration(milliseconds: 800));
      await shot('01_onboarding_page1');
      await tapAndWait(find.text('Next'));
      await shot('02_onboarding_page2');
      await tapAndWait(find.text('Next'));
      await shot('02b_onboarding_page3');
      await tester.tap(find.text('Get Started'));
      expect(await waitFor(find.byType(MainScaffold)), isTrue, reason: 'onboarding should lead to the main app');
      await pumpFor(const Duration(seconds: 2));
      await shot('04_explore_top');

      final explore = find.byType(Scrollable).first;
      await tester.scrollUntilVisible(find.text('Recommended'), 250, scrollable: explore);
      await pumpFor(const Duration(milliseconds: 600));
      await shot('05_explore_recommended');

      await tester.scrollUntilVisible(find.text('Weather Forecast'), 250, scrollable: explore);
      final weatherLoaded = await waitFor(find.textContaining('°C |'), timeout: const Duration(seconds: 20));
      final weatherError = find.text('The forecast is unavailable right now.').evaluate().isNotEmpty;
      notes.add('WEATHER (real OpenWeatherMap call): ${weatherLoaded ? 'loaded' : weatherError ? 'error shown' : 'not loaded'}');
      await tester.drag(explore, const Offset(0, -200));
      await pumpFor(const Duration(milliseconds: 600));
      await shot('06_explore_weather_tips');

      await tester.scrollUntilVisible(find.text('Most Popular Places'), -300, scrollable: explore);
      await pumpFor(const Duration(milliseconds: 400));
      // The swipe layer of the deck lies over the cards, so tap the spot.
      await tester.tapAt(tester.getCenter(find.byType(PopularPlaceCard).last));
      // The first place opened asks about the app. Not the happy face: the
      // store's own dialog that follows it cannot be closed from here.
      await pumpFor(const Duration(milliseconds: 1500));
      await shot('07a_rating_question');
      await tapAndWait(find.byIcon(Icons.sentiment_neutral_outlined));
      await shot('07_place_details');
      await tester.drag(find.text('About'), const Offset(0, -320));
      await pumpFor(const Duration(milliseconds: 600));
      await shot('07b_place_details_scrolled');
      await tapAndWait(find.byIcon(Icons.arrow_back_ios_new));

      // My Trip: fill the form and call the real OpenAI endpoint.
      await tapAndWait(find.byType(SvgPicture).last);
      await tapAndWait(find.text('Select date'));
      await shot('08_date_picker');
      await tapAndWait(find.text('OK'));
      await tester.enterText(find.byType(TextField).at(0), '3');
      await tester.enterText(find.byType(TextField).at(1), 'Dubai Marina');
      FocusManager.instance.primaryFocus?.unfocus();
      await pumpFor(const Duration(milliseconds: 500));
      for (final category in ['Beaches', 'Restaurants', 'Rooftops']) {
        await tester.ensureVisible(find.text(category));
        await pumpFor(const Duration(milliseconds: 300));
        await tester.tap(find.text(category));
        await tester.pump();
      }
      await pumpFor(const Duration(milliseconds: 400));
      await shot('09_my_trip_form');

      final stopwatch = Stopwatch()..start();
      await tester.tap(find.text('Show Results'));
      await tester.pump(const Duration(milliseconds: 300));
      await shot('10_my_trip_loading');
      final finished = await waitFor(
        find.byWidgetPredicate((w) => w is ItineraryScreen || w is SnackBar),
        // The app itself gives up after 3 minutes.
        timeout: const Duration(seconds: 190),
      );
      stopwatch.stop();
      if (find.byType(ItineraryScreen).evaluate().isNotEmpty) {
        await pumpFor(const Duration(milliseconds: 800));
        notes.add('AI: itinerary generated in ${stopwatch.elapsed.inMilliseconds} ms');
        await shot('11_ai_itinerary');
        await tapAndWait(find.byType(BackButton));
      } else if (finished) {
        final snack = tester.widget<Text>(find.descendant(of: find.byType(SnackBar), matching: find.byType(Text))).data;
        notes.add('AI: error after ${stopwatch.elapsed.inMilliseconds} ms -> $snack');
        await pumpFor(const Duration(milliseconds: 400));
        await shot('11_ai_error_snackbar');
      } else {
        notes.add('AI: no result after 190 s');
      }
      await pumpFor(const Duration(seconds: 4));

      // Seed a plan with long month names to check the itinerary layout.
      await TripPlanStorage.savePlan(TripPlan(
        location: 'Jumeirah Beach Residence',
        startDate: DateTime(2026, 11, 28),
        lengthInDays: 4,
        categories: const ['Beaches', 'Restaurants', 'Rooftops', 'Nightlife'],
        days: const [
          DailyPlan(title: 'Day 1: Beach and Marina Life', area: 'Jumeirah Beach Residence & Dubai Marina', highlights: [
            'Morning: JBR Beach (Jumeirah Beach Residence) – Swim, then breakfast at a beachfront café.\n'
                'Getting there: 5 min walk from your accommodation',
            'Afternoon: Dubai Marina Walk (Dubai Marina) – Stroll the promenade and take a dhow cruise.\n'
                'Getting there: 10 min by tram',
            'Evening: Pier 7 (Dubai Marina) – Dinner with marina views.\nGetting there: 5 min walk',
          ]),
          // Saved before days had an area.
          DailyPlan(title: 'Day 2: Downtown Dubai', highlights: [
            'Morning: At the Top, Burj Khalifa (levels 124–125)',
            'Afternoon: The Dubai Mall and the Dubai Aquarium',
            'Evening: Dubai Fountain show from the boardwalk',
          ]),
          DailyPlan(title: 'Day 3: Old Dubai', highlights: ['Morning: Al Fahidi', 'Evening: Gold Souk']),
          DailyPlan(title: 'Day 4: Palm Jumeirah', highlights: ['Morning: Aquaventure', 'Evening: Atlantis']),
        ],
      ));
      await tapAndWait(find.byIcon(Icons.person));
      await shot('12_profile');
      await tapAndWait(find.byType(SvgPicture).last);
      await shot('13_my_trip_saved_plan');
      await tapAndWait(find.text('Your Tailored Itinerary'));
      await shot('14_itinerary_seeded');
      await tapAndWait(find.byType(BackButton));

      await tapAndWait(find.byIcon(Icons.explore_outlined), wait: const Duration(milliseconds: 1500));
      await shot('15_categories');

      // Opening the app again now that onboarding is done.
      await tester.pumpWidget(app.MyApp(key: UniqueKey(), prefs: prefs, onboardingCompleted: true));
      expect(await waitFor(find.text('Welcome Back')), isTrue, reason: 'a returning user is welcomed back');
      await pumpFor(const Duration(milliseconds: 800));
      await shot('16_welcome_back_splash');
      expect(await waitFor(find.byType(MainScaffold), timeout: const Duration(seconds: 5)), isTrue);
    } finally {
      FlutterError.onError = previousOnError;
      // reportData also carries the screenshots, so add to it instead of replacing it.
      final report = binding.reportData ??= <String, dynamic>{};
      report['device'] = '${tester.view.physicalSize / tester.view.devicePixelRatio} @${tester.view.devicePixelRatio}x';
      report['notes'] = notes;
      report['overflows'] = overflows.toList()..sort();
    }
  });
}
