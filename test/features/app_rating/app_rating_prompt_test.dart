import 'package:dubai_trip_planner/core/models/place.dart';
import 'package:dubai_trip_planner/core/widgets/custom_back_button.dart';
import 'package:dubai_trip_planner/features/favorites/cubit/favorites_cubit.dart';
import 'package:dubai_trip_planner/features/place_details/ui/place_details_screen.dart';
import 'package:dubai_trip_planner/l10n/l10n.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  const storeChannel = MethodChannel('dev.britannio.in_app_review');
  const place = Place(
    id: 'test-place',
    name: 'Test Tower',
    imageUrl: 'assets/places_images/must_see_1.jpg',
    description: 'A very tall tower.',
    categoryId: 'must_see',
  );
  final question = find.text('How do you like\nthe app so far?');
  final sadFace = find.byIcon(Icons.sentiment_dissatisfied_outlined);
  final neutralFace = find.byIcon(Icons.sentiment_neutral_outlined);
  final happyFace = find.byIcon(Icons.sentiment_very_satisfied_outlined);

  late List<String> storeCalls;
  late bool storeFails;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    storeCalls = [];
    storeFails = false;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(storeChannel, (call) async {
      if (call.method == 'isAvailable') return true;
      storeCalls.add(call.method);
      if (storeFails) throw PlatformException(code: 'error');
      return null;
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(storeChannel, null);
  });

  Future<void> pumpApp(WidgetTester tester, {Size size = const Size(800, 1600)}) async {
    // Large surface on purpose: the test font draws every glyph 1em wide, far
    // wider than Poppins, so phone-size layout is checked on a real device.
    tester.view.physicalSize = size * 3;
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    final favorites = FavoritesCubit(await SharedPreferences.getInstance());
    await tester.pumpWidget(BlocProvider.value(
      value: favorites,
      child: MaterialApp(localizationsDelegates: appLocalizationsDelegates, supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PlaceDetailsScreen(place: place)),
              ),
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    ));
  }

  /// Opens the place and waits long enough for the question to have appeared.
  Future<void> openPlace(WidgetTester tester) async {
    await tester.tap(find.text('Open'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
  }

  Future<void> leavePlace(WidgetTester tester) async {
    await tester.tap(find.byType(CustomBackButton));
    await tester.pumpAndSettle();
  }

  testWidgets('the first place opened asks about the app, with three faces', (tester) async {
    await pumpApp(tester);
    await openPlace(tester);

    expect(question, findsOneWidget);
    expect(sadFace, findsOneWidget);
    expect(neutralFace, findsOneWidget);
    expect(happyFace, findsOneWidget);
    expect(storeCalls, isEmpty);
  });

  testWidgets('it waits for the screen to slide in first', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.text('Open'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byType(PlaceDetailsScreen), findsOneWidget);
    expect(question, findsNothing);
  });

  testWidgets('the happy face closes the question and asks the store for its dialog', (tester) async {
    await pumpApp(tester);
    await openPlace(tester);

    await tester.tap(happyFace);
    await tester.pumpAndSettle();

    expect(question, findsNothing);
    expect(storeCalls, ['requestReview']);
    expect(find.byType(PlaceDetailsScreen), findsOneWidget);
  });

  for (final (name, face) in [('sad', sadFace), ('neutral', neutralFace)]) {
    testWidgets('the $name face closes the question without the store', (tester) async {
      await pumpApp(tester);
      await openPlace(tester);

      await tester.tap(face);
      await tester.pumpAndSettle();

      expect(question, findsNothing);
      expect(storeCalls, isEmpty);
      expect(find.byType(PlaceDetailsScreen), findsOneWidget);
    });
  }

  testWidgets('a tap next to the question closes it without the store', (tester) async {
    await pumpApp(tester);
    await openPlace(tester);

    await tester.tapAt(const Offset(5, 5));
    await tester.pumpAndSettle();

    expect(question, findsNothing);
    expect(storeCalls, isEmpty);
    expect(find.byType(PlaceDetailsScreen), findsOneWidget);
  });

  testWidgets('it is asked only once, also after closing it without an answer or restarting the app', (tester) async {
    await pumpApp(tester);
    await openPlace(tester);
    await tester.tapAt(const Offset(5, 5));
    await tester.pumpAndSettle();
    await leavePlace(tester);

    await openPlace(tester);
    expect(question, findsNothing);
    await leavePlace(tester);

    await tester.pumpWidget(const SizedBox());
    await pumpApp(tester);
    await openPlace(tester);
    expect(question, findsNothing);
  });

  testWidgets('leaving right away keeps the question for the next visit', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.text('Open'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    await tester.tap(find.byType(CustomBackButton));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 1));
    expect(question, findsNothing);

    await openPlace(tester);
    expect(question, findsOneWidget);
  });

  testWidgets('it does not open over the previous screen while leaving', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.text('Open'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 700));

    // The time for it to appear passes during the transition back.
    await tester.tap(find.byType(CustomBackButton));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 150));
    await tester.pumpAndSettle();

    expect(find.byType(PlaceDetailsScreen), findsNothing);
    expect(question, findsNothing);

    await openPlace(tester);
    expect(question, findsOneWidget);
  });

  testWidgets('a store that fails goes unnoticed', (tester) async {
    storeFails = true;
    await pumpApp(tester);
    await openPlace(tester);

    await tester.tap(happyFace);
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(storeCalls, ['requestReview']);
    expect(question, findsNothing);
  });

  testWidgets('it fits a small phone', (tester) async {
    await pumpApp(tester, size: const Size(320, 568));
    await openPlace(tester);

    expect(question, findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.tap(happyFace);
    await tester.pumpAndSettle();
    expect(storeCalls, ['requestReview']);
  });
}
