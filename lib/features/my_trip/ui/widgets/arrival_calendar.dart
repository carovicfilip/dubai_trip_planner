import 'package:dubai_trip_planner/core/constants/app_palette.dart';
import 'package:material_ui/material_ui.dart';

/// An always open calendar for picking the day of arrival, which also marks the
/// rest of the stay. Swipe it or use its arrows to change the month.
class ArrivalCalendar extends StatefulWidget {
  const ArrivalCalendar({
    super.key,
    required this.firstDate,
    required this.lastDate,
    required this.selected,
    required this.stayDays,
    required this.onSelected,
  });

  final DateTime firstDate;
  final DateTime lastDate;
  final DateTime? selected;

  /// How long the stay is, once that has been chosen.
  final int? stayDays;
  final ValueChanged<DateTime> onSelected;

  @override
  State<ArrivalCalendar> createState() => _ArrivalCalendarState();
}

class _ArrivalCalendarState extends State<ArrivalCalendar> {
  static const _rowHeight = 36.0;

  // Every month gets as many rows as the longest, so what is below it stays put.
  static const _rows = 6;

  late final PageController _pages;
  late int _page;

  int get _lastPage => DateUtils.monthDelta(widget.firstDate, widget.lastDate);

  int _pageOf(DateTime date) => DateUtils.monthDelta(widget.firstDate, date).clamp(0, _lastPage);

  DateTime _monthOf(int page) => DateUtils.addMonthsToMonthDate(widget.firstDate, page);

  @override
  void initState() {
    super.initState();
    final selected = widget.selected;
    _page = selected == null ? 0 : _pageOf(selected);
    _pages = PageController(initialPage: _page);
  }

  @override
  void didUpdateWidget(ArrivalCalendar oldWidget) {
    super.didUpdateWidget(oldWidget);
    // A saved plan can fill in the date after the calendar has opened.
    final selected = widget.selected;
    if (selected != null && selected != oldWidget.selected && _pageOf(selected) != _page) {
      final page = _pageOf(selected);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _pages.hasClients) _pages.jumpToPage(page);
      });
    }
  }

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  void _goTo(int page) {
    _pages.animateToPage(page, duration: const Duration(milliseconds: 300), curve: Curves.easeOutCubic);
  }

  @override
  Widget build(BuildContext context) {
    final localizations = MaterialLocalizations.of(context);
    final palette = context.palette;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            _MonthArrow(
              icon: Icons.chevron_left,
              tooltip: localizations.previousMonthTooltip,
              onPressed: _page > 0 ? () => _goTo(_page - 1) : null,
            ),
            Expanded(
              child: Text(
                localizations.formatMonthYear(_monthOf(_page)),
                textAlign: TextAlign.center,
                style: TextStyle(color: palette.ink, fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
            _MonthArrow(
              icon: Icons.chevron_right,
              tooltip: localizations.nextMonthTooltip,
              onPressed: _page < _lastPage ? () => _goTo(_page + 1) : null,
            ),
          ],
        ),
        const SizedBox(height: 2),
        ExcludeSemantics(
          child: Row(
            children: [
              for (var column = 0; column < DateTime.daysPerWeek; column++)
                Expanded(
                  child: Text(
                    localizations.narrowWeekdays[(localizations.firstDayOfWeekIndex + column) % DateTime.daysPerWeek],
                    textAlign: TextAlign.center,
                    style: TextStyle(color: palette.muted, fontSize: 12),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        SizedBox(
          height: _rowHeight * _rows,
          child: PageView.builder(
            controller: _pages,
            itemCount: _lastPage + 1,
            onPageChanged: (page) => setState(() => _page = page),
            itemBuilder: (context, page) => _buildMonth(localizations, _monthOf(page)),
          ),
        ),
      ],
    );
  }

  Widget _buildMonth(MaterialLocalizations localizations, DateTime month) {
    final firstDayOffset = DateUtils.firstDayOffset(month.year, month.month, localizations);
    final daysInMonth = DateUtils.getDaysInMonth(month.year, month.month);
    final today = DateUtils.dateOnly(DateTime.now());
    final selected = widget.selected;
    final stayDays = widget.stayDays;
    final arrival = selected == null ? null : DateUtils.dateOnly(selected);
    final lastDay = arrival == null || stayDays == null ? null : DateUtils.addDaysToDate(arrival, stayDays - 1);

    return Column(
      children: [
        for (var row = 0; row < _rows; row++)
          SizedBox(
            height: _rowHeight,
            child: Row(
              children: [
                for (var column = 0; column < DateTime.daysPerWeek; column++)
                  Expanded(
                    child: Builder(
                      builder: (context) {
                        final day = row * DateTime.daysPerWeek + column - firstDayOffset + 1;
                        if (day < 1 || day > daysInMonth) return const SizedBox();

                        final date = DateTime(month.year, month.month, day);
                        return _DayCell(
                          date: date,
                          isEnabled: !date.isBefore(widget.firstDate) && !date.isAfter(widget.lastDate),
                          isToday: date == today,
                          arrival: arrival,
                          lastDay: lastDay,
                          roundsStart: column == 0,
                          roundsEnd: column == DateTime.daysPerWeek - 1,
                          onTap: () => widget.onSelected(date),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

class _MonthArrow extends StatelessWidget {
  const _MonthArrow({required this.icon, required this.tooltip, required this.onPressed});

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return IconButton(
      icon: Icon(icon),
      tooltip: tooltip,
      iconSize: 24,
      color: palette.ink,
      disabledColor: palette.muted.withValues(alpha: 0.35),
      visualDensity: VisualDensity.compact,
      onPressed: onPressed,
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.date,
    required this.isEnabled,
    required this.isToday,
    required this.arrival,
    required this.lastDay,
    required this.roundsStart,
    required this.roundsEnd,
    required this.onTap,
  });

  final DateTime date;
  final bool isEnabled;
  final bool isToday;
  final DateTime? arrival;
  final DateTime? lastDay;

  /// Whether the band of the stay ends here, at the edge of the week.
  final bool roundsStart;
  final bool roundsEnd;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final arrival = this.arrival;
    final lastDay = this.lastDay;
    final isArrival = date == arrival;
    final isLastDay = date == lastDay;
    final isInStay = arrival != null && lastDay != null && !date.isBefore(arrival) && !date.isAfter(lastDay);
    final palette = context.palette;
    final stayColor = palette.accent.withValues(alpha: 0.1);
    const bandEnd = Radius.circular(16);

    final Color textColor;
    if (isArrival) {
      textColor = palette.onAccent;
    } else if (isEnabled) {
      textColor = palette.ink;
    } else {
      textColor = palette.muted.withValues(alpha: 0.5);
    }

    return Semantics(
      button: true,
      enabled: isEnabled,
      selected: isArrival,
      label: MaterialLocalizations.of(context).formatFullDate(date),
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: isEnabled ? onTap : null,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // The band across the days of the stay, ending under the first and last.
            if (isInStay)
              Positioned.fill(
                top: 2,
                bottom: 2,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: isArrival
                          ? const SizedBox()
                          : DecoratedBox(
                              decoration: BoxDecoration(
                                color: stayColor,
                                borderRadius: BorderRadiusDirectional.horizontal(start: roundsStart ? bandEnd : Radius.zero),
                              ),
                            ),
                    ),
                    Expanded(
                      child: isLastDay
                          ? const SizedBox()
                          : DecoratedBox(
                              decoration: BoxDecoration(
                                color: stayColor,
                                borderRadius: BorderRadiusDirectional.horizontal(end: roundsEnd ? bandEnd : Radius.zero),
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 32,
              height: 32,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isArrival ? palette.accent : (isLastDay ? stayColor : Colors.transparent),
                border: isToday && !isArrival ? Border.all(color: palette.accent.withValues(alpha: 0.45)) : null,
              ),
              child: Text('${date.day}', style: TextStyle(color: textColor, fontSize: 14)),
            ),
          ],
        ),
      ),
    );
  }
}
