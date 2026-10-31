// Calls the real OpenAI API through the app's own TripPlannerService.
// Skipped by default; costs a fraction of a cent per run.
//
//   LIVE_AI_TEST=1 flutter test test/live/openai_live_test.dart
//
// The key is read from .env (OPENAI_API_KEY=...). Without a real key only the
// connectivity check runs.

import 'dart:convert';
import 'dart:io';

import 'package:dubai_trip_planner/features/my_trip/models/trip_plan.dart';
import 'package:dubai_trip_planner/features/my_trip/services/trip_planner_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

/// Forwards to a real client and keeps the last raw response for inspection.
class _RecordingClient extends http.BaseClient {
  final _inner = http.Client();
  http.Response? last;
  Duration? elapsed;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final stopwatch = Stopwatch()..start();
    final response = await http.Response.fromStream(await _inner.send(request));
    elapsed = stopwatch.elapsed;
    last = response;
    return http.StreamedResponse(
      Stream.value(response.bodyBytes),
      response.statusCode,
      headers: response.headers,
      request: request,
      reasonPhrase: response.reasonPhrase,
    );
  }
}

String? _keyFromDotEnv() {
  final file = File('.env');
  if (!file.existsSync()) return null;
  for (final line in file.readAsLinesSync()) {
    final match = RegExp(r'^\s*OPENAI_API_KEY\s*=\s*(.+?)\s*$').firstMatch(line);
    if (match != null) return match.group(1)!.replaceAll(RegExp('''^["']|["']\$'''), '');
  }
  return null;
}

const _fillerFirstLine = 'Morning: Free time to revisit favorite spots or relax at the hotel spa.';

void main() {
  final enabled = Platform.environment['LIVE_AI_TEST'] == '1';
  final key = _keyFromDotEnv();
  final hasRealKey = key != null && key.startsWith('sk-') && !key.contains('placeholder');

  Future<(TripPlan, _RecordingClient)> generate(int days, List<String> categories) async {
    dotenv.testLoad(fileInput: 'OPENAI_API_KEY=$key');
    final client = _RecordingClient();
    final plan = await TripPlannerService(httpClient: client).generatePlan(
      startDate: DateTime.now().add(const Duration(days: 30)),
      lengthInDays: days,
      location: 'Dubai Marina',
      categories: categories,
    );
    return (plan, client);
  }

  void report(String label, TripPlan plan, _RecordingClient client) {
    final body = jsonDecode(client.last!.body) as Map<String, dynamic>;
    final usage = body['usage'] as Map<String, dynamic>;
    final filler = plan.days.where((d) => d.highlights.first == _fillerFirstLine).length;
    // ignore: avoid_print
    print('[$label] ${client.elapsed!.inMilliseconds} ms | model ${body['model']} | '
        'finish_reason ${body['choices'][0]['finish_reason']} | '
        'tokens in/out ${usage['prompt_tokens']}/${usage['completion_tokens']} | '
        'content-type ${client.last!.headers['content-type']} | '
        'days ${plan.days.length} (filler: $filler)');
    for (final day in plan.days) {
      // ignore: avoid_print
      print('  ${day.title}\n    - ${day.highlights.join('\n    - ')}');
    }
  }

  test(
    'api.openai.com is reachable and a bad key is rejected with 401',
    () async {
      dotenv.testLoad(fileInput: 'OPENAI_API_KEY=sk-invalid-live-check');
      final future = TripPlannerService().generatePlan(
        startDate: DateTime.now(),
        lengthInDays: 1,
        location: 'Downtown Dubai',
        categories: const ['Attractions'],
      );
      await expectLater(future, throwsA(predicate((e) => e.toString().contains('invalid_api_key'))));
    },
    skip: enabled ? false : 'set LIVE_AI_TEST=1 to call the real API',
  );

  group(
    'with the real key from .env',
    () {
      test('3-day plan: every day is planned by the model, with 3+ activities', () async {
        final (plan, client) = await generate(3, const ['Beaches', 'Restaurants', 'Rooftops']);
        report('3 days', plan, client);

        expect(client.last!.statusCode, 200);
        expect(plan.days, hasLength(3));
        for (final day in plan.days) {
          expect(day.highlights.first, isNot(_fillerFirstLine), reason: '${day.title} is app filler, not AI output');
          expect(day.highlights.length, greaterThanOrEqualTo(3), reason: day.title);
        }
        expect(client.last!.body, isNot(contains('â€')), reason: 'UTF-8 mis-decoded as Latin-1');
      }, timeout: const Timeout(Duration(minutes: 2)));

      test('10-day plan: does the model return all 10 days?', () async {
        final (plan, client) = await generate(10, const ['Attractions', 'Shopping', 'Desserts', 'Nightlife']);
        report('10 days', plan, client);

        final filler = plan.days.where((d) => d.highlights.first == _fillerFirstLine).length;
        expect(filler, 0, reason: '$filler of 10 days were padded by the app');
      }, timeout: const Timeout(Duration(minutes: 3)));
    },
    skip: !enabled
        ? 'set LIVE_AI_TEST=1 to call the real API'
        : (hasRealKey ? false : 'no real OPENAI_API_KEY in .env'),
  );
}
