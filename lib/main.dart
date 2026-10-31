import 'package:dubai_trip_planner/features/favorites/cubit/favorites_cubit.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'app/theme/app_theme.dart';
import 'features/splash/ui/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  final prefs = await SharedPreferences.getInstance();
  runApp(MyApp(prefs: prefs));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.prefs});

  final SharedPreferences prefs;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => FavoritesCubit(prefs),
      child: MaterialApp(
        title: 'Dubai Trip Planner',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        home: SplashScreen(),
      ),
    );
  }
}
