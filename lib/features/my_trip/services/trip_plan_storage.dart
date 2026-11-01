import 'package:shared_preferences/shared_preferences.dart';

import '../models/trip_plan.dart';

class TripPlanStorage {
  TripPlanStorage._();

  static const _plansKey = 'trip_plans';

  // The one plan that was kept before there could be several.
  static const _oldPlanKey = 'recent_trip_plan';

  static Future<void> savePlans(List<TripPlan> plans) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_plansKey, [for (final plan in plans) plan.serialize()]);
  }

  /// The saved plans, the newest first. A plan that cannot be read is left out
  /// instead of keeping the others from opening.
  static Future<List<TripPlan>> loadPlans() async {
    final prefs = await SharedPreferences.getInstance();
    final plans = <TripPlan>[
      for (final raw in prefs.getStringList(_plansKey) ?? const <String>[]) ?_read(raw),
    ];

    final oldRaw = prefs.getString(_oldPlanKey);
    if (oldRaw != null) {
      final oldPlan = _read(oldRaw);
      if (oldPlan != null && plans.every((plan) => plan.id != oldPlan.id)) plans.add(oldPlan);
      await savePlans(plans);
      await prefs.remove(_oldPlanKey);
    }
    return plans;
  }

  static TripPlan? _read(String raw) {
    try {
      return TripPlan.deserialize(raw);
    } catch (_) {
      return null;
    }
  }
}
