import 'package:dubai_trip_planner/core/widgets/custom_back_button.dart';
import 'package:material_ui/material_ui.dart';

/// A photo at the top of a trip screen, melting into the page.
class TripPhoto extends StatelessWidget {
  const TripPhoto({super.key, required this.image, this.alignment = Alignment.center});

  final String image;

  /// Which part of the photo shows.
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: SizedBox(
        width: double.infinity,
        // The first card of the screen covers the end of it.
        height: MediaQuery.paddingOf(context).top + 140,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 600),
          child: ShaderMask(
            key: ValueKey(image),
            blendMode: BlendMode.dstIn,
            shaderCallback: (bounds) => const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: [0.8, 1],
              colors: [Colors.white, Colors.transparent],
            ).createShader(bounds),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(image, fit: BoxFit.cover, alignment: alignment, excludeFromSemantics: true),
                // Keeps the status bar and the app bar legible on any photo.
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: const [0, 0.54, 0.8],
                      colors: [
                        Colors.black.withValues(alpha: 0.42),
                        Colors.black.withValues(alpha: 0.32),
                        Colors.black.withValues(alpha: 0),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The app bar of a trip screen, over its [TripPhoto].
class TripTopBar extends StatelessWidget {
  const TripTopBar({super.key, required this.title, required this.onBack, this.trailing});

  final String title;

  /// Null leaves out the back button.
  final VoidCallback? onBack;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final onBack = this.onBack;
    final trailing = this.trailing;

    return SizedBox(
      height: 48,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (onBack != null) Align(alignment: AlignmentDirectional.centerStart, child: CustomBackButton(onPressed: onBack)),
          Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              // It sits on the photo, which can be bright.
              shadows: [Shadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 14)],
            ),
          ),
          if (trailing != null) Align(alignment: AlignmentDirectional.centerEnd, child: trailing),
        ],
      ),
    );
  }
}
