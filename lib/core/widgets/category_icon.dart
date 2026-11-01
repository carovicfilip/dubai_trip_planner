import 'package:dubai_trip_planner/core/constants/app_palette.dart';
import 'package:material_ui/material_ui.dart';

/// A category's icon: one color in the light theme, its own colors in the dark.
class CategoryIcon extends StatelessWidget {
  const CategoryIcon(this.path, {super.key, this.size});

  final String path;
  final double? size;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Image.asset(
      path,
      width: size,
      height: size,
      fit: BoxFit.contain,
      color: isDark ? null : context.palette.ink,
      colorBlendMode: isDark ? null : BlendMode.srcIn,
    );
  }
}
