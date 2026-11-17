import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';

/// The code that gives Google Play's app reviewers Pro without buying it.
///
/// Google reviews apps without buying anything or starting a free trial, so a
/// paid feature has to be reachable some other way, and the Play Console's
/// Sign-in details declaration says how. The code is written only there; the
/// app keeps just its SHA-256, so the code is not in the app or in git.
///
/// Android only: on iOS, App Review buys in the sandbox for free, and App
/// Store guideline 2.3.1 does not allow hidden features.
abstract final class ReviewerCode {
  static const _sha256 = 'f5963e2e41e26ab19bd5e27bc80cf4cbe73f370639aa7f895d6310f7f5c38e23';

  /// Whether this platform offers the reviewer code at all.
  static bool get isAvailable => !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  /// Tests set this to the hash of a code of their own, since the real code
  /// is not in git.
  @visibleForTesting
  static String? debugSha256;

  /// Whether [input] is the reviewer code. Case, spaces and dashes do not
  /// matter, so "abcd-1234" counts the same as "ABCD1234".
  static bool matches(String input) => matchesHash(input, debugSha256 ?? _sha256);

  @visibleForTesting
  static bool matchesHash(String input, String sha256Hex) {
    final normalized = input.toUpperCase().replaceAll(RegExp(r'[\s-]'), '');
    if (normalized.isEmpty) return false;
    return sha256.convert(utf8.encode(normalized)).toString() == sha256Hex;
  }
}
