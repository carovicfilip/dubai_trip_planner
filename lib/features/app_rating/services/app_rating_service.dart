import 'package:flutter/services.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppRatingService {
  static const String _askedKey = 'app_rating_asked';

  static Future<bool> wasAsked() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_askedKey) ?? false;
  }

  static Future<void> markAsked() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_askedKey, true);
  }

  static Future<void> resetAsked() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_askedKey, false);
  }

  /// Asks the store for its own rating dialog. The store alone decides whether
  /// to show it, and it can always be closed; the app is never told whether it
  /// appeared or what the user chose.
  static Future<void> requestStoreReview() async {
    final inAppReview = InAppReview.instance;
    try {
      if (await inAppReview.isAvailable()) await inAppReview.requestReview();
    } on PlatformException {
      // The user only misses a dialog they did not ask for.
    }
  }
}
