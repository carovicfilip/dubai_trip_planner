import 'package:dubai_trip_planner/core/constants/app_color.dart';
import 'package:material_ui/material_ui.dart';

class HeaderWidget extends StatelessWidget {
  final String name;
  final String savings;

  const HeaderWidget({super.key, required this.name, required this.savings});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Welcome to",
              style: textTheme.bodyMedium?.copyWith(
                fontSize: 16,
                color: AppColors.gray500,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Dubai Trip Planner",
              style: textTheme.headlineSmall?.copyWith(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryBlue,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        // Column(
        //   children: [
        //     Text("Total Savings", style: TextStyle(fontSize: 12, color: Colors.black)),
        //     Text(savings, style: TextStyle(fontSize: 16, color: Colors.black26, fontWeight: FontWeight.bold)),
        //   ],
        //)
      ],
    );
  }
}
