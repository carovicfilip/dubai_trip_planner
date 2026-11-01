import 'package:dubai_trip_planner/features/explore/ui/widgets/hack_and_tips_card.dart';
import 'package:dubai_trip_planner/l10n/l10n.dart';
import 'package:material_ui/material_ui.dart';

List<({String emoji, String title, String description})> _tipsIn(AppLocalizations l10n) => [
      (emoji: "🚇", title: l10n.tipNolCardTitle, description: l10n.tipNolCardText),
      (emoji: "🌇", title: l10n.tipSunsetTitle, description: l10n.tipSunsetText),
      (emoji: "💧", title: l10n.tipWaterTitle, description: l10n.tipWaterText),
      (emoji: "🏜️", title: l10n.tipSafariTitle, description: l10n.tipSafariText),
      (emoji: "🚖", title: l10n.tipCareemTitle, description: l10n.tipCareemText),
      (emoji: "🕌", title: l10n.tipDressTitle, description: l10n.tipDressText),
      (emoji: "💰", title: l10n.tipBargainTitle, description: l10n.tipBargainText),
      (emoji: "📅", title: l10n.tipFridayTitle, description: l10n.tipFridayText),
      (emoji: "🛍️", title: l10n.tipTaxFreeTitle, description: l10n.tipTaxFreeText),
      (emoji: "⛵", title: l10n.tipAbraTitle, description: l10n.tipAbraText),
    ];

class HackAndTips extends StatelessWidget {
  const HackAndTips({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tips = _tipsIn(l10n);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.tipsTitle, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        SizedBox(
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: tips.length,
            itemBuilder: (context, index) {
              final tip = tips[index];
              return HackAndTipsCard(
                emoji: tip.emoji,
                title: tip.title,
                description: tip.description,
              );
            },
          ),
        ),
      ],
    );
  }
}
