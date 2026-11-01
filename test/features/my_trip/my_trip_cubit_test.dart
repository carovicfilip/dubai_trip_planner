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

void main() {
  late List<http.Request> requests;

  setUp(() {
    requests = [];
    SharedPreferences.setMockInitialValues({});
    dotenv.loadFromString(envString: 'OPENAI_API_KEY=sk-test-123');
  });

  final savedPlan = TripPlan(
    location: 'Business Bay',
    startDate: DateTime(2026, 12, 20),
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
      ..updateStayLength('3')
      ..updateLocation(' Dubai Marina ')
      ..toggleCategory('Beaches');
  }

  Future<http.Response> itinerary() async => jsonResponse(chatCompletionBody(itineraryJson(3)), 200);

  test('reports the first problem in the form, step by step', () {
    final trip = cubit();
    expect(trip.state.formError, MyTripFormError.missingDate);

    trip.selectStartDate(DateTime(2026, 12, 1));
    for (final invalid in ['', '0', '-2', 'abc', '2.5']) {
      trip.updateStayLength(invalid);
      expect(trip.state.formError, MyTripFormError.missingLength, reason: '"$invalid"');
    }

    trip.updateStayLength('${TripPlannerService.maxTripDays + 1}');
    expect(trip.state.formError, MyTripFormError.tooLong);
    trip.shortenToMaxDays();
    expect(trip.state.stayLength, '${TripPlannerService.maxTripDays}');

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

  test('generatePlan plans the form, saves the plan and shows it', () async {
    final trip = withValidForm(answer: itinerary);

    final generating = trip.generatePlan();
    expect(trip.state.isGenerating, isTrue);
    final plan = await generating;

    expect(trip.state.isGenerating, isFalse);
    expect(trip.state.savedPlan, same(plan));
    expect(plan.location, 'Dubai Marina');
    expect((await TripPlanStorage.loadPlan())?.days, hasLength(3));
    expect(requests.single.body, contains('Create exactly 3 days'));
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
    await TripPlanStorage.savePlan(savedPlan);
    final trip = withValidForm(answer: () async => jsonResponse(openAiErrorBody('server_error', 'Oops'), 500));
    await trip.loadSavedPlan();

    await expectLater(trip.generatePlan(), throwsA(isA<OpenAiHttpException>()));

    expect(trip.state.isGenerating, isFalse);
    expect(trip.state.savedPlan?.location, 'Business Bay');
    expect((await TripPlanStorage.loadPlan())?.location, 'Business Bay');
  });

  test('refuses an incomplete form without calling OpenAI', () async {
    final trip = cubit();

    await expectLater(trip.generatePlan(), throwsStateError);

    expect(trip.state.isGenerating, isFalse);
    expect(requests, isEmpty);
  });

  group('loadSavedPlan', () {
    test('fills an empty form with the saved plan', () async {
      await TripPlanStorage.savePlan(savedPlan);
      final trip = cubit();

      await trip.loadSavedPlan();

      expect(trip.state.savedPlan?.location, 'Business Bay');
      expect(trip.state.startDate, DateTime(2026, 12, 20));
      expect(trip.state.stayLength, '2');
      expect(trip.state.location, 'Business Bay');
      expect(trip.state.categories, {'Spas'});
    });

    test('keeps what the user has already typed', () async {
      await TripPlanStorage.savePlan(savedPlan);
      final trip = cubit()..updateLocation('JBR');

      await trip.loadSavedPlan();

      expect(trip.state.savedPlan?.location, 'Business Bay');
      expect(trip.state.location, 'JBR');
      expect(trip.state.stayLength, isEmpty);
    });
  });

  test('deletePlan removes the saved plan and clears the form', () async {
    await TripPlanStorage.savePlan(savedPlan);
    final trip = cubit();
    await trip.loadSavedPlan();

    await trip.deletePlan();

    expect(trip.state.savedPlan, isNull);
    expect(trip.state.isFormEmpty, isTrue);
    expect(await TripPlanStorage.loadPlan(), isNull);
  });
}
