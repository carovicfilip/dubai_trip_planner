import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:dubai_trip_planner/core/paywall/paywall.dart';
import 'package:dubai_trip_planner/core/paywall/reviewer_code.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  // The real code is not in git, so the tests use a code of their own.
  const testCode = 'TESTCODE';
  final testHash = sha256.convert(utf8.encode(testCode)).toString();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    ReviewerCode.debugSha256 = testHash;
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
  });

  tearDown(() {
    ReviewerCode.debugSha256 = null;
    debugDefaultTargetPlatformOverride = null;
    Paywall.debugSetUp(configured: false);
  });

  group('ReviewerCode', () {
    test('accepts the code however it is typed', () {
      for (final typed in ['TESTCODE', 'testcode', ' TestCode ', 'TEST-CODE', 'test code']) {
        expect(ReviewerCode.matches(typed), isTrue, reason: typed);
      }
    });

    test('refuses anything else', () {
      for (final typed in ['', '   ', 'TESTCOD', 'TESTCODEX', 'TESTC0DE']) {
        expect(ReviewerCode.matches(typed), isFalse, reason: typed);
      }
    });

    test('the real code is not the test code', () {
      ReviewerCode.debugSha256 = null;
      expect(ReviewerCode.matches(testCode), isFalse);
    });

    test('is offered on Android only', () {
      expect(ReviewerCode.isAvailable, isTrue);
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      expect(ReviewerCode.isAvailable, isFalse);
    });
  });

  group('Paywall with the reviewer code', () {
    test('the right code gives Pro at once and stops locking plans', () async {
      Paywall.debugSetUp(configured: true);
      expect(Paywall.locksPlans, isTrue);

      expect(await Paywall.unlockWithReviewerCode('testcode'), isTrue);

      expect(Paywall.subscribed.value, isTrue);
      expect(Paywall.hasReviewerAccess, isTrue);
      expect(Paywall.locksPlans, isFalse);
    });

    test('a wrong code changes nothing', () async {
      Paywall.debugSetUp(configured: true);

      expect(await Paywall.unlockWithReviewerCode('WRONG123'), isFalse);

      expect(Paywall.subscribed.value, isFalse);
      expect(Paywall.locksPlans, isTrue);
      expect((await SharedPreferences.getInstance()).getBool('reviewer_access'), isNull);
    });

    test('the code does nothing on iOS', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      Paywall.debugSetUp(configured: true);

      expect(await Paywall.unlockWithReviewerCode(testCode), isFalse);

      expect(Paywall.locksPlans, isTrue);
    });

    test('Pro from the code is remembered when the app starts again', () async {
      await Paywall.unlockWithReviewerCode(testCode);
      Paywall.debugSetUp(configured: false); // the app is closed

      await Paywall.configure();

      expect(Paywall.hasReviewerAccess, isTrue);
      expect(Paywall.subscribed.value, isTrue);
    });

    test('without the code, starting the app gives no Pro', () async {
      await Paywall.configure();

      expect(Paywall.hasReviewerAccess, isFalse);
      expect(Paywall.subscribed.value, isFalse);
    });
  });
}
