# Dubai Trip Planner

A Flutter app for planning a trip to Dubai: curated places by category,
favorites, a weather forecast (OpenWeather) and AI-generated day-by-day
itineraries (OpenAI). Both go through the app's backend, a Cloudflare Worker
in `backend/` that holds the API keys; the app itself has none.

## Requirements

- Flutter 3.47.9 (stable), Dart 3.13
- iOS 15.0+ / macOS 12.0+: Xcode 27. Native dependencies come through Swift
  Package Manager; the project does not use CocoaPods.
- Android: minSdk 24, targetSdk 36, JDK 17+ (AGP 9.5, Gradle 9.8)

## Setup

1. `flutter pub get`
2. On a simulator or emulator, App Check needs a debug token, because only a
   real device can pass Play Integrity or App Attest. Create one in the
   Firebase console (project `dubaitripplanner-ae015` → App Check → Apps →
   ⋮ → Manage debug tokens), put it into `app_check_debug.json` (not in git)
   as `{"APP_CHECK_DEBUG_TOKEN": "..."}` and run
   `flutter run --dart-define-from-file=app_check_debug.json`.
   Without the token the app works, but the backend refuses the trip planner
   and the forecast. Release builds never use the debug token.
3. Paywalls come from Superwall. Copy `superwall_keys.example.json` to
   `superwall_keys.json` (not in git) and paste the public API keys from
   Superwall → Settings → Keys, one per platform. Pass the file to every run
   and build, next to the App Check file:
   `flutter run --dart-define-from-file=app_check_debug.json --dart-define-from-file=superwall_keys.json`.
   Without it the app runs without paywalls. Debug builds use Superwall's test
   mode, which simulates purchases; `--dart-define=SUPERWALL_TEST_MODE=false`
   switches to the stores' sandboxes. Release builds
   (`flutter build appbundle` / `flutter build ipa`) need the same
   `--dart-define-from-file=superwall_keys.json`.

## Tests

- `flutter test` runs the unit and widget tests.
- `cd backend && npm test` runs the tests of the backend. Its live OpenAI test
  is skipped unless you opt in; see `backend/README.md`.
- The end-to-end journey runs on a simulator or device. It makes one real
  trip plan through the backend and writes screenshots and `report.json` to
  `e2e_out/`:

  ```sh
  E2E_OUT=e2e_out flutter drive --driver=test_driver/integration_test.dart \
    --target=integration_test/app_e2e_test.dart \
    --dart-define-from-file=app_check_debug.json -d <device id>
  ```

## Release builds (Android)

Release builds are signed with the upload key from `android/key.properties`,
which points to `android/app/upload-keystore.jks` (alias `upload`). Neither
file is in git, so keep a backup of both, e.g. in a password manager. Without
them `flutter build appbundle` fails on purpose instead of signing with the
debug key, which Google Play rejects. Google Play re-signs the app with its own
app signing key, and a lost upload key can be reset in the Play Console.

## Backend and Firebase

- `backend/` is a Cloudflare Worker (free plan) with two routes, `POST
  /trip-plan` and `GET /weather`. It owns the OpenAI prompt, the schema, the
  model and the limits, and keeps the keys as Worker secrets. See
  `backend/README.md`. The app's address for it is `BackendApi.baseUri` in
  `lib/core/backend/backend_api.dart`.
- Firebase (project `dubaitripplanner-ae015`, Spark plan) is used only for
  App Check: Play Integrity on Android and App Attest on iOS prove that a
  request comes from this app on a real device, and the Worker refuses
  requests without a valid token.
- Firebase is set up from Dart (`lib/firebase_options.dart`), so there is no
  `google-services.json`, no google-services Gradle plugin (its version from
  `flutterfire configure` predates AGP 9) and no `GoogleService-Info.plist`.
  `flutterfire configure` also fails on this project, because it needs the
  `xcodeproj` Ruby gem, which went with CocoaPods. The values in
  `firebase_options.dart` are not secret.

## Project structure

- `lib/core/`: models, repositories (place and category data) and widgets
  shared by several features. Code in `core/` never imports from `features/`.
- `lib/features/<feature>/`: one folder per feature, with `ui/` for screens
  and widgets, `services/` for data access (APIs, local storage) and `cubit/`
  for state that has to outlive a screen.
- The tab bar builds only the selected tab, so every tab starts over when it
  is opened again. State that must survive that lives in the cubits provided
  in `main.dart` (`FavoritesCubit`, `MyTripCubit`) or in a cache (the weather
  forecast).
- Place ids are made from the category and the name (`must_see_burj-khalifa`),
  so places can be added or reordered without moving saved favorites.
- Bundled images are kept close to the size they are shown at (place photos
  at most 1920 px, category icons 256 px); a test fails if a larger one is
  added.

## Notes

- Material widgets come from the `material_ui` package. Import
  `package:material_ui/material_ui.dart`, not `package:flutter/material.dart`.
  Mixing the two gives type errors, because `ThemeData`, `TextTheme` and the
  widgets are different classes in each.
- Texts live in `lib/l10n/arb/` (one ARB file per language); `flutter gen-l10n`
  turns them into `lib/l10n/generated/`, which is committed. Use the delegates
  from `lib/l10n/l10n.dart`, not `AppLocalizations.localizationsDelegates`:
  those have the Material texts of `flutter_localizations`, which the widgets
  of `material_ui` do not read. The texts of the places are in
  `lib/l10n/places/`, by place id, and a test fails if one is missing.
- Launcher icons are generated with `dart run flutter_launcher_icons` from
  `assets/launcher/app_icon2.png`; the configuration is in `pubspec.yaml`.
  `assets/launcher/` is not bundled into the app.
