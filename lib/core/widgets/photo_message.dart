import 'dart:ui' show ImageFilter;

import 'package:dubai_trip_planner/core/constants/app_color.dart';
import 'package:material_ui/material_ui.dart';

/// A photo over the whole screen that melts into a short message at the bottom.
class PhotoMessage extends StatelessWidget {
  const PhotoMessage({
    super.key,
    required this.image,
    required this.title,
    required this.label,
    required this.text,
    required this.bottomSpace,
  });

  final String image;
  final String title;

  /// A word or two between the title and the text, widely spaced.
  final String label;
  final String text;

  /// The room left under the message, e.g. for a button placed over it.
  final double bottomSpace;

  @override
  Widget build(BuildContext context) {
    final photo = Image.asset(
      image,
      fit: BoxFit.cover,
      excludeFromSemantics: true,
      // The screen the app opens on is built before its photo is decoded.
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) => wasSynchronouslyLoaded
          ? child
          : AnimatedOpacity(
              opacity: frame == null ? 0 : 1,
              duration: const Duration(milliseconds: 300),
              child: child,
            ),
    );

    return Stack(
      fit: StackFit.expand,
      children: [
        photo,
        // A blurred copy of the photo fades in towards the bottom, so the
        // blur has no visible edge.
        ShaderMask(
          blendMode: BlendMode.dstIn,
          shaderCallback: (bounds) => const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.42, 0.66],
            colors: [Colors.transparent, Colors.white],
          ).createShader(bounds),
          child: ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 18, sigmaY: 18, tileMode: TileMode.clamp),
            child: photo,
          ),
        ),
        // Keeps the status bar and the text legible on any photo.
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: const [0, 0.14, 0.42, 0.68, 1],
              colors: [
                Colors.black.withValues(alpha: 0.28),
                Colors.transparent,
                Colors.transparent,
                AppColors.darkNavy.withValues(alpha: 0.72),
                AppColors.darkNavy.withValues(alpha: 0.94),
              ],
            ),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(28, 0, 28, bottomSpace),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 32, height: 1.2),
                ),
                const SizedBox(height: 16),
                Text(
                  label,
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 13, letterSpacing: 7),
                ),
                const SizedBox(height: 16),
                Text(
                  text,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 15, height: 1.45),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
