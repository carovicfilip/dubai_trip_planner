import 'dart:async';
import 'dart:ui' show ImageFilter, lerpDouble;

import 'package:dubai_trip_planner/core/models/place.dart';
import 'package:dubai_trip_planner/core/repositories/place_repository.dart';
import 'package:dubai_trip_planner/core/widgets/place_image.dart';
import 'package:dubai_trip_planner/features/explore/ui/widgets/popular_place_card.dart';
import 'package:dubai_trip_planner/features/place_details/ui/place_details_screen.dart';
import 'package:dubai_trip_planner/l10n/l10n.dart';
import 'package:material_ui/material_ui.dart';

/// The most popular places as a carousel: a large card in the middle between
/// two smaller ones. The cards change every [_holdTime] and can be swiped.
class MostPopularSection extends StatefulWidget {
  const MostPopularSection({super.key});

  @override
  State<MostPopularSection> createState() => _MostPopularSectionState();
}

class _MostPopularSectionState extends State<MostPopularSection> {
  static const _holdTime = Duration(seconds: 5);
  static const _centerSize = Size(PopularPlaceCard.fullWidth, 225);
  static const _sideSize = Size(84, 125);
  static const _gap = 12.0;
  static const _height = 255.0;

  final List<Place> _places = PlaceRepository.getFeaturedPlaces().take(5).toList(growable: false);

  // An endless list of empty pages only turns swipes into a position; the
  // cards are drawn from that position, because their sizes and gaps differ.
  // It starts far from page 0 so it can be swiped back as well.
  late final PageController _pages = PageController(
    initialPage: _places.length * 1000,
    viewportFraction: 0.4,
  );
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _restartTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pages.dispose();
    super.dispose();
  }

  void _restartTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(_holdTime, (_) => _showNextCard());
  }

  void _showNextCard() {
    if (MediaQuery.disableAnimationsOf(context)) return;
    // Someone is holding the carousel, or the screen is covered and the last
    // change is still waiting to run.
    if (!_pages.hasClients || _pages.position.isScrollingNotifier.value) return;
    _moveBy(1);
  }

  void _moveBy(int cards) {
    final target = _page.round() + cards;
    _pages.animateToPage(target, duration: const Duration(milliseconds: 600), curve: Curves.easeInOutCubic);
  }

  // In Arabic the page view runs from right to left, and the cards with it.
  bool get _isRtl => Directionality.of(context) == TextDirection.rtl;

  double get _page => _pages.hasClients ? _pages.page ?? _pages.initialPage.toDouble() : _pages.initialPage.toDouble();

  Place get _centerPlace => _places[_page.round() % _places.length];

  void _openCenterCard() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PlaceDetailsScreen(place: _centerPlace)),
    );
  }

  /// The swipe layer lies over the cards, so a tap is matched to them by where
  /// it lands: the card in the middle opens, a side card moves to the middle.
  void _handleTap(Offset position, double width) {
    final x = position.dx - width / 2;
    final y = (position.dy - _height / 2).abs();
    if (x.abs() <= _centerSize.width / 2) {
      if (y <= _centerSize.height / 2) _openCenterCard();
    } else if (y <= _sideSize.height / 2) {
      _moveBy(x.isNegative != _isRtl ? -1 : 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(context.l10n.mostPopularTitle, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        SizedBox(
          height: _height,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return GestureDetector(
                onTapUp: (details) => _handleTap(details.localPosition, constraints.maxWidth),
                child: Stack(
                  clipBehavior: Clip.none,
                  fit: StackFit.expand,
                  children: [
                    AnimatedBuilder(
                      animation: _pages,
                      builder: (context, _) => _buildCards(),
                    ),
                    PageView.builder(
                      controller: _pages,
                      onPageChanged: (_) => _restartTimer(),
                      itemBuilder: (_, _) => const SizedBox.expand(),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCards() {
    final center = _page.round();
    final shift = _page - center;

    return Semantics(
      button: true,
      label: context.l10n.placeText(_centerPlace).name,
      onTap: _openCenterCard,
      child: ExcludeSemantics(
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            // The middle card comes last, over the glow of the others.
            for (final offset in const [-2, 2, -1, 1, 0])
              _buildCard(_places[(center + offset) % _places.length], offset - shift),
          ],
        ),
      ),
    );
  }

  /// [position] is 0 for the card in the middle, -1 and 1 for the cards beside
  /// it; further out they fade away.
  Widget _buildCard(Place place, double position) {
    final distance = position.abs();
    final toSide = distance.clamp(0.0, 1.0);
    final step = (_centerSize.width + _sideSize.width) / 2 + _gap;
    final x = distance <= 1 ? distance * step : step + (distance - 1) * (_sideSize.width + _gap);
    final width = lerpDouble(_centerSize.width, _sideSize.width, toSide)!;
    final height = lerpDouble(_centerSize.height, _sideSize.height, toSide)!;
    final focus = (1 - toSide * 2).clamp(0.0, 1.0);

    return Transform.translate(
      key: ValueKey(place.id),
      offset: Offset(position.isNegative != _isRtl ? -x : x, 0),
      child: Opacity(
        opacity: (2 - distance).clamp(0.0, 1.0),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            // A soft glow in the colors of the photo.
            if (focus > 0)
              Transform.translate(
                offset: const Offset(0, 12),
                child: Opacity(
                  opacity: focus * 0.45,
                  child: ImageFiltered(
                    imageFilter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(26),
                      child: SizedBox(width: width * 0.94, height: height * 0.94, child: PlaceImage(place.imageUrl)),
                    ),
                  ),
                ),
              ),
            SizedBox(
              width: width,
              height: height,
              child: PopularPlaceCard(place: place, focus: focus),
            ),
          ],
        ),
      ),
    );
  }
}
