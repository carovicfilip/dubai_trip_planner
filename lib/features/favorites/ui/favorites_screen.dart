import 'package:flutter/material.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  final List<Map<String, String>> favorites = const [
    {"title": "Sky Lounge", "category": "Brunch", "image": "", "desc": "Rooftop dining with skyline view"},
    {"title": "Aqua Park", "category": "Leisure", "image": "", "desc": "Water fun for the whole family"},
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: true,
      bottom: true,
      child: ListView.builder(
        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16), // bez top padding-a
        itemCount: favorites.length,
        itemBuilder: (context, index) {
          final item = favorites[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: Container(width: 60, height: 60, color: Colors.grey),
                title: Text(item['title']!),
                subtitle: Text(item['desc']!),
                trailing: Icon(Icons.arrow_forward_ios),
              ),
            ),
          );
        },
      ),
    );
  }
}
