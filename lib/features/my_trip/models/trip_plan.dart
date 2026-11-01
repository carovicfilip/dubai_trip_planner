import 'dart:convert';

class DailyPlan {
  final String title;

  /// The part of Dubai the day is spent in, e.g. "Downtown Dubai & Business
  /// Bay". Null for plans saved before the planner was asked for it.
  final String? area;
  final List<String> highlights;

  /// Which of the [highlights] are checked off, by position. It can be shorter
  /// than them; what it does not reach is not checked off.
  final List<bool> done;

  const DailyPlan({
    required this.title,
    this.area,
    required this.highlights,
    this.done = const [],
  });

  factory DailyPlan.fromJson(Map<String, dynamic> json) {
    final rawHighlights = json['highlights'] as List<dynamic>? ?? const [];
    return DailyPlan(
      title: json['title'] as String? ?? 'Day',
      area: json['area'] as String?,
      highlights: rawHighlights
          .map((item) => item is String ? item : item.toString())
          .toList(growable: false),
      done: (json['done'] as List<dynamic>? ?? const []).map((item) => item == true).toList(growable: false),
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        if (area != null) 'area': area,
        'highlights': highlights,
        if (done.contains(true)) 'done': _doneFlags,
      };

  bool isDone(int index) => index < done.length && done[index];

  int get doneCount => _doneFlags.where((isDone) => isDone).length;

  /// Whether there are items, and all of them are checked off.
  bool get isFinished => highlights.isNotEmpty && doneCount == highlights.length;

  List<bool> get _doneFlags => [for (var i = 0; i < highlights.length; i++) isDone(i)];

  DailyPlan _withItems(List<String> highlights, List<bool> done) {
    return DailyPlan(title: title, area: area, highlights: highlights, done: done);
  }

  DailyPlan withItemToggled(int index) {
    final flags = _doneFlags;
    flags[index] = !flags[index];
    return _withItems(highlights, flags);
  }

  DailyPlan withoutItem(int index) {
    return _withItems(List.of(highlights)..removeAt(index), _doneFlags..removeAt(index));
  }

  DailyPlan withItemInserted(int index, String text, {bool isDone = false}) {
    return _withItems(List.of(highlights)..insert(index, text), _doneFlags..insert(index, isDone));
  }

  /// Moves an item so that it ends up at position [to].
  DailyPlan withItemMoved(int from, int to) {
    final items = List.of(highlights);
    final flags = _doneFlags;
    items.insert(to, items.removeAt(from));
    flags.insert(to, flags.removeAt(from));
    return _withItems(items, flags);
  }
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

  /// Which trip this is: a plan for the same place, dates and length is a new
  /// version of the same trip.
  String get id => '$location|${startDate.toIso8601String()}|$lengthInDays';

  TripPlan withDay(int index, DailyPlan day) {
    return TripPlan(
      location: location,
      startDate: startDate,
      lengthInDays: lengthInDays,
      categories: categories,
      days: List.of(days)..[index] = day,
    );
  }

  String serialize() => jsonEncode(toJson());

  static TripPlan deserialize(String source) {
    final map = jsonDecode(source) as Map<String, dynamic>;
    return TripPlan.fromJson(map);
  }
}

