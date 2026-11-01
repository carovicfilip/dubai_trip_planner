import 'package:dubai_trip_planner/features/my_trip/cubit/my_trip_cubit.dart';
import 'package:dubai_trip_planner/features/my_trip/services/trip_planner_service.dart';
import 'package:dubai_trip_planner/features/my_trip/ui/my_trip_screen.dart';
import 'package:dubai_trip_planner/features/my_trip/ui/widgets/promo_banner.dart';
import 'package:dubai_trip_planner/l10n/l10n.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  Future<void> pumpBanner(WidgetTester tester, {bool disableAnimations = false}) async {
    tester.view.physicalSize = const Size(800, 1600) * 3;
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(BlocProvider(
      create: (_) => MyTripCubit(TripPlannerService()),
      child: MediaQuery(
        data: MediaQueryData(size: const Size(800, 1600), disableAnimations: disableAnimations),
        child: const MaterialApp(localizationsDelegates: appLocalizationsDelegates, supportedLocales: AppLocalizations.supportedLocales, home: Scaffold(body: PromoBanner())),
      ),
    ));
  }

  testWidgets('is a low card without a photo or a label', (tester) async {
    await pumpBanner(tester);

    expect(find.byType(Image), findsNothing);
    expect(find.text('AI TRIP PLANNER'), findsNothing);
    expect(tester.getSize(find.byType(PromoBanner)).height, lessThan(140));
  });

  testWidgets('invites to plan a trip, and a tap anywhere on the card opens the planner', (tester) async {
    await pumpBanner(tester);
    expect(find.text('Your perfect Dubai trip,\nplanned in minutes'), findsOneWidget);
    expect(find.text('Plan My Trip'), findsOneWidget);

    await tester.tapAt(tester.getTopRight(find.byType(PromoBanner)) + const Offset(-20, 20));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.byType(MyTripScreen), findsOneWidget);
  });

  testWidgets('keeps animating to draw the eye', (tester) async {
    await pumpBanner(tester);

    await tester.pump(const Duration(seconds: 1));
    expect(tester.binding.hasScheduledFrame, isTrue);
  });

  testWidgets('stands still when the system asks for less motion', (tester) async {
    await pumpBanner(tester, disableAnimations: true);

    await tester.pump(const Duration(seconds: 1));
    expect(tester.binding.hasScheduledFrame, isFalse);
  });
}
