import 'dart:io';

import 'package:dubai_trip_planner/core/services/weather_forecast_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  // Real response recorded from api.openweathermap.org on 2026-10-30.
  final fixture = File('test/fixtures/openweather_forecast_dubai.json').readAsStringSync();

  Future<List<DailyForecast>> fetchWith(http.Client client) =>
      http.runWithClient(() => WeatherForecastService().fetch10DayForecast(), () => client);

  test('requests the Dubai forecast in metric units', () async {
    late Uri url;
    await fetchWith(MockClient((request) async {
      url = request.url;
      return http.Response(fixture, 200, headers: {'content-type': 'application/json; charset=utf-8'});
    }));

    expect(url.host, 'api.openweathermap.org');
    expect(url.path, '/data/2.5/forecast');
    expect(url.queryParameters['lat'], '25.276987');
    expect(url.queryParameters['lon'], '55.296249');
    expect(url.queryParameters['units'], 'metric');
    expect(url.queryParameters['appid'], isNotEmpty);
  });

  test('groups 3-hour slots into days with sane temperatures and rain %', () async {
    final days = await fetchWith(MockClient((_) async => http.Response(fixture, 200)));

    expect(days, isNotEmpty);
    for (final day in days) {
      expect(day.minTemp, lessThanOrEqualTo(day.maxTemp));
      expect(day.minTemp, inInclusiveRange(5, 55), reason: 'Dubai temperature in °C');
      expect(day.rainProbability, inInclusiveRange(0, 100));
      expect(day.emoji, isNotEmpty, reason: 'unknown icon code ${day.icon}');
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

  test('maps OpenWeatherMap icon codes to emoji', () {
    DailyForecast withIcon(String icon) =>
        DailyForecast(date: DateTime(2026), minTemp: 20, maxTemp: 30, icon: icon, rainProbability: 0);

    expect(withIcon('01d').emoji, '☀️');
    expect(withIcon('03n').emoji, '⛅');
    expect(withIcon('04d').emoji, '☁️');
    expect(withIcon('10d').emoji, '🌧️');
    expect(withIcon('11d').emoji, '🌩️');
    expect(withIcon('50d').emoji, '🌫️');
  });

  test('throws when the API answers with an error (e.g. revoked key)', () async {
    final client = MockClient((_) async => http.Response('{"cod":401,"message":"Invalid API key"}', 401));
    await expectLater(fetchWith(client), throwsA(isA<Exception>()));
  });
}
