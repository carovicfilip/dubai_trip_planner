import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// The app's backend, a Cloudflare Worker (see `backend/`). It holds the
/// OpenAI and OpenWeather keys, so the app itself has none. The Worker only
/// answers requests that carry a Firebase App Check token, which proves they
/// come from this app on a real device.
abstract final class BackendApi {
  static final baseUri = Uri.parse('https://dubai-trip-planner-api.dubai-trip-planner-api.workers.dev/');

  static final tripPlanUri = baseUri.resolve('trip-plan');
  static final weatherUri = baseUri.resolve('weather');

  static const appCheckHeader = 'X-Firebase-AppCheck';

  /// The headers of a request to the backend. Without an App Check token the
  /// request still goes out, and the Worker refuses it with 401.
  static Future<Map<String, String>> headers(AppCheckTokenSource appCheckToken, {bool json = false}) async {
    final token = await appCheckToken();
    return {
      if (json) 'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) appCheckHeader: token,
    };
  }
}

/// Gets the App Check token sent with each request to the backend.
typedef AppCheckTokenSource = Future<String?> Function();

/// The token from Firebase App Check, or null when there is none: Firebase is
/// not set up on this platform (or in tests), or the device could not be
/// checked. Firebase caches the token and renews it before it expires.
Future<String?> firebaseAppCheckToken() async {
  if (Firebase.apps.isEmpty) return null;
  try {
    return await FirebaseAppCheck.instance.getToken();
  } catch (error) {
    debugPrint('No App Check token: $error');
    return null;
  }
}
