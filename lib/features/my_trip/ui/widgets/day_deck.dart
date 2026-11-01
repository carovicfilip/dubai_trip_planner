import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

/// The days as a deck of cards: the current one on top, the next ones peeking
/// out behind it. It only ever moves when the user moves it.
class DayDeck extends StatelessWidget {
  const DayDeck({
    super.key,
    required this.position,
    required this.dayCount,
    required this.currentDay,
    required this.canSwipe,
    required this.onDragUpdate,
    required this.onDragEnd,
    required this.onDragCancel,
    required this.cardBuilder,
  });

  /// How many cards behind the top one are drawn.
  static const _depth = 3;
  static const _startInset = 16.0;

  // Leaves room for the cards peeking out at the end of the line.
  static const _endInset = 40.0;

  /// Where the deck is, in cards: 1.5 is halfway from the second to the third.
  final Animation<double> position;
  final int dayCount;
  final int currentDay;

  /// Off while the items of a card are being moved.
  final bool canSwipe;

  /// How far the deck was dragged, in cards.
  final ValueChanged<double> onDragUpdate;

  /// How fast it was let go, in cards per second.
  final ValueChanged<double> onDragEnd;
  final VoidCallback onDragCancel;
  final IndexedWidgetBuilder cardBuilder;

  @override
  Widget build(BuildContext context) {
    if (dayCount == 0) return const SizedBox.shrink();

    // The next day lies to the left in a language written right to left.
    final side = Directionality.of(context) == TextDirection.rtl ? -1.0 : 1.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = constraints.maxWidth - _startInset - _endInset;

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onHorizontalDragUpdate: canSwipe ? (details) => onDragUpdate(-side * details.primaryDelta! / cardWidth) : null,
          onHorizontalDragEnd: canSwipe ? (details) => onDragEnd(-side * (details.primaryVelocity ?? 0) / cardWidth) : null,
          onHorizontalDragCancel: canSwipe ? onDragCancel : null,
          child: AnimatedBuilder(
            animation: position,
            builder: (context, _) {
              final page = position.value;
              final first = page.floor().clamp(0, dayCount - 1);
              final last = math.min(first + _depth, dayCount - 1);

              return Stack(
                clipBehavior: Clip.none,
                children: [
                  // The farthest first, as the last one drawn ends up on top.
                  for (var day = last; day >= first; day--)
                    PositionedDirectional(
                      key: ValueKey(day),
                      start: _startInset,
                      width: cardWidth,
                      top: 0,
                      bottom: 0,
                      child: _PlacedCard(
                        distance: day - page,
                        cardWidth: cardWidth,
                        side: side,
                        isOnTop: day == currentDay && (day - page).abs() < 0.01,
                        child: RepaintBoundary(child: cardBuilder(context, day)),
                      ),
                    ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

/// A card where it belongs in the deck, for its [distance] from the top: behind
/// it for more than 0, on its way off the screen for less than 0.
class _PlacedCard extends StatelessWidget {
  const _PlacedCard({
    required this.distance,
    required this.cardWidth,
    required this.side,
    required this.isOnTop,
    required this.child,
  });

  final double distance;
  final double cardWidth;

  /// 1 when the next card lies to the right, -1 when it lies to the left.
  final double side;
  final bool isOnTop;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final card = ExcludeSemantics(
      excluding: !isOnTop,
      child: IgnorePointer(ignoring: !isOnTop, child: child),
    );

    if (distance < 0) {
      return Transform.translate(
        offset: Offset(side * distance * (cardWidth + 48), 0),
        child: Transform.rotate(angle: side * distance * 0.12, child: card),
      );
    }

    final opacity = (DayDeck._depth - distance).clamp(0.0, 1.0);
    return Transform.translate(
      offset: Offset(side * distance * (cardWidth * 0.025 + 12), 0),
      child: Transform.rotate(
        angle: side * distance * 0.012,
        child: Transform.scale(
          scale: 1 - 0.05 * distance,
          child: opacity < 1 ? Opacity(opacity: opacity, child: card) : card,
        ),
      ),
    );
  }
}
