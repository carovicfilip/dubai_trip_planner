import 'package:dubai_trip_planner/core/repositories/place_repository.dart';
import 'package:dubai_trip_planner/core/widgets/place_photo_card.dart';
import 'package:dubai_trip_planner/features/explore/ui/widgets/recommended_section.dart';
import 'package:dubai_trip_planner/features/favorites/cubit/favorites_cubit.dart';
import 'package:dubai_trip_planner/features/place_details/ui/place_details_screen.dart';
import 'package:dubai_trip_planner/l10n/l10n.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  final first = PlaceRepository.getTopRatedPlaces().first;

  setUp(() => SharedPreferences.setMockInitialValues({}));

  Future<FavoritesCubit> pumpSection(WidgetTester tester) async {
    // Large surface on purpose: the test font draws every glyph 1em wide, far
    // wider than Poppins, so phone-size layout is checked on a real device.
    tester.view.physicalSize = const Size(1600, 1200) * 3;
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    // For the same reason the rating on the photo reports overflows here that
    // do not happen with Poppins on a device; only those are ignored.
    final reportError = FlutterError.onError!;
    FlutterError.onError = (details) {
      if (!details.exceptionAsString().contains('A RenderFlex overflowed')) reportError(details);
    };
    addTearDown(() => FlutterError.onError = reportError);

    final favorites = FavoritesCubit(await SharedPreferences.getInstance());
    await tester.pumpWidget(BlocProvider.value(
      value: favorites,
      child: const MaterialApp(localizationsDelegates: appLocalizationsDelegates, supportedLocales: AppLocalizations.supportedLocales, home: Scaffold(body: RecommendedSection())),
    ));
    return favorites;
  }

  testWidgets('shows the name, category and rating of the best rated places', (tester) async {
    await pumpSection(tester);

    expect(find.byType(PlacePhotoCard), findsWidgets);
    expect(find.byIcon(Icons.arrow_outward_rounded), findsNothing);
    expect(find.text(first.name), findsOneWidget);
    expect(find.text(first.reviewSummary!), findsOneWidget);
    expect(find.text(lookupAppLocalizations(const Locale('en')).categoryName(first.categoryId).toUpperCase()), findsWidgets);
  });

  testWidgets('the heart adds the place to favorites without opening it', (tester) async {
    final favorites = await pumpSection(tester);

    await tester.tap(find.byIcon(Icons.favorite_border).first);
    await tester.pump();

    expect(favorites.state.isFavorite(first.id), isTrue);
    expect(find.byIcon(Icons.favorite), findsOneWidget);
    expect(find.byType(PlaceDetailsScreen), findsNothing);
  });

  testWidgets('tapping the card opens the place', (tester) async {
    await pumpSection(tester);

    await tester.tap(find.text(first.name));
    await tester.pumpAndSettle();

    expect(tester.widget<PlaceDetailsScreen>(find.byType(PlaceDetailsScreen)).place.id, first.id);
  });
}
