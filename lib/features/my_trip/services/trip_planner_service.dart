import 'dart:async';
import 'dart:convert';
import 'dart:ui' show Locale;

import 'package:dubai_trip_planner/core/backend/backend_api.dart';
import 'package:dubai_trip_planner/l10n/l10n.dart';
import 'package:http/http.dart' as http;

import '../models/trip_plan.dart';

/// Plans a trip through the app's backend, which asks OpenAI. The backend
/// owns the prompt, the model and the key; the app sends only the form.
class TripPlannerService {
  TripPlannerService({http.Client? httpClient, AppCheckTokenSource? appCheckToken})
      : _client = httpClient ?? http.Client(),
        _appCheckToken = appCheckToken ?? firebaseAppCheckToken;

  final http.Client _client;
  final AppCheckTokenSource _appCheckToken;

  // Long itineraries take a while to write, so this only guards against a
  // stalled connection keeping the spinner going forever. The backend gives
  // up on OpenAI a little earlier and answers 504.
  static const _requestTimeout = Duration(minutes: 3);

  /// Longest stay one plan may cover. Longer itineraries make the request
  /// slow and costly, and the answer more likely to be cut off. The backend
  /// has the same limit.
  static const maxTripDays = 15;

  /// Longest accommodation text sent to the model. It goes into the prompt
  /// as typed, so it is capped like the trip length, here and in the backend.
  static const maxLocationLength = 100;

  /// A short explanation of an error thrown by [generatePlan] that is safe to
  /// show the user. The error itself can contain the backend's raw JSON, so it
  /// belongs in the logs only.
  static String userMessage(Object error, AppLocalizations l10n) {
    if (error is http.ClientException) return l10n.plannerErrorOffline;
    if (error is TimeoutException) return l10n.plannerErrorTimeout;
    if (error is TripPlannerHttpException) {
      return switch (error.statusCode) {
        429 => l10n.plannerErrorBusy,
        504 => l10n.plannerErrorTimeout,
        // The model's answer was unusable; another try usually works.
        _ when error.code == 'invalid_answer' => l10n.plannerErrorGeneric,
        >= 500 => l10n.plannerErrorServer,
        // App Check refused, or a request the backend does not accept:
        // nothing the user can fix.
        _ => l10n.plannerErrorUnavailable,
      };
    }
    return l10n.plannerErrorGeneric;
  }

  /// Plans a trip in the language of [languageCode]. The plan keeps that language,
  /// also if the app changes to another later.
  Future<TripPlan> generatePlan({
    required DateTime startDate,
    required int lengthInDays,
    required String location,
    required List<String> categories,
    String languageCode = 'en',
  }) async {
    if (lengthInDays < 1 || lengthInDays > maxTripDays) {
      throw ArgumentError.value(lengthInDays, 'lengthInDays', 'must be between 1 and $maxTripDays');
    }
    if (location.length > maxLocationLength) {
      throw ArgumentError.value(location.length, 'location.length', 'must be at most $maxLocationLength');
    }

    final l10n = lookupAppLocalizations(Locale(languageCode));

    final http.Response response;
    try {
      response = await _client
          .post(
            BackendApi.tripPlanUri,
            headers: await BackendApi.headers(_appCheckToken, json: true),
            body: jsonEncode({
              'startDate': _calendarDate(startDate),
              'lengthInDays': lengthInDays,
              'accommodation': location,
              'interests': categories,
              'language': languageCode,
            }),
          )
          .timeout(_requestTimeout);
    } on TimeoutException {
      throw TimeoutException(
          'The trip planner did not respond within ${_requestTimeout.inMinutes} minutes', _requestTimeout);
    }

    final body = utf8.decode(response.bodyBytes, allowMalformed: true);
    if (response.statusCode != 200) {
      throw TripPlannerHttpException(response.statusCode, body);
    }

    final List<dynamic> daysJson;
    try {
      daysJson = (jsonDecode(body) as Map<String, dynamic>)['days'] as List<dynamic>? ?? const [];
    } catch (e) {
      throw Exception('Invalid answer from the trip planner: $e');
    }

    final days = <DailyPlan>[];
    for (var i = 0; i < daysJson.length; i++) {
      final day = daysJson[i] as Map<String, dynamic>;
      final theme = (day['theme'] as String? ?? '').trim();
      final area = (day['area'] as String? ?? '').trim();
      final activities = (day['activities'] as List<dynamic>? ?? const [])
          .map((activity) => _describeActivity(activity, l10n))
          .toList(growable: false);

      days.add(
        DailyPlan(
          title: theme.isEmpty ? l10n.planDayTitle(i + 1) : l10n.planDayThemeTitle(i + 1, theme),
          area: area.isEmpty ? null : area,
          highlights: activities.isEmpty ? [l10n.planFreeTime] : activities,
        ),
      );
    }

    if (days.isEmpty) {
      throw Exception('Plan generation failed: empty itinerary.');
    }

    final trimmedDays = List<DailyPlan>.from(
      days.take(lengthInDays),
      growable: true,
    );

    // The schema asks for exactly lengthInDays days; this only covers an
    // answer that does not follow it.
    while (trimmedDays.length < lengthInDays) {
      trimmedDays.add(
        DailyPlan(
          title: l10n.planFreeDayTitle(trimmedDays.length + 1),
          highlights: [l10n.planFreeTime],
        ),
      );
    }

    return TripPlan(
      location: location,
      startDate: startDate,
      lengthInDays: trimmedDays.length,
      categories: categories,
      days: trimmedDays,
    );
  }

  /// The day as the user picked it, e.g. 2026-11-10, whatever the time zone.
  static String _calendarDate(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  /// One highlight of the itinerary, e.g. "Morning: Burj Khalifa (Downtown
  /// Dubai) – Sunset views from level 124." with "Getting there: 5 min walk"
  /// on a second line.
  static String _describeActivity(Object? activity, AppLocalizations l10n) {
    if (activity is! Map<String, dynamic>) return '$activity';
    String field(String key) => (activity[key] as String? ?? '').trim();
    // The schema has these in English, so that the app can tell them apart.
    final time = switch (field('time')) {
      'Breakfast' => l10n.planBreakfast,
      'Morning' => l10n.planMorning,
      'Lunch' => l10n.planLunch,
      'Afternoon' => l10n.planAfternoon,
      'Dinner' => l10n.planDinner,
      'Evening' => l10n.planEvening,
      'Night' => l10n.planNight,
      '' => '',
      final other => '$other:',
    };
    final area = field('area');
    final description = field('description');
    final travel = field('travel');
    return [
      if (time.isNotEmpty) '$time ',
      field('place'),
      if (area.isNotEmpty) ' ($area)',
      if (description.isNotEmpty) ' – $description',
      if (travel.isNotEmpty) '\n${l10n.planGettingThere(travel)}',
    ].join();
  }
}

/// The backend answered with an error status. [body] holds its JSON error,
/// e.g. {"error":"app_check_failed"}, which is for logs;
/// [TripPlannerService.userMessage] explains it to the user.
class TripPlannerHttpException implements Exception {
  TripPlannerHttpException(this.statusCode, this.body);

  final int statusCode;
  final String body;

  /// The backend's error code, or null when the body is not its JSON error
  /// (e.g. an HTML page from a proxy).
  String? get code {
    try {
      final error = (jsonDecode(body) as Map<String, dynamic>)['error'];
      return error is String ? error : null;
    } catch (_) {
      return null;
    }
  }

  @override
  String toString() => 'Trip planner error ($statusCode): $body';
}
