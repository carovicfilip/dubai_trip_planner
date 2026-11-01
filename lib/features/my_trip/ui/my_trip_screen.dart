import 'package:dubai_trip_planner/core/constants/app_palette.dart';
import 'package:dubai_trip_planner/core/widgets/frosted_app_bar.dart';
import 'package:dubai_trip_planner/features/my_trip/cubit/my_trip_cubit.dart';
import 'package:dubai_trip_planner/features/my_trip/models/trip_plan.dart';
import 'package:dubai_trip_planner/features/my_trip/services/trip_planner_service.dart';
import 'package:dubai_trip_planner/features/my_trip/ui/itinerary_screen.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:intl/intl.dart';

const _interests = [
  'Restaurants',
  'Attractions',
  'Cafes',
  'Breakfast and brunch',
  'Bakeries',
  'Bars',
  'Shopping',
  'Nightlife',
  'Museums',
  'Art museums',
  'Science & space museums',
  'Theme parks',
  'Arts and culture',
  'Parks and gardens',
  'Beaches',
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

class MyTripScreen extends StatefulWidget {
  const MyTripScreen({super.key});

  @override
  State<MyTripScreen> createState() => _MyTripScreenState();
}

class _MyTripScreenState extends State<MyTripScreen> {
  // What the user types is kept in MyTripCubit; the controllers mirror it.
  late final TextEditingController _stayLengthCtrl;
  late final TextEditingController _accommodationCtrl;

  @override
  void initState() {
    super.initState();
    final cubit = context.read<MyTripCubit>();
    _stayLengthCtrl = TextEditingController(text: cubit.state.stayLength);
    _accommodationCtrl = TextEditingController(text: cubit.state.location);
    cubit.loadSavedPlan();
  }

  @override
  void dispose() {
    _accommodationCtrl.dispose();
    _stayLengthCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final cubit = context.read<MyTripCubit>();
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(now.year + 1, now.month, now.day),
    );
    if (picked != null) cubit.selectStartDate(picked);
  }

  Future<void> _handleShowResults() async {
    final cubit = context.read<MyTripCubit>();
    var error = cubit.state.formError;
    if (error == MyTripFormError.tooLong) {
      final planFirstPart = await _askToPlanFirstPart(cubit.state.stayLengthDays!);
      if (!mounted || !planFirstPart) return;
      cubit.shortenToMaxDays();
      error = cubit.state.formError;
    }
    if (error != null) {
      _showFormError(error);
      return;
    }

    try {
      final plan = await cubit.generatePlan();
      if (!mounted) return;
      _openItinerary(plan);
    } catch (error) {
      // The error can hold OpenAI's raw JSON: log it, show the user a short message.
      debugPrint('Trip plan generation failed: $error');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(TripPlannerService.userMessage(error)),
        ),
      );
    }
  }

  void _showFormError(MyTripFormError error) {
    final message = switch (error) {
      MyTripFormError.missingDate => 'Please select your trip date (Step 1)',
      MyTripFormError.missingLength => 'Please enter trip duration (Step 1)',
      MyTripFormError.tooLong => 'Please enter up to ${TripPlannerService.maxTripDays} days (Step 1)',
      MyTripFormError.missingLocation => 'Please enter your accommodation location (Step 2)',
      MyTripFormError.missingCategories => 'Please select at least one category (Step 3)',
    };
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
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

  /// Explains the [TripPlannerService.maxTripDays] limit and how to split a
  /// longer stay. Returns true when the user wants the first part planned now.
  Future<bool> _askToPlanFirstPart(int days) async {
    const maxDays = TripPlannerService.maxTripDays;
    final startDate = context.read<MyTripCubit>().state.startDate!;
    final nextPartStart = DateFormat.yMMMMd().format(DateUtils.addDaysToDate(startDate, maxDays));
    final planFirstPart = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: context.palette.card,
        title: const Text('Up to $maxDays days per plan'),
        content: Text(
          'To keep every day detailed, one plan covers at most $maxDays days.\n\n'
          'Split your $days-day stay into parts: plan the first $maxDays days now, then come back '
          'and create a new plan starting $nextPartStart for the rest of your trip.\n\n'
          'Note: each new plan replaces the one you have saved.',
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Change length'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Plan first $maxDays days'),
          ),
        ],
      ),
    );
    return planFirstPart ?? false;
  }

  Future<void> _confirmDeleteTrip() async {
    final cubit = context.read<MyTripCubit>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: context.palette.card,
        title: const Text('Delete Trip?'),
        content: const Text('Are you sure you want to delete this trip? This action cannot be undone.'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) await cubit.deletePlan();
  }

  static void _showText(TextEditingController controller, String text) {
    if (controller.text != text) controller.text = text;
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MyTripCubit, MyTripState>(
      // Restoring the saved plan, shortening the stay and deleting the plan
      // change the text without the user typing it.
      listener: (context, state) {
        _showText(_stayLengthCtrl, state.stayLength);
        _showText(_accommodationCtrl, state.location);
      },
      builder: (context, state) {
        final palette = context.palette;
        final cubit = context.read<MyTripCubit>();
        final savedPlan = state.savedPlan;
        final startDate = state.startDate;
        final dateText = startDate != null ? DateFormat.yMMMMd().format(startDate) : 'Select date';

        return Scaffold(
          resizeToAvoidBottomInset: true,
          extendBodyBehindAppBar: true,
          appBar: const FrostedAppBar(title: 'Plan Your Trip'),
          body: AbsorbPointer(
            absorbing: state.isGenerating,
            child: Container(
              color: palette.surface,
              child: SafeArea(
                top: false,
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(16, FrostedAppBar.heightOn(context) + 16, 16, 140),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (savedPlan != null)
                        _SavedPlanCard(
                          plan: savedPlan,
                          onTap: () => _openItinerary(savedPlan),
                          onDelete: _confirmDeleteTrip,
                        ),
                      _StepCard(
                        step: 1,
                        title: 'Choose Date',
                        description:
                            "Select when your Dubai adventure begins. Pick your arrival date and how many days you'll be staying to create a personalized itinerary.",
                        children: [
                          const SizedBox(height: 14),
                          GestureDetector(
                            onTap: _pickDate,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              decoration: BoxDecoration(
                                color: palette.tile,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(dateText, style: const TextStyle(fontSize: 16)),
                                  const Icon(Icons.calendar_today_outlined),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "Trip Duration",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: palette.ink),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _stayLengthCtrl,
                            onChanged: cubit.updateStayLength,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: "How many days you stay (up to ${TripPlannerService.maxTripDays})",
                              filled: true,
                              fillColor: palette.tile,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              prefixIcon: const Icon(Icons.calendar_view_week_outlined),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _StepCard(
                        step: 2,
                        title: 'Select your accommodation location',
                        description:
                            "Tell us where you'll be staying in Dubai, ideally the hotel's name. This helps us optimize your itinerary based on proximity to attractions, restaurants, and activities.",
                        children: [
                          const SizedBox(height: 20),
                          TextField(
                            controller: _accommodationCtrl,
                            onChanged: cubit.updateLocation,
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(TripPlannerService.maxLocationLength),
                            ],
                            decoration: InputDecoration(
                              hintText: "e.g. Dubai Marina, Downtown, JBR…",
                              filled: true,
                              fillColor: palette.tile,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: BorderSide.none,
                              ),
                              prefixIcon: const Icon(Icons.location_on_outlined),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _StepCard(
                        step: 3,
                        title: 'Choose Categories',
                        description:
                            "Select the types of places and experiences you're interested in. Choose multiple categories to create a diverse and exciting trip plan tailored to your preferences.",
                        children: [
                          const SizedBox(height: 20),
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: [
                              for (final interest in _interests)
                                ChoiceChip(
                                  label: Text(interest),
                                  selected: state.categories.contains(interest),
                                  selectedColor: palette.accent,
                                  checkmarkColor: palette.onAccent,
                                  labelStyle: TextStyle(
                                    color: state.categories.contains(interest) ? palette.onAccent : palette.ink,
                                  ),
                                  backgroundColor: palette.card,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  onSelected: (_) => cubit.toggleCategory(interest),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          /// ✅ Fiksirano dugme dole
          floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
          floatingActionButton: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: TextButton(
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all<Color>(palette.accent),
                  foregroundColor: WidgetStateProperty.all<Color>(palette.onAccent),
                  overlayColor: WidgetStateProperty.all(palette.onAccent.withValues(alpha: 0.08)),
                  shape: WidgetStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                onPressed: state.isGenerating ? null : _handleShowResults,
                child: state.isGenerating
                    ? SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.6,
                          valueColor: AlwaysStoppedAnimation<Color>(palette.onAccent),
                        ),
                      )
                    : Text(
                        "Show Results",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: palette.onAccent),
                      ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// The saved plan: tap to open it, swipe it left to delete it.
class _SavedPlanCard extends StatelessWidget {
  const _SavedPlanCard({
    required this.plan,
    required this.onTap,
    required this.onDelete,
  });

  final TripPlan plan;
  final VoidCallback onTap;
  final Future<void> Function() onDelete;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key('${plan.location}_${plan.startDate.toIso8601String()}_${plan.lengthInDays}'),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(24),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(
          Icons.delete_outline,
          color: Colors.white,
          size: 32,
        ),
      ),
      confirmDismiss: (direction) async {
        await onDelete();
        return false; // The dialog deletes the plan, which removes this card.
      },
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          margin: const EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            color: context.palette.heroCard,
            borderRadius: BorderRadius.circular(24),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 12,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Your Tailored Itinerary',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(
                '${DateFormat.yMMMMd().format(plan.startDate)} · ${plan.lengthInDays} days · ${plan.location}',
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 12),
              const Row(
                children: [
                  Icon(Icons.auto_awesome, color: Colors.amber, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Tap to review the AI-crafted day-by-day plan.',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// One numbered step of the form: its header, title and description, then
/// the step's own fields in [children].
class _StepCard extends StatelessWidget {
  const _StepCard({
    required this.step,
    required this.title,
    required this.description,
    required this.children,
  });

  final int step;
  final String title;
  final String description;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: palette.card,
        border: Border.all(color: palette.hairline, width: 1),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: palette.muted, width: 2),
                ),
                child: Center(
                  child: Text(
                    '$step',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: palette.muted,
                    ),
                  ),
                ),
              ),
              Text(
                " Step",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: palette.muted),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: palette.ink),
          ),
          const SizedBox(height: 10),
          Text(
            description,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w300, color: palette.ink),
          ),
          ...children,
        ],
      ),
    );
  }
}
