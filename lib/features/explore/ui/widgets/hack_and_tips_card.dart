import 'package:dubai_trip_planner/core/constants/app_palette.dart';
import 'package:dubai_trip_planner/core/widgets/glass_card.dart';
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
    final palette = context.palette;
    return GlassCard(
      width: 250,
      margin: const EdgeInsetsDirectional.only(end: 18),
      padding: const EdgeInsets.all(14),
      radius: 28,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: palette.tile,
                  shape: BoxShape.circle,
                ),
                child: Text(emoji, style: const TextStyle(fontSize: 21)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: palette.ink, fontWeight: FontWeight.w500, fontSize: 14)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(description,
              style: TextStyle(fontSize: 13, color: palette.muted),
              overflow: TextOverflow.ellipsis,
              maxLines: 3),
        ],
      ),
    );
  }
}
