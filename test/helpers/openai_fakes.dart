import 'dart:convert';

import 'package:http/http.dart' as http;

/// Body shaped like a real OpenAI `chat.completions` response.
String chatCompletionBody(String content, {String finishReason = 'stop'}) => jsonEncode({
      'id': 'chatcmpl-test',
      'object': 'chat.completion',
      'model': 'gpt-6-luna',
      'choices': [
        {
          'index': 0,
          'message': {'role': 'assistant', 'content': content, 'refusal': null},
          'finish_reason': finishReason,
        },
      ],
      'usage': {'prompt_tokens': 1200, 'completion_tokens': 900, 'total_tokens': 2100},
    });

/// Itinerary JSON in the shape of the schema the app sends.
String itineraryJson(int days, {int activitiesPerDay = 3}) => jsonEncode({
      'days': [
        for (var d = 1; d <= days; d++)
          {
            'area': 'Area $d',
            'theme': 'Theme $d',
            'activities': [
              for (var a = 1; a <= activitiesPerDay; a++)
                {
                  'time': 'Morning',
                  'place': 'Place $a of day $d',
                  'area': 'Area $d',
                  'travel': '5 min walk',
                  'description': 'Activity $a of day $d.',
                },
            ],
          },
      ],
    });

/// UTF-8 encoded response, like the real API sends it.
http.Response jsonResponse(String body, int status, {String contentType = 'application/json'}) =>
    http.Response.bytes(utf8.encode(body), status, headers: {'content-type': contentType});

String openAiErrorBody(String code, String message) => jsonEncode({
      'error': {'message': message, 'type': 'invalid_request_error', 'code': code, 'param': null},
    });

/// The trip details (accommodation, interests, dates) the app sent to OpenAI.
Map<String, dynamic> tripDetailsSent(http.Request request) {
  final messages = jsonDecode(request.body)['messages'] as List<dynamic>;
  return jsonDecode(messages.last['content'] as String) as Map<String, dynamic>;
}
