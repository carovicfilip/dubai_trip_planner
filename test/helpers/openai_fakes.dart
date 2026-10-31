import 'dart:convert';

import 'package:http/http.dart' as http;

/// Body shaped like a real OpenAI `chat.completions` response.
String chatCompletionBody(String content, {String finishReason = 'stop'}) => jsonEncode({
      'id': 'chatcmpl-test',
      'object': 'chat.completion',
      'model': 'gpt-4o-mini-2024-07-18',
      'choices': [
        {
          'index': 0,
          'message': {'role': 'assistant', 'content': content},
          'finish_reason': finishReason,
        },
      ],
      'usage': {'prompt_tokens': 300, 'completion_tokens': 400, 'total_tokens': 700},
    });

/// Itinerary JSON in the format the prompt asks the model for.
String itineraryJson(int days, {int activitiesPerDay = 3}) => jsonEncode({
      'days': [
        for (var d = 1; d <= days; d++)
          {
            'title': 'Day $d: Theme $d',
            'activities': [
              for (var a = 1; a <= activitiesPerDay; a++) 'Activity $a of day $d',
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
