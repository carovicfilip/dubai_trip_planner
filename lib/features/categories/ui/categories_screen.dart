import 'package:dubai_trip_planner/core/models/category.dart';
import 'package:dubai_trip_planner/core/models/place.dart';
import 'package:dubai_trip_planner/core/repositories/place_repository.dart';
import 'package:dubai_trip_planner/core/widgets/custom_back_button.dart';
import 'package:dubai_trip_planner/features/explore/ui/widgets/places_card.dart';
import 'package:dubai_trip_planner/features/favorites/cubit/favorites_cubit.dart';
import 'package:dubai_trip_planner/features/place_details/screens/more_details_screen.dart';
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
    return Scaffold(
      appBar: AppBar(
        // 👇 Ako postoji selectedCategory, prikaži custom back btn
        leading: widget.selectedCategory != null
            ? const CustomBackButton()
            : null, // 👈 ako je root ekran, nema back dugmeta
        title: const Text(
          'Explore Categories',
          style: TextStyle(fontSize: 18, color: Colors.white),
        ),
        backgroundColor:   Color(0xFF101A26),
        shadowColor: Colors.black26,
      ),
      body: ScrollablePositionedList.builder(
        itemScrollController: _itemScrollController,
        itemPositionsListener: _itemPositionsListener,
        padding: const EdgeInsets.all(10),
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
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Image.asset(
                      category.iconPath,
                      height: 40,
                      width: 40,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      category.name,
                      style: const TextStyle(
                        fontSize: 18,
                        color: Color(0xFF101A26),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 280,
                child: places.isEmpty
                    ? const Center(child: Text('No places found for this category yet.'))
                    : ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: places.length,
                        itemBuilder: (context, placeIndex) {
                          final place = places[placeIndex];
                          return Padding(
                            padding: EdgeInsets.only(right: placeIndex == places.length - 1 ? 0 : 20),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => MoreDetailsScreen(place: place),
                                  ),
                                );
                              },
                              child: PlacesCard(
                                place: place,
                                index: placeIndex,
                                isFavorite: favoritesState.isFavorite(place.id),
                                onFavoriteToggle: () =>
                                    context.read<FavoritesCubit>().toggleFavorite(place),
                              ),
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
