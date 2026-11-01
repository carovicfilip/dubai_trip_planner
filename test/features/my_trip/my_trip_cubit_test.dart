import 'dart:async';

import 'package:dubai_trip_planner/features/my_trip/cubit/my_trip_cubit.dart';
import 'package:dubai_trip_planner/features/my_trip/models/trip_plan.dart';
import 'package:dubai_trip_planner/features/my_trip/services/trip_plan_storage.dart';
import 'package:dubai_trip_planner/features/my_trip/services/trip_planner_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/openai_fakes.dart';

Future<void> savePlan(TripPlan plan) => TripPlanStorage.savePlans([plan]);

Future<TripPlan?> loadPlan() async => (await TripPlanStorage.loadPlans()).firstOrNull;

void main() {
  late List<http.Request> requests;

  setUp(() {
    requests = [];
    SharedPreferences.setMockInitialValues({});
    dotenv.loadFromString(envString: 'OPENAI_API_KEY=sk-test-123');
  });

  final now = DateTime.now();
  final nextMonth = DateTime(now.year, now.month + 1, now.day);

  final savedPlan = TripPlan(
    location: 'Business Bay',
    startDate: nextMonth,
    lengthInDays: 2,
    categories: const ['Spas'],
    days: const [
      DailyPlan(title: 'Day 1', highlights: ['Morning: Spa']),
      DailyPlan(title: 'Day 2', highlights: ['Evening: Rooftop']),
    ],
  );

  MyTripCubit cubit({Future<http.Response> Function()? answer}) {
    return MyTripCubit(TripPlannerService(
      httpClient: MockClient((request) {
        requests.add(request);
        return answer?.call() ?? Future.error(StateError('unexpected OpenAI call'));
      }),
    ));
  }

  MyTripCubit withValidForm({required Future<http.Response> Function() answer}) {
    return cubit(answer: answer)
      ..selectStartDate(DateTime(2026, 12, 1))
      ..selectStayLength(3)
      ..updateLocation(' Dubai Marina ')
      ..toggleCategory('Beaches');
  }

  Future<http.Response> itinerary() async => jsonResponse(chatCompletionBody(itineraryJson(3)), 200);

  test('reports the first problem in the form, step by step', () {
    final trip = cubit();
    expect(trip.state.formError, MyTripFormError.missingDate);

    trip.selectStartDate(DateTime(2026, 12, 1));
    expect(trip.state.formError, MyTripFormError.missingLength);
    trip.selectStayLength(TripPlannerService.maxTripDays);

    expect(trip.state.formError, MyTripFormError.missingLocation);
    trip.updateLocation('   ');
    expect(trip.state.formError, MyTripFormError.missingLocation);
    trip.updateLocation('JBR');

    expect(trip.state.formError, MyTripFormError.missingCategories);
    trip.toggleCategory('Beaches');
    expect(trip.state.formError, isNull);
    trip.toggleCategory('Beaches');
    expect(trip.state.formError, MyTripFormError.missingCategories);
  });

  group('steps', () {
    test('goes on only from a step that is filled in', () {
      final trip = cubit();

      trip.nextStep();
      expect(trip.state.step, 0, reason: 'nothing chosen');
      trip.selectStartDate(nextMonth);
      trip.nextStep();
      expect(trip.state.step, 0, reason: 'only the date chosen');
      trip.selectStayLength(3);
      trip.nextStep();
      expect(trip.state.step, 1);

      trip.updateLocation('   ');
      trip.nextStep();
      expect(trip.state.step, 1, reason: 'only spaces typed');
      trip.updateLocation('JBR');
      trip.nextStep();
      expect(trip.state.step, 2);

      expect(trip.state.isStepComplete, isFalse);
      trip.toggleCategory('Spas');
      expect(trip.state.isStepComplete, isTrue);
      trip.nextStep();
      expect(trip.state.step, MyTripState.lastStep, reason: 'there is no step after the last');
    });

    test('going back keeps the answers and stops at the first step', () {
      final trip = cubit()
        ..selectStartDate(nextMonth)
        ..selectStayLength(3)
        ..nextStep()
        ..updateLocation('JBR')
        ..nextStep();

      trip.previousStep();
      expect(trip.state.step, 1);
      expect(trip.state.location, 'JBR');
      trip.previousStep();
      trip.previousStep();
      expect(trip.state.step, 0);
      expect(trip.state.stayLengthDays, 3);
    });

    test('a finished plan brings the form back to the first step, a failed one does not', () async {
      var fails = true;
      final trip = cubit(
        answer: () async => fails ? jsonResponse(openAiErrorBody('server_error', 'Oops'), 500) : await itinerary(),
      )
        ..selectStartDate(nextMonth)
        ..selectStayLength(3)
        ..nextStep()
        ..updateLocation('JBR')
        ..nextStep()
        ..toggleCategory('Spas');

      await expectLater(trip.generatePlan(), throwsA(isA<OpenAiHttpException>()));
      expect(trip.state.step, MyTripState.lastStep);

      fails = false;
      await trip.generatePlan();
      expect(trip.state.step, 0);
    });
  });

  test('generatePlan plans the form, saves the plan and shows it', () async {
    final trip = withValidForm(answer: itinerary);

    final generating = trip.generatePlan();
    expect(trip.state.isGenerating, isTrue);
    final plan = await generating;

    expect(trip.state.isGenerating, isFalse);
    expect(trip.state.savedPlans.firstOrNull, same(plan));
    expect(plan.location, 'Dubai Marina');
    expect((await loadPlan())?.days, hasLength(3));
    final details = tripDetailsSent(requests.single);
    expect(details['accommodation'], 'Dubai Marina', reason: 'sent without the spaces around it');
    expect(details['dates'], hasLength(3));
  });

  test('asking again while a plan is generated sends no second request', () async {
    final response = Completer<http.Response>();
    final trip = withValidForm(answer: () => response.future);

    final first = trip.generatePlan();
    final second = trip.generatePlan();
    response.complete(await itinerary());

    expect(await second, same(await first));
    expect(requests, hasLength(1));
  });

  test('a failed request ends the loading state and keeps the saved plan', () async {
    await savePlan(savedPlan);
    final trip = withValidForm(answer: () async => jsonResponse(openAiErrorBody('server_error', 'Oops'), 500));
    await trip.loadSavedPlans();

    await expectLater(trip.generatePlan(), throwsA(isA<OpenAiHttpException>()));

    expect(trip.state.isGenerating, isFalse);
    expect(trip.state.savedPlans.firstOrNull?.location, 'Business Bay');
    expect((await loadPlan())?.location, 'Business Bay');
  });

  test('refuses an incomplete form without calling OpenAI', () async {
    final trip = cubit();

    await expectLater(trip.generatePlan(), throwsStateError);

    expect(trip.state.isGenerating, isFalse);
    expect(requests, isEmpty);
  });

  group('loadSavedPlans', () {
    test('fills an empty form with the saved plan', () async {
      await savePlan(savedPlan);
      final trip = cubit();

      await trip.loadSavedPlans();

      expect(trip.state.savedPlans.firstOrNull?.location, 'Business Bay');
      expect(trip.state.startDate, nextMonth);
      expect(trip.state.stayLengthDays, 2);
      expect(trip.state.location, 'Business Bay');
      expect(trip.state.categories, {'Spas'});
    });

    test('keeps what the user has already typed', () async {
      await savePlan(savedPlan);
      final trip = cubit()..updateLocation('JBR');

      await trip.loadSavedPlans();

      expect(trip.state.savedPlans.firstOrNull?.location, 'Business Bay');
      expect(trip.state.location, 'JBR');
      expect(trip.state.stayLengthDays, isNull);
    });

    test('leaves out a date that has passed, which the calendar could not show', () async {
      await savePlan(TripPlan(
        location: 'Business Bay',
        startDate: DateTime(now.year, now.month, now.day - 1),
        lengthInDays: 2,
        categories: const ['Spas'],
        days: savedPlan.days,
      ));
      final trip = cubit();

      await trip.loadSavedPlans();

      expect(trip.state.savedPlans.firstOrNull, isNotNull);
      expect(trip.state.startDate, isNull);
      expect(trip.state.isStepComplete, isFalse);
      expect(trip.state.location, 'Business Bay');
    });
  });

  test('updateSavedPlan shows the changed plan and keeps it for the next time', () async {
    await savePlan(savedPlan);
    final trip = cubit();
    await trip.loadSavedPlans();

    final changed = savedPlan.withDay(0, savedPlan.days[0].withItemToggled(0));
    await trip.updateSavedPlan(changed);

    expect(trip.state.savedPlans.firstOrNull, same(changed));
    expect((await loadPlan())?.days[0].isDone(0), isTrue);
  });

  group('several trips', () {
    TripPlan tripTo(String location) => TripPlan(
          location: location,
          startDate: nextMonth,
          lengthInDays: 3,
          categories: const ['Spas'],
          days: const [
            DailyPlan(title: 'Day 1', highlights: ['Morning: Spa']),
          ],
        );

    test('a new plan comes first and keeps the others', () async {
      await TripPlanStorage.savePlans([tripTo('JBR'), tripTo('Deira')]);
      final trip = withValidForm(answer: itinerary);
      await trip.loadSavedPlans();

      await trip.generatePlan(languageCode: 'en');

      expect(trip.state.savedPlans.map((plan) => plan.location), ['Dubai Marina', 'JBR', 'Deira']);
      expect((await TripPlanStorage.loadPlans()).map((plan) => plan.location), ['Dubai Marina', 'JBR', 'Deira']);
    });

    test('a new plan for the same trip takes the place of the old one', () async {
      final start = DateTime(2026, 12, 1);
      await TripPlanStorage.savePlans([
        TripPlan(location: 'Dubai Marina', startDate: start, lengthInDays: 3, categories: const ['Spas'], days: const []),
        tripTo('Deira'),
      ]);
      final trip = withValidForm(answer: itinerary);

      await trip.generatePlan(languageCode: 'en');

      final saved = await TripPlanStorage.loadPlans();
      expect(saved.map((plan) => plan.location), ['Dubai Marina', 'Deira']);
      expect(saved.first.days, hasLength(3), reason: 'the new version, not the old one');
    });

    test('updating one leaves the others alone', () async {
      final first = tripTo('JBR');
      final second = tripTo('Deira').withDay(0, tripTo('Deira').days[0].withItemToggled(0));
      await TripPlanStorage.savePlans([first, tripTo('Deira')]);
      final trip = cubit();
      await trip.loadSavedPlans();

      await trip.updateSavedPlan(second);

      final saved = await TripPlanStorage.loadPlans();
      expect(saved.map((plan) => plan.location), ['JBR', 'Deira']);
      expect(saved[0].days[0].isDone(0), isFalse);
      expect(saved[1].days[0].isDone(0), isTrue);
      expect(trip.state.savedPlans[1].days[0].isDone(0), isTrue);
    });

    test('deleting one keeps the others and the form', () async {
      final first = tripTo('JBR');
      await TripPlanStorage.savePlans([first, tripTo('Deira')]);
      final trip = cubit();
      await trip.loadSavedPlans();

      await trip.deletePlan(first);

      expect(trip.state.savedPlans.map((plan) => plan.location), ['Deira']);
      expect((await TripPlanStorage.loadPlans()).map((plan) => plan.location), ['Deira']);
      expect(trip.state.location, 'JBR', reason: 'the form was filled in from the newest and stays');
    });

    test('the form is filled in from the newest', () async {
      await TripPlanStorage.savePlans([tripTo('JBR'), tripTo('Deira')]);
      final trip = cubit();

      await trip.loadSavedPlans();

      expect(trip.state.location, 'JBR');
      expect(trip.state.savedPlans, hasLength(2));
    });
  });

  test('deletePlan removes the last saved plan and clears the form', () async {
    await savePlan(savedPlan);
    final trip = cubit();
    await trip.loadSavedPlans();

    await trip.deletePlan(savedPlan);

    expect(trip.state.savedPlans.firstOrNull, isNull);
    expect(trip.state.isFormEmpty, isTrue);
    expect(await loadPlan(), isNull);
  });
}
