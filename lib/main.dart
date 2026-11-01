import 'package:dubai_trip_planner/features/favorites/cubit/favorites_cubit.dart';
import 'package:dubai_trip_planner/features/my_trip/cubit/my_trip_cubit.dart';
import 'package:dubai_trip_planner/features/my_trip/services/trip_planner_service.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'app/theme/app_theme.dart';
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
      ],
      child: MaterialApp(
        title: 'Dubai Trip Planner',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        // The default for screens without an app bar. Screens over a photo set
        // their own, and this brings the status bar back when they are left.
        builder: (context, child) => AnnotatedRegion<SystemUiOverlayStyle>(
          value: AppTheme.statusBarOnLight,
          child: child!,
        ),
        home: onboardingCompleted ? const SplashScreen() : const OnboardingScreen(),
      ),
    );
  }
}
