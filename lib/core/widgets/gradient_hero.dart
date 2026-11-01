import 'package:dubai_trip_planner/core/constants/app_color.dart';
import 'package:material_ui/material_ui.dart';

/// The dark header with an orange glow at the top of the Explore and Profile
/// tabs, the same in the light and the dark theme. It starts behind the status bar; put it
/// first in a [HeroListView].
class GradientHero extends StatelessWidget {
  const GradientHero({
    super.key,
    required this.lightTitle,
    required this.boldTitle,
    this.trailing,
    required this.child,
  });

  final String lightTitle;
  final String boldTitle;

  /// Shown at the end of the first title line.
  final Widget? trailing;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    const titleSize = 30.0;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(36)),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.heroDeep, Color(0xFF3A1D10), AppColors.heroBrown],
          ),
        ),
        child: DecoratedBox(
          // The glow coming in from the side.
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(-1.1, 0.5),
              radius: 1.25,
              stops: [0, 0.5, 1],
              colors: [Color(0xDDFF6D29), Color(0x77B65327), Color(0x00B65327)],
            ),
          ),
          child: Padding(
            padding: EdgeInsets.fromLTRB(16, MediaQuery.paddingOf(context).top + 14, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        lightTitle,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: titleSize,
                          fontWeight: FontWeight.w300,
                          height: 1.2,
                        ),
                      ),
                    ),
                    ?trailing,
                  ],
                ),
                Text(
                  boldTitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: titleSize,
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 18),
                child,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A list that starts with a [GradientHero]. Its screen needs white status bar
/// icons, in both themes. Once the header has scrolled away they would be lost
/// on what passes under them, so a band in the header's color appears there.
class HeroListView extends StatefulWidget {
  const HeroListView({super.key, this.padding, required this.children});

  static const statusBarBandKey = ValueKey('hero-status-bar-band');

  final EdgeInsetsGeometry? padding;
  final List<Widget> children;

  @override
  State<HeroListView> createState() => _HeroListViewState();
}

class _HeroListViewState extends State<HeroListView> {
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ListView(controller: _scrollController, padding: widget.padding, children: widget.children),
        Align(
          alignment: Alignment.topCenter,
          child: IgnorePointer(
            child: AnimatedBuilder(
              animation: _scrollController,
              builder: (context, band) {
                final offset = _scrollController.hasClients ? _scrollController.offset : 0.0;
                // Just before the dark card of the header reaches the status bar.
                return Opacity(opacity: ((offset - 60) / 40).clamp(0.0, 1.0), child: band);
              },
              child: Container(
                key: HeroListView.statusBarBandKey,
                height: MediaQuery.paddingOf(context).top + 8,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: [0.75, 1],
                    colors: [AppColors.heroDeep, Color(0x001E100B)],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
