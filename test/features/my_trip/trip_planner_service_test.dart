import 'dart:async';
import 'dart:convert';

import 'package:dubai_trip_planner/features/my_trip/models/trip_plan.dart';
import 'package:dubai_trip_planner/features/my_trip/services/trip_planner_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import '../../helpers/openai_fakes.dart';

void main() {
  final startDate = DateTime(2026, 11, 10);

  setUp(() => dotenv.loadFromString(envString: 'OPENAI_API_KEY=sk-test-123'));

  Future<TripPlan> generate(
    http.Client client, {
    int days = 3,
    List<String> categories = const ['Beaches', 'Restaurants'],
  }) {
    return TripPlannerService(httpClient: client).generatePlan(
      startDate: startDate,
      lengthInDays: days,
      location: 'Dubai Marina',
      categories: categories,
    );
  }

  MockClient answering(String content, {int status = 200, String finishReason = 'stop'}) {
    return MockClient((_) async => jsonResponse(chatCompletionBody(content, finishReason: finishReason), status));
  }

  Matcher throwsWithMessage(String fragment) =>
      throwsA(predicate((e) => e.toString().contains(fragment), 'error mentioning "$fragment"'));

  group('request sent to OpenAI', () {
    test('POSTs to chat/completions with the key, gpt-4o-mini and JSON mode', () async {
      late http.Request sent;
      final client = MockClient((request) async {
        sent = request;
        return jsonResponse(chatCompletionBody(itineraryJson(3)), 200);
      });

      await generate(client);

      expect(sent.method, 'POST');
      expect(sent.url.toString(), 'https://api.openai.com/v1/chat/completions');
      expect(sent.headers['Authorization'], 'Bearer sk-test-123');
      expect(sent.headers['Content-Type'], startsWith('application/json'));

      final body = jsonDecode(sent.body) as Map<String, dynamic>;
      expect(body['model'], 'gpt-4o-mini');
      expect(body['response_format'], {'type': 'json_object'});
      final messages = body['messages'] as List<dynamic>;
      expect(messages.map((m) => m['role']), ['system', 'user']);

      final prompt = messages[1]['content'] as String;
      expect(prompt, contains('Starting date: 2026-11-10'));
      expect(prompt, contains('Traveler base location: Dubai Marina'));
      expect(prompt, contains('Interests/Categories: Beaches, Restaurants'));
      expect(prompt, contains('Create exactly 3 days'));
    });

    test('asks for "General must-see spots" when no category is given', () async {
      late http.Request sent;
      final client = MockClient((request) async {
        sent = request;
        return jsonResponse(chatCompletionBody(itineraryJson(1)), 200);
      });

      await generate(client, days: 1, categories: const []);

      final prompt = (jsonDecode(sent.body)['messages'] as List<dynamic>)[1]['content'] as String;
      expect(prompt, contains('Interests/Categories: General must-see spots'));
    });
  });

  group('API key', () {
    test('throws StateError and sends nothing when OPENAI_API_KEY is missing', () async {
      dotenv.loadFromString(envString: '', isOptional: true);
      var calls = 0;
      final client = MockClient((_) async {
        calls++;
        return jsonResponse('{}', 200);
      });

      await expectLater(generate(client), throwsA(isA<StateError>()));
      expect(calls, 0);
    });

    test('throws StateError when OPENAI_API_KEY is empty', () async {
      dotenv.loadFromString(envString: 'OPENAI_API_KEY=');
      await expectLater(generate(answering(itineraryJson(3))), throwsA(isA<StateError>()));
    });
  });

  group('parsing the model output', () {
    test('turns a valid response into a TripPlan', () async {
      final plan = await generate(answering(itineraryJson(3)));

      expect(plan.location, 'Dubai Marina');
      expect(plan.startDate, startDate);
      expect(plan.lengthInDays, 3);
      expect(plan.categories, ['Beaches', 'Restaurants']);
      expect(plan.days.map((d) => d.title), ['Day 1: Theme 1', 'Day 2: Theme 2', 'Day 3: Theme 3']);
      expect(plan.days.first.highlights, ['Activity 1 of day 1', 'Activity 2 of day 1', 'Activity 3 of day 1']);
    });

    test('accepts JSON wrapped in ```json markdown fences', () async {
      final plan = await generate(answering('```json\n${itineraryJson(3)}\n```'));
      expect(plan.days, hasLength(3));
    });

    test('accepts JSON surrounded by prose', () async {
      final plan = await generate(answering('Here is your plan:\n${itineraryJson(3)}\nEnjoy Dubai!'));
      expect(plan.days, hasLength(3));
    });

    test('keeps non-ASCII text intact (em dash, Arabic, accents)', () async {
      const title = 'Day 1: Old Dubai — Al Fahidi';
      const activity = 'Evening: Crème brûlée at La Serre, then شاي كرك at Al Ustad';
      final content = jsonEncode({
        'days': [
          {'title': title, 'activities': [activity]},
        ],
      });

      final plan = await generate(answering(content), days: 1);

      expect(plan.days.single.title, title);
      expect(plan.days.single.highlights.single, activity);
    });

    test('drops extra days when the model returns more than requested', () async {
      final plan = await generate(answering(itineraryJson(5)));
      expect(plan.days, hasLength(3));
      expect(plan.lengthInDays, 3);
    });

    test('uses "Day N" when a day has no title', () async {
      final content = jsonEncode({
        'days': [
          {'activities': ['Morning: Burj Khalifa']},
          {'activities': ['Morning: Dubai Mall']},
        ],
      });
      final plan = await generate(answering(content), days: 2);
      expect(plan.days.map((d) => d.title), ['Day 1', 'Day 2']);
    });
  });

  group('when the model returns fewer days than requested', () {
    // Documents current behaviour: the gap is filled with the same generic
    // day, and nothing tells the user that the AI did not plan those days.
    test('pads the plan with identical generic filler days', () async {
      final plan = await generate(answering(itineraryJson(4)), days: 7);

      expect(plan.days, hasLength(7));
      final filler = plan.days.sublist(4);
      expect(filler.map((d) => d.highlights.join('|')).toSet(), hasLength(1));
      expect(filler.first.highlights.first, startsWith('Morning: Free time'));
    });

    test('a day with an empty activity list gets placeholder activities', () async {
      final content = jsonEncode({
        'days': [
          {'title': 'Day 1: Marina', 'activities': <String>[]},
        ],
      });
      final plan = await generate(answering(content), days: 1);
      expect(plan.days.single.highlights, contains('Evening: Visit Dubai Fountain'));
    });
  });

  group('error handling', () {
    test('HTTP 401 (bad key) throws, and the raw OpenAI JSON ends up in the message', () async {
      final client = MockClient((_) async => jsonResponse(
            openAiErrorBody('invalid_api_key', 'Incorrect API key provided: sk-test***123.'),
            401,
            contentType: 'text/plain',
          ));

      await expectLater(generate(client), throwsWithMessage('"code":"invalid_api_key"'));
    });

    test('HTTP 429 (rate limit / no credit) throws after a single attempt, without retry', () async {
      var calls = 0;
      final client = MockClient((_) async {
        calls++;
        return jsonResponse(openAiErrorBody('insufficient_quota', 'You exceeded your current quota.'), 429);
      });

      await expectLater(generate(client), throwsWithMessage('insufficient_quota'));
      expect(calls, 1);
    });

    test('HTML error page from a proxy (502) still throws an Exception', () async {
      final client = MockClient((_) async => http.Response('<html>Bad Gateway</html>', 502));
      await expectLater(generate(client), throwsA(isA<Exception>()));
    });

    test('empty choices list throws', () async {
      final client = MockClient((_) async => jsonResponse(jsonEncode({'choices': []}), 200));
      await expectLater(generate(client), throwsWithMessage('no choices'));
    });

    test('null message content throws', () async {
      final client = MockClient((_) async => jsonResponse(
            jsonEncode({
              'choices': [
                {'message': {'role': 'assistant', 'content': null}},
              ],
            }),
            200,
          ));
      await expectLater(generate(client), throwsWithMessage('empty content'));
    });

    test('content that is not JSON throws "Invalid JSON from OpenAI"', () async {
      await expectLater(generate(answering('Sorry, I cannot help with that.')), throwsWithMessage('Invalid JSON'));
    });

    test('JSON without any days throws "empty itinerary"', () async {
      await expectLater(generate(answering('{"days": []}')), throwsWithMessage('empty itinerary'));
    });

    test('output cut off by the token limit (finish_reason=length) surfaces only as "Invalid JSON"', () async {
      final full = itineraryJson(3);
      final truncated = full.substring(0, full.length ~/ 2);

      await expectLater(
        generate(answering(truncated, finishReason: 'length')),
        throwsWithMessage('Invalid JSON'),
      );
    });

    test('no internet: the ClientException propagates to the caller', () async {
      final client = MockClient((_) async => throw http.ClientException('Failed host lookup: api.openai.com'));
      await expectLater(generate(client), throwsA(isA<http.ClientException>()));
    });
  });

  test('refuses an accommodation text over ${TripPlannerService.maxLocationLength} characters without calling OpenAI',
      () async {
    var called = false;
    final client = MockClient((_) async {
      called = true;
      return jsonResponse(chatCompletionBody(itineraryJson(1)), 200);
    });

    final future = TripPlannerService(httpClient: client).generatePlan(
      startDate: startDate,
      lengthInDays: 3,
      location: 'x' * (TripPlannerService.maxLocationLength + 1),
      categories: const ['Beaches'],
    );

    await expectLater(future, throwsArgumentError);
    expect(called, isFalse);
  });

  group('message shown to the user', () {
    test('explains each kind of failure in plain words', () {
      String message(Object error) => TripPlannerService.userMessage(error);

      expect(message(http.ClientException('Failed host lookup')), contains('internet connection'));
      expect(message(TimeoutException('slow')), contains('took too long'));
      expect(message(OpenAiHttpException(429, '{}')), contains('busy'));
      expect(message(OpenAiHttpException(503, '{}')), contains('having problems'));
      expect(message(OpenAiHttpException(401, '{}')), contains('unavailable'));
      expect(message(StateError('OPENAI_API_KEY is missing')), contains('unavailable'));
      expect(message(Exception('Invalid JSON from OpenAI')), contains('could not create your plan'));
    });

    test('never repeats the raw error', () {
      final body = openAiErrorBody('invalid_api_key', 'Incorrect API key provided: sk-test***123.');
      final message = TripPlannerService.userMessage(OpenAiHttpException(401, body));

      expect(message, isNot(contains('{')));
      expect(message, isNot(contains('invalid_api_key')));
    });

    testWidgets('a timed-out request reports a TimeoutException', (tester) async {
      Object? error;
      unawaited(generate(MockClient((_) => Completer<http.Response>().future))
          .then((_) {}, onError: (Object e) => error = e));

      await tester.pump(const Duration(minutes: 3));

      expect(error, isA<TimeoutException>());
    });
  });

  group('trip length limit', () {
    test('plans up to ${TripPlannerService.maxTripDays} days', () async {
      final plan = await generate(answering(itineraryJson(15)), days: 15);
      expect(plan.days, hasLength(15));
    });

    for (final days in [0, 16, 365]) {
      test('refuses $days days without calling OpenAI', () async {
        var called = false;
        final client = MockClient((_) async {
          called = true;
          return jsonResponse(chatCompletionBody(itineraryJson(1)), 200);
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
