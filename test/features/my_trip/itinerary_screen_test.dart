import 'package:dubai_trip_planner/features/my_trip/models/trip_plan.dart';
import 'package:dubai_trip_planner/features/my_trip/ui/itinerary_screen.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TripPlan planStarting(DateTime start, int days) => TripPlan(
        location: 'Downtown Dubai',
        startDate: start,
        lengthInDays: days,
        categories: const ['Attractions', 'Restaurants', 'Shopping', 'Rooftops'],
        days: [
          for (var i = 1; i <= days; i++)
            DailyPlan(title: 'Day $i: Theme', highlights: ['Morning: activity $i']),
        ],
      );

  Future<void> pumpItinerary(WidgetTester tester, TripPlan plan) async {
    // Large surface on purpose: the test font draws every glyph 1em wide, far
    // wider than Poppins, so phone-size layout is checked on a real device.
    tester.view.physicalSize = const Size(800 * 3, 4000 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(home: ItineraryScreen(plan: plan)));
  }

  testWidgets('shows the overview and one card per day', (tester) async {
    await pumpItinerary(tester, planStarting(DateTime(2026, 11, 10), 3));

    expect(find.text('3-day stay in Downtown Dubai'), findsOneWidget);
    expect(find.text('Attractions, Restaurants, Shopping…'), findsOneWidget);
    for (var i = 1; i <= 3; i++) {
      expect(find.text('Day $i: Theme'), findsOneWidget);
      expect(find.text('Morning: activity $i'), findsOneWidget);
    }
  });

  // Regression test for DST time zones such as Europe/Belgrade: adding
  // Duration(days: n) to local midnight landed on 23:00 of the previous day
  // after the clocks went back (25 Oct 2026), so a date repeated.
  testWidgets('day dates stay consecutive across the end of daylight saving time', (tester) async {
    await pumpItinerary(tester, planStarting(DateTime(2026, 10, 23), 5));

    for (final day in [23, 24, 25, 26, 27]) {
      expect(find.text('October $day, 2026'), findsOneWidget, reason: 'expected exactly one card dated October $day');
    }
    expect(find.text('October 23, 2026 – October 27, 2026'), findsOneWidget);
  });
}
