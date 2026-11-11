import 'package:dubai_trip_planner/app/language/app_language.dart';
import 'package:dubai_trip_planner/app/language/language_cubit.dart';
import 'package:dubai_trip_planner/core/paywall/paywall.dart';
import 'package:dubai_trip_planner/features/favorites/cubit/favorites_cubit.dart';
import 'package:dubai_trip_planner/features/my_trip/cubit/my_trip_cubit.dart';
import 'package:dubai_trip_planner/features/my_trip/services/trip_planner_service.dart';
import 'package:dubai_trip_planner/firebase_options.dart';
import 'package:dubai_trip_planner/l10n/l10n.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show debugPrint, kDebugMode;
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app/theme/app_theme.dart';
import 'app/theme/theme_cubit.dart';
import 'features/onboarding/services/onboarding_service.dart';
import 'features/onboarding/ui/onboarding_screen.dart';
import 'features/splash/ui/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _startAppCheck();
  Paywall.configure();
  final prefs = await SharedPreferences.getInstance();
  final onboardingCompleted = await OnboardingService.isOnboardingCompleted();
  runApp(MyApp(prefs: prefs, onboardingCompleted: onboardingCompleted));
}

/// Debug token for simulators and emulators, which cannot pass Play Integrity
/// or App Attest. It comes from app_check_debug.json, which is not in git:
/// `flutter run --dart-define-from-file=app_check_debug.json`.
const _appCheckDebugToken = String.fromEnvironment('APP_CHECK_DEBUG_TOKEN');

/// Starts Firebase App Check, which proves to the backend that a request comes
/// from this app on a real device. Without it the trip planner and the
/// forecast are unavailable, but the rest of the app works, so a failure here
/// must not stop the app from starting.
Future<void> _startAppCheck() async {
  final options = DefaultFirebaseOptions.currentPlatform;
  if (options == null) return; // no Firebase app for web and desktop
  try {
    await Firebase.initializeApp(options: options);
    final debugToken = _appCheckDebugToken.isEmpty ? null : _appCheckDebugToken;
    await FirebaseAppCheck.instance.activate(
      providerAndroid: kDebugMode ? AndroidDebugProvider(debugToken: debugToken) : const AndroidPlayIntegrityProvider(),
      providerApple: kDebugMode ? AppleDebugProvider(debugToken: debugToken) : const AppleAppAttestProvider(),
    );
  } catch (error) {
    debugPrint('App Check did not start: $error');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.prefs, required this.onboardingCompleted});

  final SharedPreferences prefs;
  final bool onboardingCompleted;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => FavoritesCubit(prefs)),
        BlocProvider(create: (_) => MyTripCubit(TripPlannerService())),
        BlocProvider(create: (_) => ThemeCubit(prefs)),
        BlocProvider(create: (_) => LanguageCubit(prefs)),
      ],
      child: BlocBuilder<LanguageCubit, AppLanguage>(
        builder: (context, language) => BlocBuilder<ThemeCubit, ThemeMode>(
          builder: (context, themeMode) => MaterialApp(
            onGenerateTitle: (context) => context.l10n.appTitle,
            locale: language.locale,
            localizationsDelegates: appLocalizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            theme: AppTheme.lightFor(language),
            darkTheme: AppTheme.darkFor(language),
            themeMode: themeMode,
            debugShowCheckedModeBanner: false,
            // The default for screens without an app bar. Screens over a photo
            // set their own, and this brings the status bar back when they are left.
            builder: (context, child) => AnnotatedRegion<SystemUiOverlayStyle>(
              value: AppTheme.statusBarFor(context),
              child: child!,
            ),
            home: onboardingCompleted ? const SplashScreen() : const OnboardingScreen(),
          ),
        ),
      ),
    );
  }
}
