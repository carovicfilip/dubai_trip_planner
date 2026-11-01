import 'package:dubai_trip_planner/app/theme/app_theme.dart';
import 'package:dubai_trip_planner/core/constants/app_palette.dart';
import 'package:dubai_trip_planner/core/repositories/place_repository.dart';
import 'package:dubai_trip_planner/core/widgets/category_icon.dart';
import 'package:dubai_trip_planner/core/widgets/place_photo_card.dart';
import 'package:dubai_trip_planner/features/categories/ui/categories_screen.dart';
import 'package:dubai_trip_planner/features/favorites/cubit/favorites_cubit.dart';
import 'package:dubai_trip_planner/features/place_details/ui/place_details_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  final first = PlaceRepository.getPlacesByCategory('must_see').first;

  setUp(() => SharedPreferences.setMockInitialValues({}));

  Future<FavoritesCubit> pumpCategories(WidgetTester tester, {ThemeData? theme}) async {
    // Large surface on purpose: the test font draws every glyph 1em wide, far
    // wider than Poppins, so phone-size layout is checked on a real device.
    tester.view.physicalSize = const Size(1600, 1600) * 3;
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    final favorites = FavoritesCubit(await SharedPreferences.getInstance());
    await tester.pumpWidget(BlocProvider.value(
      value: favorites,
      child: MaterialApp(theme: theme, home: const CategoryScreen()),
    ));
    await tester.pump();
    return favorites;
  }

  testWidgets('shows the small photo cards, without reviews or an arrow', (tester) async {
    await pumpCategories(tester);

    final card = tester.widget<PlacePhotoCard>(find.byType(PlacePhotoCard).first);
    expect(card.compact, isTrue);
    expect(find.text(first.name), findsWidgets);
    expect(find.text(first.reviewSummary!), findsNothing);
    expect(find.byIcon(Icons.star_rounded), findsNothing);
    expect(find.byIcon(Icons.arrow_outward_rounded), findsNothing);
    expect(tester.getSize(find.byType(PlacePhotoCard).first).height, PlacePhotoCard.compactHeight);
  });

  testWidgets('the heart and the card still work', (tester) async {
    final favorites = await pumpCategories(tester);

    await tester.tap(find.byIcon(Icons.favorite_border).first);
    await tester.pump();
    expect(favorites.state.isFavorite(first.id), isTrue);

    await tester.tap(find.text(first.name).first);
    await tester.pumpAndSettle();
    expect(tester.widget<PlaceDetailsScreen>(find.byType(PlaceDetailsScreen)).place.id, first.id);
  });

  group('the category icons', () {
    Image iconImage(WidgetTester tester) => tester.widget<Image>(
          find.descendant(of: find.byType(CategoryIcon).first, matching: find.byType(Image)),
        );

    testWidgets('are one color in the light theme', (tester) async {
      await pumpCategories(tester, theme: AppTheme.lightTheme);
      expect(iconImage(tester).color, AppPalette.light.ink);
    });

    testWidgets('keep their own colors in the dark theme', (tester) async {
      await pumpCategories(tester, theme: AppTheme.darkTheme);
      expect(iconImage(tester).color, isNull);
    });
  });
}
