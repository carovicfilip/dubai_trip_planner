/// The parts of a place that are written in the language of the app. Its address
/// stays as it is in every language: that is what maps and taxi apps go by.
class PlaceText {
  const PlaceText({required this.name, required this.description, this.openingHours});

  final String name;
  final String description;
  final String? openingHours;
}
