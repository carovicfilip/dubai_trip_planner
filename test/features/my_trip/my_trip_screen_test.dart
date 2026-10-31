import 'dart:async';
import 'dart:convert';

import 'package:dubai_trip_planner/features/my_trip/models/trip_plan.dart';
import 'package:dubai_trip_planner/features/my_trip/services/trip_plan_storage.dart';
import 'package:dubai_trip_planner/features/my_trip/ui/itinerary_screen.dart';
import 'package:dubai_trip_planner/features/my_trip/ui/my_trip_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/openai_fakes.dart';

void main() {
  late List<http.Request> requests;

  setUp(() {
    requests = [];
    SharedPreferences.setMockInitialValues({});
    dotenv.loadFromString(envString: 'OPENAI_API_KEY=sk-test-123');
  });

  MockClient openAi(Future<http.Response> Function(http.Request request) handler) {
    return MockClient((request) {
      requests.add(request);
      return handler(request);
    });
  }

  /// MyTripScreen creates its own TripPlannerService(); building it inside
  /// http.runWithClient makes that service use [client].
  Future<void> pumpMyTrip(WidgetTester tester, {http.Client? client}) async {
    // Large surface on purpose: the test font draws every glyph 1em wide, far
    // wider than Poppins, so phone-size layout is checked on a real device.
    tester.view.physicalSize = const Size(800 * 3, 1600 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await http.runWithClient(
      () async {
        await tester.pumpWidget(const MaterialApp(home: MyTripScreen()));
        await tester.pumpAndSettle();
      },
      () => client ?? openAi((_) async => throw StateError('unexpected OpenAI call')),
    );
  }

  Future<void> pickToday(WidgetTester tester) async {
    await tester.tap(find.text('Select date'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
  }

  Future<void> enterDays(WidgetTester tester, String days) async {
    await tester.enterText(find.byType(TextField).at(0), days);
    await tester.pump();
  }

  Future<void> enterLocation(WidgetTester tester, String location) async {
    await tester.enterText(find.byType(TextField).at(1), location);
    await tester.pump();
  }

  Future<void> selectCategory(WidgetTester tester, String category) async {
    await tester.ensureVisible(find.text(category));
    await tester.pumpAndSettle();
    await tester.tap(find.text(category));
    await tester.pump();
  }

  Future<void> fillValidForm(WidgetTester tester, {String days = '3'}) async {
    await pickToday(tester);
    await enterDays(tester, days);
    await enterLocation(tester, 'Dubai Marina');
    await selectCategory(tester, 'Beaches');
  }

  Future<void> tapShowResults(WidgetTester tester) async {
    await tester.tap(find.text('Show Results'));
    await tester.pump();
  }

  group('form validation (no AI call is made)', () {
    testWidgets('asks for the date first', (tester) async {
      await pumpMyTrip(tester);
      await tapShowResults(tester);
      expect(find.text('Please select your trip date (Step 1)'), findsOneWidget);
    });

    testWidgets('asks for the trip length', (tester) async {
      await pumpMyTrip(tester);
      await pickToday(tester);
      await tapShowResults(tester);
      expect(find.text('Please enter trip duration (Step 1)'), findsOneWidget);
    });

    for (final invalid in ['0', '-2', 'abc', '2.5']) {
      testWidgets('rejects trip length "$invalid"', (tester) async {
        await pumpMyTrip(tester);
        await pickToday(tester);
        await enterDays(tester, invalid);
        await tapShowResults(tester);
        expect(find.text('Please enter trip duration (Step 1)'), findsOneWidget);
      });
    }

    testWidgets('asks for the accommodation', (tester) async {
      await pumpMyTrip(tester);
      await pickToday(tester);
      await enterDays(tester, '3');
      await tapShowResults(tester);
      expect(find.text('Please enter your accommodation location (Step 2)'), findsOneWidget);
    });

    testWidgets('asks for at least one category', (tester) async {
      await pumpMyTrip(tester);
      await pickToday(tester);
      await enterDays(tester, '3');
      await enterLocation(tester, 'Dubai Marina');
      await tapShowResults(tester);
      expect(find.text('Please select at least one category (Step 3)'), findsOneWidget);
      expect(requests, isEmpty);
    });
  });

  testWidgets('happy path: sends the form to OpenAI, saves the plan and opens the itinerary', (tester) async {
    final response = Completer<http.Response>();
    await pumpMyTrip(tester, client: openAi((_) => response.future));
    await fillValidForm(tester);

    await tapShowResults(tester);
    expect(find.byType(CircularProgressIndicator), findsOneWidget, reason: 'spinner while waiting for the AI');
    expect(requests, hasLength(1));
    final prompt = (jsonDecode(requests.single.body)['messages'] as List<dynamic>)[1]['content'] as String;
    expect(prompt, contains('Traveler base location: Dubai Marina'));
    expect(prompt, contains('Interests/Categories: Beaches'));
    expect(prompt, contains('Create exactly 3 days'));

    response.complete(jsonResponse(chatCompletionBody(itineraryJson(3)), 200));
    await tester.pumpAndSettle();

    expect(find.byType(ItineraryScreen), findsOneWidget);
    expect(find.text('3-day stay in Dubai Marina'), findsOneWidget);
    expect(find.text('Day 1: Theme 1'), findsOneWidget);

    final saved = await TripPlanStorage.loadPlan();
    expect(saved?.location, 'Dubai Marina');
    expect(saved?.days, hasLength(3));
  });

  testWidgets('AI failure: shows an error and lets the user try again', (tester) async {
    await pumpMyTrip(
      tester,
      client: openAi((_) async => jsonResponse(
            openAiErrorBody('invalid_api_key', 'Incorrect API key provided: sk-test***123.'),
            401,
            contentType: 'text/plain',
          )),
    );
    await fillValidForm(tester);

    await tapShowResults(tester);
    await tester.pumpAndSettle();

    final snackText = tester.widget<Text>(find.descendant(of: find.byType(SnackBar), matching: find.byType(Text))).data!;
    // Documents what the user sees today: the raw OpenAI JSON.
    expect(snackText, startsWith('Plan generation failed: Exception: OpenAI error: {"error"'));
    expect(find.byType(ItineraryScreen), findsNothing);
    expect(find.text('Show Results'), findsOneWidget, reason: 'button is usable again');
  });

  testWidgets('restores the last saved plan when the screen opens', (tester) async {
    final plan = TripPlan(
      location: 'Business Bay',
      startDate: DateTime.now().add(const Duration(days: 10)),
      lengthInDays: 4,
      categories: const ['Rooftops', 'Spas'],
      days: [for (var i = 1; i <= 4; i++) DailyPlan(title: 'Day $i', highlights: const ['x'])],
    );
    SharedPreferences.setMockInitialValues({'recent_trip_plan': plan.serialize()});

    await pumpMyTrip(tester);

    expect(find.text('Your Tailored Itinerary'), findsOneWidget);
    expect(find.textContaining('4 days · Business Bay'), findsOneWidget);
    expect(tester.widget<TextField>(find.byType(TextField).at(0)).controller!.text, '4');
    expect(tester.widget<TextField>(find.byType(TextField).at(1)).controller!.text, 'Business Bay');
  });

  // Expected behaviour. Fails today: lastDate is DateTime(now.year + 1), i.e.
  // 1 January of next year, so in late October only ~2 months can be picked.
  testWidgets('date picker allows planning about a year ahead', (tester) async {
    await pumpMyTrip(tester);
    await tester.tap(find.text('Select date'));
    await tester.pumpAndSettle();

    final dialog = tester.widget<DatePickerDialog>(find.byType(DatePickerDialog));
    final daysAhead = dialog.lastDate.difference(DateUtils.dateOnly(DateTime.now())).inDays;
    expect(daysAhead, greaterThanOrEqualTo(364), reason: 'last selectable date is ${dialog.lastDate}');
  });

  // Documents current behaviour: there is no upper limit, so a 365-day
  // itinerary is requested from the model in a single call.
  testWidgets('accepts an unrealistic trip length and sends it to the AI', (tester) async {
    final response = Completer<http.Response>();
    await pumpMyTrip(tester, client: openAi((_) => response.future));
    await fillValidForm(tester, days: '365');

    await tapShowResults(tester);

    expect(requests, hasLength(1));
    expect(requests.single.body, contains('Create exactly 365 days'));
    response.complete(jsonResponse(chatCompletionBody(itineraryJson(1)), 200));
    await tester.pumpAndSettle();
  });
}
