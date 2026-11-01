part of 'my_trip_cubit.dart';

/// What keeps the form from being planned, in the order its steps are checked.
enum MyTripFormError { missingDate, missingLength, missingLocation, missingCategories }

@immutable
class MyTripState {
  const MyTripState({
    this.step = 0,
    this.startDate,
    this.stayLengthDays,
    this.location = '',
    this.categories = const {},
    this.savedPlans = const [],
    this.isGenerating = false,
  });

  /// The last step of the form; they are counted from 0.
  static const lastStep = 2;

  /// The step of the form on screen.
  final int step;
  final DateTime? startDate;
  final int? stayLengthDays;
  final String location;
  final Set<String> categories;

  /// The newest first.
  final List<TripPlan> savedPlans;
  final bool isGenerating;

  bool get isFormEmpty =>
      startDate == null && stayLengthDays == null && location.trim().isEmpty && categories.isEmpty;

  /// The first problem in the form, or null when it can be planned.
  MyTripFormError? get formError {
    if (startDate == null) return MyTripFormError.missingDate;
    if (stayLengthDays == null) return MyTripFormError.missingLength;
    if (location.trim().isEmpty) return MyTripFormError.missingLocation;
    if (categories.isEmpty) return MyTripFormError.missingCategories;
    return null;
  }

  /// Whether the step on screen is filled in, so the user can go on.
  bool get isStepComplete {
    return switch (step) {
      0 => startDate != null && stayLengthDays != null,
      1 => location.trim().isNotEmpty,
      _ => categories.isNotEmpty,
    };
  }

  MyTripState copyWith({
    int? step,
    DateTime? startDate,
    int? stayLengthDays,
    String? location,
    Set<String>? categories,
    List<TripPlan>? savedPlans,
    bool? isGenerating,
  }) {
    return MyTripState(
      step: step ?? this.step,
      startDate: startDate ?? this.startDate,
      stayLengthDays: stayLengthDays ?? this.stayLengthDays,
      location: location ?? this.location,
      categories: categories != null ? Set.unmodifiable(categories) : this.categories,
      savedPlans: savedPlans ?? this.savedPlans,
      isGenerating: isGenerating ?? this.isGenerating,
    );
  }
}
