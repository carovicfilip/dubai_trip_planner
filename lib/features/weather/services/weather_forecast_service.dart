import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class WeatherForecastService {
  WeatherForecastService({DateTime Function()? clock}) : _now = clock ?? DateTime.now;

  final String apiKey = '726875b4edccad51e99ecfff52400699';
  final double lat = 25.276987;
  final double lon = 55.296249;

  /// Every user sees the same forecast (fixed coordinates) and it only comes
  /// in 3-hour steps, so one request per hour per device is enough. All users
  /// share one API key and its rate limit, so opening the Explore tab again or
  /// restarting the app must not request the forecast again.
  static const cacheDuration = Duration(hours: 1);
  static const requestTimeout = Duration(seconds: 15);
  static const _storageKey = 'weather_forecast_cache';

  // Static because every visit to the Explore tab builds a new
  // WeatherForecastSection, and with it a new service.
  static _SavedForecast? _memory;
  static Future<List<DailyForecast>>? _inFlight;

  final DateTime Function() _now;

  @visibleForTesting
  static void clearMemoryCache() {
    _memory = null;
    _inFlight = null;
  }

  /// The last forecast loaded while the app has been running, even if it is
  /// older than [cacheDuration], so a rebuilt widget can show it right away.
  List<DailyForecast>? get lastKnownForecast {
    final memory = _memory;
    if (memory == null) return null;
    final days = _upcomingDays(memory);
    return days.isEmpty ? null : days;
  }

  Future<List<DailyForecast>> fetch10DayForecast() {
    final memory = _memory;
    if (memory != null && _isFresh(memory)) return Future.value(_upcomingDays(memory));
    return _inFlight ??= _load().whenComplete(() => _inFlight = null);
  }

  Future<List<DailyForecast>> _load() async {
    final saved = _memory ?? await _readSaved();
    if (saved != null && _isFresh(saved)) {
      _memory = saved;
      return _upcomingDays(saved);
    }

    try {
      final days = await _fetchFromApi();
      _memory = _SavedForecast(_now(), days);
      await _save(_memory!);
      return days;
    } catch (error) {
      debugPrint('Weather forecast request failed: $error');
      // An older forecast is better than none, e.g. while the phone is offline
      // or the shared API key is over its rate limit.
      final fallback = saved == null ? const <DailyForecast>[] : _upcomingDays(saved);
      if (fallback.isEmpty) rethrow;
      _memory ??= saved;
      return fallback;
    }
  }

  bool _isFresh(_SavedForecast saved) {
    final age = _now().difference(saved.fetchedAt);
    return !age.isNegative && age < cacheDuration;
  }

  /// Leaves out days that are already over, which an older forecast can have.
  List<DailyForecast> _upcomingDays(_SavedForecast saved) {
    final now = _now();
    final today = DateTime(now.year, now.month, now.day);
    return saved.days.where((day) => !day.date.isBefore(today)).toList(growable: false);
  }

  Future<_SavedForecast?> _readSaved() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_storageKey);
      if (raw == null) return null;
      return _SavedForecast.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null; // unreadable cache: load a new forecast instead
    }
  }

  Future<void> _save(_SavedForecast forecast) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_storageKey, jsonEncode(forecast.toJson()));
    } catch (_) {
      // Failing to cache must not hide the forecast that was just loaded.
    }
  }

  Future<List<DailyForecast>> _fetchFromApi() async {
    final url =
        Uri.parse('https://api.openweathermap.org/data/2.5/forecast?lat=$lat&lon=$lon&appid=$apiKey&units=metric');

    final response = await http.get(url).timeout(requestTimeout);

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch weather: ${response.body}');
    }

    final data = json.decode(response.body);
    final List<dynamic> list = data['list'];

    // Grupisanje po datumu
    final Map<String, List<dynamic>> grouped = {};
    for (final item in list) {
      final date = DateTime.fromMillisecondsSinceEpoch(item['dt'] * 1000);
      final dateStr = '${date.year}-${date.month}-${date.day}';
      grouped.putIfAbsent(dateStr, () => []).add(item);
    }

    final forecasts = grouped.entries.map((entry) {
      final items = entry.value;
      final temps = items.map((e) {
        final temp = e['main']['temp'];
        return temp is int ? temp.toDouble() : temp;
      });
      final minTemp = temps.reduce((a, b) => a < b ? a : b);
      final maxTemp = temps.reduce((a, b) => a > b ? a : b);
      final icon = items[0]['weather'][0]['icon'];
      final rain = items.map((e) {
        final pop = e['pop'] ?? 0.0;
        return pop is int ? pop.toDouble() * 100 : pop * 100;
      }).reduce((a, b) => a > b ? a : b);

      return DailyForecast(
        date: DateTime(
          int.parse(entry.key.split('-')[0]),
          int.parse(entry.key.split('-')[1]),
          int.parse(entry.key.split('-')[2]),
        ),
        minTemp: minTemp,
        maxTemp: maxTemp,
        icon: icon,
        rainProbability: rain,
      );
    }).toList();

    return forecasts.take(10).toList();
  }
}

class _SavedForecast {
  _SavedForecast(this.fetchedAt, this.days);

  factory _SavedForecast.fromJson(Map<String, dynamic> json) => _SavedForecast(
        DateTime.fromMillisecondsSinceEpoch(json['fetchedAt'] as int),
        [for (final day in json['days'] as List<dynamic>) DailyForecast.fromJson(day as Map<String, dynamic>)],
      );

  final DateTime fetchedAt;
  final List<DailyForecast> days;

  Map<String, dynamic> toJson() => {
        'fetchedAt': fetchedAt.millisecondsSinceEpoch,
        'days': [for (final day in days) day.toJson()],
      };
}

class DailyForecast {
  final DateTime date;
  final double minTemp;
  final double maxTemp;
  final String icon;
  final double rainProbability;

  DailyForecast({
    required this.date,
    required this.minTemp,
    required this.maxTemp,
    required this.icon,
    required this.rainProbability,
  });

  factory DailyForecast.fromJson(Map<String, dynamic> json) => DailyForecast(
        date: DateTime.parse(json['date'] as String),
        minTemp: (json['minTemp'] as num).toDouble(),
        maxTemp: (json['maxTemp'] as num).toDouble(),
        icon: json['icon'] as String,
        rainProbability: (json['rainProbability'] as num).toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'minTemp': minTemp,
        'maxTemp': maxTemp,
        'icon': icon,
        'rainProbability': rainProbability,
      };
}
