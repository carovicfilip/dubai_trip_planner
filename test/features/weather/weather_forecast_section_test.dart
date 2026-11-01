import 'dart:convert';
import 'dart:io';

import 'package:dubai_trip_planner/features/weather/services/weather_forecast_service.dart';
import 'package:dubai_trip_planner/features/weather/ui/weather_forecast_section.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  // The recorded forecast, moved so that it starts now. Cached days that are
  // over get dropped, so this keeps the cards on screen whenever tests run.
  String currentForecast() {
    final data = jsonDecode(File('test/fixtures/openweather_forecast_dubai.json').readAsStringSync())
        as Map<String, dynamic>;
    final slots = (data['list'] as List<dynamic>).cast<Map<String, dynamic>>();
    final shift = DateTime.now().millisecondsSinceEpoch ~/ 1000 - (slots.first['dt'] as int);
    for (final slot in slots) {
      slot['dt'] = (slot['dt'] as int) + shift;
    }
    return jsonEncode(data);
  }

  const section = MaterialApp(home: Scaffold(body: WeatherForecastSection()));
  late int requests;

  setUp(() {
    requests = 0;
    WeatherForecastService.clearMemoryCache();
    SharedPreferences.setMockInitialValues({});
  });

  /// Runs [body] with every HTTP request answered by [respond].
  Future<void> withApi(http.Response Function() respond, Future<void> Function() body) async {
    // The test font draws every glyph 1em wide, far wider than Poppins, so the
    // fixed-size forecast cards overflow here but not on a device. Only those
    // errors are ignored, like in onboarding_flow_test.dart.
    final reportError = FlutterError.onError!;
    FlutterError.onError = (details) {
      if (!details.exceptionAsString().contains('A RenderFlex overflowed')) reportError(details);
    };

    try {
      await http.runWithClient(
        body,
        () => MockClient((_) async {
          requests++;
          return respond();
        }),
      );
    } finally {
      FlutterError.onError = reportError;
    }
  }

  test('maps OpenWeatherMap icon codes to outline icons', () {
    expect(weatherIcon('01d'), Icons.wb_sunny_outlined);
    expect(weatherIcon('01n'), Icons.wb_sunny_outlined);
    expect(weatherIcon('03n'), Icons.filter_drama_outlined);
    expect(weatherIcon('04d'), Icons.cloud_outlined);
    expect(weatherIcon('10d'), Icons.water_drop_outlined);
    expect(weatherIcon('11d'), Icons.thunderstorm_outlined);
    expect(weatherIcon('13d'), Icons.ac_unit_outlined);
    expect(weatherIcon('50d'), Icons.foggy);
    expect(weatherIcon('unknown'), Icons.cloud_outlined);
  });

  testWidgets('the forecast cards show one-color outline icons instead of emoji', (tester) async {
    await withApi(() => http.Response(currentForecast(), 200), () async {
      await tester.pumpWidget(section);
      await tester.pumpAndSettle();

      final icons = tester.widgetList<Icon>(find.byType(Icon)).toList();
      expect(icons, isNotEmpty);
      expect(icons.map((icon) => icon.color).toSet(), hasLength(1), reason: 'all in the same color');
      expect(find.text('☀️'), findsNothing);
    });
  });

  testWidgets('a failed request shows a short message instead of the raw error, and can be retried', (tester) async {
    var response = http.Response('{"cod":401,"message":"Invalid API key"}', 401);
    await withApi(() => response, () async {
      await tester.pumpWidget(section);
      await tester.pumpAndSettle();

      expect(find.text('The forecast is unavailable right now.'), findsOneWidget);
      expect(find.textContaining('Invalid API key'), findsNothing);

      response = http.Response(currentForecast(), 200);
      await tester.tap(find.text('Try again'));
      await tester.pumpAndSettle();

      expect(find.textContaining('°C |'), findsWidgets);
      expect(requests, 2);
    });
  });

  testWidgets('a rebuilt section (Explore tab opened again) shows the forecast at once, without a request',
      (tester) async {
    await withApi(() => http.Response(currentForecast(), 200), () async {
      await tester.pumpWidget(section);
      await tester.pumpAndSettle();
      expect(requests, 1);

      await tester.pumpWidget(const SizedBox()); // another tab: the section is disposed
      await tester.pumpWidget(section); // builds a single frame

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.textContaining('°C |'), findsWidgets);
      await tester.pumpAndSettle();
      expect(requests, 1);
    });
  });
}
