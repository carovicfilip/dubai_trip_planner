import 'package:dubai_trip_planner/core/paywall/paywall.dart';
import 'package:dubai_trip_planner/features/my_trip/models/trip_plan.dart';
import 'package:dubai_trip_planner/features/my_trip/services/trip_plan_storage.dart';
import 'package:dubai_trip_planner/features/my_trip/services/trip_planner_service.dart';
import 'package:flutter/foundation.dart' show immutable;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'my_trip_state.dart';

/// The My Trip form and the saved plans.
///
/// Provided above the tabs: the tab bar builds My Trip from scratch on every
/// visit, and neither a plan that takes up to a minute to generate nor a
/// half-filled form may get lost when the user looks at another tab meanwhile.
class MyTripCubit extends Cubit<MyTripState> {
  MyTripCubit(this._planner) : super(const MyTripState()) {
    Paywall.subscribed.addListener(_onSubscriptionChanged);
  }

  final TripPlannerService _planner;
  Future<TripPlan>? _generating;

  static const _freePlanUsedKey = 'free_plan_used';

  @override
  Future<void> close() {
    Paywall.subscribed.removeListener(_onSubscriptionChanged);
    return super.close();
  }

  void _onSubscriptionChanged() {
    if (Paywall.subscribed.value) unlockAllPlans();
  }

  /// Shows the saved plans. The form is left as it is: it is for a new trip,
  /// and a saved one opens from its card.
  Future<void> loadSavedPlans() async {
    final plans = await TripPlanStorage.loadPlans();
    if (!isClosed) emit(state.copyWith(savedPlans: plans));
    if (Paywall.subscribed.value) await unlockAllPlans();
  }

  /// Whether a new plan needs a subscription first: the user has no
  /// subscription and has already had the one free plan.
  Future<bool> needsSubscriptionForNewPlan() async {
    if (!Paywall.locksPlans) return false;
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_freePlanUsedKey) ?? false;
  }

  /// Unlocks every saved plan, for good: called once the user subscribes.
  Future<void> unlockAllPlans() async {
    final plans = await TripPlanStorage.loadPlans();
    if (!plans.any((plan) => plan.isLocked)) return;
    final unlocked = [for (final plan in plans) plan.unlocked()];
    await TripPlanStorage.savePlans(unlocked);
    if (!isClosed) emit(state.copyWith(savedPlans: unlocked));
  }

  void selectStartDate(DateTime date) => emit(state.copyWith(startDate: date));

  void selectStayLength(int days) => emit(state.copyWith(stayLengthDays: days));

  void updateLocation(String text) => emit(state.copyWith(location: text));

  void toggleCategory(String category) {
    final categories = Set.of(state.categories);
    if (!categories.remove(category)) categories.add(category);
    emit(state.copyWith(categories: categories));
  }

  /// Goes on to the next step, once the one on screen is filled in.
  void nextStep() {
    if (state.isStepComplete && state.step < MyTripState.lastStep) emit(state.copyWith(step: state.step + 1));
  }

  void previousStep() {
    if (state.step > 0) emit(state.copyWith(step: state.step - 1));
  }

  /// Plans the trip in the form and saves the plan. Asking again while a plan
  /// is being generated returns that request instead of paying for another.
  /// The plan is written in the language of [languageCode].
  Future<TripPlan> generatePlan({String languageCode = 'en'}) =>
      _generating ??= _generate(languageCode).whenComplete(() => _generating = null);

  Future<TripPlan> _generate(String languageCode) async {
    final form = state;
    if (form.formError != null) {
      throw StateError('The form is not complete: ${form.formError}');
    }

    emit(form.copyWith(isGenerating: true));
    try {
      final generated = await _planner.generatePlan(
        startDate: form.startDate!,
        lengthInDays: form.stayLengthDays!,
        location: form.location.trim(),
        categories: form.categories.toList()..sort(),
        languageCode: languageCode,
      );
      // Without a subscription this is the one free plan, and it stays locked
      // until the user subscribes.
      final locks = Paywall.locksPlans;
      final plan = locks ? generated.locked() : generated;
      if (locks) await (await SharedPreferences.getInstance()).setBool(_freePlanUsedKey, true);
      // A new plan joins the others, unless it is for the same trip as one of them.
      final others = await TripPlanStorage.loadPlans();
      final plans = [plan, ...others.where((saved) => saved.id != plan.id)];
      await TripPlanStorage.savePlans(plans);
      // Back from the plan, the user finds it above an empty form, ready for
      // the next trip.
      if (!isClosed) emit(MyTripState(savedPlans: plans));
      return plan;
    } catch (_) {
      if (!isClosed) emit(state.copyWith(isGenerating: false));
      rethrow;
    }
  }

  /// Keeps what the user changed in a saved plan.
  Future<void> updateSavedPlan(TripPlan plan) async {
    final plans = [for (final saved in state.savedPlans) saved.id == plan.id ? plan : saved];
    emit(state.copyWith(savedPlans: plans));
    await TripPlanStorage.savePlans(plans);
  }

  /// Deletes a saved plan. The form, which is for a new trip, stays as it is.
  Future<void> deletePlan(TripPlan plan) async {
    final plans = state.savedPlans.where((saved) => saved.id != plan.id).toList(growable: false);
    await TripPlanStorage.savePlans(plans);
    if (!isClosed) emit(state.copyWith(savedPlans: plans));
  }
}
