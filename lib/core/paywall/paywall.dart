import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:superwallkit_flutter/superwallkit_flutter.dart';

/// Where the app can open a paywall. Each one is a placement in the Superwall
/// dashboard, whose campaigns decide which paywall it shows and to whom.
enum PaywallPlacement {
  /// Right after the onboarding screens. The paywall starts on its preview
  /// step.
  onboardingComplete('onboarding_complete', 'onboarding'),

  /// Every time the user comes into the app: after the Welcome Back splash,
  /// and on coming back from the background. The paywall starts on its plans
  /// step. Not `app_open`: Superwall refuses placements named like its own
  /// events (app_open, app_launch, session_start, ...).
  appEntry('app_entry', 'app');

  const PaywallPlacement(this.placementName, this.source);

  /// The placement's name in the Superwall dashboard.
  final String placementName;

  /// The paywall's `source` parameter, which picks the step it starts on.
  final String source;
}

/// The paywalls, which are built in Superwall's editor. Superwall also handles
/// the purchases.
abstract final class Paywall {
  /// Superwall's public SDK keys, one per platform. They come from
  /// superwall_keys.json, which is not in git:
  /// `flutter run --dart-define-from-file=superwall_keys.json`.
  static const _iosApiKey = String.fromEnvironment('SUPERWALL_IOS_API_KEY');
  static const _androidApiKey = String.fromEnvironment('SUPERWALL_ANDROID_API_KEY');

  /// In test mode Superwall simulates purchases, so nothing is bought for real.
  /// On by default in debug builds; `--dart-define=SUPERWALL_TEST_MODE=false`
  /// turns it off to test with the stores' sandboxes.
  static const _testMode = bool.fromEnvironment('SUPERWALL_TEST_MODE', defaultValue: kDebugMode);

  /// On Android a paywall is its own screen, so closing it brings the app back
  /// from the background. Returns this soon after a paywall closes are part of
  /// that paywall, not a new visit.
  static const _closeEchoWindow = Duration(seconds: 3);

  /// How long a return still counts as coming back from something the app
  /// itself opened, such as a link in the browser.
  static const _sentOutWindow = Duration(minutes: 10);

  static bool _configured = false;
  static bool _requesting = false;
  static bool _showing = false;
  static DateTime? _closedAt;
  static DateTime? _sentOutAt;

  /// Starts Superwall. Without a key for this platform (tests, or a build made
  /// without superwall_keys.json) the app simply runs without paywalls.
  static void configure() {
    if (kIsWeb || !(Platform.isIOS || Platform.isAndroid)) return;
    final apiKey = Platform.isIOS ? _iosApiKey : _androidApiKey;
    if (apiKey.isEmpty) {
      debugPrint('No Superwall key: run with --dart-define-from-file=superwall_keys.json. No paywalls in this build.');
      return;
    }
    try {
      final options = SuperwallOptions()
        ..testModeBehavior = _testMode ? TestModeBehavior.always : TestModeBehavior.automatic;
      Superwall.configure(apiKey, options: options);
      _configured = true;
    } catch (error) {
      debugPrint('Superwall did not start: $error');
    }
  }

  /// Asks Superwall for the paywall of [placement]. The dashboard decides
  /// whether one shows: a subscriber, for example, gets none.
  static Future<void> show(PaywallPlacement placement) async {
    if (!_configured || _requesting || _showing) return;
    _requesting = true;
    final handler = PaywallPresentationHandler()
      ..onPresent((_) => _showing = true)
      ..onDismiss((_, _) => _closed())
      ..onSkip((reason) => debugPrint('Paywall ${placement.placementName} skipped: $reason'))
      ..onError((error) {
        _showing = false;
        debugPrint('Paywall ${placement.placementName} failed: $error');
      });
    try {
      await Superwall.shared.registerPlacement(
        placement.placementName,
        params: {'source': placement.source},
        handler: handler,
      );
    } catch (error) {
      debugPrint('Paywall ${placement.placementName} failed: $error');
    } finally {
      _requesting = false;
    }
  }

  static void _closed() {
    _showing = false;
    _closedAt = DateTime.now();
  }

  /// Call just before the app sends the user out of it, to the browser or to
  /// the store's rating dialog, so that coming back does not open a paywall.
  static void sendingUserOut() => _sentOutAt = DateTime.now();

  /// The app has come back from the background.
  static void onReturnToApp() {
    final now = DateTime.now();
    final closedAt = _closedAt;
    final sentOutAt = _sentOutAt;
    if (closedAt != null && now.difference(closedAt) < _closeEchoWindow) return;
    if (sentOutAt != null && now.difference(sentOutAt) < _sentOutWindow) {
      _sentOutAt = null;
      return;
    }
    show(PaywallPlacement.appEntry);
  }
}
