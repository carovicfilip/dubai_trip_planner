import 'package:dubai_trip_planner/core/constants/app_color.dart';
import 'package:material_ui/material_ui.dart';

/// The colors that change between the light and the dark theme. The screens
/// made of a full photo (onboarding, splash, details) look the same in both
/// and use [AppColors].
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.surface,
    required this.pageGradient,
    required this.card,
    required this.tile,
    required this.hairline,
    required this.ink,
    required this.muted,
    required this.accent,
    required this.onAccent,
    required this.heroCard,
    required this.success,
    required this.successSurface,
  });

  final Color surface;
  final List<Color> pageGradient;
  final Color card;
  final Color tile;
  final Color hairline;
  final Color ink;
  final Color muted;

  /// The one strong color: buttons and selected items.
  final Color accent;
  final Color onAccent;

  /// The dark card of a saved trip plan, dark in both themes.
  final Color heroCard;

  /// Something finished: a checked item, and a card with all of its items checked.
  final Color success;
  final Color successSurface;

  static const light = AppPalette(
    surface: Color(0xFFF7F8FA),
    pageGradient: [Color(0xFFFFFFFF), Color(0xFFF7F8FA), Color(0xFFEEF1F5)],
    card: Colors.white,
    tile: Color(0xFFF1F3F6),
    hairline: Color(0xFFE6E9EE),
    ink: AppColors.darkNavy,
    muted: Color(0xFF6B7480),
    accent: AppColors.darkNavy,
    onAccent: Colors.white,
    heroCard: AppColors.darkNavy,
    success: Color(0xFF1F9D63),
    successSurface: Color(0xFFE5F6EC),
  );

  static const dark = AppPalette(
    surface: Color(0xFF0E1620),
    pageGradient: [Color(0xFF17222F), Color(0xFF101923), Color(0xFF0B121A)],
    card: Color(0xFF1A2532),
    tile: Color(0xFF263242),
    hairline: Color(0xFF2D3949),
    ink: Color(0xFFF4F6F8),
    muted: Color(0xFFA3AEBA),
    accent: Colors.white,
    onAccent: AppColors.darkNavy,
    heroCard: Color(0xFF223040),
    success: Color(0xFF3CCB8A),
    successSurface: Color(0xFF17382C),
  );

  @override
  AppPalette copyWith({
    Color? surface,
    List<Color>? pageGradient,
    Color? card,
    Color? tile,
    Color? hairline,
    Color? ink,
    Color? muted,
    Color? accent,
    Color? onAccent,
    Color? heroCard,
    Color? success,
    Color? successSurface,
  }) {
    return AppPalette(
      surface: surface ?? this.surface,
      pageGradient: pageGradient ?? this.pageGradient,
      card: card ?? this.card,
      tile: tile ?? this.tile,
      hairline: hairline ?? this.hairline,
      ink: ink ?? this.ink,
      muted: muted ?? this.muted,
      accent: accent ?? this.accent,
      onAccent: onAccent ?? this.onAccent,
      heroCard: heroCard ?? this.heroCard,
      success: success ?? this.success,
      successSurface: successSurface ?? this.successSurface,
    );
  }

  /// Lets the colors change smoothly when the theme is switched.
  @override
  AppPalette lerp(AppPalette? other, double t) {
    if (other == null) return this;
    return AppPalette(
      surface: Color.lerp(surface, other.surface, t)!,
      pageGradient: [
        for (var i = 0; i < pageGradient.length; i++) Color.lerp(pageGradient[i], other.pageGradient[i], t)!,
      ],
      card: Color.lerp(card, other.card, t)!,
      tile: Color.lerp(tile, other.tile, t)!,
      hairline: Color.lerp(hairline, other.hairline, t)!,
      ink: Color.lerp(ink, other.ink, t)!,
      muted: Color.lerp(muted, other.muted, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      onAccent: Color.lerp(onAccent, other.onAccent, t)!,
      heroCard: Color.lerp(heroCard, other.heroCard, t)!,
      success: Color.lerp(success, other.success, t)!,
      successSurface: Color.lerp(successSurface, other.successSurface, t)!,
    );
  }
}

extension AppPaletteOf on BuildContext {
  /// The palette of the current theme.
  AppPalette get palette => Theme.of(this).extension<AppPalette>() ?? AppPalette.light;
}
