import 'dart:convert';

import 'package:http/http.dart' as http;

/// The backend's answer to a trip plan: the itinerary in the shape of the
/// schema it asks OpenAI for.
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

/// UTF-8 encoded response, like the backend sends it.
http.Response jsonResponse(String body, int status, {String contentType = 'application/json'}) =>
    http.Response.bytes(utf8.encode(body), status, headers: {'content-type': contentType});

/// The backend's error answer, e.g. {"error":"upstream_error"}.
String backendErrorBody(String code) => jsonEncode({'error': code});

/// The trip form the app sent to the backend.
Map<String, dynamic> tripFormSent(http.Request request) => jsonDecode(request.body) as Map<String, dynamic>;
