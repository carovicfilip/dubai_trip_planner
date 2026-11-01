import 'package:dubai_trip_planner/core/constants/app_palette.dart';
import 'package:dubai_trip_planner/features/my_trip/models/trip_plan.dart';
import 'package:dubai_trip_planner/features/my_trip/ui/widgets/day_card.dart';
import 'package:dubai_trip_planner/l10n/l10n.dart';
import 'package:material_ui/material_ui.dart';

/// All the days of a plan at a glance, to jump to one of them.
class DayGrid extends StatelessWidget {
  const DayGrid({
    super.key,
    required this.days,
    required this.dateOf,
    required this.currentDay,
    required this.onTapDay,
  });

  final List<DailyPlan> days;
  final String Function(int day) dateOf;
  final int currentDay;
  final ValueChanged<int> onTapDay;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        mainAxisExtent: 156,
      ),
      itemCount: days.length,
      itemBuilder: (context, index) => _DayTile(
        number: index + 1,
        day: days[index],
        date: dateOf(index),
        isCurrent: index == currentDay,
        onTap: () => onTapDay(index),
      ),
    );
  }
}

class _DayTile extends StatelessWidget {
  const _DayTile({
    required this.number,
    required this.day,
    required this.date,
    required this.isCurrent,
    required this.onTap,
  });

  // "Day 2: " at the start of a title, in whatever language the plan is in.
  static final _dayPrefix = RegExp(r'^[^:：\n]*\d+\s*[:：]\s*');

  final int number;
  final DailyPlan day;
  final String date;
  final bool isCurrent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final label = context.l10n.planDayTitle(number);
    final theme = day.title.replaceFirst(_dayPrefix, '');
    final total = day.highlights.length;
    final isFinished = day.isFinished;

    return Material(
      color: isFinished ? palette.successSurface : palette.card,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(
          color: isCurrent
              ? palette.accent
              : (isFinished ? palette.success.withValues(alpha: 0.35) : palette.hairline),
          width: isCurrent ? 1.5 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      label,
                      style: TextStyle(color: palette.ink, fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                  ),
                  if (isFinished) Icon(Icons.check_circle_rounded, size: 18, color: palette.success),
                ],
              ),
              const SizedBox(height: 2),
              Text(date, style: TextStyle(color: palette.muted, fontSize: 11)),
              const SizedBox(height: 8),
              Expanded(
                child: theme == label
                    ? const SizedBox.shrink()
                    : Text(
                        theme,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        textDirection: textDirectionOf(day),
                        style: TextStyle(color: palette.ink, fontSize: 13, height: 1.3),
                      ),
              ),
              if (total > 0) ...[
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: day.doneCount / total,
                    minHeight: 3,
                    color: isFinished ? palette.success : palette.accent,
                    backgroundColor: palette.tile,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
