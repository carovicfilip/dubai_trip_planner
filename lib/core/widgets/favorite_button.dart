import 'package:material_ui/material_ui.dart';

class FavoriteButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isFavorite;
  final double radius;
  final double iconSize;

  const FavoriteButton({
    super.key,
    this.onPressed,
    this.isFavorite = false,
    this.radius = 20,
    this.iconSize = 22,
  });

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.black45,
      child: IconButton(
        padding: EdgeInsets.zero,
        icon: Icon(
          isFavorite ? Icons.favorite : Icons.favorite_border,
          color: Colors.white,
          size: iconSize,
        ),
        onPressed: onPressed,
      ),
    );
  }
}
