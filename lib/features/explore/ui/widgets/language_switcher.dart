import 'dart:math' show pi;
import 'dart:ui' show ImageFilter, lerpDouble;

import 'package:dubai_trip_planner/app/language/app_language.dart';
import 'package:dubai_trip_planner/app/language/language_cubit.dart';
import 'package:dubai_trip_planner/app/theme/app_theme.dart';
import 'package:dubai_trip_planner/core/constants/app_color.dart';
import 'package:dubai_trip_planner/core/widgets/liquid_glass_painter.dart';
import 'package:dubai_trip_planner/l10n/l10n.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:material_ui/material_ui.dart';

const _closedSize = Size(90, 40);
const _openWidth = 176.0;
const _rowHeight = 46.0;
const _bottomPadding = 6.0;
const _flagSize = 24.0;
const _flagInset = 10.0;
const _flagGap = 8.0;

/// Text keeps to these sizes however large the system font is set: the button
/// and the rows have a fixed size, for the one to grow out of the other.
const _maxTextScale = 1.2;

final _closedTint = AppColors.heroDeep.withValues(alpha: 0.28);
final _openTint = AppColors.heroDeep.withValues(alpha: 0.82);

/// The language of the app, as a flag and a code at the top of the Explore tab.
/// A tap grows it into a piece of liquid glass with the other languages.
class LanguageSwitcher extends StatelessWidget {
  const LanguageSwitcher({super.key});

  Future<void> _open(BuildContext context) async {
    final button = context.findRenderObject()! as RenderBox;
    final anchor = button.localToGlobal(Offset.zero) & button.size;
    final current = AppLanguage.of(context);
    final direction = Directionality.of(context);
    final languages = context.read<LanguageCubit>();

    final chosen = await showGeneralDialog<AppLanguage>(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black.withValues(alpha: 0.25),
      transitionDuration: MediaQuery.disableAnimationsOf(context) ? Duration.zero : const Duration(milliseconds: 300),
      // The panel moves by itself, so the route adds no transition of its own.
      transitionBuilder: (_, _, _, panel) => panel,
      // Picking Arabic turns the whole app around while the panel is closing. It
      // stays as it was, and where it was, until it is gone.
      pageBuilder: (_, animation, _) => Directionality(
        textDirection: direction,
        child: _LanguagePanel(animation: animation, anchor: anchor, current: current),
      ),
    );

    if (chosen != null && chosen != current) {
      HapticFeedback.selectionClick();
      await languages.select(chosen);
    }
  }

  @override
  Widget build(BuildContext context) {
    final language = AppLanguage.of(context);
    final radius = _closedSize.height / 2;

    return Semantics(
      button: true,
      label: context.l10n.changeLanguage,
      value: language.nativeName,
      onTap: () => _open(context),
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _open(context),
        child: MediaQuery.withClampedTextScaling(
          maxScaleFactor: _maxTextScale,
          child: SizedBox.fromSize(
            size: _closedSize,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(radius),
              child: _Glass(
                radius: radius,
                tint: _closedTint,
                child: _CurrentLanguage(language: language, opened: 0),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Glass extends StatelessWidget {
  const _Glass({required this.radius, required this.tint, required this.child});

  final double radius;
  final Color tint;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: tint,
      child: CustomPaint(painter: LiquidGlassPainter(radius: radius), child: child),
    );
  }
}

/// Grows out of the button, over it, so that the button seems to be what opens.
class _LanguagePanel extends StatelessWidget {
  const _LanguagePanel({required this.animation, required this.anchor, required this.current});

  final Animation<double> animation;

  /// Where the button is on the screen.
  final Rect anchor;
  final AppLanguage current;

  @override
  Widget build(BuildContext context) {
    final others = [
      for (final language in AppLanguage.values)
        if (language != current) language,
    ];
    final openHeight = _closedSize.height + others.length * _rowHeight + _bottomPadding;
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return MediaQuery.withClampedTextScaling(
      maxScaleFactor: _maxTextScale,
      child: Stack(
        children: [
          Positioned(
            top: anchor.top,
            left: isRtl ? anchor.left : null,
            right: isRtl ? null : MediaQuery.sizeOf(context).width - anchor.right,
            child: AnimatedBuilder(
              animation: animation,
              builder: (context, _) {
                final opened = Curves.easeOutCubic.transform(animation.value);
                final radius = lerpDouble(_closedSize.height / 2, 24, opened)!;

                return Opacity(
                  // Comes and goes right over the button, which looks the same.
                  opacity: (animation.value * 6).clamp(0.0, 1.0),
                  child: SizedBox(
                    width: lerpDouble(_closedSize.width, _openWidth, opened),
                    height: lerpDouble(_closedSize.height, openHeight, opened),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(radius),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 16 * opened, sigmaY: 16 * opened),
                        child: _Glass(
                          radius: radius,
                          tint: Color.lerp(_closedTint, _openTint, opened)!,
                          child: Material(
                            type: MaterialType.transparency,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                InkResponse(
                                  highlightShape: BoxShape.rectangle,
                                  containedInkWell: true,
                                  onTap: () => Navigator.pop(context),
                                  child: SizedBox(
                                    height: _closedSize.height,
                                    child: _CurrentLanguage(language: current, opened: opened),
                                  ),
                                ),
                                // They keep their width while the panel opens,
                                // so that their text does not wrap.
                                Expanded(
                                  child: OverflowBox(
                                    alignment: AlignmentDirectional.topStart,
                                    minWidth: _openWidth,
                                    maxWidth: _openWidth,
                                    minHeight: openHeight - _closedSize.height,
                                    maxHeight: openHeight - _closedSize.height,
                                    child: Column(
                                      children: [
                                        for (var i = 0; i < others.length; i++)
                                          _LanguageRow(
                                            language: others[i],
                                            // One after the other, from the top.
                                            visible: Interval(0.2 + i * 0.12, 0.6 + i * 0.12, curve: Curves.easeOut)
                                                .transform(animation.value),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// A flag in a circle, with a thin edge for the white and dark stripes that
/// would otherwise run into the background.
class _Flag extends StatelessWidget {
  const _Flag(this.language);

  final AppLanguage language;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _flagSize,
      height: _flagSize,
      clipBehavior: Clip.antiAlias,
      foregroundDecoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withValues(alpha: 0.55), width: 0.75),
      ),
      decoration: const BoxDecoration(shape: BoxShape.circle),
      child: SvgPicture.asset(language.flag, fit: BoxFit.cover, excludeFromSemantics: true),
    );
  }
}

/// What the button shows: the flag, the code, and an arrow. While the panel
/// opens, the code turns into the name of the language and the arrow turns over.
class _CurrentLanguage extends StatelessWidget {
  const _CurrentLanguage({required this.language, required this.opened});

  final AppLanguage language;

  /// From 0 for the button to 1 for the open panel.
  final double opened;

  @override
  Widget build(BuildContext context) {
    final style = AppTheme.textThemeFor(language).bodyMedium!.copyWith(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        );
    Widget label(String text, double opacity) => Opacity(
          opacity: opacity,
          child: Text(text, maxLines: 1, softWrap: false, overflow: TextOverflow.clip, style: style),
        );

    return Padding(
      padding: const EdgeInsetsDirectional.only(start: _flagInset, end: 6),
      child: Row(
        children: [
          _Flag(language),
          const SizedBox(width: _flagGap),
          Expanded(
            child: Stack(
              alignment: AlignmentDirectional.centerStart,
              children: [
                if (opened < 1) label(language.code.toUpperCase(), 1 - opened),
                if (opened > 0) label(language.nativeName, opened),
              ],
            ),
          ),
          Transform.rotate(
            angle: opened * pi,
            child: const Icon(Icons.keyboard_arrow_down_rounded, size: 20, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _LanguageRow extends StatelessWidget {
  const _LanguageRow({required this.language, required this.visible});

  final AppLanguage language;

  /// From 0 to 1 while it comes in.
  final double visible;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      child: Opacity(
        opacity: visible,
        child: Transform.translate(
          offset: Offset(0, 8 * (1 - visible)),
          child: InkWell(
            onTap: () => Navigator.pop(context, language),
            splashColor: Colors.white.withValues(alpha: 0.14),
            highlightColor: Colors.white.withValues(alpha: 0.08),
            child: SizedBox(
              height: _rowHeight,
              child: Padding(
                padding: const EdgeInsetsDirectional.symmetric(horizontal: _flagInset),
                child: Row(
                  children: [
                    _Flag(language),
                    const SizedBox(width: _flagGap),
                    Expanded(
                      child: Text(
                        language.nativeName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTheme.textThemeFor(language).bodyMedium!.copyWith(color: Colors.white, fontSize: 15),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
