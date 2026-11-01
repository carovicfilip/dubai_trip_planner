import 'package:material_ui/material_ui.dart';

/// A place photo from the app's assets, or a grey placeholder when it is
/// missing or cannot be loaded.
class PlaceImage extends StatelessWidget {
  const PlaceImage(this.path, {super.key, this.height = double.infinity});

  final String path;
  final double height;

  @override
  Widget build(BuildContext context) {
    final placeholder = Container(
      width: double.infinity,
      height: height,
      color: Colors.grey[300],
      child: const Center(
        child: Icon(
          Icons.image_not_supported,
          size: 50,
          color: Colors.grey,
        ),
      ),
    );
    if (path.isEmpty) return placeholder;

    return Image.asset(
      path,
      width: double.infinity,
      height: height,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        debugPrint('Could not load image $path: $error');
        return placeholder;
      },
    );
  }
}
