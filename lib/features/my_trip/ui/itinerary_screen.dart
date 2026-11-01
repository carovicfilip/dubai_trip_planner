import 'package:dubai_trip_planner/core/constants/app_palette.dart';
import 'package:dubai_trip_planner/core/widgets/frosted_app_bar.dart';
import 'package:material_ui/material_ui.dart';
import 'package:intl/intl.dart';

import '../models/trip_plan.dart';

class ItineraryScreen extends StatelessWidget {
  const ItineraryScreen({
    super.key,
    required this.plan,
  });

  final TripPlan plan;

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat.yMMMMd();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const FrostedAppBar(title: 'Plan Your Trip'),
      body: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: ListView(
            padding: EdgeInsets.only(top: FrostedAppBar.heightOn(context) + 16, bottom: 16),
            children: [
              _TripOverview(
                location: plan.location,
                startDate: plan.startDate,
                categories: plan.categories,
                totalDays: plan.days.length,
              ),
              const SizedBox(height: 16),
              ...plan.days.asMap().entries.map((entry) {
                final index = entry.key;
                final plan = entry.value;
                return _DailyPlanCard(
                  dayIndex: index,
                  plan: plan,
                  startDate: this.plan.startDate,
                  formatter: formatter,
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

class _TripOverview extends StatelessWidget {
  const _TripOverview({
    required this.location,
    required this.startDate,
    required this.categories,
    required this.totalDays,
  });

  final String location;
  final DateTime startDate;
  final List<String> categories;
  final int totalDays;

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat.yMMMMd();
    final endDate = formatter.format(_addDays(startDate, totalDays - 1));
    final categoryPreview = categories.take(3).join(', ');
    final hasMore = categories.length > 3;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.palette.heroCard,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$totalDays-day stay in $location',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.calendar_month, color: Colors.white70, size: 18),
              const SizedBox(width: 8),
              Text(
                '${formatter.format(startDate)} – $endDate',
                style: const TextStyle(color: Colors.white70),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.category, color: Colors.white70, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  hasMore ? '$categoryPreview…' : categoryPreview,
                  style: const TextStyle(color: Colors.white70),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DailyPlanCard extends StatelessWidget {
  const _DailyPlanCard({
    required this.dayIndex,
    required this.plan,
    required this.startDate,
    required this.formatter,
  });

  final int dayIndex;
  final DailyPlan plan;
  final DateTime startDate;
  final DateFormat formatter;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateLabel = formatter.format(_addDays(startDate, dayIndex));
    final area = plan.area;
    final palette = context.palette;
    final secondaryStyle = theme.textTheme.bodyMedium?.copyWith(color: palette.muted);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: palette.card,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.colorScheme.primary.withValues(alpha: 0.12),
                ),
                child: Center(
                  child: Text(
                    '${dayIndex + 1}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plan.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(dateLabel, style: secondaryStyle),
                    if (area != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.location_on_outlined, size: 18, color: palette.muted),
                          const SizedBox(width: 4),
                          Expanded(child: Text(area, style: secondaryStyle)),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...plan.highlights.map((item) {
            // Lines after the first ("Getting there: …") are a side note.
            final firstLineEnd = item.indexOf('\n');
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.check_circle_outline, size: 18, color: palette.accent),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        text: firstLineEnd == -1 ? item : item.substring(0, firstLineEnd),
                        children: [
                          if (firstLineEnd != -1)
                            TextSpan(text: item.substring(firstLineEnd), style: TextStyle(color: palette.muted)),
                        ],
                      ),
                      style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

// Calendar arithmetic on purpose: adding Duration(days: n) to a local midnight
// lands on 23:00 of the previous day once the clocks go back, repeating a date.
DateTime _addDays(DateTime date, int days) => DateTime(date.year, date.month, date.day + days);
