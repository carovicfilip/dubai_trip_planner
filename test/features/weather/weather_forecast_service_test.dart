import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dubai_trip_planner/core/backend/backend_api.dart';
import 'package:dubai_trip_planner/features/weather/services/weather_forecast_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  // Real response recorded from api.openweathermap.org on 2026-10-30. The
  // backend answers in the same shape, with fewer fields.
  final fixture = File('test/fixtures/openweather_forecast_dubai.json').readAsStringSync();

  // Start of the fixture's first 3-hour slot. The cache tests use it as "now",
  // so they depend neither on today's date nor on the machine's time zone.
  final slots = (jsonDecode(fixture) as Map<String, dynamic>)['list'] as List<dynamic>;
  final recordedAt = DateTime.fromMillisecondsSinceEpoch(((slots.first as Map<String, dynamic>)['dt'] as int) * 1000);

  setUp(() {
    WeatherForecastService.clearMemoryCache();
    SharedPreferences.setMockInitialValues({});
  });

  Future<List<DailyForecast>> fetchWith(http.Client client, {DateTime Function()? clock}) =>
      http.runWithClient(() => WeatherForecastService(clock: clock).fetch10DayForecast(), () => client);

  test('requests the forecast from the backend with the App Check token, and no key', () async {
    late http.Request sent;
    await http.runWithClient(
      () => WeatherForecastService(appCheckToken: () async => 'app-check-token').fetch10DayForecast(),
      () => MockClient((request) async {
        sent = request;
        return http.Response(fixture, 200, headers: {'content-type': 'application/json; charset=utf-8'});
      }),
    );

    expect(sent.method, 'GET');
    expect(sent.url, BackendApi.weatherUri);
    expect(sent.url.path, '/weather');
    expect(sent.url.queryParameters, isEmpty);
    expect(sent.headers['X-Firebase-AppCheck'], 'app-check-token');
  });

  test('reads the slim forecast the backend sends', () async {
    final slim = jsonEncode({
      'list': [
        for (final slot in slots.cast<Map<String, dynamic>>())
          {
            'dt': slot['dt'],
            'main': {'temp': slot['main']['temp']},
            'weather': [
              {'icon': slot['weather'][0]['icon']},
            ],
            'pop': slot['pop'],
          },
      ],
    });
    final fromSlim = await fetchWith(MockClient((_) async => http.Response(slim, 200)));
    WeatherForecastService.clearMemoryCache();
    SharedPreferences.setMockInitialValues({});
    final fromFull = await fetchWith(MockClient((_) async => http.Response(fixture, 200)));

    expect(fromSlim.map((d) => d.toJson()), fromFull.map((d) => d.toJson()));
  });

  test('groups 3-hour slots into days with sane temperatures and rain %', () async {
    final days = await fetchWith(MockClient((_) async => http.Response(fixture, 200)));

    expect(days, isNotEmpty);
    for (final day in days) {
      expect(day.minTemp, lessThanOrEqualTo(day.maxTemp));
      expect(day.minTemp, inInclusiveRange(5, 55), reason: 'Dubai temperature in °C');
      expect(day.rainProbability, inInclusiveRange(0, 100));
      expect(day.icon, isNotEmpty);
    }
    final dates = days.map((d) => d.date).toList();
    expect(dates.toSet(), hasLength(dates.length), reason: 'one entry per calendar day');
  });

  // The free endpoint is a 5-day / 3-hour forecast, so the
  // "10-day forecast" never shows more than 6 (partial) days.
  test('returns at most 6 days although the method is called fetch10DayForecast', () async {
    final days = await fetchWith(MockClient((_) async => http.Response(fixture, 200)));
    expect(days.length, lessThanOrEqualTo(6));
  });

  test('throws when the backend answers with an error (e.g. App Check refused)', () async {
    final client = MockClient((_) async => http.Response('{"error":"app_check_failed"}', 401));
    await expectLater(fetchWith(client), throwsA(isA<Exception>()));
  });

  testWidgets('gives up after ${WeatherForecastService.requestTimeout.inSeconds} s without an answer', (tester) async {
    Object? error;
    unawaited(fetchWith(MockClient((_) => Completer<http.Response>().future))
        .then((_) {}, onError: (Object e) => error = e));

    await tester.pump(WeatherForecastService.requestTimeout + const Duration(seconds: 1));

    expect(error, isA<TimeoutException>());
  });

  group('cache (the backend\'s free plan has a daily request limit)', () {
    late DateTime now;
    late int requests;
    late http.Response Function() respond;

    setUp(() {
      now = recordedAt;
      requests = 0;
      respond = () => http.Response(fixture, 200);
    });

    /// Uses a new service every time, like the section built on each visit
    /// to the Explore tab.
    Future<List<DailyForecast>> fetch() => fetchWith(
          MockClient((_) async {
            requests++;
            return respond();
          }),
          clock: () => now,
        );

    test('one request serves the next hour, also for new service instances', () async {
      final first = await fetch();
      now = now.add(const Duration(minutes: 59));
      final again = await fetch();

      expect(requests, 1);
      expect(again.map((d) => d.date), first.map((d) => d.date));
    });

    test('a forecast that is an hour old is fetched again', () async {
      await fetch();
      now = now.add(WeatherForecastService.cacheDuration);
      await fetch();

      expect(requests, 2);
    });

    test('survives an app restart: the saved forecast is used while it is fresh', () async {
      await fetch();
      WeatherForecastService.clearMemoryCache(); // what a cold start looks like
      now = now.add(const Duration(minutes: 30));

      expect(await fetch(), isNotEmpty);
      expect(requests, 1);
    });

    test('calls made while a request is running share it', () async {
      final response = Completer<http.Response>();
      final client = MockClient((_) {
        requests++;
        return response.future;
      });
      final first = fetchWith(client, clock: () => now);
      final second = fetchWith(client, clock: () => now);
      response.complete(http.Response(fixture, 200));

      expect((await second).map((d) => d.date), (await first).map((d) => d.date));
      expect(requests, 1);
    });

    test('when the backend fails, the last forecast is shown without the days that are over', () async {
      final first = await fetch();
      final firstDay = first.first.date;
      now = DateTime(firstDay.year, firstDay.month, firstDay.day + 1, 12);
      respond = () => http.Response('{"error":"upstream_error"}', 502);

      final fallback = await fetch();

      expect(requests, 2, reason: 'the expired forecast is refreshed first');
      expect(fallback.first.date, DateTime(firstDay.year, firstDay.month, firstDay.day + 1));
      expect(fallback, hasLength(first.length - 1));
    });

    test('a corrupt saved forecast is ignored', () async {
      SharedPreferences.setMockInitialValues({'weather_forecast_cache': '{not json'});

      expect(await fetch(), isNotEmpty);
      expect(requests, 1);
    });
  });
}
