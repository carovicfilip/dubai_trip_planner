import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:dubai_trip_planner/core/paywall/paywall.dart';
import 'package:dubai_trip_planner/core/paywall/reviewer_code.dart';
import 'package:dubai_trip_planner/features/onboarding/ui/onboarding_screen.dart';
import 'package:dubai_trip_planner/features/profile/ui/profile_screen.dart';
import 'package:dubai_trip_planner/features/weather/services/weather_forecast_service.dart';
import 'package:dubai_trip_planner/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  final weatherFixture = File('test/fixtures/openweather_forecast_dubai.json').readAsStringSync();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    WeatherForecastService.clearMemoryCache();
    // The real code is not in git, so the tests use a code of their own.
    ReviewerCode.debugSha256 = sha256.convert(utf8.encode('TESTCODE')).toString();
    Paywall.debugSetUp(configured: true);
  });

  tearDown(() {
    ReviewerCode.debugSha256 = null;
    Paywall.debugSetUp(configured: false);
  });

  /// Opens Profile in the real app and passes it to [body].
  Future<void> onProfile(WidgetTester tester, Future<void> Function() body) async {
    // Large surface on purpose, as in dark_theme_switch_test.dart.
    tester.view.physicalSize = const Size(1200, 2400) * 3;
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    final reportError = FlutterError.onError!;
    FlutterError.onError = (details) {
      if (!details.exceptionAsString().contains('A RenderFlex overflowed')) reportError(details);
    };
    final prefs = await SharedPreferences.getInstance();
    try {
      await http.runWithClient(
        () async {
          await tester.pumpWidget(MyApp(prefs: prefs, onboardingCompleted: false));
          Navigator.of(tester.element(find.byType(OnboardingScreen)))
              .push(MaterialPageRoute(builder: (_) => const ProfileScreen()));
          await tester.pump(const Duration(seconds: 1));
          await tester.pump(const Duration(seconds: 1));
          await body();
        },
        () => MockClient((_) async => http.Response(weatherFixture, 200)),
      );
    } finally {
      FlutterError.onError = reportError;
    }
  }

  /// Profile has endless animations, so pumpAndSettle would never return.
  Future<void> settle(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
  }

  testWidgets(
    'a long press on Terms of Use asks for the reviewer code, which unlocks Pro',
    (tester) async {
      await onProfile(tester, () async {
        await tester.longPress(find.text('Terms of Use'));
        await settle(tester);
        expect(find.text('Reviewer code'), findsOneWidget);

        await tester.enterText(find.byType(TextField), 'WRONG123');
        await tester.tap(find.text('Unlock'));
        await settle(tester);
        expect(find.text('This code is not valid.'), findsOneWidget);
        expect(Paywall.locksPlans, isTrue);

        await tester.enterText(find.byType(TextField), 'test-code');
        await tester.pump();
        expect(find.text('This code is not valid.'), findsNothing, reason: 'typing again clears the error');
        await tester.tap(find.text('Unlock'));
        await settle(tester);

        expect(find.text('Reviewer code'), findsNothing);
        expect(find.text('Pro is unlocked on this device.'), findsOneWidget);
        expect(Paywall.locksPlans, isFalse);
        expect((await SharedPreferences.getInstance()).getBool('reviewer_access'), isTrue);
      });
    },
    variant: TargetPlatformVariant.only(TargetPlatform.android),
  );

  testWidgets(
    'on iOS a long press on Terms of Use does nothing',
    (tester) async {
      await onProfile(tester, () async {
        await tester.longPress(find.text('Terms of Use'));
        await settle(tester);

        expect(find.text('Reviewer code'), findsNothing);
        expect(Paywall.locksPlans, isTrue);
      });
    },
    variant: TargetPlatformVariant.only(TargetPlatform.iOS),
  );
}
