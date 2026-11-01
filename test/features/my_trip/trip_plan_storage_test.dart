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
      DailyPlan(
        title: 'Day 1: JBR — The Walk',
        area: 'JBR & Dubai Marina',
        highlights: ['Morning: Swim\nGetting there: 5 min walk', 'Evening: Ain Dubai'],
      ),
      DailyPlan(title: 'Day 2: Marina', highlights: ['Afternoon: Dhow cruise']),
    ],
  );

  void expectSamePlan(TripPlan actual, TripPlan expected) {
    expect(actual.location, expected.location);
    expect(actual.startDate, expected.startDate);
    expect(actual.lengthInDays, expected.lengthInDays);
    expect(actual.categories, expected.categories);
    expect(actual.days.map((d) => d.title), expected.days.map((d) => d.title));
    expect(actual.days.map((d) => d.area), expected.days.map((d) => d.area));
    expect(actual.days.map((d) => d.highlights), expected.days.map((d) => d.highlights));
  }

  test('serialize/deserialize round-trips every field', () {
    expectSamePlan(TripPlan.deserialize(plan.serialize()), plan);
  });

  group('the items of a day', () {
    const day = DailyPlan(title: 'Day 1', highlights: ['A', 'B', 'C']);

    test('nothing is checked off at first, also in a plan saved before this existed', () {
      expect(day.doneCount, 0);
      expect(day.isDone(0), isFalse);
      expect(day.toJson().containsKey('done'), isFalse, reason: 'saved plans stay as they were');

      final old = DailyPlan.fromJson({'title': 'Day 1', 'highlights': ['A', 'B']});
      expect(old.isDone(1), isFalse);
      expect(old.highlights, ['A', 'B']);
    });

    test('checking off goes both ways and survives saving', () {
      final checked = day.withItemToggled(1);
      expect(checked.isDone(1), isTrue);
      expect(checked.doneCount, 1);
      expect(checked.withItemToggled(1).doneCount, 0);

      final restored = DailyPlan.fromJson(checked.toJson());
      expect(restored.isDone(0), isFalse);
      expect(restored.isDone(1), isTrue);
      expect(restored.isDone(2), isFalse);
    });

    test('moving an item keeps it checked off, in both directions', () {
      final checked = day.withItemToggled(0);

      final down = checked.withItemMoved(0, 2);
      expect(down.highlights, ['B', 'C', 'A']);
      expect(down.isDone(2), isTrue);
      expect(down.isDone(0), isFalse);

      final up = down.withItemMoved(2, 1);
      expect(up.highlights, ['B', 'A', 'C']);
      expect(up.isDone(1), isTrue);
    });

    test('deleting an item keeps the others checked off as they were', () {
      final checked = day.withItemToggled(2);

      final fewer = checked.withoutItem(0);

      expect(fewer.highlights, ['B', 'C']);
      expect(fewer.isDone(1), isTrue);
      expect(fewer.doneCount, 1);
    });

    test('an item can be added at any position, checked off or not', () {
      final checked = day.withItemToggled(1);

      final atEnd = checked.withItemInserted(3, 'D');
      expect(atEnd.highlights, ['A', 'B', 'C', 'D']);
      expect(atEnd.isDone(3), isFalse);

      final atStart = checked.withItemInserted(0, 'Z', isDone: true);
      expect(atStart.highlights, ['Z', 'A', 'B', 'C']);
      expect(atStart.isDone(0), isTrue);
      expect(atStart.isDone(2), isTrue);
    });

    test('the original day stays as it was', () {
      day.withItemToggled(0);
      day.withoutItem(0);
      day.withItemMoved(0, 1);
      expect(day.highlights, ['A', 'B', 'C']);
      expect(day.doneCount, 0);
    });

    test('changing one day of a plan leaves the rest of it alone', () {
      final plan = TripPlan(
        location: 'JBR',
        startDate: DateTime(2026, 12, 1),
        lengthInDays: 2,
        categories: const ['Spas'],
        days: const [day, DailyPlan(title: 'Day 2', highlights: ['X'])],
      );

      final changed = plan.withDay(1, plan.days[1].withItemToggled(0));

      expect(changed.days[1].isDone(0), isTrue);
      expect(changed.days[0], same(day));
      expect(changed.location, 'JBR');
      expect(plan.days[1].isDone(0), isFalse);
    });
  });

  test('loads a plan saved before days had an area', () {
    const saved = '{"location":"Business Bay","startDate":"2026-12-20T00:00:00.000","lengthInDays":1,'
        '"categories":["Spas"],"days":[{"title":"Day 1: Spa day","highlights":["Morning: Spa"]}]}';

    final day = TripPlan.deserialize(saved).days.single;

    expect(day.title, 'Day 1: Spa day');
    expect(day.area, isNull);
    expect(day.highlights, ['Morning: Spa']);
  });

  group('TripPlanStorage', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    final other = TripPlan(
      location: 'JBR',
      startDate: DateTime(2027, 1, 5),
      lengthInDays: 1,
      categories: const ['Spas'],
      days: const [
        DailyPlan(title: 'Day 1', highlights: ['Morning: Spa']),
      ],
    );

    test('has no plans when nothing was saved', () async {
      expect(await TripPlanStorage.loadPlans(), isEmpty);
    });

    test('keeps several plans, in their order', () async {
      await TripPlanStorage.savePlans([other, plan]);

      final saved = await TripPlanStorage.loadPlans();

      expect(saved, hasLength(2));
      expectSamePlan(saved[0], other);
      expectSamePlan(saved[1], plan);
    });

    test('saving no plans removes them', () async {
      await TripPlanStorage.savePlans([plan]);
      await TripPlanStorage.savePlans([]);

      expect(await TripPlanStorage.loadPlans(), isEmpty);
    });

    test('takes over the one plan that was kept before there could be several', () async {
      SharedPreferences.setMockInitialValues({'recent_trip_plan': plan.serialize()});

      expectSamePlan((await TripPlanStorage.loadPlans()).single, plan);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.containsKey('recent_trip_plan'), isFalse);
      expectSamePlan((await TripPlanStorage.loadPlans()).single, plan);
    });

    test('that old plan joins the newer ones, once', () async {
      SharedPreferences.setMockInitialValues({
        'recent_trip_plan': plan.serialize(),
        'trip_plans': [other.serialize(), plan.serialize()],
      });

      final saved = await TripPlanStorage.loadPlans();

      expect(saved.map((trip) => trip.location), ['JBR', plan.location]);
    });

    test('drops a corrupt old plan instead of crashing', () async {
      SharedPreferences.setMockInitialValues({'recent_trip_plan': '{not json'});

      expect(await TripPlanStorage.loadPlans(), isEmpty);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.containsKey('recent_trip_plan'), isFalse);
    });

    test('a corrupt plan does not take the others with it', () async {
      SharedPreferences.setMockInitialValues({
        'trip_plans': ['{not json', other.serialize()],
      });

      expectSamePlan((await TripPlanStorage.loadPlans()).single, other);
    });
  });
}
