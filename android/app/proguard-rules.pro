# App-specific R8 keep rules. Flutter's Gradle plugin adds this file to release builds by itself.

# Room creates its generated databases by reflection (the no-argument constructor of <Name>_Impl).
# Room 2.6's own rule keeps the class but names no members, and AGP 9's R8 no longer keeps default
# constructors implicitly. WorkManager (pulled in by the Superwall SDK) opens its WorkDatabase when
# the app starts, so release build 8 crashed at launch with
# NoSuchMethodException: androidx.work.impl.WorkDatabase_Impl.<init>, and Google Play rejected it.
-keep class * extends androidx.room.RoomDatabase { <init>(); }

# WorkManager creates input mergers by reflection too, through the same kind of member-less rule.
-keep class * extends androidx.work.InputMerger { <init>(); }
