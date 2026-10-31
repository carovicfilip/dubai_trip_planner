// lib/core/widgets/hack_and_tips.dart
import 'package:material_ui/material_ui.dart';
import '../../../features/explore/ui/widgets/hack_and_tips_card.dart';

class HackAndTips extends StatelessWidget {
  const HackAndTips({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> tips = [
      {
        "emoji": "🚇",
        "title": "Use Nol Card for Transport",
        "description": "Pay less for metro, buses, and water taxis by using a Nol card."
      },
      {
        "emoji": "🌇",
        "title": "Burj Khalifa Sunset View",
        "description": "Visit around 4–5 PM to catch both daylight and sunset views."
      },
      {
        "emoji": "💧",
        "title": "Stay Hydrated",
        "description": "Dubai heat is intense! Always carry water while exploring."
      },
      {
        "emoji": "🏜️",
        "title": "Book Desert Safari Early",
        "description": "Book online in advance to get better deals and avoid scams."
      },
      {
        "emoji": "🚖",
        "title": "Use Careem App",
        "description": "Cheaper than Uber and better tailored for Dubai."
      },
      {
        "emoji": "🕌",
        "title": "Respect Dress Code",
        "description": "Wear modest clothes in malls and religious places."
      },
      {
        "emoji": "💰",
        "title": "Bargain in Gold Souk",
        "description": "Negotiating is expected. Don't accept the first price!"
      },
      {
        "emoji": "📅",
        "title": "Plan for Friday Weekend",
        "description": "Friday and Saturday are weekends in Dubai, not Saturday-Sunday."
      },
      {
        "emoji": "🛍️",
        "title": "Ask for Tax-Free Shopping",
        "description": "Get VAT refunds at the airport with a tax-free receipt."
      },
      {
        "emoji": "⛵",
        "title": "Ride an Abra",
        "description": "Cross Dubai Creek for 1 AED on a traditional wooden boat."
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Hack & Tips", style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        SizedBox(
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: tips.length,
            itemBuilder: (context, index) {
              final tip = tips[index];
              return HackAndTipsCard(
                emoji: tip["emoji"]!,
                title: tip["title"]!,
                description: tip["description"]!,
              );
            },
          ),
        ),
      ],
    );
  }
}
