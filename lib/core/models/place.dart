class Place {
  final String id;
  final String categoryId;
  final String name;
  final String description;
  final String imageUrl;
  final String? openingHours;
  final String? location;
  final String? reviewSummary;

  const Place({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.description,
    required this.imageUrl,
    this.openingHours,
    this.location,
    this.reviewSummary,
  });

  factory Place.fromJson(Map<String, dynamic> json) {
    return Place(
      id: json['id'] as String,
      categoryId: json['categoryId'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      imageUrl: json['imageUrl'] as String,
      openingHours: json['openingHours'] as String?,
      location: json['location'] as String?,
      reviewSummary: json['reviewSummary'] as String?,
    );
  }

  /// The rating [reviewSummary] starts with, e.g. 4.7 for
  /// "4.7 (166k reviews)", or 0 when there is none.
  double get rating {
    final match = RegExp(r'^(\d+\.?\d*)').firstMatch(reviewSummary ?? '');
    return double.tryParse(match?.group(1) ?? '') ?? 0;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'categoryId': categoryId,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'openingHours': openingHours,
      'location': location,
      'reviewSummary': reviewSummary,
    };
  }
}

