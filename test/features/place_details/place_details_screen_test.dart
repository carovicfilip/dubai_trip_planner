import 'package:dubai_trip_planner/core/models/place.dart';
import 'package:dubai_trip_planner/core/repositories/place_repository.dart';
import 'package:dubai_trip_planner/features/favorites/cubit/favorites_cubit.dart';
import 'package:dubai_trip_planner/features/place_details/ui/place_details_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  const fullPlace = Place(
    id: 'must_see_test',
    categoryId: 'must_see',
    name: 'Test Tower',
    description: 'A very tall tower with a view.',
    imageUrl: 'assets/places_images/must_see_1.jpg',
    openingHours: 'Mon-Fri: 10:00 AM - 10:00 PM, Sat-Sun: 11:00 AM - 11:00 PM',
    location: '1 Test Boulevard, Downtown',
    reviewSummary: '4.7 (166k reviews)',
  );

  // The question about the app has its own tests.
  setUp(() => SharedPreferences.setMockInitialValues({'app_rating_asked': true}));

  /// Shows [place] on a screen [Navigator] can leave; returns the favorites.
  Future<FavoritesCubit> pumpDetails(WidgetTester tester, Place place) async {
    // Large surface on purpose: the test font draws every glyph 1em wide, far
    // wider than Poppins, so phone-size layout is checked on a real device.
    tester.view.physicalSize = const Size(800, 1600) * 3;
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    final favorites = FavoritesCubit(await SharedPreferences.getInstance());
    await tester.pumpWidget(BlocProvider.value(
      value: favorites,
      child: MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => PlaceDetailsScreen(place: place)),
              ),
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    return favorites;
  }

  testWidgets('shows everything the app knows about the place', (tester) async {
    await pumpDetails(tester, fullPlace);

    expect(find.text('Test Tower'), findsOneWidget);
    expect(find.text('MUST-SEE'), findsOneWidget);
    expect(find.text('1 Test Boulevard, Downtown'), findsOneWidget);
    expect(find.text('4.7'), findsOneWidget);
    expect(find.text('166k reviews'), findsOneWidget);
    expect(find.text('Mon-Fri: 10:00 AM - 10:00 PM\nSat-Sun: 11:00 AM - 11:00 PM'), findsOneWidget);
    expect(find.text('A very tall tower with a view.'), findsOneWidget);
  });

  testWidgets('leaves out what a place does not have', (tester) async {
    await pumpDetails(
      tester,
      const Place(
        id: 'desert_adventure_test',
        categoryId: 'desert_adventure',
        name: 'Test Dunes',
        description: 'Sand as far as you can see.',
        imageUrl: 'assets/places_images/desert_adventure_1.jpg',
      ),
    );

    expect(find.text('DESERT ADVENTURE'), findsOneWidget);
    expect(find.text('Rating'), findsNothing);
    expect(find.text('Opening hours'), findsNothing);
    expect(find.byIcon(Icons.location_on_outlined), findsNothing);
    expect(find.byType(VerticalDivider), findsNothing);
    // Named in the title and, with no address to show, next to the photo.
    expect(find.text('Test Dunes'), findsNWidgets(2));
    expect(find.text('Sand as far as you can see.'), findsOneWidget);
  });

  testWidgets('a place with only reviews or only hours shows no divider', (tester) async {
    await pumpDetails(
      tester,
      const Place(
        id: 'must_see_test',
        categoryId: 'must_see',
        name: 'Test Fountain',
        description: 'Water.',
        imageUrl: 'assets/places_images/must_see_3.jpg',
        reviewSummary: '4.8 (137k reviews)',
      ),
    );

    expect(find.text('4.8'), findsOneWidget);
    expect(find.text('Opening hours'), findsNothing);
    expect(find.byType(VerticalDivider), findsNothing);
  });

  testWidgets('the button adds the place to favorites and removes it again', (tester) async {
    final favorites = await pumpDetails(tester, fullPlace);

    await tester.tap(find.text('Add to Favorites'));
    await tester.pumpAndSettle();
    expect(favorites.state.isFavorite(fullPlace.id), isTrue);
    expect(find.text('Saved to Favorites'), findsOneWidget);
    expect(find.byIcon(Icons.favorite), findsOneWidget);

    await tester.tap(find.text('Saved to Favorites'));
    await tester.pumpAndSettle();
    expect(favorites.state.isFavorite(fullPlace.id), isFalse);
    expect(find.text('Add to Favorites'), findsOneWidget);
  });

  testWidgets('the panel scrolls over the title, which stays in place', (tester) async {
    await pumpDetails(
      tester,
      Place(
        id: 'must_see_test',
        categoryId: 'must_see',
        name: 'Test Tower',
        description: 'A long story. ' * 400,
        imageUrl: 'assets/places_images/must_see_1.jpg',
      ),
    );
    final titleBefore = tester.getTopLeft(find.text('Test Tower').first);
    final panelBefore = tester.getTopLeft(find.text('About'));

    await tester.drag(find.text('About'), const Offset(0, -300));
    await tester.pumpAndSettle();

    expect(tester.getTopLeft(find.text('Test Tower').first), titleBefore);
    expect(tester.getTopLeft(find.text('About')).dy, lessThan(panelBefore.dy));
  });

  testWidgets('the back button returns to the previous screen', (tester) async {
    await pumpDetails(tester, fullPlace);

    await tester.tap(find.byIcon(Icons.arrow_back_ios_new));
    await tester.pumpAndSettle();

    expect(find.byType(PlaceDetailsScreen), findsNothing);
    expect(find.text('Open'), findsOneWidget);
  });

  testWidgets('every place in the app fits a small phone', (tester) async {
    tester.view.physicalSize = const Size(320, 568) * 3;
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    final favorites = FavoritesCubit(await SharedPreferences.getInstance());

    for (final place in PlaceRepository.getAllPlaces()) {
      await tester.pumpWidget(BlocProvider.value(
        value: favorites,
        child: MaterialApp(home: PlaceDetailsScreen(key: ValueKey(place.id), place: place)),
      ));
      await tester.pump();
      expect(tester.takeException(), isNull, reason: place.name);
    }
  });
}
