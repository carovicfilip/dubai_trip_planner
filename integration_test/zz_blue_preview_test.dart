import 'package:dubai_trip_planner/core/repositories/place_repository.dart';
import 'package:dubai_trip_planner/features/explore/ui/explore_screen.dart';
import 'package:dubai_trip_planner/features/my_trip/ui/widgets/promo_banner.dart';
import 'package:dubai_trip_planner/features/place_details/ui/place_details_screen.dart';
import 'package:dubai_trip_planner/main.dart' as app;
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('preview', (tester) async {
    final errors = <String>{};
    final previous = FlutterError.onError;
    FlutterError.onError = (d) => errors.add(d.exceptionAsString().split('\n').first);
    Future<void> wait(int ms) async {
      final end = DateTime.now().add(Duration(milliseconds: ms));
      while (DateTime.now().isBefore(end)) {
        await tester.pump(const Duration(milliseconds: 16));
      }
    }

    Future<void> snap(String name) async {
      // ignore: avoid_print
      print('SNAP $name');
      await wait(2500);
    }

    final prefs = await SharedPreferences.getInstance();
    final userDark = prefs.getBool('dark_theme');
    await prefs.setBool('onboarding_completed', true);
    await prefs.setBool('dark_theme', false);
    await prefs.remove('app_rating_asked');
    await app.main();
    while (find.byType(ExploreScreen).evaluate().isEmpty) {
      await tester.pump(const Duration(milliseconds: 16));
    }
    await wait(700);
    final card = find.byType(PromoBanner);
    // ignore: avoid_print
    print('CARD ${tester.getTopLeft(card).dx} ${tester.getTopLeft(card).dy} ${tester.getSize(card).width} ${tester.getSize(card).height}');
    for (var i = 0; i < 8; i++) {
      await binding.takeScreenshot('frame_$i');
      await wait(1900);
    }
    await snap('real_top');
    await tester.drag(find.byType(Scrollable).first, const Offset(0, -500));
    await wait(700);
    await snap('real_scrolled');
    await tester.drag(find.byType(Scrollable).first, const Offset(0, 500));
    await wait(500);

    final place = PlaceRepository.getAllPlaces().firstWhere((p) => p.name.contains('Burj Khalifa'));
    Navigator.of(tester.element(find.byType(ExploreScreen))).push(
      MaterialPageRoute(builder: (_) => PlaceDetailsScreen(place: place)),
    );
    await wait(1700);
    final title = find.text('How do you like\nthe app so far?');
    // ignore: avoid_print
    print('RECT ${tester.getTopLeft(title).dx} ${tester.getTopLeft(title).dy} ${tester.getBottomRight(title).dx} ${tester.getBottomRight(title).dy}');
    await binding.takeScreenshot('dialog');
    await tester.tap(find.byIcon(Icons.sentiment_neutral_outlined));
    await wait(600);
    await tester.tap(find.byIcon(Icons.arrow_back_ios_new));
    await wait(900);

    await tester.tap(find.text('Profile'));
    await wait(900);
    await snap('real_profile');
    await tester.tap(find.text('Dark theme'));
    await wait(800);
    await tester.tap(find.text('Explore'));
    await wait(900);
    await snap('real_top_dark');
    await tester.drag(find.byType(Scrollable).first, const Offset(0, -500));
    await wait(700);
    await snap('real_scrolled_dark');

    await prefs.remove('app_rating_asked');
    if (userDark == null) {
      await prefs.remove('dark_theme');
    } else {
      await prefs.setBool('dark_theme', userDark);
    }
    FlutterError.onError = previous;
    // ignore: avoid_print
    print('ERRORS: $errors');
  });
}
