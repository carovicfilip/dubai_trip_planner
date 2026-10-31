# Dubai Trip Planner

A Flutter app for planning a trip to Dubai: curated places by category,
favorites, a weather forecast (OpenWeather) and AI-generated day-by-day
itineraries (OpenAI).

## Requirements

- Flutter 3.47.9 (stable), Dart 3.13
- iOS 15.0+ / macOS 12.0+: Xcode 27. Native dependencies come through Swift
  Package Manager; the project does not use CocoaPods.
- Android: minSdk 24, targetSdk 36, JDK 17+ (AGP 9.5, Gradle 9.8)

## Setup

1. Copy `.env.example` to `.env` and set `OPENAI_API_KEY`. `.env` is not
   committed, but it is bundled into the app as an asset, so the build fails
   without it and anything in it can be extracted from the installed app.
2. `flutter pub get`
3. `flutter run`

## Tests

- `flutter test` runs the unit and widget tests. The live OpenAI tests are
  skipped unless you opt in.
- `LIVE_AI_TEST=1 flutter test test/live/openai_live_test.dart` calls the real
  OpenAI API. It needs a real key and costs a fraction of a cent.
- The end-to-end journey runs on a simulator or device. It makes one real
  OpenAI call and writes screenshots and `report.json` to `e2e_out/`:

  ```sh
  E2E_OUT=e2e_out flutter drive --driver=test_driver/integration_test.dart \
    --target=integration_test/app_e2e_test.dart -d <device id>
  ```

## Notes

- Material widgets come from the `material_ui` package. Import
  `package:material_ui/material_ui.dart`, not `package:flutter/material.dart`.
  Mixing the two gives type errors, because `ThemeData`, `TextTheme` and the
  widgets are different classes in each.
- Launcher icons are generated with `dart run flutter_launcher_icons`; the
  configuration is in `pubspec.yaml`.
