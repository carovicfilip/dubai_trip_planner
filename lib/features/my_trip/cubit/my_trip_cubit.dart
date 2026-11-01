import 'package:dubai_trip_planner/features/my_trip/models/trip_plan.dart';
import 'package:dubai_trip_planner/features/my_trip/services/trip_plan_storage.dart';
import 'package:dubai_trip_planner/features/my_trip/services/trip_planner_service.dart';
import 'package:flutter/foundation.dart' show immutable;
import 'package:flutter_bloc/flutter_bloc.dart';

part 'my_trip_state.dart';

/// The My Trip form and the saved plans.
///
/// Provided above the tabs: the tab bar builds My Trip from scratch on every
/// visit, and neither a plan that takes up to a minute to generate nor a
/// half-filled form may get lost when the user looks at another tab meanwhile.
class MyTripCubit extends Cubit<MyTripState> {
  MyTripCubit(this._planner) : super(const MyTripState());

  final TripPlannerService _planner;
  Future<TripPlan>? _generating;

  /// Shows the saved plans. An empty form is filled in from the newest, so the
  /// user can adjust the last trip instead of starting over.
  Future<void> loadSavedPlans() async {
    final plans = await TripPlanStorage.loadPlans();
    if (isClosed) return;
    final plan = plans.firstOrNull;
    if (plan == null || !state.isFormEmpty) {
      emit(state.copyWith(savedPlans: plans));
      return;
    }
    final now = DateTime.now();
    final hasStarted = plan.startDate.isBefore(DateTime(now.year, now.month, now.day));
    emit(state.copyWith(
      savedPlans: plans,
      // What the form could not offer has to be chosen anew.
      startDate: hasStarted ? null : plan.startDate,
      stayLengthDays: plan.lengthInDays <= TripPlannerService.maxTripDays ? plan.lengthInDays : null,
      location: plan.location,
      categories: plan.categories.toSet(),
    ));
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
      final plan = await _planner.generatePlan(
        startDate: form.startDate!,
        lengthInDays: form.stayLengthDays!,
        location: form.location.trim(),
        categories: form.categories.toList()..sort(),
        languageCode: languageCode,
      );
      // A new plan joins the others, unless it is for the same trip as one of them.
      final others = await TripPlanStorage.loadPlans();
      final plans = [plan, ...others.where((saved) => saved.id != plan.id)];
      await TripPlanStorage.savePlans(plans);
      // Back from the plan, the user finds it at the start of the form.
      if (!isClosed) emit(state.copyWith(step: 0, savedPlans: plans, isGenerating: false));
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

  /// Deletes a saved plan. With the last one goes the form filled in from it.
  Future<void> deletePlan(TripPlan plan) async {
    final plans = state.savedPlans.where((saved) => saved.id != plan.id).toList(growable: false);
    await TripPlanStorage.savePlans(plans);
    if (isClosed) return;
    emit(plans.isEmpty ? MyTripState(isGenerating: state.isGenerating) : state.copyWith(savedPlans: plans));
  }
}
