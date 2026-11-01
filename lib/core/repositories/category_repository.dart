import 'package:dubai_trip_planner/core/models/category.dart';

class CategoryRepository {
  const CategoryRepository._();

  static const List<Category> _categories = [
    Category(
      id: 'must_see',
      name: 'Must-See',
      iconPath: 'assets/icons/icon1.png',
    ),
    Category(
      id: 'restaurants',
      name: 'Restaurants',
      iconPath: 'assets/icons/icon2.png',
    ),
    Category(
      id: 'nightlife',
      name: 'Nightlife',
      iconPath: 'assets/icons/icon3.png',
    ),
    Category(
      id: 'beaches_pools',
      name: 'Beaches & Pools',
      iconPath: 'assets/icons/icon4.png',
    ),
    Category(
      id: 'culture_museums',
      name: 'Culture & Museums',
      iconPath: 'assets/icons/icon5.png',
    ),
    Category(
      id: 'shopping',
      name: 'Shopping',
      iconPath: 'assets/icons/icon6.png',
    ),
    Category(
      id: 'desert_adventure',
      name: 'Desert Adventure',
      iconPath: 'assets/icons/icon7.png',
    ),
    Category(
      id: 'family_fun',
      name: 'Family Fun',
      iconPath: 'assets/icons/icon8.png',
    ),
  ];

  static List<Category> get allCategories => _categories;

  static int getCategoryIndex(Category category) => _categories.indexOf(category);
}
