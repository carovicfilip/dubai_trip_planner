import 'dart:math' as math;

import 'package:dubai_trip_planner/app/theme/app_theme.dart';
import 'package:dubai_trip_planner/core/constants/app_palette.dart';
import 'package:dubai_trip_planner/core/widgets/glass_card.dart';
import 'package:dubai_trip_planner/features/my_trip/cubit/my_trip_cubit.dart';
import 'package:dubai_trip_planner/features/my_trip/ui/trip_labels.dart';
import 'package:dubai_trip_planner/features/my_trip/ui/widgets/day_card.dart';
import 'package:dubai_trip_planner/features/my_trip/ui/widgets/day_deck.dart';
import 'package:dubai_trip_planner/features/my_trip/ui/widgets/day_grid.dart';
import 'package:dubai_trip_planner/features/my_trip/ui/widgets/trip_form_button.dart';
import 'package:dubai_trip_planner/features/my_trip/ui/widgets/trip_photo_header.dart';
import 'package:dubai_trip_planner/l10n/l10n.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:intl/intl.dart';

import '../models/trip_plan.dart';

/// A plan, day by day, as a deck of cards or a grid of them. What the user
/// changes here is kept in the saved plan.
class ItineraryScreen extends StatefulWidget {
  const ItineraryScreen({
    super.key,
    required this.plan,
  });

  final TripPlan plan;

  @override
  State<ItineraryScreen> createState() => _ItineraryScreenState();
}

class _ItineraryScreenState extends State<ItineraryScreen> with SingleTickerProviderStateMixin {
  late TripPlan _plan = widget.plan;

  // Where the deck is, in cards. It may go a little past both ends while dragged.
  late final AnimationController _deck = AnimationController.unbounded(vsync: this);
  int _currentDay = 0;
  bool _showsGrid = false;
  bool _isEditing = false;

  int get _lastDay => math.max(_plan.days.length - 1, 0);

  @override
  void dispose() {
    _deck.dispose();
    super.dispose();
  }

  void _goToDay(int day) {
    setState(() {
      _currentDay = day;
      _isEditing = false;
    });
    if (MediaQuery.disableAnimationsOf(context)) {
      _deck.value = day.toDouble();
      return;
    }
    // Longer the farther it goes, so the cards can be seen going by.
    final distance = (day - _deck.value).abs();
    _deck.animateTo(
      day.toDouble(),
      duration: Duration(milliseconds: (240 + 110 * distance).clamp(240, 1000).round()),
      curve: Curves.easeOutCubic,
    );
  }

  void _dragDeck(double cards) {
    final next = _deck.value + cards;
    // Resists being pulled past the first and the last card.
    final isPastEnd = next < 0 || next > _lastDay;
    _deck.value = (isPastEnd ? _deck.value + cards * 0.3 : next).clamp(-0.3, _lastDay + 0.3);
  }

  void _settleDeck(double cardsPerSecond) {
    var day = _deck.value.round();
    if (cardsPerSecond.abs() > 0.6) day = _currentDay + (cardsPerSecond > 0 ? 1 : -1);
    _goToDay(day.clamp(0, _lastDay));
  }

  void _showInDeck(int day) {
    setState(() => _showsGrid = false);
    _goToDay(day);
  }

  void _updateDay(int index, DailyPlan day) {
    setState(() => _plan = _plan.withDay(index, day));
    context.read<MyTripCubit>().updateSavedPlan(_plan);
  }

  void _deleteItem(int dayIndex, int itemIndex) {
    final day = _plan.days[dayIndex];
    final text = day.highlights[itemIndex];
    final wasDone = day.isDone(itemIndex);
    _updateDay(dayIndex, day.withoutItem(itemIndex));

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(context.l10n.itineraryItemRemoved),
          persist: false,
          action: SnackBarAction(
            label: context.l10n.itineraryUndo,
            onPressed: () {
              if (!mounted) return;
              final current = _plan.days[dayIndex];
              final position = math.min(itemIndex, current.highlights.length);
              _updateDay(dayIndex, current.withItemInserted(position, text, isDone: wasDone));
            },
          ),
        ),
      );
  }

  Future<void> _addItem(int dayIndex) async {
    final text = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: context.palette.card,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (_) => _AddItemSheet(dayNumber: dayIndex + 1),
    );
    if (text == null || !mounted) return;

    final day = _plan.days[dayIndex];
    _updateDay(dayIndex, day.withItemInserted(day.highlights.length, text));
  }

  // Calendar arithmetic on purpose: adding Duration(days: n) to a local midnight
  // lands on 23:00 of the previous day once the clocks go back, repeating a date.
  String _dateOf(int day) {
    return DateFormat.yMMMMd(context.l10n.localeName).format(DateUtils.addDaysToDate(_plan.startDate, day));
  }

  Widget _buildDeck() {
    return Column(
      key: const ValueKey('deck'),
      children: [
        Expanded(
          child: DayDeck(
            position: _deck,
            dayCount: _plan.days.length,
            currentDay: _currentDay,
            canSwipe: !_isEditing,
            onDragUpdate: _dragDeck,
            onDragEnd: _settleDeck,
            onDragCancel: () => _goToDay(_currentDay),
            cardBuilder: (context, index) => DayCard(
              day: _plan.days[index],
              date: _dateOf(index),
              isEditing: _isEditing && index == _currentDay,
              onToggleEditing: () => setState(() => _isEditing = !_isEditing),
              onToggleItem: (item) => _updateDay(index, _plan.days[index].withItemToggled(item)),
              onDeleteItem: (item) => _deleteItem(index, item),
              onMoveItem: (from, to) => _updateDay(index, _plan.days[index].withItemMoved(from, to)),
              onAddItem: () => _addItem(index),
            ),
          ),
        ),
        _DayPager(
          day: _currentDay,
          dayCount: _plan.days.length,
          onGoToDay: _goToDay,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppTheme.statusBarOnDark,
      child: Scaffold(
        backgroundColor: palette.surface,
        body: Stack(
          fit: StackFit.expand,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: palette.pageGradient,
                ),
              ),
            ),
            const TripPhoto(image: 'assets/images/trip_step_1.webp', alignment: Alignment(0, 0.71)),
            SafeArea(
              child: Column(
                children: [
                  TripTopBar(
                    title: context.l10n.itineraryTitle,
                    onBack: () => Navigator.maybePop(context),
                    trailing: _ViewToggle(
                      showsGrid: _showsGrid,
                      onPressed: () => setState(() {
                        _showsGrid = !_showsGrid;
                        _isEditing = false;
                      }),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 28, 16, 12),
                    child: _TripOverview(plan: _plan, dateOf: _dateOf),
                  ),
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: _showsGrid
                          ? DayGrid(
                              key: const ValueKey('grid'),
                              days: _plan.days,
                              dateOf: _dateOf,
                              currentDay: _currentDay,
                              onTapDay: _showInDeck,
                            )
                          : _buildDeck(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Switches between the deck and the grid, in the style of the back button.
class _ViewToggle extends StatelessWidget {
  const _ViewToggle({required this.showsGrid, required this.onPressed});

  final bool showsGrid;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      tooltip: showsGrid ? context.l10n.itineraryShowDeck : context.l10n.itineraryShowGrid,
      icon: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(color: Colors.black45, borderRadius: BorderRadius.circular(20)),
        child: Icon(showsGrid ? Icons.style : Icons.grid_view_rounded, color: Colors.white, size: 24),
      ),
    );
  }
}

class _TripOverview extends StatelessWidget {
  const _TripOverview({required this.plan, required this.dateOf});

  final TripPlan plan;
  final String Function(int day) dateOf;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final l10n = context.l10n;
    final totalDays = plan.days.length;
    final categoryPreview = plan.categories.take(3).map(l10n.interestLabel).join(l10n.listSeparator);
    final hasMore = plan.categories.length > 3;
    final detailStyle = TextStyle(color: palette.muted, fontSize: 12, height: 1.4);

    return GlassCard(
      width: double.infinity,
      radius: 24,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.itineraryStay(totalDays, l10n.areaLabel(plan.location)),
            style: TextStyle(color: palette.ink, fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 2),
          Text('${dateOf(0)} – ${dateOf(math.max(totalDays - 1, 0))}', style: detailStyle),
          Text(
            hasMore ? '$categoryPreview…' : categoryPreview,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: detailStyle,
          ),
        ],
      ),
    );
  }
}

class _DayPager extends StatelessWidget {
  const _DayPager({required this.day, required this.dayCount, required this.onGoToDay});

  final int day;
  final int dayCount;
  final ValueChanged<int> onGoToDay;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: day > 0 ? () => onGoToDay(day - 1) : null,
            tooltip: l10n.itineraryPreviousDay,
            color: palette.ink,
            icon: const Icon(Icons.chevron_left),
          ),
          SizedBox(
            width: 110,
            child: Text(
              l10n.itineraryDayOf(day + 1, dayCount),
              textAlign: TextAlign.center,
              style: TextStyle(color: palette.ink, fontSize: 14),
            ),
          ),
          IconButton(
            onPressed: day < dayCount - 1 ? () => onGoToDay(day + 1) : null,
            tooltip: l10n.itineraryNextDay,
            color: palette.ink,
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }
}

class _AddItemSheet extends StatefulWidget {
  const _AddItemSheet({required this.dayNumber});

  final int dayNumber;

  @override
  State<_AddItemSheet> createState() => _AddItemSheetState();
}

class _AddItemSheetState extends State<_AddItemSheet> {
  static const _maxLength = 200;

  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _add() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) Navigator.pop(context, text);
  }

  OutlineInputBorder _border(Color color) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(20),
      borderSide: BorderSide(color: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final l10n = context.l10n;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 20, 16, MediaQuery.viewInsetsOf(context).bottom + 16),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.itineraryAddTitle(widget.dayNumber),
              textAlign: TextAlign.center,
              style: TextStyle(color: palette.ink, fontSize: 20),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _controller,
              autofocus: true,
              minLines: 1,
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
              textInputAction: TextInputAction.done,
              cursorColor: palette.ink,
              inputFormatters: [LengthLimitingTextInputFormatter(_maxLength)],
              onChanged: (_) => setState(() {}),
              onSubmitted: (_) => _add(),
              style: TextStyle(color: palette.ink, fontSize: 16),
              decoration: InputDecoration(
                hintText: l10n.itineraryAddHint,
                hintStyle: TextStyle(color: palette.muted),
                filled: true,
                fillColor: palette.tile,
                border: _border(palette.hairline),
                enabledBorder: _border(palette.hairline),
                focusedBorder: _border(palette.accent),
              ),
            ),
            const SizedBox(height: 14),
            TripFormButton(
              label: l10n.itineraryAdd,
              icon: Icons.add_rounded,
              onPressed: _controller.text.trim().isEmpty ? null : _add,
            ),
          ],
        ),
      ),
    );
  }
}
