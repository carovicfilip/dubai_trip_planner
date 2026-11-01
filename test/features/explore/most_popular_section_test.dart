import 'package:dubai_trip_planner/core/repositories/place_repository.dart';
import 'package:dubai_trip_planner/features/explore/ui/widgets/most_popular_section.dart';
import 'package:dubai_trip_planner/features/explore/ui/widgets/popular_place_card.dart';
import 'package:dubai_trip_planner/features/favorites/cubit/favorites_cubit.dart';
import 'package:dubai_trip_planner/features/place_details/ui/place_details_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  final places = PlaceRepository.getFeaturedPlaces().take(5).map((place) => place.name).toList();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  Future<void> pumpDeck(WidgetTester tester, {bool disableAnimations = false}) async {
    tester.view.physicalSize = const Size(800, 1600) * 3;
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(BlocProvider(
      create: (_) => FavoritesCubit(prefs),
      child: MediaQuery(
        data: MediaQueryData(size: const Size(800, 1600), disableAnimations: disableAnimations),
        child: const MaterialApp(home: Scaffold(body: MostPopularSection())),
      ),
    ));
  }

  Finder deck() => find.byType(PageView);

  /// The place on the card in the middle: tapping it opens that place's details.
  Future<String> frontPlace(WidgetTester tester) async {
    await tester.tapAt(tester.getCenter(deck()));
    await tester.pumpAndSettle();
    final name = tester.widget<PlaceDetailsScreen>(find.byType(PlaceDetailsScreen)).place.name;
    await tester.tap(find.byIcon(Icons.arrow_back_ios_new));
    await tester.pumpAndSettle();
    return name;
  }

  Future<void> swipe(WidgetTester tester, double dx) async {
    await tester.fling(deck(), Offset(dx, 0), 1000);
    await tester.pumpAndSettle();
  }

  testWidgets('shows a large card in the middle between two smaller ones, without numbers', (tester) async {
    await pumpDeck(tester);

    final cards = find.byType(PopularPlaceCard);
    final middle = tester.getRect(cards.last);
    expect(middle.size, const Size(190, 225));

    final byName = {
      for (final element in cards.evaluate())
        (element.widget as PopularPlaceCard).place.name: tester.getRect(find.byWidget(element.widget)),
    };
    final next = byName[places[1]]!;
    final previous = byName[places.last]!;
    expect(next.size, const Size(84, 125));
    expect(previous.size, const Size(84, 125));
    expect(previous.right, lessThan(middle.left), reason: 'the previous card is on the left, with a gap');
    expect(next.left, greaterThan(middle.right), reason: 'the next card is on the right, with a gap');

    for (var number = 1; number <= 5; number++) {
      expect(find.text('$number'), findsNothing);
    }
    expect(await frontPlace(tester), places[0]);
  });

  testWidgets('tapping a side card brings it to the middle', (tester) async {
    await pumpDeck(tester);
    final cards = find.byType(PopularPlaceCard);
    final middle = tester.getRect(cards.last);

    await tester.tapAt(middle.centerRight + const Offset(50, 0));
    await tester.pumpAndSettle();
    expect(await frontPlace(tester), places[1]);

    await tester.tapAt(middle.centerLeft - const Offset(50, 0));
    await tester.pumpAndSettle();
    expect(await frontPlace(tester), places[0]);
  });

  testWidgets('the card in the middle changes every 5 seconds', (tester) async {
    await pumpDeck(tester);

    await tester.pump(const Duration(milliseconds: 4900));
    await tester.pump(const Duration(milliseconds: 50));
    expect(await frontPlace(tester), places[0], reason: 'still the first card just before 5 seconds');

    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 700));
    expect(await frontPlace(tester), places[1]);
  });

  testWidgets('after the last card comes the first one again', (tester) async {
    await pumpDeck(tester);

    for (var i = 0; i < places.length; i++) {
      await swipe(tester, -200);
    }

    expect(await frontPlace(tester), places[0]);
  });

  testWidgets('can be swiped both ways, also back from the first card', (tester) async {
    await pumpDeck(tester);

    await swipe(tester, -200);
    expect(await frontPlace(tester), places[1]);

    await swipe(tester, 200);
    await swipe(tester, 200);
    expect(await frontPlace(tester), places.last);
  });

  testWidgets('a swipe restarts the 5 seconds', (tester) async {
    await pumpDeck(tester);

    await tester.pump(const Duration(seconds: 4));
    await swipe(tester, -200);
    await tester.pump(const Duration(seconds: 3));
    await tester.pump(const Duration(milliseconds: 700));

    expect(await frontPlace(tester), places[1], reason: 'the 4 seconds before the swipe no longer count');
  });

  testWidgets('does not change by itself when the system asks for less motion', (tester) async {
    await pumpDeck(tester, disableAnimations: true);

    await tester.pump(const Duration(seconds: 6));
    await tester.pump(const Duration(milliseconds: 700));
    expect(await frontPlace(tester), places[0]);

    await swipe(tester, -200);
    expect(await frontPlace(tester), places[1], reason: 'swiping still works');
  });

  testWidgets('a tap beside the cards opens nothing', (tester) async {
    await pumpDeck(tester);

    await tester.tapAt(tester.getTopLeft(deck()) + const Offset(10, 6));
    await tester.pumpAndSettle();

    expect(find.byType(PlaceDetailsScreen), findsNothing);
  });
}
