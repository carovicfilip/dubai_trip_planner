import 'dart:async';
import 'dart:ui' show ImageFilter;

import 'package:dubai_trip_planner/core/constants/app_color.dart';
import 'package:dubai_trip_planner/core/widgets/liquid_glass_painter.dart';
import 'package:dubai_trip_planner/features/app_rating/services/app_rating_service.dart';
import 'package:material_ui/material_ui.dart';

/// Asks how the user likes the app, once ever, shortly after this first appears.
/// Only the happy face leads on to the store's rating dialog.
class AppRatingPrompt extends StatefulWidget {
  const AppRatingPrompt({super.key});

  @override
  State<AppRatingPrompt> createState() => _AppRatingPromptState();
}

class _AppRatingPromptState extends State<AppRatingPrompt> {
  Timer? _askTimer;

  @override
  void initState() {
    super.initState();
    // Lets the screen slide in and be seen first.
    _askTimer = Timer(const Duration(milliseconds: 800), _askOnce);
  }

  @override
  void dispose() {
    _askTimer?.cancel();
    super.dispose();
  }

  Future<void> _askOnce() async {
    if (await AppRatingService.wasAsked() || !mounted) return;
    // The user is on the way off this screen, so it waits for the next visit.
    if (ModalRoute.isCurrentOf(context) != true || Navigator.of(context).userGestureInProgress) return;

    await AppRatingService.markAsked();
    if (!mounted) return;
    final feeling = await showGeneralDialog<_Feeling>(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: AppColors.darkNavy.withValues(alpha: 0.45),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (_, _, _) => const SafeArea(child: _AppRatingDialog()),
      transitionBuilder: (_, animation, _, dialog) => AnimatedBuilder(
        animation: animation,
        // Everything behind melts away, as at the bottom of the onboarding. Kept
        // out of the fade: a blur under a fade has nothing behind it to work on.
        builder: (_, child) {
          final sigma = 14 * animation.value;
          return BackdropFilter(filter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma), child: child);
        },
        child: FadeTransition(
          opacity: animation,
          child: ScaleTransition(scale: Tween(begin: 0.94, end: 1.0).animate(animation), child: dialog),
        ),
      ),
    );
    if (feeling == _Feeling.happy) await AppRatingService.requestStoreReview();
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

enum _Feeling { unhappy, neutral, happy }

/// The same in both themes, as it opens over a full-photo screen.
class _AppRatingDialog extends StatelessWidget {
  const _AppRatingDialog();

  static const _radius = 32.0;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(_radius))),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(_radius),
        child: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppColors.darkNavy, AppColors.primaryBlue],
            ),
          ),
          child: DecoratedBox(
            // A soft gray light coming in from the side.
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(-1.1, 0.5),
                radius: 1.25,
                stops: [0, 0.5, 1],
                colors: [Color(0x88A3AEBA), Color(0x33A3AEBA), Color(0x00A3AEBA)],
              ),
            ),
            child: CustomPaint(
              painter: const LiquidGlassPainter(radius: _radius, light: Colors.white, shade: AppColors.darkNavy),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 30, 20, 28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'How do you like\nthe app so far?',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white, fontSize: 26, height: 1.25),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'DUBAI',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 13, letterSpacing: 7),
                    ),
                    const SizedBox(height: 26),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _FaceButton(
                          icon: Icons.sentiment_dissatisfied_outlined,
                          label: "I don't like it",
                          feeling: _Feeling.unhappy,
                        ),
                        _FaceButton(
                          icon: Icons.sentiment_neutral_outlined,
                          label: "It's okay",
                          feeling: _Feeling.neutral,
                        ),
                        _FaceButton(
                          icon: Icons.sentiment_very_satisfied_outlined,
                          label: 'I love it',
                          feeling: _Feeling.happy,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FaceButton extends StatelessWidget {
  const _FaceButton({required this.icon, required this.label, required this.feeling});

  final IconData icon;

  /// Read out by screen readers, and shown on a long press.
  final String label;
  final _Feeling feeling;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: label,
      iconSize: 42,
      onPressed: () => Navigator.pop(context, feeling),
      style: IconButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: Colors.white.withValues(alpha: 0.12),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.35)),
        fixedSize: const Size.square(74),
      ),
      icon: Icon(icon),
    );
  }
}
