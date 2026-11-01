import 'package:dubai_trip_planner/app/theme/app_theme.dart';
import 'package:dubai_trip_planner/core/constants/app_palette.dart';
import 'package:dubai_trip_planner/core/widgets/glass_card.dart';
import 'package:dubai_trip_planner/features/my_trip/cubit/my_trip_cubit.dart';
import 'package:dubai_trip_planner/features/my_trip/models/trip_plan.dart';
import 'package:dubai_trip_planner/features/my_trip/services/trip_planner_service.dart';
import 'package:dubai_trip_planner/features/my_trip/ui/itinerary_screen.dart';
import 'package:dubai_trip_planner/features/my_trip/ui/trip_labels.dart';
import 'package:dubai_trip_planner/features/my_trip/ui/widgets/arrival_calendar.dart';
import 'package:dubai_trip_planner/features/my_trip/ui/widgets/saved_plan_card.dart';
import 'package:dubai_trip_planner/features/my_trip/ui/widgets/stay_length_picker.dart';
import 'package:dubai_trip_planner/features/my_trip/ui/widgets/trip_form_button.dart';
import 'package:dubai_trip_planner/features/my_trip/ui/widgets/trip_photo_header.dart';
import 'package:dubai_trip_planner/l10n/l10n.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:intl/intl.dart';

// The values of these lists stay in English, because they are saved with a plan
// and sent to the trip planner. The screen shows them through TripLabels.

/// What most visitors to Dubai come for, offered apart from the rest.
const _popularInterests = ['Attractions', 'Shopping', 'Beaches', 'Restaurants', 'Theme parks'];

const _otherInterests = [
  'Cafes',
  'Breakfast and brunch',
  'Bakeries',
  'Bars',
  'Nightlife',
  'Museums',
  'Art museums',
  'Science & space museums',
  'Arts and culture',
  'Parks and gardens',
  'Pools',
  'Asian food',
  'Sushi',
  'Pizzas',
  'Gelato',
  'Desserts',
  'Rooftops',
  'Fun things to do',
  'Spas',
];

/// To choose from instead of typing.
const _areas = [
  'Dubai Marina',
  'Palm Jumeirah',
  'Oud Metha',
  'Al Barsha',
  'Bur Dubai',
  'Jumeirah',
  'Dubai World Trade Centre (DWTC)',
  'Deira',
  'Jebel Ali',
  'Downtown Dubai',
];

/// The photo of each step, and which part of it shows.
const _stepPhotos = [
  (image: 'assets/images/trip_step_1.webp', alignment: Alignment(0, 0.71)),
  (image: 'assets/images/splash.webp', alignment: Alignment.center),
  (image: 'assets/images/trip_step_3.webp', alignment: Alignment(0, 0.05)),
];

/// The trip form, one question per step: a photo at the top like the onboarding
/// and details screens, with cards over the page of the current theme like Explore.
class MyTripScreen extends StatefulWidget {
  const MyTripScreen({super.key});

  @override
  State<MyTripScreen> createState() => _MyTripScreenState();
}

class _MyTripScreenState extends State<MyTripScreen> {
  // The location is kept in MyTripCubit; the controller mirrors it.
  final _accommodationCtrl = TextEditingController();

  // Which way the steps last moved, for the transition between them.
  late int _shownStep;
  bool _movingForward = true;

  @override
  void initState() {
    super.initState();
    final cubit = context.read<MyTripCubit>();
    _shownStep = cubit.state.step;
    cubit.loadSavedPlans();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // So the photo of the next step is there the moment it is needed.
    for (final photo in _stepPhotos) {
      precacheImage(AssetImage(photo.image), context);
    }
    _showLocation(context.read<MyTripCubit>().state.location);
  }

  @override
  void dispose() {
    _accommodationCtrl.dispose();
    super.dispose();
  }

  void _goToNextStep() {
    FocusScope.of(context).unfocus();
    context.read<MyTripCubit>().nextStep();
  }

  void _goBack({required bool toPreviousStep}) {
    FocusScope.of(context).unfocus();
    if (toPreviousStep) {
      context.read<MyTripCubit>().previousStep();
    } else {
      Navigator.maybePop(context);
    }
  }

  Future<void> _handleShowResults() async {
    final cubit = context.read<MyTripCubit>();
    final l10n = context.l10n;
    try {
      final plan = await cubit.generatePlan(languageCode: l10n.localeName);
      if (!mounted) return;
      _openItinerary(plan);
    } catch (error) {
      // The error can hold OpenAI's raw JSON: log it, show the user a short message.
      debugPrint('Trip plan generation failed: $error');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(TripPlannerService.userMessage(error, l10n)),
        ),
      );
    }
  }

  void _openItinerary(TripPlan plan) {
    FocusScope.of(context).unfocus();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ItineraryScreen(plan: plan),
      ),
    );
  }

  Future<void> _confirmDeleteTrip(TripPlan plan) async {
    final cubit = context.read<MyTripCubit>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: context.palette.card,
        title: Text(context.l10n.deleteTripTitle),
        content: Text(context.l10n.deleteTripText),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(context.l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(context.l10n.delete),
          ),
        ],
      ),
    );

    if (confirmed == true) await cubit.deletePlan(plan);
  }

  /// Restoring the saved plan, deleting it and picking an area change the text
  /// without the user typing it. What the user typed stays as it is.
  void _showLocation(String location) {
    if (_accommodationCtrl.text == location) return;
    final text = context.l10n.areaLabel(location);
    if (_accommodationCtrl.text != text) _accommodationCtrl.text = text;
  }

  Widget _buildStep(MyTripState state) {
    return switch (state.step) {
      0 => _DateStep(state: state, onOpenPlan: _openItinerary, onDeletePlan: _confirmDeleteTrip),
      1 => _LocationStep(state: state, controller: _accommodationCtrl),
      _ => _CategoriesStep(state: state),
    };
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MyTripCubit, MyTripState>(
      listener: (context, state) {
        _movingForward = state.step >= _shownStep;
        _shownStep = state.step;
        _showLocation(state.location);
      },
      builder: (context, state) {
        final palette = context.palette;
        final l10n = context.l10n;
        final photo = _stepPhotos[state.step];
        final isLastStep = state.step == MyTripState.lastStep;
        final canGoToPreviousStep = state.step > 0 && !state.isGenerating;
        final String label;
        if (state.isGenerating) {
          label = l10n.tripPlanning;
        } else {
          label = isLastStep ? l10n.tripShowResults : l10n.next;
        }

        return PopScope(
          // The system's back gesture and button go through the steps as well.
          canPop: !canGoToPreviousStep,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) context.read<MyTripCubit>().previousStep();
          },
          child: AnnotatedRegion<SystemUiOverlayStyle>(
            value: AppTheme.statusBarOnDark,
            child: Scaffold(
              backgroundColor: palette.surface,
              body: Stack(
                fit: StackFit.expand,
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: palette.pageGradient,
                      ),
                    ),
                  ),
                  TripPhoto(image: photo.image, alignment: photo.alignment),
                  SafeArea(
                    minimum: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      children: [
                        TripTopBar(
                          title: l10n.tripTitle,
                          onBack: canGoToPreviousStep || Navigator.canPop(context)
                              ? () => _goBack(toPreviousStep: canGoToPreviousStep)
                              : null,
                        ),
                        _StepProgress(step: state.step),
                        Expanded(
                          child: AbsorbPointer(
                            absorbing: state.isGenerating,
                            child: _FadingEdges(
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 320),
                                switchInCurve: Curves.easeOutCubic,
                                switchOutCurve: Curves.easeInCubic,
                                layoutBuilder: (current, previous) => Stack(
                                  fit: StackFit.expand,
                                  children: [...previous, ?current],
                                ),
                                transitionBuilder: (child, animation) {
                                  // Going on, a step comes in from the right and
                                  // leaves to the left; going back, the opposite.
                                  // In Arabic it is all mirrored.
                                  final isIncoming = child.key == ValueKey(state.step);
                                  final side = _movingForward == isIncoming ? 1.0 : -1.0;
                                  return FadeTransition(
                                    opacity: animation,
                                    child: SlideTransition(
                                      textDirection: Directionality.of(context),
                                      position: Tween(begin: Offset(0.1 * side, 0), end: Offset.zero).animate(animation),
                                      child: child,
                                    ),
                                  );
                                },
                                child: KeyedSubtree(key: ValueKey(state.step), child: _buildStep(state)),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: TripFormButton(
                            label: label,
                            icon: isLastStep ? Icons.auto_awesome : Icons.arrow_forward_rounded,
                            isLoading: state.isGenerating,
                            onPressed: state.isGenerating || !state.isStepComplete
                                ? null
                                : (isLastStep ? _handleShowResults : _goToNextStep),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _StepProgress extends StatelessWidget {
  const _StepProgress({required this.step});

  final int step;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: context.l10n.tripStepLabel(step + 1, MyTripState.lastStep + 1),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
        child: Row(
          spacing: 6,
          children: [
            for (var i = 0; i <= MyTripState.lastStep; i++)
              Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: 3,
                  decoration: BoxDecoration(
                    color: i <= step ? Colors.white : Colors.white.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// A step scrolling past the top and bottom fades away instead of being cut off.
class _FadingEdges extends StatelessWidget {
  const _FadingEdges({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.dstIn,
      shaderCallback: (bounds) {
        final top = (12 / bounds.height).clamp(0.0, 0.5);
        final bottom = (20 / bounds.height).clamp(0.0, 0.5);
        return LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: [0, top, 1 - bottom, 1],
          colors: const [Colors.transparent, Colors.white, Colors.white, Colors.transparent],
        ).createShader(bounds);
      },
      child: child,
    );
  }
}

class _StepBody extends StatelessWidget {
  const _StepBody({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      // The room at the top leaves the photo in view.
      padding: const EdgeInsets.fromLTRB(16, 41, 16, 22),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: children),
    );
  }
}

class _StepHeading extends StatelessWidget {
  const _StepHeading({required this.title, required this.text});

  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Column(
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(color: palette.ink, fontSize: 26, height: 1.2),
        ),
        const SizedBox(height: 4),
        Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(color: palette.muted, fontSize: 14, height: 1.4),
        ),
      ],
    );
  }
}

String _stayText(AppLocalizations l10n, DateTime start, int days) {
  final format = DateFormat.MMMd(l10n.localeName);
  if (days == 1) return '${format.format(start)} · ${l10n.tripDays(days)}';
  return '${format.format(start)} – ${format.format(DateUtils.addDaysToDate(start, days - 1))} · ${l10n.tripDays(days)}';
}

class _DateStep extends StatelessWidget {
  const _DateStep({required this.state, required this.onOpenPlan, required this.onDeletePlan});

  final MyTripState state;
  final ValueChanged<TripPlan> onOpenPlan;
  final Future<void> Function(TripPlan plan) onDeletePlan;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<MyTripCubit>();
    final palette = context.palette;
    final l10n = context.l10n;
    final today = DateUtils.dateOnly(DateTime.now());
    final startDate = state.startDate;
    final days = state.stayLengthDays;

    return _StepBody(
      children: [
        if (state.savedPlans.isNotEmpty) ...[
          SavedPlansStrip(plans: state.savedPlans, onOpen: onOpenPlan, onDelete: onDeletePlan),
          const SizedBox(height: 16),
        ],
        GlassCard(
          radius: 28,
          padding: const EdgeInsets.fromLTRB(10, 14, 10, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _StepHeading(title: l10n.tripArrivalTitle, text: l10n.tripArrivalText),
              const SizedBox(height: 6),
              ArrivalCalendar(
                firstDate: today,
                lastDate: DateTime(today.year + 1, today.month, today.day),
                selected: startDate,
                stayDays: days,
                onSelected: cubit.selectStartDate,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        GlassCard(
          radius: 28,
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Turns into the answer once there is one, without moving anything.
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Text(
                  startDate == null || days == null ? l10n.tripHowManyDays : _stayText(l10n, startDate, days),
                  key: ValueKey('$startDate $days'),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: palette.ink, fontSize: 15, fontWeight: FontWeight.w500),
                ),
              ),
              const SizedBox(height: 10),
              StayLengthPicker(selected: days, onSelected: cubit.selectStayLength),
              AnimatedSize(
                duration: const Duration(milliseconds: 200),
                alignment: Alignment.topCenter,
                child: startDate == null || days != TripPlannerService.maxTripDays
                    ? const SizedBox(width: double.infinity)
                    : Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Text(
                          l10n.tripStayingLonger(
                            TripPlannerService.maxTripDays,
                            DateFormat.MMMd(l10n.localeName).format(DateUtils.addDaysToDate(startDate, TripPlannerService.maxTripDays)),
                          ),
                          textAlign: TextAlign.center,
                          style: TextStyle(color: palette.muted, fontSize: 12, height: 1.35),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LocationStep extends StatelessWidget {
  const _LocationStep({required this.state, required this.controller});

  final MyTripState state;
  final TextEditingController controller;

  OutlineInputBorder _border(Color color) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(20),
      borderSide: BorderSide(color: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<MyTripCubit>();
    final palette = context.palette;
    final l10n = context.l10n;

    return _StepBody(
      children: [
        GlassCard(
          radius: 28,
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _StepHeading(title: l10n.tripLocationTitle, text: l10n.tripLocationText),
              const SizedBox(height: 10),
              _TripRecap(state: state),
              const SizedBox(height: 14),
              TextField(
                controller: controller,
                onChanged: cubit.updateLocation,
                onTapOutside: (_) => FocusScope.of(context).unfocus(),
                textInputAction: TextInputAction.done,
                textCapitalization: TextCapitalization.words,
                cursorColor: palette.ink,
                inputFormatters: [
                  LengthLimitingTextInputFormatter(TripPlannerService.maxLocationLength),
                ],
                style: TextStyle(color: palette.ink, fontSize: 16),
                decoration: InputDecoration(
                  hintText: l10n.tripLocationHint,
                  hintStyle: TextStyle(color: palette.muted),
                  filled: true,
                  fillColor: palette.tile,
                  prefixIcon: const Icon(Icons.location_on_outlined),
                  prefixIconColor: palette.ink,
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  border: _border(palette.hairline),
                  enabledBorder: _border(palette.hairline),
                  focusedBorder: _border(palette.accent),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.tripPopularAreas,
                textAlign: TextAlign.center,
                style: TextStyle(color: palette.muted, fontSize: 13),
              ),
              const SizedBox(height: 10),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final area in _areas)
                    _OptionChip(
                      label: l10n.areaLabel(area),
                      isSelected: state.location.trim() == area,
                      onTap: () {
                        FocusScope.of(context).unfocus();
                        cubit.updateLocation(area);
                      },
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CategoriesStep extends StatelessWidget {
  const _CategoriesStep({required this.state});

  final MyTripState state;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return _StepBody(
      children: [
        GlassCard(
          radius: 28,
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _StepHeading(
                title: l10n.tripInterestsTitle,
                text: state.isGenerating ? l10n.tripInterestsGenerating : l10n.tripInterestsText,
              ),
              const SizedBox(height: 10),
              _TripRecap(state: state),
              const SizedBox(height: 14),
              _CategoryGroup(title: l10n.tripMostPopular, categories: _popularInterests, state: state),
            ],
          ),
        ),
        const SizedBox(height: 12),
        GlassCard(
          radius: 28,
          padding: const EdgeInsets.all(14),
          child: _CategoryGroup(title: l10n.tripMoreCategories, categories: _otherInterests, state: state),
        ),
      ],
    );
  }
}

class _CategoryGroup extends StatelessWidget {
  const _CategoryGroup({required this.title, required this.categories, required this.state});

  final String title;
  final List<String> categories;
  final MyTripState state;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<MyTripCubit>();
    final palette = context.palette;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(color: palette.ink, fontSize: 15, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 10),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final category in categories)
              _OptionChip(
                label: context.l10n.interestLabel(category),
                isSelected: state.categories.contains(category),
                onTap: () => cubit.toggleCategory(category),
              ),
          ],
        ),
      ],
    );
  }
}

/// What the user has answered so far, to show the plan taking shape.
class _TripRecap extends StatelessWidget {
  const _TripRecap({required this.state});

  final MyTripState state;

  @override
  Widget build(BuildContext context) {
    final startDate = state.startDate;
    final days = state.stayLengthDays;
    if (startDate == null || days == null) return const SizedBox.shrink();

    final location = state.location.trim();
    final palette = context.palette;
    final l10n = context.l10n;

    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: palette.tile,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Wrap(
          alignment: WrapAlignment.center,
          spacing: 10,
          runSpacing: 2,
          children: [
            _RecapItem(icon: Icons.calendar_today_outlined, text: _stayText(l10n, startDate, days)),
            if (state.step == MyTripState.lastStep && location.isNotEmpty)
              _RecapItem(icon: Icons.location_on_outlined, text: l10n.areaLabel(location)),
          ],
        ),
      ),
    );
  }
}

class _RecapItem extends StatelessWidget {
  const _RecapItem({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: palette.ink),
        const SizedBox(width: 5),
        Flexible(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: palette.ink, fontSize: 12),
          ),
        ),
      ],
    );
  }
}

class _OptionChip extends StatelessWidget {
  const _OptionChip({required this.label, required this.isSelected, required this.onTap});

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Semantics(
      button: true,
      selected: isSelected,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            color: isSelected ? palette.accent : palette.tile,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: isSelected ? palette.accent : palette.hairline),
          ),
          child: Text(
            label,
            style: TextStyle(color: isSelected ? palette.onAccent : palette.ink, fontSize: 14),
          ),
        ),
      ),
    );
  }
}
