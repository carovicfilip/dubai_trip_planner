import 'package:dubai_trip_planner/core/constants/app_palette.dart';
import 'package:dubai_trip_planner/core/models/category.dart';
import 'package:dubai_trip_planner/core/models/place.dart';
import 'package:dubai_trip_planner/core/repositories/category_repository.dart';
import 'package:dubai_trip_planner/core/repositories/place_repository.dart';
import 'package:dubai_trip_planner/core/widgets/category_icon.dart';
import 'package:dubai_trip_planner/core/widgets/custom_back_button.dart';
import 'package:dubai_trip_planner/core/widgets/frosted_app_bar.dart';
import 'package:dubai_trip_planner/core/widgets/place_photo_card.dart';
import 'package:dubai_trip_planner/features/favorites/cubit/favorites_cubit.dart';
import 'package:dubai_trip_planner/features/place_details/ui/place_details_screen.dart';
import 'package:dubai_trip_planner/l10n/l10n.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class CategoryScreen extends StatefulWidget {
  final Category? selectedCategory;

  const CategoryScreen({super.key, this.selectedCategory});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final ItemScrollController _itemScrollController = ItemScrollController();
  final ItemPositionsListener _itemPositionsListener = ItemPositionsListener.create();

  late final List<Category> categories;

  @override
  void initState() {
    super.initState();
    categories = CategoryRepository.allCategories;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final sel = widget.selectedCategory;
      if (sel == null) return;

      final selectedIndex = CategoryRepository.getCategoryIndex(sel);
      if (selectedIndex == -1) return;
      if (!_itemScrollController.isAttached) return;

      // 👉 Za prve dve kategorije (index 0 i 1) – ne skroluj / ne centriraj
      if (selectedIndex < 2) return;

      // 👉 Za ostale – centriraj
      _itemScrollController.scrollTo(
        index: selectedIndex,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
        alignment: 0.5, // centar ekrana
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final l10n = context.l10n;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: FrostedAppBar(
        title: l10n.categoriesScreenTitle,
        // 👇 Ako postoji selectedCategory, prikaži custom back btn
        leading: widget.selectedCategory != null
            ? const CustomBackButton()
            : null, // 👈 ako je root ekran, nema back dugmeta
      ),
      body: ScrollablePositionedList.builder(
        itemScrollController: _itemScrollController,
        itemPositionsListener: _itemPositionsListener,
        padding: EdgeInsets.fromLTRB(10, FrostedAppBar.heightOn(context) + 10, 10, 10),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final List<Place> places = PlaceRepository.getPlacesByCategory(category.id);
          final favoritesState = context.watch<FavoritesCubit>().state;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header reda sa ikonom i imenom kategorije
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: palette.card,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: palette.hairline),
                ),
                child: Row(
                  children: [
                    CategoryIcon(category.iconPath, size: 40),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Text(
                        l10n.categoryName(category.id),
                        style: TextStyle(
                          fontSize: 18,
                          color: palette.ink,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                // A little more than the cards, to leave room for their shadow.
                height: PlacePhotoCard.compactHeight + 14,
                child: places.isEmpty
                    ? Center(child: Text(l10n.categoryEmpty))
                    : ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.only(bottom: 14),
                        itemCount: places.length,
                        itemBuilder: (context, placeIndex) {
                          final place = places[placeIndex];
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => PlaceDetailsScreen(place: place),
                                ),
                              );
                            },
                            child: PlacePhotoCard(
                              compact: true,
                              place: place,
                              isFavorite: favoritesState.isFavorite(place.id),
                              onFavoriteToggle: () =>
                                  context.read<FavoritesCubit>().toggleFavorite(place),
                            ),
                          );
                        },
                      ),
              ),
              const SizedBox(height: 30),
            ],
          );
        },
      ),
    );
  }
}
