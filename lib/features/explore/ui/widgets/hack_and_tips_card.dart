import 'package:material_ui/material_ui.dart';

class HackAndTipsCard extends StatelessWidget {
  final String emoji;
  final String title;
  final String description;

  const HackAndTipsCard({
    super.key,
    required this.emoji,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      margin: const EdgeInsets.only(right: 18),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 26)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14)),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(description,
              style: const TextStyle(fontSize: 13),
              overflow: TextOverflow.ellipsis,
              maxLines: 3),
        ],
      ),
    );
  }
}
