import 'dart:async';

import 'package:dubai_trip_planner/app/theme/app_theme.dart';
import 'package:dubai_trip_planner/core/widgets/custom_back_button.dart';
import 'package:dubai_trip_planner/features/my_trip/cubit/my_trip_cubit.dart';
import 'package:dubai_trip_planner/features/my_trip/models/trip_plan.dart';
import 'package:dubai_trip_planner/features/my_trip/services/trip_plan_storage.dart';
import 'package:dubai_trip_planner/features/my_trip/services/trip_planner_service.dart';
import 'package:dubai_trip_planner/features/my_trip/ui/itinerary_screen.dart';
import 'package:dubai_trip_planner/features/my_trip/ui/my_trip_screen.dart';
import 'package:dubai_trip_planner/features/my_trip/ui/widgets/arrival_calendar.dart';
import 'package:dubai_trip_planner/features/my_trip/ui/widgets/saved_plan_card.dart';
import 'package:dubai_trip_planner/features/my_trip/ui/widgets/stay_length_picker.dart';
import 'package:dubai_trip_planner/features/my_trip/ui/widgets/trip_form_button.dart';
import 'package:dubai_trip_planner/l10n/l10n.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:intl/intl.dart' hide TextDirection;
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

  /// Shows [home] (My Trip by default) under a MyTripCubit whose trip planner
  /// sends its OpenAI requests to [client].
  Future<void> pumpMyTrip(WidgetTester tester, {http.Client? client, Widget home = const MyTripScreen(), Locale? locale}) async {
    // Large surface on purpose: the test font draws every glyph 1em wide, far
    // wider than Poppins, so phone-size layout is checked on a real device.
    tester.view.physicalSize = const Size(800 * 3, 1600 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    final planner = TripPlannerService(
      httpClient: client ?? openAi((_) async => throw StateError('unexpected OpenAI call')),
    );
    await tester.pumpWidget(BlocProvider(
      create: (_) => MyTripCubit(planner),
      child: MaterialApp(locale: locale, localizationsDelegates: appLocalizationsDelegates, supportedLocales: AppLocalizations.supportedLocales, home: home),
    ));
    await tester.pumpAndSettle();
  }

  Finder dayInCalendar(String day) => find.descendant(of: find.byType(ArrivalCalendar), matching: find.text(day));
  Finder daysToStay(int days) => find.descendant(of: find.byType(StayLengthPicker), matching: find.text('$days'));

  bool isLocked(WidgetTester tester) {
    final button = find.descendant(of: find.byType(TripFormButton), matching: find.byType(TextButton));
    return tester.widget<TextButton>(button).onPressed == null;
  }

  MyTripState formState(WidgetTester tester) => tester.element(find.byType(MyTripScreen)).read<MyTripCubit>().state;

  /// Next month, where every day can be picked whatever the date today.
  Future<void> pickDayNextMonth(WidgetTester tester) async {
    await tester.tap(find.byIcon(Icons.chevron_right));
    await tester.pumpAndSettle();
    await tester.tap(dayInCalendar('15'));
    await tester.pumpAndSettle();
  }

  Future<void> pickDays(WidgetTester tester, int days) async {
    await tester.ensureVisible(daysToStay(days));
    await tester.pumpAndSettle();
    await tester.tap(daysToStay(days));
    await tester.pumpAndSettle();
  }

  Future<void> tapNext(WidgetTester tester) async {
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
  }

  Future<void> enterLocation(WidgetTester tester, String location) async {
    await tester.enterText(find.byType(TextField), location);
    await tester.pumpAndSettle();
  }

  Future<void> selectCategory(WidgetTester tester, String category) async {
    await tester.ensureVisible(find.text(category));
    await tester.pumpAndSettle();
    await tester.tap(find.text(category));
    await tester.pumpAndSettle();
  }

  Future<void> goToLocationStep(WidgetTester tester, {int days = 3}) async {
    await pickDayNextMonth(tester);
    await pickDays(tester, days);
    await tapNext(tester);
  }

  Future<void> goToCategoriesStep(WidgetTester tester, {int days = 3}) async {
    await goToLocationStep(tester, days: days);
    await enterLocation(tester, 'Dubai Marina');
    await tapNext(tester);
  }

  Future<void> fillValidForm(WidgetTester tester, {int days = 3}) async {
    await goToCategoriesStep(tester, days: days);
    await selectCategory(tester, 'Beaches');
  }

  Future<void> tapShowResults(WidgetTester tester) async {
    await tester.tap(find.text('Show Results'));
    await tester.pump();
  }

  Widget openedFromAnotherScreen() {
    return Builder(
      builder: (context) => Scaffold(
        body: TextButton(
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MyTripScreen())),
          child: const Text('Open'),
        ),
      ),
    );
  }

  TripPlan planStarting(DateTime startDate, {int days = 4}) {
    return TripPlan(
      location: 'Business Bay',
      startDate: startDate,
      lengthInDays: days,
      categories: const ['Rooftops', 'Spas'],
      days: [for (var i = 1; i <= days; i++) DailyPlan(title: 'Day $i', highlights: const ['x'])],
    );
  }

  group('step 1: the arrival day and the length of the stay', () {
    testWidgets('opens with the calendar and the numbers 1 to 15 in view', (tester) async {
      await pumpMyTrip(tester);

      expect(find.text('When do you arrive?'), findsOneWidget);
      expect(find.byType(ArrivalCalendar), findsOneWidget);
      for (var days = 1; days <= TripPlannerService.maxTripDays; days++) {
        expect(daysToStay(days), findsOneWidget);
      }
      expect(daysToStay(TripPlannerService.maxTripDays + 1), findsNothing);
    });

    testWidgets('Next looks locked and does nothing until both are chosen', (tester) async {
      await pumpMyTrip(tester);
      expect(isLocked(tester), isTrue);
      expect(find.byIcon(Icons.lock_outline_rounded), findsOneWidget);
      await tester.tap(find.text('Next'), warnIfMissed: false);
      await tester.pumpAndSettle();
      expect(find.text('When do you arrive?'), findsOneWidget);

      await pickDayNextMonth(tester);
      expect(isLocked(tester), isTrue, reason: 'only the day chosen');

      await pickDays(tester, 3);
      expect(isLocked(tester), isFalse);
      expect(find.byIcon(Icons.lock_outline_rounded), findsNothing);
      await tapNext(tester);
      expect(find.text('Where are you staying?'), findsOneWidget);
    });

    testWidgets('the length alone does not unlock Next either', (tester) async {
      await pumpMyTrip(tester);

      await pickDays(tester, 3);

      expect(isLocked(tester), isTrue);
    });

    testWidgets('what was picked is what gets stored, and shown back', (tester) async {
      await pumpMyTrip(tester);

      await pickDayNextMonth(tester);
      await pickDays(tester, 5);

      final now = DateTime.now();
      final arrival = DateTime(now.year, now.month + 1, 15);
      expect(formState(tester).startDate, arrival);
      expect(formState(tester).stayLengthDays, 5);
      final format = DateFormat.MMMd();
      final last = DateUtils.addDaysToDate(arrival, 4);
      expect(find.text('${format.format(arrival)} – ${format.format(last)} · 5 days'), findsOneWidget);
    });

    testWidgets('the arrival day can be today, but not a day before it or a month before this one', (tester) async {
      await pumpMyTrip(tester);
      final now = DateTime.now();

      final previousMonth = tester.widget<IconButton>(find.widgetWithIcon(IconButton, Icons.chevron_left));
      expect(previousMonth.onPressed, isNull);
      if (now.day > 1) {
        await tester.tap(dayInCalendar('${now.day - 1}'));
        await tester.pumpAndSettle();
        expect(formState(tester).startDate, isNull);
      }

      await tester.tap(dayInCalendar('${now.day}'));
      await tester.pumpAndSettle();
      expect(formState(tester).startDate, DateTime(now.year, now.month, now.day));
    });

    // Regression test: lastDate used to be DateTime(now.year + 1), i.e.
    // 1 January of next year, so in late October only ~2 months could be picked.
    testWidgets('the calendar allows planning about a year ahead, and stops there', (tester) async {
      await pumpMyTrip(tester);

      final calendar = tester.widget<ArrivalCalendar>(find.byType(ArrivalCalendar));
      final daysAhead = calendar.lastDate.difference(DateUtils.dateOnly(DateTime.now())).inDays;
      expect(daysAhead, greaterThanOrEqualTo(364), reason: 'last selectable date is ${calendar.lastDate}');

      IconButton nextMonth() => tester.widget<IconButton>(find.widgetWithIcon(IconButton, Icons.chevron_right));
      var pages = 0;
      while (nextMonth().onPressed != null) {
        await tester.tap(find.byIcon(Icons.chevron_right));
        await tester.pumpAndSettle();
        pages++;
      }
      expect(pages, 12);
      expect(find.text(DateFormat.yMMMM().format(calendar.lastDate)), findsOneWidget);
    });

    testWidgets('choosing the longest stay explains what to do about a longer one', (tester) async {
      await pumpMyTrip(tester);
      await pickDayNextMonth(tester);

      await pickDays(tester, 14);
      expect(find.textContaining('Staying longer?'), findsNothing);

      await pickDays(tester, TripPlannerService.maxTripDays);
      final now = DateTime.now();
      final nextPart = DateFormat.MMMd().format(DateTime(now.year, now.month + 1, 30));
      expect(find.textContaining('Staying longer?'), findsOneWidget);
      expect(find.textContaining('start a new plan from $nextPart'), findsOneWidget);
    });
  });

  group('step 2: the accommodation', () {
    testWidgets('Next stays locked until something is entered', (tester) async {
      await pumpMyTrip(tester);
      await goToLocationStep(tester);

      expect(find.text('Where are you staying?'), findsOneWidget);
      expect(isLocked(tester), isTrue);

      await enterLocation(tester, '   ');
      expect(isLocked(tester), isTrue, reason: 'only spaces');

      await enterLocation(tester, 'Dubai Marina');
      expect(isLocked(tester), isFalse);
      await tapNext(tester);
      expect(find.text('What do you love?'), findsOneWidget);
    });

    testWidgets('offers the areas to choose from', (tester) async {
      await pumpMyTrip(tester);
      await goToLocationStep(tester);

      for (final area in [
        'Dubai Marina',
        'Palm Jumeirah',
        'Oud Metha',
        'Al Barsha',
        'Bur Dubai',
        'Jumeirah',
        'Dubai World Trade Centre (DWTC)',
        'Deira',
        'Jebel Ali',
        'Downtown Dubai',
      ]) {
        expect(find.text(area), findsOneWidget, reason: area);
      }
    });

    testWidgets('an area can be chosen instead of typing', (tester) async {
      await pumpMyTrip(tester);
      await goToLocationStep(tester);

      await tester.tap(find.text('Palm Jumeirah'));
      await tester.pumpAndSettle();

      expect(tester.widget<TextField>(find.byType(TextField)).controller!.text, 'Palm Jumeirah');
      expect(formState(tester).location, 'Palm Jumeirah');
      expect(isLocked(tester), isFalse);
    });

    testWidgets('the text that goes into the AI prompt is capped', (tester) async {
      await pumpMyTrip(tester);
      await goToLocationStep(tester);

      await tester.enterText(find.byType(TextField), 'Dubai Marina ' * 20);

      final text = tester.widget<TextField>(find.byType(TextField)).controller!.text;
      expect(text, hasLength(TripPlannerService.maxLocationLength));
    });
  });

  group('step 3: the categories', () {
    testWidgets('Show Results is locked without a category', (tester) async {
      await pumpMyTrip(tester);
      await goToCategoriesStep(tester);

      expect(find.text('What do you love?'), findsOneWidget);
      expect(find.text('Next'), findsNothing);
      expect(find.text('Show Results'), findsOneWidget);
      expect(isLocked(tester), isTrue);

      await selectCategory(tester, 'Beaches');
      expect(isLocked(tester), isFalse);

      await selectCategory(tester, 'Beaches');
      expect(isLocked(tester), isTrue, reason: 'the only category taken away again');
      await tester.tap(find.text('Show Results'), warnIfMissed: false);
      await tester.pump();
      expect(requests, isEmpty);
    });

    testWidgets('the five most popular come first, apart from the others', (tester) async {
      await pumpMyTrip(tester);
      await goToCategoriesStep(tester);
      double top(String text) => tester.getTopLeft(find.text(text)).dy;

      final popular = ['Attractions', 'Shopping', 'Beaches', 'Restaurants', 'Theme parks'];
      for (final category in popular) {
        expect(top(category), lessThan(top('More categories')), reason: category);
        expect(top(category), greaterThan(top('Most popular')), reason: category);
      }
      for (final category in ['Cafes', 'Museums', 'Spas', 'Rooftops']) {
        expect(top(category), greaterThan(top('More categories')), reason: category);
      }
      expect(find.text('Attractions'), findsOneWidget, reason: 'not listed twice');
    });

    testWidgets('a category from either group can be picked', (tester) async {
      await pumpMyTrip(tester);
      await goToCategoriesStep(tester);

      await selectCategory(tester, 'Shopping');
      await selectCategory(tester, 'Spas');

      expect(formState(tester).categories, {'Shopping', 'Spas'});
    });

    testWidgets('shows the answers so far', (tester) async {
      await pumpMyTrip(tester);
      await goToCategoriesStep(tester);

      expect(find.textContaining('· 3 days'), findsOneWidget);
      expect(find.text('Dubai Marina'), findsOneWidget);
    });
  });

  testWidgets('says which step this is to a screen reader, and no longer on screen', (tester) async {
    final semantics = tester.ensureSemantics();
    await pumpMyTrip(tester);

    expect(find.bySemanticsLabel('Step 1 of 3'), findsOneWidget);
    expect(find.text('1/3'), findsNothing);

    await goToLocationStep(tester);
    expect(find.bySemanticsLabel('Step 2 of 3'), findsOneWidget);
    expect(find.text('2/3'), findsNothing);
    semantics.dispose();
  });

  group('going back', () {
    testWidgets('the arrow goes back a step keeping the answers, and leaves from the first step', (tester) async {
      await pumpMyTrip(tester, home: openedFromAnotherScreen());
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      await goToCategoriesStep(tester);

      await tester.tap(find.byType(CustomBackButton));
      await tester.pumpAndSettle();
      expect(find.text('Where are you staying?'), findsOneWidget);
      expect(tester.widget<TextField>(find.byType(TextField)).controller!.text, 'Dubai Marina');

      await tester.tap(find.byType(CustomBackButton));
      await tester.pumpAndSettle();
      expect(find.text('When do you arrive?'), findsOneWidget);
      expect(isLocked(tester), isFalse, reason: 'the day and the length are still chosen');

      await tester.tap(find.byType(CustomBackButton));
      await tester.pumpAndSettle();
      expect(find.byType(MyTripScreen), findsNothing);
      expect(find.text('Open'), findsOneWidget);
    });

    testWidgets('as a tab, the first step has no arrow to leave by', (tester) async {
      await pumpMyTrip(tester);
      expect(find.byType(CustomBackButton), findsNothing);

      await goToLocationStep(tester);
      expect(find.byType(CustomBackButton), findsOneWidget);
    });

    testWidgets("the system's back goes back a step as well", (tester) async {
      await pumpMyTrip(tester);
      await goToLocationStep(tester);

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();

      expect(find.byType(MyTripScreen), findsOneWidget);
      expect(find.text('When do you arrive?'), findsOneWidget);
    });
  });

  testWidgets('happy path: sends the form to OpenAI, saves the plan and opens the itinerary', (tester) async {
    final response = Completer<http.Response>();
    await pumpMyTrip(tester, client: openAi((_) => response.future));
    await fillValidForm(tester);

    await tapShowResults(tester);
    expect(find.byType(CircularProgressIndicator), findsOneWidget, reason: 'spinner while waiting for the AI');
    expect(requests, hasLength(1));
    final details = tripDetailsSent(requests.single);
    expect(details['accommodation'], 'Dubai Marina');
    expect(details['interests'], ['Beaches']);
    expect(details['dates'], hasLength(3));

    response.complete(jsonResponse(chatCompletionBody(itineraryJson(3)), 200));
    await tester.pumpAndSettle();

    expect(find.byType(ItineraryScreen), findsOneWidget);
    expect(find.text('3-day stay in Dubai Marina'), findsOneWidget);
    expect(find.text('Day 1: Theme 1'), findsOneWidget);
    expect(find.text('Area 1'), findsOneWidget);

    final saved = (await TripPlanStorage.loadPlans()).single;
    expect(saved.location, 'Dubai Marina');
    expect(saved.days, hasLength(3));

    await tester.tap(find.byType(CustomBackButton));
    await tester.pumpAndSettle();
    expect(find.text('When do you arrive?'), findsOneWidget);
    expect(find.text('Your Tailored Itinerary'), findsOneWidget);
  });

  testWidgets('15 days can be planned', (tester) async {
    final response = Completer<http.Response>();
    await pumpMyTrip(tester, client: openAi((_) => response.future));
    await fillValidForm(tester, days: TripPlannerService.maxTripDays);

    await tapShowResults(tester);

    expect(tripDetailsSent(requests.single)['dates'], hasLength(TripPlannerService.maxTripDays));
    response.complete(jsonResponse(chatCompletionBody(itineraryJson(TripPlannerService.maxTripDays)), 200));
    await tester.pumpAndSettle();
    expect(find.byType(ItineraryScreen), findsOneWidget);
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
    // A rejected key is nothing the user can fix, and OpenAI's raw JSON must not show.
    expect(snackText, 'The trip planner is unavailable right now. Please try again later.');
    expect(snackText, isNot(contains('{')));
    expect(find.byType(ItineraryScreen), findsNothing);
    expect(find.text('Show Results'), findsOneWidget, reason: 'button is usable again');
    expect(isLocked(tester), isFalse);
  });

  group('the saved plan', () {
    testWidgets('is restored when the screen opens, with the form filled in from it', (tester) async {
      final plan = planStarting(DateTime.now().add(const Duration(days: 10)));
      SharedPreferences.setMockInitialValues({'recent_trip_plan': plan.serialize()});

      await pumpMyTrip(tester);

      expect(find.text('Your Tailored Itinerary'), findsOneWidget);
      expect(find.text('Business Bay'), findsOneWidget);
      expect(
        find.descendant(of: find.byType(SavedPlanCard), matching: find.textContaining('· 4 days')),
        findsOneWidget,
      );
      expect(formState(tester).stayLengthDays, 4);
      expect(isLocked(tester), isFalse);

      await tapNext(tester);
      expect(tester.widget<TextField>(find.byType(TextField)).controller!.text, 'Business Bay');
    });

    testWidgets('that has already started leaves the day to be picked again', (tester) async {
      final plan = planStarting(DateTime.now().subtract(const Duration(days: 10)));
      SharedPreferences.setMockInitialValues({'recent_trip_plan': plan.serialize()});

      await pumpMyTrip(tester);

      expect(find.text('Your Tailored Itinerary'), findsOneWidget);
      expect(formState(tester).startDate, isNull);
      expect(isLocked(tester), isTrue);
    });

    testWidgets('has a border in the colors of the open button', (tester) async {
      final plan = planStarting(DateTime.now().add(const Duration(days: 10)));
      SharedPreferences.setMockInitialValues({'recent_trip_plan': plan.serialize()});
      await pumpMyTrip(tester);

      final border = tester.widget<DecoratedBox>(
        find.descendant(of: find.byType(SavedPlanCard), matching: find.byType(DecoratedBox)).first,
      );

      expect((border.decoration as BoxDecoration).gradient, TripFormButton.gradient);
    });

    testWidgets('opens with a tap', (tester) async {
      final plan = planStarting(DateTime.now().add(const Duration(days: 10)));
      SharedPreferences.setMockInitialValues({'recent_trip_plan': plan.serialize()});
      await pumpMyTrip(tester);

      await tester.tap(find.text('Your Tailored Itinerary'));
      await tester.pumpAndSettle();

      expect(find.byType(ItineraryScreen), findsOneWidget);
    });

    testWidgets('is deleted with its button, after asking', (tester) async {
      final plan = planStarting(DateTime.now().add(const Duration(days: 10)));
      SharedPreferences.setMockInitialValues({'recent_trip_plan': plan.serialize()});
      await pumpMyTrip(tester);

      await tester.tap(find.byTooltip('Delete'));
      await tester.pumpAndSettle();
      expect(find.text('Delete Trip?'), findsOneWidget);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(find.byType(SavedPlanCard), findsOneWidget);

      await tester.tap(find.byTooltip('Delete'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      expect(find.byType(SavedPlanCard), findsNothing);
      expect(await TripPlanStorage.loadPlans(), isEmpty);
      expect(formState(tester).isFormEmpty, isTrue);
      expect(isLocked(tester), isTrue);
    });
  });

  group('several saved trips', () {
    TripPlan tripTo(String location) {
      return TripPlan(
        location: location,
        startDate: DateTime.now().add(const Duration(days: 10)),
        lengthInDays: 2,
        categories: const ['Spas'],
        days: const [
          DailyPlan(title: 'Day 1', highlights: ['Morning: Spa']),
          DailyPlan(title: 'Day 2', highlights: ['Morning: Pool']),
        ],
      );
    }

    Future<void> pumpThreeTrips(WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({
        'trip_plans': [for (final area in ['Jumeirah', 'Deira', 'Bur Dubai']) tripTo(area).serialize()],
      });
      await pumpMyTrip(tester);
    }

    testWidgets('all show on the first step, the newest first', (tester) async {
      await pumpThreeTrips(tester);

      expect(find.byType(SavedPlanCard), findsNWidgets(3));
      final left = [for (final area in ['Jumeirah', 'Deira', 'Bur Dubai']) tester.getTopLeft(find.text(area)).dx];
      expect(left, orderedEquals([...left]..sort()));
      expect(find.byType(ArrivalCalendar), findsOneWidget, reason: 'the form is still there');
    });

    testWidgets('each opens its own plan, scrolling sideways to reach it', (tester) async {
      await pumpThreeTrips(tester);

      await tester.drag(find.byType(SavedPlansStrip), const Offset(-1200, 0));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Bur Dubai'));
      await tester.pumpAndSettle();

      expect(find.byType(ItineraryScreen), findsOneWidget);
      expect(find.text('2-day stay in Bur Dubai'), findsOneWidget);
    });

    testWidgets('deleting one leaves the others', (tester) async {
      await pumpThreeTrips(tester);

      await tester.tap(find.byTooltip('Delete').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      expect(find.byType(SavedPlanCard), findsNWidgets(2));
      expect(find.text('Jumeirah'), findsNothing);
      expect((await TripPlanStorage.loadPlans()).map((plan) => plan.location), ['Deira', 'Bur Dubai']);
    });

    testWidgets('a new plan is added to them instead of replacing them', (tester) async {
      final response = Completer<http.Response>();
      SharedPreferences.setMockInitialValues({
        'trip_plans': [for (final area in ['Jumeirah', 'Deira', 'Bur Dubai']) tripTo(area).serialize()],
      });
      await pumpMyTrip(tester, client: openAi((_) => response.future));
      await tester.tap(find.byIcon(Icons.chevron_right));
      await tester.pumpAndSettle();
      await tester.tap(dayInCalendar('15'));
      await tester.pumpAndSettle();
      await tapNext(tester);
      await enterLocation(tester, 'Dubai Marina');
      await tapNext(tester);
      await tapShowResults(tester);

      response.complete(jsonResponse(chatCompletionBody(itineraryJson(2)), 200));
      await tester.pumpAndSettle();

      final saved = await TripPlanStorage.loadPlans();
      expect(saved.map((plan) => plan.location), ['Dubai Marina', 'Jumeirah', 'Deira', 'Bur Dubai']);
    });
  });

  // Regression test: the app's theme paints text buttons dark blue, which hid
  // both the colors of the open button and the glass of the locked one.
  group('in another language', () {
    testWidgets('the form is translated, its values stay in English, and the plan is asked for in that language', (tester) async {
      await pumpMyTrip(
        tester,
        locale: const Locale('de'),
        client: openAi((_) async => jsonResponse(chatCompletionBody(itineraryJson(3)), 200)),
      );
      expect(find.text('Wann kommst du an?'), findsOneWidget);

      await pickDayNextMonth(tester);
      await pickDays(tester, 3);
      await tester.tap(find.text('Weiter'));
      await tester.pumpAndSettle();
      expect(find.text('Wo übernachtest du?'), findsOneWidget);

      await tester.tap(find.text('Downtown Dubai'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Weiter'));
      await tester.pumpAndSettle();
      expect(find.text('Was liebst du?'), findsOneWidget);

      await selectCategory(tester, 'Strände');
      expect(formState(tester).categories, {'Beaches'});

      await tester.tap(find.text('Ergebnis anzeigen'));
      await tester.pumpAndSettle();

      final details = tripDetailsSent(requests.single);
      expect(details['language'], 'German');
      expect(details['interests'], ['Beaches']);
      expect(details['accommodation'], 'Downtown Dubai');

      expect(find.byType(ItineraryScreen), findsOneWidget);
      expect(find.text('Dein Reiseplan'), findsOneWidget);
      expect(find.text('3 Tage in Downtown Dubai'), findsOneWidget);
      expect(find.text('Strände'), findsOneWidget);
      expect(find.text('Tag 1: Theme 1'), findsOneWidget);
    });

    testWidgets('an area is shown in the language of the app and stored in English', (tester) async {
      await pumpMyTrip(tester, locale: const Locale('ru'));
      await pickDayNextMonth(tester);
      await pickDays(tester, 3);
      await tester.tap(find.text('Далее'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Дейра'));
      await tester.pumpAndSettle();

      expect(formState(tester).location, 'Deira');
      expect(find.widgetWithText(TextField, 'Дейра'), findsOneWidget);
      final chip = tester.getSemantics(find.text('Дейра').last);
      expect(chip, isNotNull);
    });

    testWidgets('what the user types stays as it is, also the name of an area', (tester) async {
      await pumpMyTrip(tester, locale: const Locale('ru'));
      await pickDayNextMonth(tester);
      await pickDays(tester, 3);
      await tester.tap(find.text('Далее'));
      await tester.pumpAndSettle();

      await enterLocation(tester, 'Deira');

      expect(formState(tester).location, 'Deira');
      expect(find.widgetWithText(TextField, 'Deira'), findsOneWidget);
    });

    testWidgets('an error is explained in the language of the app', (tester) async {
      await pumpMyTrip(
        tester,
        locale: const Locale('fr'),
        client: openAi((_) async => jsonResponse(openAiErrorBody('rate_limit_exceeded', 'Slow down'), 429)),
      );
      await pickDayNextMonth(tester);
      await pickDays(tester, 3);
      await tester.tap(find.text('Suivant'));
      await tester.pumpAndSettle();
      await enterLocation(tester, 'Deira');
      await tester.tap(find.text('Suivant'));
      await tester.pumpAndSettle();
      await selectCategory(tester, 'Plages');
      await tester.tap(find.text('Voir les résultats'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Le planificateur est occupé'), findsOneWidget);
    });

    testWidgets('the steps and the calendar run from right to left in Arabic', (tester) async {
      await pumpMyTrip(tester, locale: const Locale('ar'));
      expect(Directionality.of(tester.element(find.byType(ArrivalCalendar))), TextDirection.rtl);

      final previous = tester.getCenter(find.byIcon(Icons.chevron_left));
      final next = tester.getCenter(find.byIcon(Icons.chevron_right));
      expect(next.dx, lessThan(previous.dx));

      await pickDayNextMonth(tester);
      await pickDays(tester, 3);
      expect(formState(tester).stayLengthDays, 3);
    });
  });

  testWidgets("the app's theme does not paint over the button", (tester) async {
    tester.view.physicalSize = const Size(800 * 3, 1600 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(BlocProvider(
      create: (_) => MyTripCubit(TripPlannerService()),
      child: MaterialApp(localizationsDelegates: appLocalizationsDelegates, supportedLocales: AppLocalizations.supportedLocales, theme: AppTheme.lightTheme, home: const MyTripScreen()),
    ));
    await tester.pumpAndSettle();

    final button = find.descendant(of: find.byType(TripFormButton), matching: find.byType(TextButton));
    final style = tester.widget<TextButton>(button).style!;
    expect(style.backgroundColor!.resolve({}), Colors.transparent);
    expect(style.backgroundColor!.resolve({WidgetState.disabled}), Colors.transparent);
  });

  group('with the keyboard open', () {
    const keyboardHeight = 300.0;
    const screenHeight = 800.0;

    Future<void> openKeyboardOnLocationStep(WidgetTester tester) async {
      await goToLocationStep(tester);
      tester.view.physicalSize = const Size(800 * 3, screenHeight * 3);
      tester.view.viewInsets = const FakeViewPadding(bottom: keyboardHeight * 3);
      await tester.pumpAndSettle();
    }

    testWidgets('the button stays above it when opened from another screen', (tester) async {
      await pumpMyTrip(tester);
      await openKeyboardOnLocationStep(tester);

      expect(tester.getBottomLeft(find.byType(TripFormButton)).dy, lessThanOrEqualTo(screenHeight - keyboardHeight));
      expect(tester.takeException(), isNull);
    });

    testWidgets('the button stays above it on the tab, over the floating bar', (tester) async {
      await pumpMyTrip(
        tester,
        home: const Scaffold(body: MyTripScreen(), bottomNavigationBar: SizedBox(height: 100)),
      );
      await openKeyboardOnLocationStep(tester);

      expect(tester.getBottomLeft(find.byType(TripFormButton)).dy, lessThanOrEqualTo(screenHeight - keyboardHeight));
      expect(tester.takeException(), isNull);
    });
  });

  testWidgets('every step fits a small phone', (tester) async {
    await pumpMyTrip(tester);
    tester.view.physicalSize = const Size(320 * 3, 568 * 3);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    await goToLocationStep(tester, days: TripPlannerService.maxTripDays);
    expect(tester.takeException(), isNull);

    await enterLocation(tester, 'Dubai Marina');
    await tapNext(tester);
    expect(find.text('What do you love?'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  // Regression test: the tab bar builds My Trip from scratch on every visit.
  // Leaving the tab while a plan was being generated dropped the spinner, so
  // the user could pay for the same plan twice, and lost what they had typed.
  testWidgets('leaving My Trip while a plan is generated keeps the request, the form and the step', (tester) async {
    final response = Completer<http.Response>();
    var onMyTrip = true;
    late StateSetter switchTab;
    await pumpMyTrip(
      tester,
      client: openAi((_) => response.future),
      home: StatefulBuilder(builder: (context, setState) {
        switchTab = setState;
        return onMyTrip ? const MyTripScreen() : const Scaffold(body: Text('Explore'));
      }),
    );
    await fillValidForm(tester);
    await tapShowResults(tester);

    switchTab(() => onMyTrip = false);
    await tester.pump();
    switchTab(() => onMyTrip = true);
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget, reason: 'the plan is still being generated');
    expect(find.text('What do you love?'), findsOneWidget);
    expect(formState(tester).location, 'Dubai Marina');
    await tester.tap(find.byType(TextButton), warnIfMissed: false);
    await tester.pump();

    response.complete(jsonResponse(chatCompletionBody(itineraryJson(3)), 200));
    await tester.pumpAndSettle();

    expect(find.text('Your Tailored Itinerary'), findsOneWidget);
    expect(requests, hasLength(1));
  });

  testWidgets('a half-filled form comes back on the same step after leaving the tab', (tester) async {
    var onMyTrip = true;
    late StateSetter switchTab;
    await pumpMyTrip(
      tester,
      home: StatefulBuilder(builder: (context, setState) {
        switchTab = setState;
        return onMyTrip ? const MyTripScreen() : const Scaffold(body: Text('Explore'));
      }),
    );
    await goToLocationStep(tester);
    await enterLocation(tester, 'JBR');

    switchTab(() => onMyTrip = false);
    await tester.pumpAndSettle();
    switchTab(() => onMyTrip = true);
    await tester.pumpAndSettle();

    expect(find.text('Where are you staying?'), findsOneWidget);
    expect(tester.widget<TextField>(find.byType(TextField)).controller!.text, 'JBR');
  });
}
