import 'package:dubai_trip_planner/core/constants/app_palette.dart';
import 'package:dubai_trip_planner/features/my_trip/services/trip_planner_service.dart';
import 'package:dubai_trip_planner/l10n/l10n.dart';
import 'package:material_ui/material_ui.dart';

/// The numbers of days a plan can cover, all in view at once.
class StayLengthPicker extends StatelessWidget {
  const StayLengthPicker({super.key, required this.selected, required this.onSelected});

  static const _gap = 6.0;
  static const _minSize = 36.0;

  final int? selected;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final perRow = ((constraints.maxWidth + _gap) / (_minSize + _gap)).floor().clamp(5, 8);
        final size = (constraints.maxWidth - _gap * (perRow - 1)) / perRow;

        return Wrap(
          alignment: WrapAlignment.center,
          spacing: _gap,
          runSpacing: 8,
          children: [
            for (var days = 1; days <= TripPlannerService.maxTripDays; days++)
              _DaysButton(days: days, size: size, isSelected: days == selected, onTap: () => onSelected(days)),
          ],
        );
      },
    );
  }
}

class _DaysButton extends StatelessWidget {
  const _DaysButton({required this.days, required this.size, required this.isSelected, required this.onTap});

  final int days;
  final double size;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Semantics(
      button: true,
      selected: isSelected,
      label: context.l10n.tripDays(days),
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: size,
          height: size,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isSelected ? palette.accent : palette.tile,
            border: Border.all(color: isSelected ? palette.accent : palette.hairline),
          ),
          child: Text(
            '$days',
            style: TextStyle(color: isSelected ? palette.onAccent : palette.ink, fontSize: 14),
          ),
        ),
      ),
    );
  }
}
