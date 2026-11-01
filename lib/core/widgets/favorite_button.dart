import 'package:material_ui/material_ui.dart';

class FavoriteButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isFavorite;
  final double radius;
  final double iconSize;
  final Color backgroundColor;
  final Color iconColor;

  const FavoriteButton({
    super.key,
    this.onPressed,
    this.isFavorite = false,
    this.radius = 20,
    this.iconSize = 22,
    this.backgroundColor = Colors.black45,
    this.iconColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor,
      child: IconButton(
        padding: EdgeInsets.zero,
        icon: Icon(
          isFavorite ? Icons.favorite : Icons.favorite_border,
          color: iconColor,
          size: iconSize,
        ),
        onPressed: onPressed,
      ),
    );
  }
}
