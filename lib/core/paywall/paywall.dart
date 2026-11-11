import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  appEntry('app_entry', 'app'),

  /// A trip plan that is locked until the user subscribes: the results
  /// paywall. Starts on the plans step.
  planUnlock('plan_unlock', 'app'),

  /// A new trip plan once the free one has been used.
  newPlan('new_plan', 'app'),

  /// The one-time offer. It follows only the results paywall, when that one
  /// is closed without buying, and at most once per install.
  resultsOffer('results_offer', 'app');

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

  /// Whether the user has an active subscription, kept up to date by
  /// Superwall.
  static final subscribed = ValueNotifier<bool>(false);

  /// Whether trip plans are locked for this user: paywalls are on and there is
  /// no subscription. Builds without a Superwall key never lock anything.
  static bool get locksPlans => _configured && !subscribed.value;

  static const _resultsOfferShownKey = 'results_offer_shown';

  @visibleForTesting
  static void debugSetUp({required bool configured, bool subscribed = false}) {
    _configured = configured;
    Paywall.subscribed.value = subscribed;
  }

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
      // Superwall opens some paywalls by itself (the offer after a closed
      // paywall), so the app follows every paywall through the delegate.
      Superwall.shared.setDelegate(_PaywallTracker());
      _configured = true;
      _followSubscription();
    } catch (error) {
      debugPrint('Superwall did not start: $error');
    }
  }

  /// Keeps [subscribed] up to date.
  ///
  /// On iOS the status stream only exists once the native side has handled
  /// configure, and listening any sooner fails with a MissingPluginException.
  /// The platform answers calls in the order they were made, so once the
  /// status below has come back, configure has been handled.
  static Future<void> _followSubscription() async {
    try {
      subscribed.value = (await Superwall.shared.getSubscriptionStatus()).isActive;
    } catch (error) {
      debugPrint('Superwall subscription status unavailable: $error');
    }
    Superwall.shared.subscriptionStatus.listen((status) {
      if (kDebugMode) debugPrint('Superwall subscription active: ${status.isActive}');
      subscribed.value = status.isActive;
    });
  }

  /// Asks Superwall for the paywall of [placement]. The dashboard decides
  /// whether one shows: a subscriber, for example, gets none.
  ///
  /// [onDeclined] runs when the paywall is closed without buying, and
  /// [onPurchased] when it ends in a purchase or a restore.
  static Future<void> show(
    PaywallPlacement placement, {
    VoidCallback? onDeclined,
    VoidCallback? onPurchased,
    VoidCallback? onPresented,
  }) async {
    if (!_configured || _requesting || _showing) return;
    _requesting = true;
    final handler = PaywallPresentationHandler()
      ..onPresent((_) => onPresented?.call())
      ..onDismiss((_, result) {
        switch (result) {
          case DeclinedPaywallResult():
            onDeclined?.call();
          case PurchasedPaywallResult() || RestoredPaywallResult():
            // Superwall's status comes a moment later; what runs next (making
            // the plan) must already see the subscription.
            subscribed.value = true;
            onPurchased?.call();
        }
      })
      ..onSkip((reason) => debugPrint('Paywall ${placement.placementName} skipped: $reason'))
      ..onError((error) => debugPrint('Paywall ${placement.placementName} failed: $error'));
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

  /// The results paywall of a locked plan. Closing it without buying brings
  /// the one-time offer, once per install.
  static Future<void> showPlanUnlock({VoidCallback? onPurchased}) {
    return show(PaywallPlacement.planUnlock, onPurchased: onPurchased, onDeclined: _showResultsOfferOnce);
  }

  static Future<void> _showResultsOfferOnce() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_resultsOfferShownKey) ?? false) return;
    // Superwall needs the closed paywall gone before it can show another.
    await Future<void>.delayed(const Duration(milliseconds: 600));
    await show(
      PaywallPlacement.resultsOffer,
      onPresented: () => prefs.setBool(_resultsOfferShownKey, true),
    );
  }

  static void _opened() => _showing = true;

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

/// Follows every paywall Superwall shows, including the ones it opens by
/// itself, and passes Superwall's warnings to the debug log. In 2.8.0 every
/// method of the delegate has to be implemented, so the rest are empty.
class _PaywallTracker extends SuperwallDelegate {
  @override
  void willPresentPaywall(PaywallInfo paywallInfo) {
    if (kDebugMode) {
      debugPrint('Paywall shown: ${paywallInfo.name} (${paywallInfo.presentedByPlacementWithName}, '
          'intro offer: ${paywallInfo.isFreeTrialAvailable})');
    }
    Paywall._opened();
  }

  @override
  void didDismissPaywall(PaywallInfo paywallInfo) {
    if (kDebugMode) debugPrint('Paywall closed: ${paywallInfo.name}');
    Paywall._closed();
  }

  @override
  void handleLog(String level, String scope, String? message, Map<dynamic, dynamic>? info, String? error) {
    if (!kDebugMode) return;
    final lower = level.toLowerCase();
    if (lower.contains('warn') || lower.contains('error')) {
      debugPrint('Superwall $level [$scope]: ${message ?? ''} ${error ?? ''}');
    }
  }

  @override
  void subscriptionStatusDidChange(SubscriptionStatus newValue) {}

  @override
  void handleSuperwallEvent(SuperwallEventInfo eventInfo) {}

  @override
  void handleCustomPaywallAction(String name) {}

  @override
  void willDismissPaywall(PaywallInfo paywallInfo) {}

  @override
  void didPresentPaywall(PaywallInfo paywallInfo) {}

  @override
  void paywallWillOpenURL(Uri url) {}

  @override
  void paywallWillOpenDeepLink(Uri url) {}

  @override
  void handleSuperwallDeepLink(Uri fullURL, List<String> pathComponents, Map<String, String> queryParameters) {}
}
