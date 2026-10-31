import 'package:material_ui/material_ui.dart';

class CustomBackButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final double iconSize;
  final EdgeInsets padding;

  const CustomBackButton({
    super.key,
    this.onPressed,
    this.iconSize = 24,
    this.padding = const EdgeInsets.all(6),
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Container(
        decoration: BoxDecoration(
          color: Colors.black45, // pozadina
          borderRadius: BorderRadius.circular(20), // zaobljeno
        ),
        padding: padding,
        child: Icon(
          Icons.arrow_back_ios_new, // modernija ikonica
          color: Colors.white,
          size: iconSize,
        ),
      ),
      onPressed: onPressed ?? () => Navigator.pop(context),
    );
  }
}
