import 'package:dubai_trip_planner/features/my_trip/models/trip_plan.dart';
import 'package:dubai_trip_planner/features/my_trip/services/trip_plan_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  final plan = TripPlan(
    location: 'Jumeirah Beach Residence',
    startDate: DateTime(2026, 12, 20),
    lengthInDays: 2,
    categories: const ['Beaches', 'Rooftops'],
    days: const [
      DailyPlan(title: 'Day 1: JBR — The Walk', highlights: ['Morning: Swim', 'Evening: Ain Dubai']),
      DailyPlan(title: 'Day 2: Marina', highlights: ['Afternoon: Dhow cruise']),
    ],
  );

  void expectSamePlan(TripPlan actual, TripPlan expected) {
    expect(actual.location, expected.location);
    expect(actual.startDate, expected.startDate);
    expect(actual.lengthInDays, expected.lengthInDays);
    expect(actual.categories, expected.categories);
    expect(actual.days.map((d) => d.title), expected.days.map((d) => d.title));
    expect(actual.days.map((d) => d.highlights), expected.days.map((d) => d.highlights));
  }

  test('serialize/deserialize round-trips every field', () {
    expectSamePlan(TripPlan.deserialize(plan.serialize()), plan);
  });

  group('TripPlanStorage', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    test('returns null when nothing was saved', () async {
      expect(await TripPlanStorage.loadPlan(), isNull);
    });

    test('saves and loads the latest plan', () async {
      await TripPlanStorage.savePlan(plan);
      expectSamePlan((await TripPlanStorage.loadPlan())!, plan);
    });

    test('clear() removes the saved plan', () async {
      await TripPlanStorage.savePlan(plan);
      await TripPlanStorage.clear();
      expect(await TripPlanStorage.loadPlan(), isNull);
    });

    test('drops a corrupt saved plan instead of crashing', () async {
      SharedPreferences.setMockInitialValues({'recent_trip_plan': '{not json'});

      expect(await TripPlanStorage.loadPlan(), isNull);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.containsKey('recent_trip_plan'), isFalse);
    });
  });
}
