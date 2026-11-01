import 'package:dubai_trip_planner/app/language/app_language.dart';
import 'package:dubai_trip_planner/app/language/language_cubit.dart';
import 'package:dubai_trip_planner/features/favorites/cubit/favorites_cubit.dart';
import 'package:dubai_trip_planner/features/my_trip/cubit/my_trip_cubit.dart';
import 'package:dubai_trip_planner/features/my_trip/services/trip_planner_service.dart';
import 'package:dubai_trip_planner/l10n/l10n.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'app/theme/app_theme.dart';
import 'app/theme/theme_cubit.dart';
import 'features/onboarding/services/onboarding_service.dart';
import 'features/onboarding/ui/onboarding_screen.dart';
import 'features/splash/ui/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  final prefs = await SharedPreferences.getInstance();
  final onboardingCompleted = await OnboardingService.isOnboardingCompleted();
  runApp(MyApp(prefs: prefs, onboardingCompleted: onboardingCompleted));
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
