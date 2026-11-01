import 'package:dubai_trip_planner/features/my_trip/models/trip_plan.dart';
import 'package:dubai_trip_planner/features/my_trip/services/trip_plan_storage.dart';
import 'package:dubai_trip_planner/features/my_trip/services/trip_planner_service.dart';
import 'package:flutter/foundation.dart' show immutable;
import 'package:flutter_bloc/flutter_bloc.dart';

part 'my_trip_state.dart';

/// The My Trip form and the saved plan.
///
/// Provided above the tabs: the tab bar builds My Trip from scratch on every
/// visit, and neither a plan that takes up to a minute to generate nor a
/// half-filled form may get lost when the user looks at another tab meanwhile.
class MyTripCubit extends Cubit<MyTripState> {
  MyTripCubit(this._planner) : super(const MyTripState());

  final TripPlannerService _planner;
  Future<TripPlan>? _generating;

  /// Shows the saved plan. An empty form is filled in from it, so the user
  /// can adjust the last trip instead of starting over.
  Future<void> loadSavedPlan() async {
    final plan = await TripPlanStorage.loadPlan();
    if (isClosed) return;
    if (plan == null || !state.isFormEmpty) {
      emit(state.copyWith(savedPlan: plan));
      return;
    }
    emit(state.copyWith(
      savedPlan: plan,
      startDate: plan.startDate,
      stayLength: '${plan.lengthInDays}',
      location: plan.location,
      categories: plan.categories.toSet(),
    ));
  }

  void selectStartDate(DateTime date) => emit(state.copyWith(startDate: date));

  void updateStayLength(String text) => emit(state.copyWith(stayLength: text));

  void updateLocation(String text) => emit(state.copyWith(location: text));

  void toggleCategory(String category) {
    final categories = Set.of(state.categories);
    if (!categories.remove(category)) categories.add(category);
    emit(state.copyWith(categories: categories));
  }

  /// Shortens the stay to the longest one plan can cover, see
  /// [TripPlannerService.maxTripDays].
  void shortenToMaxDays() => emit(state.copyWith(stayLength: '${TripPlannerService.maxTripDays}'));

  /// Plans the trip in the form and saves the plan. Asking again while a plan
  /// is being generated returns that request instead of paying for another.
  Future<TripPlan> generatePlan() => _generating ??= _generate().whenComplete(() => _generating = null);

  Future<TripPlan> _generate() async {
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
      );
      await TripPlanStorage.savePlan(plan);
      if (!isClosed) emit(state.copyWith(savedPlan: plan, isGenerating: false));
      return plan;
    } catch (_) {
      if (!isClosed) emit(state.copyWith(isGenerating: false));
      rethrow;
    }
  }

  /// Deletes the saved plan and clears the form.
  Future<void> deletePlan() async {
    await TripPlanStorage.clear();
    if (!isClosed) emit(MyTripState(isGenerating: state.isGenerating));
  }
}
