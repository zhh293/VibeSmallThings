# Flutter Wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# PathProvider & Pigeon
-keep class dev.flutter.pigeon.** { *; }
-keep class io.flutter.plugins.pathprovider.** { *; }

# Isar
-keep class isar.** { *; }
-keep class dev.isar.** { *; }

# FFmpegKit
-keep class com.arthenica.ffmpegkit.** { *; }

# Default
-keep public class * extends android.app.Activity
-keep public class * extends android.app.Application
-keep public class * extends android.app.Service
-keep public class * extends android.content.BroadcastReceiver
-keep public class * extends android.content.ContentProvider
-keep public class * extends android.preference.Preference
-keep public class * extends android.view.View
