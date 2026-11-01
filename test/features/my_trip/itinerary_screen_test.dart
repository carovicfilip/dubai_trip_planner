import 'package:dubai_trip_planner/core/constants/app_palette.dart';
import 'package:dubai_trip_planner/core/widgets/custom_back_button.dart';
import 'package:dubai_trip_planner/features/my_trip/cubit/my_trip_cubit.dart';
import 'package:dubai_trip_planner/features/my_trip/models/trip_plan.dart';
import 'package:dubai_trip_planner/features/my_trip/services/trip_plan_storage.dart';
import 'package:dubai_trip_planner/features/my_trip/services/trip_planner_service.dart';
import 'package:dubai_trip_planner/features/my_trip/ui/itinerary_screen.dart';
import 'package:dubai_trip_planner/features/my_trip/ui/widgets/day_card.dart';
import 'package:dubai_trip_planner/features/my_trip/ui/widgets/day_deck.dart';
import 'package:dubai_trip_planner/features/my_trip/ui/widgets/day_grid.dart';
import 'package:dubai_trip_planner/features/my_trip/ui/widgets/trip_form_button.dart';
import 'package:dubai_trip_planner/l10n/l10n.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  TripPlan planStarting(DateTime start, int days) => TripPlan(
        location: 'Downtown Dubai',
        startDate: start,
        lengthInDays: days,
        categories: const ['Attractions', 'Restaurants', 'Shopping', 'Rooftops'],
        days: [
          for (var i = 1; i <= days; i++)
            DailyPlan(title: 'Day $i: Theme $i', highlights: ['Morning: activity $i', 'Evening: dinner $i']),
        ],
      );

  /// Shows [plan] as the saved plan; returns the cubit that keeps it.
  Future<MyTripCubit> pumpItinerary(
    WidgetTester tester,
    TripPlan plan, {
    bool disableAnimations = false,
    Locale locale = const Locale('en'),
  }) async {
    // Large surface on purpose: the test font draws every glyph 1em wide, far
    // wider than Poppins, so phone-size layout is checked on a real device.
    tester.view.physicalSize = const Size(800 * 3, 1600 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await TripPlanStorage.savePlans([plan]);
    final cubit = MyTripCubit(TripPlannerService());
    await cubit.loadSavedPlans();
    await tester.pumpWidget(BlocProvider.value(
      value: cubit,
      child: MediaQuery(
        data: MediaQueryData(size: const Size(800, 1600), disableAnimations: disableAnimations),
        child: MaterialApp(
          locale: locale,
          localizationsDelegates: appLocalizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: ItineraryScreen(plan: plan),
        ),
      ),
    ));
    await tester.pumpAndSettle();
    return cubit;
  }

  Future<void> swipe(WidgetTester tester, double dx) async {
    await tester.drag(find.byType(DayDeck), Offset(dx, 0));
    await tester.pumpAndSettle();
  }

  Future<void> tapAndSettle(WidgetTester tester, Finder finder) async {
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  Finder inTopCard(String text) => find.text(text).hitTestable();

  Future<TripPlan> storedPlan() async => (await TripPlanStorage.loadPlans()).first;

  testWidgets('shows the overview and the first day on top of the deck', (tester) async {
    await pumpItinerary(tester, planStarting(DateTime(2026, 11, 10), 3));

    expect(find.text('3-day stay in Downtown Dubai'), findsOneWidget);
    expect(find.text('Attractions, Restaurants, Shopping…'), findsOneWidget);
    expect(inTopCard('Day 1: Theme 1'), findsOneWidget);
    expect(inTopCard('Morning: activity 1'), findsOneWidget);
    expect(find.text('Day 1 of 3'), findsOneWidget);
  });

  testWidgets("shows the day's area and how to get to every stop", (tester) async {
    const highlight = 'Morning: Burj Khalifa (Downtown Dubai) – Views from level 124.\n'
        'Getting there: 25 min by taxi from your accommodation';
    await pumpItinerary(
      tester,
      TripPlan(
        location: 'Dubai Marina',
        startDate: DateTime(2026, 11, 10),
        lengthInDays: 2,
        categories: const ['Attractions'],
        days: const [
          DailyPlan(title: 'Day 1: Icons', area: 'Downtown Dubai & Business Bay', highlights: [highlight]),
          // Saved before days had an area.
          DailyPlan(title: 'Day 2: Old Dubai', highlights: ['Morning: Al Fahidi']),
        ],
      ),
    );

    expect(find.text('Downtown Dubai & Business Bay'), findsOneWidget);
    expect(find.byIcon(Icons.location_on_outlined), findsOneWidget, reason: 'only the day with an area shows one');
    expect(find.text(highlight), findsOneWidget);
  });

  group('the deck', () {
    testWidgets('never moves by itself', (tester) async {
      await pumpItinerary(tester, planStarting(DateTime(2026, 11, 10), 3));

      expect(tester.binding.hasScheduledFrame, isFalse);
      await tester.pump(const Duration(seconds: 12));

      expect(tester.binding.hasScheduledFrame, isFalse);
      expect(find.text('Day 1 of 3'), findsOneWidget);
      expect(inTopCard('Day 1: Theme 1'), findsOneWidget);
    });

    testWidgets('swipes to the next and the previous day, and stops at both ends', (tester) async {
      await pumpItinerary(tester, planStarting(DateTime(2026, 11, 10), 2));

      await swipe(tester, 500);
      expect(find.text('Day 1 of 2'), findsOneWidget, reason: 'there is nothing before the first day');

      await swipe(tester, -500);
      expect(find.text('Day 2 of 2'), findsOneWidget);
      expect(inTopCard('Day 2: Theme 2'), findsOneWidget);

      await swipe(tester, -500);
      expect(find.text('Day 2 of 2'), findsOneWidget, reason: 'there is nothing after the last day');

      await swipe(tester, 500);
      expect(find.text('Day 1 of 2'), findsOneWidget);
      expect(inTopCard('Day 1: Theme 1'), findsOneWidget);
    });

    testWidgets('a small drag stays on the same day', (tester) async {
      await pumpItinerary(tester, planStarting(DateTime(2026, 11, 10), 3));

      final gesture = await tester.startGesture(tester.getCenter(find.byType(DayDeck)));
      await gesture.moveBy(const Offset(-30, 0));
      await tester.pump(const Duration(milliseconds: 500));
      await gesture.moveBy(const Offset(-10, 0));
      await tester.pump(const Duration(milliseconds: 500));
      await gesture.up();
      await tester.pumpAndSettle();

      expect(find.text('Day 1 of 3'), findsOneWidget);
    });

    testWidgets('has arrows too, which end where the days do', (tester) async {
      await pumpItinerary(tester, planStarting(DateTime(2026, 11, 10), 2));
      IconButton arrow(String tooltip) => tester.widget<IconButton>(find.widgetWithIcon(
            IconButton,
            tooltip == 'Next day' ? Icons.chevron_right : Icons.chevron_left,
          ));

      expect(arrow('Previous day').onPressed, isNull);
      await tapAndSettle(tester, find.byTooltip('Next day'));
      expect(find.text('Day 2 of 2'), findsOneWidget);
      expect(inTopCard('Day 2: Theme 2'), findsOneWidget);
      expect(arrow('Next day').onPressed, isNull);

      await tapAndSettle(tester, find.byTooltip('Previous day'));
      expect(find.text('Day 1 of 2'), findsOneWidget);
    });

    testWidgets('jumps instead of animating when the system asks for less motion', (tester) async {
      await pumpItinerary(tester, planStarting(DateTime(2026, 11, 10), 3), disableAnimations: true);

      await tester.tap(find.byTooltip('Next day'));
      await tester.pump();

      expect(find.text('Day 2 of 3'), findsOneWidget);
      expect(inTopCard('Day 2: Theme 2'), findsOneWidget, reason: 'there at once, with no frames in between');
    });

    testWidgets('only the card on top can be touched', (tester) async {
      await pumpItinerary(tester, planStarting(DateTime(2026, 11, 10), 3));

      expect(find.text('Morning: activity 2').hitTestable(), findsNothing);
    });
  });

  group('the grid', () {
    testWidgets('shows every day, and a tap brings that day to the top of the deck', (tester) async {
      await pumpItinerary(tester, planStarting(DateTime(2026, 11, 10), 6));

      await tapAndSettle(tester, find.byTooltip('Show as a grid'));
      expect(find.byType(DayDeck), findsNothing);
      for (var i = 1; i <= 4; i++) {
        expect(find.text('Day $i'), findsOneWidget);
        expect(find.text('Theme $i'), findsOneWidget);
      }

      await tapAndSettle(tester, find.text('Day 4'));

      expect(find.byType(DayGrid), findsNothing);
      expect(find.text('Day 4 of 6'), findsOneWidget);
      expect(inTopCard('Day 4: Theme 4'), findsOneWidget);
    });

    testWidgets('the deck goes through the days on its way there', (tester) async {
      await pumpItinerary(tester, planStarting(DateTime(2026, 11, 10), 6));
      await tapAndSettle(tester, find.byTooltip('Show as a grid'));

      await tester.tap(find.text('Day 5'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(tester.binding.hasScheduledFrame, isTrue);
      expect(inTopCard('Day 5: Theme 5'), findsNothing, reason: 'not there yet');
      await tester.pumpAndSettle();
      expect(inTopCard('Day 5: Theme 5'), findsOneWidget);
    });

    testWidgets('the button goes back to the deck, on the same day', (tester) async {
      await pumpItinerary(tester, planStarting(DateTime(2026, 11, 10), 3));
      await tapAndSettle(tester, find.byTooltip('Next day'));

      await tapAndSettle(tester, find.byTooltip('Show as a grid'));
      await tapAndSettle(tester, find.byTooltip('Show as a deck'));

      expect(find.text('Day 2 of 3'), findsOneWidget);
    });

    // Regression test for DST time zones such as Europe/Belgrade: adding
    // Duration(days: n) to local midnight landed on 23:00 of the previous day
    // after the clocks went back (25 Oct 2026), so a date repeated.
    testWidgets('day dates stay consecutive across the end of daylight saving time', (tester) async {
      await pumpItinerary(tester, planStarting(DateTime(2026, 10, 23), 5));

      await tapAndSettle(tester, find.byTooltip('Show as a grid'));

      for (final day in [23, 24, 25, 26, 27]) {
        expect(find.text('October $day, 2026'), findsOneWidget, reason: 'expected exactly one card dated October $day');
      }
      expect(find.text('October 23, 2026 – October 27, 2026'), findsOneWidget);
    });

    testWidgets('marks a finished day', (tester) async {
      await pumpItinerary(tester, planStarting(DateTime(2026, 11, 10), 2));
      await tester.tap(find.byType(Checkbox).hitTestable().first);
      await tester.pump();
      await tester.tap(find.byType(Checkbox).hitTestable().last);
      await tester.pumpAndSettle();

      await tapAndSettle(tester, find.byTooltip('Show as a grid'));

      expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
    });
  });

  group('checking off', () {
    testWidgets('a checkbox checks an item off and back, and it is kept', (tester) async {
      final cubit = await pumpItinerary(tester, planStarting(DateTime(2026, 11, 10), 2));
      expect(inTopCard('0 of 2 done'), findsOneWidget);

      await tester.tap(find.byType(Checkbox).hitTestable().first);
      await tester.pumpAndSettle();

      expect(inTopCard('1 of 2 done'), findsOneWidget);
      expect(cubit.state.savedPlans.first.days[0].isDone(0), isTrue);
      expect((await storedPlan()).days[0].isDone(0), isTrue);

      await tester.tap(find.byType(Checkbox).hitTestable().first);
      await tester.pumpAndSettle();

      expect(inTopCard('0 of 2 done'), findsOneWidget);
      expect((await storedPlan()).days[0].isDone(0), isFalse);
    });

    testWidgets('the circle of a checked item is green, and its text stays as it was colored', (tester) async {
      await pumpItinerary(tester, planStarting(DateTime(2026, 11, 10), 1));

      await tester.tap(find.byType(Checkbox).first);
      await tester.pumpAndSettle();

      final box = tester.widget<Checkbox>(find.byType(Checkbox).first);
      expect(box.value, isTrue);
      expect(box.activeColor, AppPalette.light.success);
      final text = tester.widget<Text>(find.text('Morning: activity 1'));
      expect(text.textSpan!.style!.color, isNot(AppPalette.light.success));
    });

    group('a day with everything checked off', () {
      Color cardColor(WidgetTester tester) {
        return tester.widget<Material>(find.descendant(of: find.byType(DayCard), matching: find.byType(Material)).first).color!;
      }

      testWidgets('turns green only once the last item is checked, and back', (tester) async {
        await pumpItinerary(tester, planStarting(DateTime(2026, 11, 10), 1));
        expect(cardColor(tester), AppPalette.light.card);

        await tester.tap(find.byType(Checkbox).first);
        await tester.pumpAndSettle();
        expect(cardColor(tester), AppPalette.light.card, reason: 'one of two is not all');

        await tester.tap(find.byType(Checkbox).last);
        await tester.pumpAndSettle();
        expect(cardColor(tester), AppPalette.light.successSurface);

        await tester.tap(find.byType(Checkbox).last);
        await tester.pumpAndSettle();
        expect(cardColor(tester), AppPalette.light.card);
      });

      testWidgets('is green in the grid as well', (tester) async {
        final plan = planStarting(DateTime(2026, 11, 10), 2);
        final finished = plan.days[0].withItemToggled(0).withItemToggled(1);
        await pumpItinerary(tester, plan.withDay(0, finished));

        await tapAndSettle(tester, find.byTooltip('Show as a grid'));

        Color tileColor(String day) => tester
            .widget<Material>(find.ancestor(of: find.text(day), matching: find.byType(Material)).first)
            .color!;
        expect(tileColor('Day 1'), AppPalette.light.successSurface);
        expect(tileColor('Day 2'), AppPalette.light.card);
      });

      testWidgets('an empty day is not a finished one', (tester) async {
        await pumpItinerary(
          tester,
          TripPlan(
            location: 'Deira',
            startDate: DateTime(2026, 11, 10),
            lengthInDays: 1,
            categories: const ['Spas'],
            days: const [DailyPlan(title: 'Day 1', highlights: [])],
          ),
        );

        expect(cardColor(tester), AppPalette.light.card);
      });

      testWidgets('adding to it takes the green away again', (tester) async {
        final plan = planStarting(DateTime(2026, 11, 10), 1);
        await pumpItinerary(tester, plan.withDay(0, plan.days[0].withItemToggled(0).withItemToggled(1)));
        expect(cardColor(tester), AppPalette.light.successSurface);

        await tapAndSettle(tester, find.text('Add to this day'));
        await tester.enterText(find.byType(TextField), 'Spa');
        await tester.pumpAndSettle();
        await tapAndSettle(tester, find.text('Add'));

        expect(cardColor(tester), AppPalette.light.card);
      });
    });

    testWidgets('a tap on the text does the same', (tester) async {
      await pumpItinerary(tester, planStarting(DateTime(2026, 11, 10), 2));

      await tapAndSettle(tester, find.text('Evening: dinner 1'));

      expect((await storedPlan()).days[0].isDone(1), isTrue);
    });

    testWidgets('an item checked off earlier shows as checked off', (tester) async {
      final plan = planStarting(DateTime(2026, 11, 10), 1);
      await pumpItinerary(tester, plan.withDay(0, plan.days[0].withItemToggled(1)));

      expect(inTopCard('1 of 2 done'), findsOneWidget);
      final boxes = tester.widgetList<Checkbox>(find.byType(Checkbox)).toList();
      expect(boxes.map((box) => box.value), [false, true]);
    });
  });

  group('editing a day', () {
    Future<TripPlan> startEditing(WidgetTester tester, {int days = 2}) async {
      final plan = planStarting(DateTime(2026, 11, 10), days);
      await pumpItinerary(tester, plan);
      await tapAndSettle(tester, find.byTooltip('Edit this day').hitTestable());
      return plan;
    }

    testWidgets('swaps the checkboxes for handles and delete buttons', (tester) async {
      await startEditing(tester);

      expect(find.byType(Checkbox).hitTestable(), findsNothing);
      expect(find.byIcon(Icons.drag_handle_rounded), findsNWidgets(2));
      expect(find.byTooltip('Delete'), findsNWidgets(2));

      await tapAndSettle(tester, find.byTooltip('Done editing'));

      expect(find.byType(Checkbox).hitTestable(), findsNWidgets(2));
      expect(find.byIcon(Icons.drag_handle_rounded), findsNothing);
    });

    testWidgets('a tap on the text does not check it off', (tester) async {
      await startEditing(tester);

      await tapAndSettle(tester, find.text('Evening: dinner 1'));

      expect((await storedPlan()).days[0].doneCount, 0);
    });

    testWidgets('deleting takes the item out, and Undo puts it back as it was', (tester) async {
      final plan = planStarting(DateTime(2026, 11, 10), 1);
      await pumpItinerary(tester, plan.withDay(0, plan.days[0].withItemToggled(0)));
      await tapAndSettle(tester, find.byTooltip('Edit this day').hitTestable());

      await tester.tap(find.byTooltip('Delete').first);
      await tester.pumpAndSettle();

      expect(find.text('Morning: activity 1'), findsNothing);
      expect((await storedPlan()).days[0].highlights, ['Evening: dinner 1']);

      await tester.tap(find.text('Undo'));
      await tester.pumpAndSettle();

      expect(find.text('Morning: activity 1'), findsOneWidget);
      final restored = (await storedPlan()).days[0];
      expect(restored.highlights, ['Morning: activity 1', 'Evening: dinner 1']);
      expect(restored.isDone(0), isTrue);
    });

    testWidgets('the notice about a deleted item goes away by itself', (tester) async {
      await startEditing(tester);

      await tester.tap(find.byTooltip('Delete').first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('Undo'), findsOneWidget);

      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();
      expect(find.text('Undo'), findsNothing);
    });

    testWidgets('a day with nothing left says so, and something can be added', (tester) async {
      await startEditing(tester);

      await tester.tap(find.byTooltip('Delete').first);
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Delete').first);
      await tester.pumpAndSettle();

      expect(find.text('Nothing planned for this day yet.'), findsOneWidget);
      expect((await storedPlan()).days[0].highlights, isEmpty);
      expect(find.text('Add to this day').hitTestable(), findsOneWidget);
    });

    testWidgets('an item can be dragged to another place', (tester) async {
      await startEditing(tester);

      final handle = tester.getCenter(find.byIcon(Icons.drag_handle_rounded).first);
      final other = tester.getCenter(find.byIcon(Icons.drag_handle_rounded).last);
      final gesture = await tester.startGesture(handle);
      await tester.pump(const Duration(milliseconds: 100));
      // The first move only starts the drag.
      await gesture.moveBy(const Offset(0, 30));
      await tester.pump(const Duration(milliseconds: 100));
      await gesture.moveTo(other + const Offset(0, 40));
      await tester.pump(const Duration(milliseconds: 300));
      await gesture.up();
      await tester.pumpAndSettle();

      expect((await storedPlan()).days[0].highlights, ['Evening: dinner 1', 'Morning: activity 1']);
    });

    testWidgets('the deck stays put while editing, and another day ends the editing', (tester) async {
      await startEditing(tester, days: 3);

      await swipe(tester, -500);
      expect(find.text('Day 1 of 3'), findsOneWidget, reason: 'a swipe could be a slip while moving items');

      await tapAndSettle(tester, find.byTooltip('Next day'));
      expect(find.text('Day 2 of 3'), findsOneWidget);
      expect(find.byIcon(Icons.drag_handle_rounded), findsNothing);
    });
  });

  group('adding to a day', () {
    Future<void> openSheet(WidgetTester tester) async {
      await tapAndSettle(tester, find.text('Add to this day').hitTestable());
    }

    bool isAddLocked(WidgetTester tester) {
      final button = find.descendant(of: find.byType(TripFormButton), matching: find.byType(TextButton));
      return tester.widget<TextButton>(button).onPressed == null;
    }

    testWidgets('puts the new item at the end, on the day on top, and keeps it', (tester) async {
      await pumpItinerary(tester, planStarting(DateTime(2026, 11, 10), 3));
      await tapAndSettle(tester, find.byTooltip('Next day'));

      await openSheet(tester);
      expect(find.text('Add to Day 2'), findsOneWidget);
      await tester.enterText(find.byType(TextField), '  Coffee at the Marina ');
      await tester.pumpAndSettle();
      await tapAndSettle(tester, find.text('Add'));

      expect(find.text('Coffee at the Marina').hitTestable(), findsOneWidget);
      final stored = await storedPlan();
      expect(stored.days[1].highlights.last, 'Coffee at the Marina');
      expect(stored.days[1].highlights, hasLength(3));
      expect(stored.days[0].highlights, hasLength(2));
    });

    testWidgets('the button stays locked without any text', (tester) async {
      await pumpItinerary(tester, planStarting(DateTime(2026, 11, 10), 1));
      await openSheet(tester);

      expect(isAddLocked(tester), isTrue);
      await tester.enterText(find.byType(TextField), '   ');
      await tester.pump();
      expect(isAddLocked(tester), isTrue);

      await tester.enterText(find.byType(TextField), 'Spa');
      await tester.pump();
      expect(isAddLocked(tester), isFalse);
    });

    testWidgets('closing the sheet adds nothing', (tester) async {
      await pumpItinerary(tester, planStarting(DateTime(2026, 11, 10), 1));
      await openSheet(tester);
      await tester.enterText(find.byType(TextField), 'Spa');

      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();

      expect((await storedPlan()).days[0].highlights, hasLength(2));
    });
  });

  group('in another language', () {
    TripPlan planIn(String title, String highlight, {int days = 1}) => TripPlan(
          location: 'Deira',
          startDate: DateTime(2026, 11, 10),
          lengthInDays: days,
          categories: const ['Beaches'],
          days: [
            for (var i = 0; i < days; i++) DailyPlan(title: title, highlights: [highlight]),
          ],
        );

    testWidgets('the screen follows the app, in its own words and dates', (tester) async {
      await pumpItinerary(tester, planIn('Tag 1', 'Morgens: Burj Khalifa'), locale: const Locale('de'));

      expect(find.text('Dein Reiseplan'), findsOneWidget);
      expect(find.text('1 Tag in Deira'), findsOneWidget);
      expect(find.text('Strände'), findsOneWidget);
      expect(find.textContaining('10. November 2026'), findsWidgets);
      expect(find.text('Tag 1 von 1'), findsOneWidget);
      expect(find.text('Zu diesem Tag hinzufügen'), findsOneWidget);
    });

    testWidgets('an English plan stays left to right in an Arabic app', (tester) async {
      await pumpItinerary(tester, planIn('Day 1: Souks', 'Morning: Gold Souk'), locale: const Locale('ar'));

      expect(Directionality.of(tester.element(find.byType(Scaffold))), TextDirection.rtl);
      expect(Directionality.of(tester.element(find.text('Day 1: Souks'))), TextDirection.ltr);
    });

    testWidgets('an Arabic plan stays right to left in an English app', (tester) async {
      await pumpItinerary(tester, planIn('اليوم 1: الأسواق', 'الصباح: سوق الذهب'));

      expect(Directionality.of(tester.element(find.byType(Scaffold))), TextDirection.ltr);
      expect(Directionality.of(tester.element(find.text('اليوم 1: الأسواق'))), TextDirection.rtl);
    });

    testWidgets('written right to left, the deck swipes the other way', (tester) async {
      await pumpItinerary(tester, planStarting(DateTime(2026, 11, 10), 2), locale: const Locale('ar'));

      await swipe(tester, -500);
      expect(find.text('اليوم 1 من 2'), findsOneWidget, reason: 'to the left is back there, and this is the first day');

      await swipe(tester, 500);
      expect(find.text('اليوم 2 من 2'), findsOneWidget);
    });

    testWidgets('the grid finds the theme of a day whatever language the plan is in', (tester) async {
      await pumpItinerary(tester, planIn('Tag 1: Altstadt', 'Morgens: Souk'), locale: const Locale('de'));

      await tapAndSettle(tester, find.byTooltip('Als Raster anzeigen'));

      expect(find.text('Altstadt'), findsOneWidget);
    });
  });

  testWidgets('the back button leaves the screen', (tester) async {
    tester.view.physicalSize = const Size(800 * 3, 1600 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    final plan = planStarting(DateTime(2026, 11, 10), 2);
    await tester.pumpWidget(BlocProvider(
      create: (_) => MyTripCubit(TripPlannerService()),
      child: MaterialApp(
        localizationsDelegates: appLocalizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ItineraryScreen(plan: plan))),
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(CustomBackButton));
    await tester.pumpAndSettle();

    expect(find.byType(ItineraryScreen), findsNothing);
  });

  testWidgets('fits a small phone, as a deck and as a grid', (tester) async {
    await pumpItinerary(tester, planStarting(DateTime(2026, 11, 10), 3));
    tester.view.physicalSize = const Size(320 * 3, 568 * 3);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    await tapAndSettle(tester, find.byTooltip('Show as a grid'));
    expect(tester.takeException(), isNull);
  });
}
