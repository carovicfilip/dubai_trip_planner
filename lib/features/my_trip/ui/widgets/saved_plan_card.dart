import 'package:dubai_trip_planner/core/constants/app_color.dart';
import 'package:dubai_trip_planner/core/constants/app_palette.dart';
import 'package:dubai_trip_planner/features/my_trip/models/trip_plan.dart';
import 'package:dubai_trip_planner/features/my_trip/ui/trip_labels.dart';
import 'package:dubai_trip_planner/features/my_trip/ui/widgets/trip_form_button.dart';
import 'package:dubai_trip_planner/l10n/l10n.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

/// The saved plans. When there are several, they scroll sideways with the next
/// one peeking in.
class SavedPlansStrip extends StatelessWidget {
  const SavedPlansStrip({super.key, required this.plans, required this.onOpen, required this.onDelete});

  final List<TripPlan> plans;
  final ValueChanged<TripPlan> onOpen;
  final Future<void> Function(TripPlan plan) onDelete;

  Widget _card(TripPlan plan) {
    return SavedPlanCard(
      key: ValueKey(plan.id),
      plan: plan,
      onTap: () => onOpen(plan),
      onDelete: () => onDelete(plan),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (plans.length == 1) return _card(plans.single);

    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        // The cards run on to the edge of the screen, past the padding of the page.
        clipBehavior: Clip.none,
        child: IntrinsicHeight(
          child: Row(
            spacing: 10,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final plan in plans) SizedBox(width: constraints.maxWidth * 0.86, child: _card(plan)),
            ],
          ),
        ),
      ),
    );
  }
}

/// A saved plan: tap to open it. The button deletes it, as a swipe would scroll.
class SavedPlanCard extends StatelessWidget {
  const SavedPlanCard({super.key, required this.plan, required this.onTap, required this.onDelete});

  static const _radius = 28.0;
  static const _borderWidth = 1.5;

  final TripPlan plan;
  final VoidCallback onTap;
  final Future<void> Function() onDelete;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final l10n = context.l10n;
    final date = DateFormat.yMMMMd(l10n.localeName).format(plan.startDate);

    return GestureDetector(
      onTap: onTap,
      // A border in a gradient: the colors show around a card just smaller than them.
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(_radius),
          gradient: TripFormButton.gradient,
          boxShadow: [
            BoxShadow(
              color: AppColors.darkNavy.withValues(alpha: 0.05),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(_borderWidth),
          child: Container(
            padding: const EdgeInsetsDirectional.fromSTEB(14, 12, 4, 12),
            decoration: BoxDecoration(
              color: palette.card,
              borderRadius: BorderRadius.circular(_radius - _borderWidth),
            ),
            child: Row(
              children: [
                Icon(Icons.auto_awesome, color: palette.ink, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.savedPlanTitle, style: TextStyle(color: palette.muted, fontSize: 11)),
                      Text(
                        l10n.areaLabel(plan.location),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: palette.ink, fontSize: 15, fontWeight: FontWeight.w600),
                      ),
                      Text(
                        '$date · ${l10n.tripDays(plan.lengthInDays)}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: palette.muted, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: onDelete,
                  tooltip: l10n.delete,
                  color: palette.muted,
                  icon: const Icon(Icons.delete_outline_rounded),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
