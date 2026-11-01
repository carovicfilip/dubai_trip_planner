import 'dart:convert';

class DailyPlan {
  final String title;

  /// The part of Dubai the day is spent in, e.g. "Downtown Dubai & Business
  /// Bay". Null for plans saved before the planner was asked for it.
  final String? area;
  final List<String> highlights;

  const DailyPlan({
    required this.title,
    this.area,
    required this.highlights,
  });

  factory DailyPlan.fromJson(Map<String, dynamic> json) {
    final rawHighlights = json['highlights'] as List<dynamic>? ?? const [];
    return DailyPlan(
      title: json['title'] as String? ?? 'Day',
      area: json['area'] as String?,
      highlights: rawHighlights
          .map((item) => item is String ? item : item.toString())
          .toList(growable: false),
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        if (area != null) 'area': area,
        'highlights': highlights,
      };
}

class TripPlan {
  final String location;
  final DateTime startDate;
  final int lengthInDays;
  final List<String> categories;
  final List<DailyPlan> days;

  const TripPlan({
    required this.location,
    required this.startDate,
    required this.lengthInDays,
    required this.categories,
    required this.days,
  });

  factory TripPlan.fromJson(Map<String, dynamic> json) {
    final daysJson = json['days'] as List<dynamic>? ?? const [];
    final categoryJson = json['categories'] as List<dynamic>? ?? const [];

    return TripPlan(
      location: json['location'] as String? ?? '',
      startDate: DateTime.parse(json['startDate'] as String),
      lengthInDays: json['lengthInDays'] as int? ?? daysJson.length,
      categories: categoryJson.map((item) => item.toString()).toList(growable: false),
      days: daysJson
          .map((item) => DailyPlan.fromJson(item as Map<String, dynamic>))
          .toList(growable: false),
    );
  }

  Map<String, dynamic> toJson() => {
        'location': location,
        'startDate': startDate.toIso8601String(),
        'lengthInDays': lengthInDays,
        'categories': categories,
        'days': days.map((day) => day.toJson()).toList(growable: false),
      };

  String serialize() => jsonEncode(toJson());

  static TripPlan deserialize(String source) {
    final map = jsonDecode(source) as Map<String, dynamic>;
    return TripPlan.fromJson(map);
  }
}

