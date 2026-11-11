// Firebase configuration of the project dubaitripplanner-ae015, taken from the
// google-services.json and GoogleService-Info.plist that `flutterfire configure`
// downloaded on 2026-11-11. None of these values are secret: they only say
// which Firebase project and app the device talks to. The app uses Firebase
// only for App Check, which proves to the backend that a request comes from
// this app.
//
// Firebase is set up from Dart only, so the Android build needs no
// google-services Gradle plugin and the Xcode project needs no plist.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show TargetPlatform, defaultTargetPlatform, kIsWeb;

class DefaultFirebaseOptions {
  /// The options for this platform, or null where the app has no Firebase app
  /// (web and desktop).
  static FirebaseOptions? get currentPlatform {
    if (kIsWeb) return null;
    return switch (defaultTargetPlatform) {
      TargetPlatform.android => android,
      TargetPlatform.iOS => ios,
      _ => null,
    };
  }

  static const android = FirebaseOptions(
    apiKey: 'AIzaSyC6ACuImxzPibwcqKCbji59YPjnFI7w3D8',
    appId: '1:1085118524930:android:03876253e309dc1daf011b',
    messagingSenderId: '1085118524930',
    projectId: 'dubaitripplanner-ae015',
    storageBucket: 'dubaitripplanner-ae015.firebasestorage.app',
  );

  static const ios = FirebaseOptions(
    apiKey: 'AIzaSyCEOTBCJQQQcIMWKDsijGxl6NkGq_1p9j8',
    appId: '1:1085118524930:ios:a8022d8e2cb93f65af011b',
    messagingSenderId: '1085118524930',
    projectId: 'dubaitripplanner-ae015',
    storageBucket: 'dubaitripplanner-ae015.firebasestorage.app',
    iosBundleId: 'com.carovicfilip.dubaiTripPlanner',
  );
}
