import 'dart:async';
import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../models/trip_plan.dart';

class TripPlannerService {
  TripPlannerService({http.Client? httpClient}) : _client = httpClient ?? http.Client();

  final http.Client _client;

  static const _endpoint = 'https://api.openai.com/v1/chat/completions';
  static const _model = 'gpt-4o-mini';
  // Long itineraries take the model well over a minute to write, so this only
  // guards against a stalled connection keeping the spinner going forever.
  static const _requestTimeout = Duration(minutes: 2);

  /// Longest stay one plan may cover. Longer itineraries make the request
  /// slow and costly, and the answer more likely to be cut off.
  static const maxTripDays = 15;

  /// Longest accommodation text sent to the model. It goes into the prompt
  /// as typed, so it is capped like the trip length.
  static const maxLocationLength = 100;

  /// A short explanation of an error thrown by [generatePlan] that is safe to
  /// show the user. The error itself can contain OpenAI's raw JSON, so it
  /// belongs in the logs only.
  static String userMessage(Object error) {
    if (error is http.ClientException) {
      return 'Could not reach the trip planner. Check your internet connection and try again.';
    }
    if (error is TimeoutException) {
      return 'The trip planner took too long to answer. Please try again.';
    }
    if (error is OpenAiHttpException && error.statusCode == 429) {
      return 'The trip planner is busy right now. Please try again in a minute.';
    }
    if (error is OpenAiHttpException && error.statusCode >= 500) {
      return 'The trip planner is having problems. Please try again later.';
    }
    if (error is OpenAiHttpException || error is StateError) {
      // A rejected key or a missing configuration: nothing the user can fix.
      return 'The trip planner is unavailable right now. Please try again later.';
    }
    return 'We could not create your plan this time. Please try again.';
  }

  Future<TripPlan> generatePlan({
    required DateTime startDate,
    required int lengthInDays,
    required String location,
    required List<String> categories,
  }) async {
    if (lengthInDays < 1 || lengthInDays > maxTripDays) {
      throw ArgumentError.value(lengthInDays, 'lengthInDays', 'must be between 1 and $maxTripDays');
    }
    if (location.length > maxLocationLength) {
      throw ArgumentError.value(location.length, 'location.length', 'must be at most $maxLocationLength');
    }

    final key = dotenv.env['OPENAI_API_KEY'];
    if (key == null || key.isEmpty) {
      throw StateError('OPENAI_API_KEY is missing. Add it to your .env file.');
    }

    final requestBody = {
      'model': _model,
      'response_format': {'type': 'json_object'},
      'messages': [
        {
          'role': 'system',
          'content':
              'You are an expert Dubai travel planner with deep knowledge of attractions, restaurants, '
                  'cultural sites, shopping areas, and experiences in Dubai. You create detailed, '
                  'practical, and personalized trip itineraries. Always return strictly valid JSON only. '
                  'Do not include any prose, explanations, or markdown formatting outside the JSON object.',
        },
        {
          'role': 'user',
          'content': _buildPrompt(
            startDate: startDate,
            lengthInDays: lengthInDays,
            location: location,
            categories: categories,
          ),
        },
      ],
    };

    final http.Response response;
    try {
      response = await _client
          .post(
            Uri.parse(_endpoint),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $key',
            },
            body: jsonEncode(requestBody),
          )
          .timeout(_requestTimeout);
    } on TimeoutException {
      throw TimeoutException('OpenAI did not respond within ${_requestTimeout.inMinutes} minutes', _requestTimeout);
    }

    if (response.statusCode != 200) {
      throw OpenAiHttpException(response.statusCode, response.body);
    }

    final Map<String, dynamic> json = jsonDecode(response.body) as Map<String, dynamic>;
    final choices = json['choices'] as List<dynamic>;
    if (choices.isEmpty) {
      throw Exception('OpenAI returned no choices.');
    }

    final message = choices.first['message'] as Map<String, dynamic>;
    final content = message['content'] as String?;

    if (content == null || content.isEmpty) {
      throw Exception('OpenAI returned empty content.');
    }

    // Extract JSON from content (handle markdown code blocks if present)
    final rawJson = _extractJsonContent(content);
    if (rawJson.isEmpty) {
      throw Exception('Failed to extract JSON from OpenAI response.');
    }

    Map<String, dynamic> parsed;
    try {
      parsed = jsonDecode(rawJson) as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Invalid JSON from OpenAI: $e. Raw content: ${rawJson.substring(0, rawJson.length > 200 ? 200 : rawJson.length)}');
    }

    final daysJson = parsed['days'] as List<dynamic>? ?? const [];

    final days = <DailyPlan>[];
    for (var i = 0; i < daysJson.length; i++) {
      final day = daysJson[i] as Map<String, dynamic>;
      final title = day['title'] as String? ?? 'Day ${i + 1}';
      final activities = (day['activities'] as List<dynamic>? ?? const [])
          .map((activity) => activity.toString())
          .toList(growable: false);

      days.add(
        DailyPlan(
          title: title,
          highlights: activities.isEmpty
              ? [
                  'Morning: Free exploration',
                  'Afternoon: Local dining suggestion',
                  'Evening: Visit Dubai Fountain',
                ]
              : activities,
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

    while (trimmedDays.length < lengthInDays) {
      trimmedDays.add(
        DailyPlan(
          title: 'Day ${trimmedDays.length + 1}',
          highlights: const [
            'Morning: Free time to revisit favorite spots or relax at the hotel spa.',
            'Afternoon: Shopping at Mall of the Emirates or Souk Madinat.',
            'Evening: Sunset walk along JBR The Walk with beachfront dining.',
          ],
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

  String _buildPrompt({
    required DateTime startDate,
    required int lengthInDays,
    required String location,
    required List<String> categories,
  }) {
    final dateString = startDate.toIso8601String().split('T').first;
    final categoriesList = categories.isEmpty ? 'General must-see spots' : categories.join(', ');

    return '''
You are creating a detailed $lengthInDays-day Dubai trip itinerary.

Trip Details:
- Starting date: $dateString
- Traveler base location: $location
- Interests/Categories: $categoriesList
- Number of days: $lengthInDays

Requirements:
1. Create exactly $lengthInDays days of activities
2. Each day should have a unique theme or focus area
3. Consider proximity to the base location ($location) when planning
4. Include specific Dubai attractions, restaurants, and experiences
5. Balance activities throughout each day (Morning, Afternoon, Evening)
6. Make activities specific and actionable (include actual place names when possible)
7. Consider the traveler's interests: $categoriesList

IMPORTANT: Return ONLY valid JSON. No explanations, no markdown, no code blocks. Just the raw JSON object.

Return the response in this exact JSON format:
{
  "days": [
    {
      "title": "Day 1: [Theme or Area Name]",
      "activities": [
        "Morning: [Specific activity with location/name]",
        "Afternoon: [Specific activity with location/name]",
        "Evening: [Specific activity with location/name]"
      ]
    }
  ]
}

Make sure to create exactly $lengthInDays day entries in the "days" array.
''';
  }

  String _extractJsonContent(String content) {
    // Remove markdown code blocks if present
    String cleaned = content.trim();
    
    // Remove ```json or ``` markers
    if (cleaned.startsWith('```')) {
      final lines = cleaned.split('\n');
      // Remove first line if it's ```json or ```
      if (lines.first.trim().startsWith('```')) {
        lines.removeAt(0);
      }
      // Remove last line if it's ```
      if (lines.isNotEmpty && lines.last.trim() == '```') {
        lines.removeLast();
      }
      cleaned = lines.join('\n').trim();
    }
    
    // Try to find JSON object boundaries
    final jsonStart = cleaned.indexOf('{');
    final jsonEnd = cleaned.lastIndexOf('}');
    
    if (jsonStart != -1 && jsonEnd != -1 && jsonEnd > jsonStart) {
      cleaned = cleaned.substring(jsonStart, jsonEnd + 1);
    }
    
    return cleaned;
  }
}

/// OpenAI answered with an error status. [body] holds its JSON error, which
/// is for logs; [TripPlannerService.userMessage] explains it to the user.
class OpenAiHttpException implements Exception {
  OpenAiHttpException(this.statusCode, this.body);

  final int statusCode;
  final String body;

  @override
  String toString() => 'OpenAI error ($statusCode): $body';
}

