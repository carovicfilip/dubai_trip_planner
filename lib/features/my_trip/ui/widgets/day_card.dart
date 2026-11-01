import 'package:dubai_trip_planner/core/constants/app_color.dart';
import 'package:dubai_trip_planner/core/constants/app_palette.dart';
import 'package:dubai_trip_planner/features/my_trip/models/trip_plan.dart';
import 'package:dubai_trip_planner/l10n/l10n.dart';
import 'package:intl/intl.dart' show Bidi;
import 'package:material_ui/material_ui.dart';

/// A plan stays in the language it was written in, also after the app has
/// changed to another, so a day can run the other way than the screen around it.
TextDirection textDirectionOf(DailyPlan day) =>
    Bidi.detectRtlDirectionality([day.title, ...day.highlights].join(' ')) ? TextDirection.rtl : TextDirection.ltr;

/// One day of a plan: what there is to do, to check off along the way. While
/// editing, the items can be moved and deleted instead.
class DayCard extends StatelessWidget {
  const DayCard({
    super.key,
    required this.day,
    required this.date,
    required this.isEditing,
    required this.onToggleEditing,
    required this.onToggleItem,
    required this.onDeleteItem,
    required this.onMoveItem,
    required this.onAddItem,
  });

  static const _radius = 28.0;

  final DailyPlan day;
  final String date;
  final bool isEditing;
  final VoidCallback onToggleEditing;
  final ValueChanged<int> onToggleItem;
  final ValueChanged<int> onDeleteItem;
  final void Function(int from, int to) onMoveItem;
  final VoidCallback onAddItem;

  /// Items have no ids, and the same text can be there twice.
  List<Key> _itemKeys() {
    final seen = <String, int>{};
    return [
      for (final text in day.highlights) ValueKey('$text#${seen[text] = (seen[text] ?? 0) + 1}'),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final l10n = context.l10n;
    final appDirection = Directionality.of(context);
    final area = day.area;
    final items = day.highlights;
    final keys = _itemKeys();
    final surface = day.isFinished ? palette.successSurface : palette.card;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(_radius),
        boxShadow: [
          BoxShadow(color: AppColors.darkNavy.withValues(alpha: 0.12), blurRadius: 24, offset: const Offset(0, 10)),
        ],
      ),
      child: Material(
        color: surface,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_radius),
          side: BorderSide(color: day.isFinished ? palette.success.withValues(alpha: 0.35) : palette.hairline),
        ),
        child: Directionality(
          textDirection: textDirectionOf(day),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 14, 8, 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(date, textDirection: appDirection, style: TextStyle(color: palette.muted, fontSize: 12)),
                          const SizedBox(height: 2),
                          Text(day.title, style: TextStyle(color: palette.ink, fontSize: 20, height: 1.2)),
                          if (area != null) ...[
                            const SizedBox(height: 4),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.location_on_outlined, size: 16, color: palette.muted),
                                const SizedBox(width: 4),
                                Expanded(child: Text(area, style: TextStyle(color: palette.muted, fontSize: 13))),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: onToggleEditing,
                      tooltip: isEditing ? l10n.itineraryDoneEditing : l10n.itineraryEditDay,
                      icon: Icon(isEditing ? Icons.check_rounded : Icons.edit_outlined, size: 20),
                      style: IconButton.styleFrom(
                        foregroundColor: isEditing ? palette.onAccent : palette.ink,
                        backgroundColor: isEditing ? palette.accent : palette.tile,
                      ),
                    ),
                  ],
                ),
              ),
              if (items.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 10, 18, 2),
                  child: _DayProgress(done: day.doneCount, total: items.length, textDirection: appDirection),
                ),
              Expanded(
                child: items.isEmpty
                    ? Center(
                        child: Text(
                          l10n.itineraryEmptyDay,
                          textAlign: TextAlign.center,
                          textDirection: appDirection,
                          style: TextStyle(color: palette.muted, fontSize: 14),
                        ),
                      )
                    : ReorderableListView.builder(
                        buildDefaultDragHandles: false,
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        itemCount: items.length,
                        onReorderItem: onMoveItem,
                        proxyDecorator: (child, _, _) => Material(
                          color: surface,
                          elevation: 4,
                          borderRadius: BorderRadius.circular(16),
                          child: child,
                        ),
                        itemBuilder: (context, index) => _ItemRow(
                          key: keys[index],
                          index: index,
                          text: items[index],
                          isDone: day.isDone(index),
                          isEditing: isEditing,
                          onToggle: () => onToggleItem(index),
                          onDelete: () => onDeleteItem(index),
                        ),
                      ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
                child: TextButton.icon(
                  onPressed: onAddItem,
                  icon: const Icon(Icons.add_rounded, size: 20),
                  label: Text(l10n.itineraryAddToDay, textDirection: appDirection),
                  style: TextButton.styleFrom(
                    backgroundColor: palette.tile,
                    foregroundColor: palette.ink,
                    minimumSize: const Size.fromHeight(46),
                    shape: const StadiumBorder(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DayProgress extends StatelessWidget {
  const _DayProgress({required this.done, required this.total, required this.textDirection});

  final int done;
  final int total;

  /// The direction of the app, as this text is in its language.
  final TextDirection textDirection;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: done / total,
              minHeight: 4,
              color: done == total ? palette.success : palette.accent,
              backgroundColor: palette.tile,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          context.l10n.itineraryDoneCount(done, total),
          textDirection: textDirection,
          style: TextStyle(color: palette.muted, fontSize: 12),
        ),
      ],
    );
  }
}

class _ItemRow extends StatelessWidget {
  const _ItemRow({
    super.key,
    required this.index,
    required this.text,
    required this.isDone,
    required this.isEditing,
    required this.onToggle,
    required this.onDelete,
  });

  final int index;
  final String text;
  final bool isDone;
  final bool isEditing;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    // Lines after the first ("Getting there: …") are a side note.
    final firstLineEnd = text.indexOf('\n');
    final main = firstLineEnd == -1 ? text : text.substring(0, firstLineEnd);
    final content = Text.rich(
      TextSpan(
        text: main,
        style: TextStyle(
          color: isDone ? palette.muted : palette.ink,
          fontSize: 14,
          height: 1.4,
          decoration: isDone ? TextDecoration.lineThrough : null,
          decorationColor: palette.muted,
        ),
        children: [
          if (firstLineEnd != -1)
            TextSpan(
              text: text.substring(firstLineEnd),
              style: TextStyle(
                color: palette.muted,
                fontSize: 13,
                height: 1.4,
                decoration: TextDecoration.none,
              ),
            ),
        ],
      ),
    );

    if (isEditing) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(6, 2, 4, 2),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ReorderableDragStartListener(
              index: index,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Icon(Icons.drag_handle_rounded, color: palette.muted, semanticLabel: context.l10n.itineraryMoveItem),
              ),
            ),
            Expanded(
              child: Padding(padding: const EdgeInsets.symmetric(vertical: 10), child: content),
            ),
            IconButton(
              onPressed: onDelete,
              tooltip: context.l10n.delete,
              color: palette.muted,
              icon: const Icon(Icons.delete_outline_rounded),
            ),
          ],
        ),
      );
    }

    return InkWell(
      onTap: onToggle,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(6, 2, 16, 2),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Checkbox(
              value: isDone,
              onChanged: (_) => onToggle(),
              semanticLabel: main,
              shape: const CircleBorder(),
              activeColor: palette.success,
              checkColor: Colors.white,
              side: BorderSide(color: palette.muted, width: 1.5),
            ),
            Expanded(
              child: Padding(padding: const EdgeInsets.symmetric(vertical: 12), child: content),
            ),
          ],
        ),
      ),
    );
  }
}
