import 'dart:ui' show ImageFilter;

import 'package:material_ui/material_ui.dart';

/// A [photo] that turns blurred towards the bottom without a visible edge: a
/// blurred copy of it fades in between [begin] and [end] of its height.
class BottomBlur extends StatelessWidget {
  const BottomBlur({
    super.key,
    required this.photo,
    required this.sigma,
    required this.begin,
    required this.end,
  });

  final Widget photo;
  final double sigma;
  final double begin;
  final double end;

  @override
  Widget build(BuildContext context) {
    // A blur reaches beyond the photo; the clip keeps it off whatever is around.
    return ClipRect(
      child: Stack(
        fit: StackFit.expand,
        children: [
          photo,
          ShaderMask(
            blendMode: BlendMode.dstIn,
            shaderCallback: (bounds) => LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: [begin, end],
              colors: const [Colors.transparent, Colors.white],
            ).createShader(bounds),
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma, tileMode: TileMode.clamp),
              child: photo,
            ),
          ),
        ],
      ),
    );
  }
}
