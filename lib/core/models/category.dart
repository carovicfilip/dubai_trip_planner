class Category {
  final String id;

  /// In English; the screens show AppLocalizations.categoryName(id).
  final String name;
  final String iconPath;

  const Category({
    required this.id,
    required this.name,
    required this.iconPath,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Category && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Category(id: $id, name: $name)';
}
