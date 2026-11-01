import 'package:dubai_trip_planner/core/constants/app_palette.dart';
import 'package:dubai_trip_planner/core/repositories/category_repository.dart';
import 'package:dubai_trip_planner/core/widgets/category_icon.dart';
import 'package:dubai_trip_planner/core/widgets/glass_card.dart';
import 'package:dubai_trip_planner/features/categories/ui/categories_screen.dart';
import 'package:dubai_trip_planner/l10n/l10n.dart';
import 'package:material_ui/material_ui.dart';

class CategorySection extends StatelessWidget {
  const CategorySection({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = CategoryRepository.allCategories;
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.categoriesTitle, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 14),
        GlassCard(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          radius: 32,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: categories.map((category) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CategoryScreen(selectedCategory: category),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Column(
                      children: [
                        Container(
                          width: 68,
                          height: 68,
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: context.palette.tile,
                          ),
                          child: CategoryIcon(category.iconPath),
                        ),
                        const SizedBox(height: 10),
                        Text(l10n.categoryName(category.id), style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}
