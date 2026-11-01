part of 'my_trip_cubit.dart';

/// What keeps the form from being planned, in the order its steps are checked.
enum MyTripFormError { missingDate, missingLength, tooLong, missingLocation, missingCategories }

@immutable
class MyTripState {
  const MyTripState({
    this.startDate,
    this.stayLength = '',
    this.location = '',
    this.categories = const {},
    this.savedPlan,
    this.isGenerating = false,
  });

  final DateTime? startDate;

  /// The trip length as typed, so the text field always shows the state.
  final String stayLength;
  final String location;
  final Set<String> categories;
  final TripPlan? savedPlan;
  final bool isGenerating;

  /// [stayLength] in days, or null while it is not a positive whole number.
  int? get stayLengthDays {
    final days = int.tryParse(stayLength.trim());
    return days != null && days > 0 ? days : null;
  }

  bool get isFormEmpty =>
      startDate == null && stayLength.trim().isEmpty && location.trim().isEmpty && categories.isEmpty;

  /// The first problem in the form, or null when it can be planned.
  MyTripFormError? get formError {
    final days = stayLengthDays;
    if (startDate == null) return MyTripFormError.missingDate;
    if (days == null) return MyTripFormError.missingLength;
    if (days > TripPlannerService.maxTripDays) return MyTripFormError.tooLong;
    if (location.trim().isEmpty) return MyTripFormError.missingLocation;
    if (categories.isEmpty) return MyTripFormError.missingCategories;
    return null;
  }

  static const _unchanged = Object();

  /// [savedPlan] can be set to null, so leaving it out means "unchanged".
  MyTripState copyWith({
    DateTime? startDate,
    String? stayLength,
    String? location,
    Set<String>? categories,
    Object? savedPlan = _unchanged,
    bool? isGenerating,
  }) {
    return MyTripState(
      startDate: startDate ?? this.startDate,
      stayLength: stayLength ?? this.stayLength,
      location: location ?? this.location,
      categories: categories != null ? Set.unmodifiable(categories) : this.categories,
      savedPlan: identical(savedPlan, _unchanged) ? this.savedPlan : savedPlan as TripPlan?,
      isGenerating: isGenerating ?? this.isGenerating,
    );
  }
}
