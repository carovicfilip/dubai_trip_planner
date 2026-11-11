import 'dart:async';
import 'dart:convert';
import 'dart:ui' show Locale;

import 'package:dubai_trip_planner/core/backend/backend_api.dart';
import 'package:dubai_trip_planner/features/my_trip/models/trip_plan.dart';
import 'package:dubai_trip_planner/features/my_trip/services/trip_planner_service.dart';
import 'package:dubai_trip_planner/l10n/l10n.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import '../../helpers/backend_fakes.dart';

// The prompt, the schema and the OpenAI request are built by the backend;
// backend/test/tripPlan.test.ts covers them.
void main() {
  final english = lookupAppLocalizations(const Locale('en'));
  final startDate = DateTime(2026, 11, 10);

  Future<String?> appCheckToken() async => 'app-check-token';

  Future<TripPlan> generate(
    http.Client client, {
    int days = 3,
    DateTime? start,
    String location = 'Dubai Marina',
    List<String> categories = const ['Beaches', 'Restaurants'],
    String languageCode = 'en',
    AppCheckTokenSource? token,
  }) {
    return TripPlannerService(httpClient: client, appCheckToken: token ?? appCheckToken).generatePlan(
      startDate: start ?? startDate,
      lengthInDays: days,
      location: location,
      categories: categories,
      languageCode: languageCode,
    );
  }

  MockClient answering(String body, {int status = 200}) => MockClient((_) async => jsonResponse(body, status));

  /// Plans a trip against a fake backend and returns the request it got.
  Future<http.Request> requestFor({DateTime? start, AppCheckTokenSource? token}) async {
    late http.Request sent;
    final client = MockClient((request) async {
      sent = request;
      return jsonResponse(itineraryJson(3), 200);
    });
    await generate(client, start: start, token: token);
    return sent;
  }

  Matcher throwsWithMessage(String fragment) =>
      throwsA(predicate((e) => e.toString().contains(fragment), 'error mentioning "$fragment"'));

  group('request sent to the backend', () {
    test('POSTs the form as JSON to /trip-plan with the App Check token', () async {
      final sent = await requestFor();

      expect(sent.method, 'POST');
      expect(sent.url, BackendApi.tripPlanUri);
      expect(sent.url.path, '/trip-plan');
      expect(sent.headers['X-Firebase-AppCheck'], 'app-check-token');
      expect(sent.headers['Content-Type'], startsWith('application/json'));
      expect(jsonDecode(sent.body), {
        'startDate': '2026-11-10',
        'lengthInDays': 3,
        'accommodation': 'Dubai Marina',
        'interests': ['Beaches', 'Restaurants'],
        'language': 'en',
      });
    });

    test('sends no key of any kind', () async {
      final sent = await requestFor();
      expect(sent.headers.keys.map((h) => h.toLowerCase()), isNot(contains('authorization')));
      expect(sent.url.queryParameters, isEmpty);
    });

    test('still sends the request without an App Check token, which the backend then refuses', () async {
      final sent = await requestFor(token: () async => null);
      expect(sent.headers, isNot(contains('X-Firebase-AppCheck')));
    });

    test('sends the day the user picked, whatever the time of day', () async {
      final sent = await requestFor(start: DateTime(2026, 10, 25, 23, 30));
      expect(jsonDecode(sent.body)['startDate'], '2026-10-25');
    });

    test('sends the language of the app', () async {
      for (final code in ['ar', 'ru', 'de', 'fr']) {
        late http.Request sent;
        await generate(
          MockClient((request) async {
            sent = request;
            return jsonResponse(itineraryJson(1), 200);
          }),
          days: 1,
          languageCode: code,
        );
        expect(jsonDecode(sent.body)['language'], code);
      }
    });

    test('writes the words the app adds to a plan in that language too', () async {
      final plan = await generate(answering(itineraryJson(1)), days: 2, languageCode: 'de');

      expect(plan.days.first.title, 'Tag 1: Theme 1');
      expect(plan.days.first.highlights.first, 'Vormittag: Place 1 of day 1 (Area 1) – Activity 1 of day 1.\nAnfahrt: 5 min walk');
      expect(plan.days.last.title, 'Tag 2: Freier Tag');
      expect(plan.days.last.highlights, [lookupAppLocalizations(const Locale('de')).planFreeTime]);
    });
  });

  group('the plan in the answer', () {
    test('turns a valid answer into a TripPlan', () async {
      final plan = await generate(answering(itineraryJson(3)));

      expect(plan.location, 'Dubai Marina');
      expect(plan.startDate, startDate);
      expect(plan.lengthInDays, 3);
      expect(plan.categories, ['Beaches', 'Restaurants']);
      expect(plan.days.map((d) => d.title), ['Day 1: Theme 1', 'Day 2: Theme 2', 'Day 3: Theme 3']);
      expect(plan.days.map((d) => d.area), ['Area 1', 'Area 2', 'Area 3']);
      expect(plan.days.first.highlights, hasLength(3));
    });

    test('writes each activity as time, place, area and description, with how to get there below', () async {
      final body = jsonEncode({
        'days': [
          {
            'area': 'Downtown Dubai',
            'theme': 'Icons of Downtown',
            'activities': [
              {
                'time': 'Evening',
                'place': 'Burj Khalifa',
                'area': 'Downtown Dubai',
                'travel': '25 min by taxi from your accommodation',
                'description': 'Watch the sunset from level 124.',
              },
            ],
          },
        ],
      });

      final plan = await generate(answering(body), days: 1);

      expect(
        plan.days.single.highlights.single,
        'Evening: Burj Khalifa (Downtown Dubai) – Watch the sunset from level 124.\n'
        'Getting there: 25 min by taxi from your accommodation',
      );
    });

    test('keeps non-ASCII text intact (em dash, Arabic, accents)', () async {
      const theme = 'Old Dubai — Al Fahidi';
      const description = 'Crème brûlée, then شاي كرك at Al Ustad';
      final body = jsonEncode({
        'days': [
          {
            'area': 'Bur Dubai',
            'theme': theme,
            'activities': [
              {'time': 'Evening', 'place': 'La Serre', 'area': 'Downtown Dubai', 'travel': '5 min walk', 'description': description},
            ],
          },
        ],
      });

      final plan = await generate(answering(body), days: 1);

      expect(plan.days.single.title, 'Day 1: $theme');
      expect(plan.days.single.highlights.single, contains(description));
    });

    test('drops extra days when the answer has more than requested', () async {
      final plan = await generate(answering(itineraryJson(5)));
      expect(plan.days, hasLength(3));
      expect(plan.lengthInDays, 3);
    });

    test('uses "Day N" when a day has no theme, and leaves out what is missing', () async {
      final body = jsonEncode({
        'days': [
          {
            'activities': [
              {'time': 'Morning', 'place': 'Burj Khalifa'},
            ],
          },
          {
            'activities': [
              {'place': 'Dubai Mall'},
            ],
          },
        ],
      });
      final plan = await generate(answering(body), days: 2);

      expect(plan.days.map((d) => d.title), ['Day 1', 'Day 2']);
      expect(plan.days.map((d) => d.area), [null, null]);
      expect(plan.days.map((d) => d.highlights.single), ['Morning: Burj Khalifa', 'Dubai Mall']);
    });

    test('keeps an activity written as plain text', () async {
      final body = jsonEncode({
        'days': [
          {
            'area': 'Dubai Marina',
            'theme': 'Marina',
            'activities': ['Morning: Dhow cruise'],
          },
        ],
      });
      final plan = await generate(answering(body), days: 1);
      expect(plan.days.single.highlights.single, 'Morning: Dhow cruise');
    });
  });

  // The schema asks for every day and at least three activities, so these
  // only cover an answer that does not follow it.
  group('when the answer leaves something out', () {
    test('missing days become free days, not fixed sights that ignore the accommodation', () async {
      final plan = await generate(answering(itineraryJson(4)), days: 7);

      expect(plan.days, hasLength(7));
      for (final day in plan.days.sublist(4)) {
        expect(day.title, endsWith(': Free day'));
        expect(day.highlights, [english.planFreeTime]);
      }
    });

    test('a day without activities becomes free time', () async {
      final body = jsonEncode({
        'days': [
          {'area': 'Dubai Marina', 'theme': 'Marina', 'activities': <Object>[]},
        ],
      });
      final plan = await generate(answering(body), days: 1);
      expect(plan.days.single.highlights, [english.planFreeTime]);
    });
  });

  group('error handling', () {
    test('an error status throws with the backend\'s error code', () async {
      final error = await generate(answering(backendErrorBody('app_check_failed'), status: 401))
          .then<Object?>((_) => null, onError: (Object e) => e);

      expect(error, isA<TripPlannerHttpException>());
      expect((error! as TripPlannerHttpException).statusCode, 401);
      expect((error as TripPlannerHttpException).code, 'app_check_failed');
    });

    test('a busy planner (429) throws after a single attempt, without retry', () async {
      var calls = 0;
      final client = MockClient((_) async {
        calls++;
        return jsonResponse(backendErrorBody('planner_busy'), 429);
      });

      await expectLater(generate(client), throwsWithMessage('planner_busy'));
      expect(calls, 1);
    });

    test('an HTML error page from a proxy (502) throws, without an error code', () async {
      final error = await generate(MockClient((_) async => http.Response('<html>Bad Gateway</html>', 502)))
          .then<Object?>((_) => null, onError: (Object e) => e);

      expect(error, isA<TripPlannerHttpException>());
      expect((error! as TripPlannerHttpException).code, isNull);
    });

    test('an answer that is not JSON throws "Invalid answer"', () async {
      await expectLater(generate(answering('<html>maintenance</html>')), throwsWithMessage('Invalid answer'));
    });

    test('an answer without any days throws "empty itinerary"', () async {
      await expectLater(generate(answering('{"days": []}')), throwsWithMessage('empty itinerary'));
    });

    test('no internet: the ClientException propagates to the caller', () async {
      final client = MockClient((_) async => throw http.ClientException('Failed host lookup'));
      await expectLater(generate(client), throwsA(isA<http.ClientException>()));
    });
  });

  test('refuses an accommodation text over ${TripPlannerService.maxLocationLength} characters without a request',
      () async {
    var called = false;
    final client = MockClient((_) async {
      called = true;
      return jsonResponse(itineraryJson(1), 200);
    });

    await expectLater(generate(client, location: 'x' * (TripPlannerService.maxLocationLength + 1)), throwsArgumentError);
    expect(called, isFalse);
  });

  group('message shown to the user', () {
    String message(Object error) => TripPlannerService.userMessage(error, english);
    TripPlannerHttpException backendError(int status, [String? code]) =>
        TripPlannerHttpException(status, code == null ? '<html></html>' : backendErrorBody(code));

    test('explains each kind of failure in plain words', () {
      expect(message(http.ClientException('Failed host lookup')), contains('internet connection'));
      expect(message(TimeoutException('slow')), contains('took too long'));
      expect(message(backendError(429, 'planner_busy')), contains('busy'));
      expect(message(backendError(429, 'too_many_requests')), contains('busy'));
      expect(message(backendError(504, 'upstream_timeout')), contains('took too long'));
      expect(message(backendError(502, 'invalid_answer')), contains('could not create your plan'));
      expect(message(backendError(502, 'upstream_error')), contains('having problems'));
      expect(message(backendError(503, 'not_configured')), contains('having problems'));
      expect(message(backendError(502)), contains('having problems'));
      expect(message(backendError(401, 'app_check_failed')), contains('unavailable'));
      expect(message(backendError(400, 'invalid_request')), contains('unavailable'));
      expect(message(Exception('Invalid answer from the trip planner')), contains('could not create your plan'));
    });

    test('never repeats the raw error', () {
      final text = message(backendError(401, 'app_check_failed'));
      expect(text, isNot(contains('{')));
      expect(text, isNot(contains('app_check_failed')));
    });

    testWidgets('a timed-out request reports a TimeoutException', (tester) async {
      Object? error;
      unawaited(generate(MockClient((_) => Completer<http.Response>().future))
          .then((_) {}, onError: (Object e) => error = e));

      await tester.pump(const Duration(minutes: 4));

      expect(error, isA<TimeoutException>());
    });
  });

  group('trip length limit', () {
    test('plans up to ${TripPlannerService.maxTripDays} days', () async {
      final plan = await generate(answering(itineraryJson(15)), days: 15);
      expect(plan.days, hasLength(15));
    });

    for (final days in [0, 16, 365]) {
      test('refuses $days days without a request', () async {
        var called = false;
        final client = MockClient((_) async {
          called = true;
          return jsonResponse(itineraryJson(1), 200);
        });

        await expectLater(generate(client, days: days), throwsArgumentError);
        expect(called, isFalse);
      });
    }
  });

  group('timeouts', () {
    // Regression test: without a timeout, a stalled connection kept the
    // "Show Results" spinner going forever.
    testWidgets('gives up on a request that never answers', (tester) async {
      final client = MockClient((_) => Completer<http.Response>().future);
      var settled = false;
      unawaited(generate(client).then((_) => settled = true, onError: (_) => settled = true));

      await tester.pump(const Duration(minutes: 10));

      expect(settled, isTrue, reason: 'generatePlan() was still waiting after 10 minutes');
    });
  });
}
