import 'dart:ui' show ImageFilter;

import 'package:dubai_trip_planner/core/constants/app_palette.dart';
import 'package:material_ui/material_ui.dart';

/// An app bar of frosted glass. Its Scaffold sets extendBodyBehindAppBar
/// and pads the content by [heightOn], so the content scrolls on under the bar.
class FrostedAppBar extends StatelessWidget implements PreferredSizeWidget {
  const FrostedAppBar({super.key, required this.title, this.leading});

  final String title;
  final Widget? leading;

  /// How far down the content of a screen with this bar starts.
  static double heightOn(BuildContext context) => MediaQuery.paddingOf(context).top + kToolbarHeight;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return AppBar(
      leading: leading,
      title: Text(title, style: TextStyle(fontSize: 18, color: palette.ink)),
      centerTitle: true,
      foregroundColor: palette.ink,
      backgroundColor: palette.card.withValues(alpha: 0.72),
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      flexibleSpace: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}
