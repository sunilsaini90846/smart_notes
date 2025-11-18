# Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.embedding.**

# Play Core (for Flutter Play Store split support)
-dontwarn com.google.android.play.core.splitcompat.SplitCompatApplication

# Hive Database
-keep class * extends com.hivedb.** { *; }
-keep class * implements com.hivedb.** { *; }
-keep class hive.** { *; }
-keep class com.hive.** { *; }
-dontwarn com.hivedb.**

# Your app's models
-keep class com.kyntesso.accountnotebook.** { *; }

# Gson (if used by any dependencies)
-keepattributes Signature
-keepattributes *Annotation*
-keep class sun.misc.Unsafe { *; }
-keep class com.google.gson.** { *; }

# Keep encryption related classes
-keep class javax.crypto.** { *; }
-keep class javax.crypto.spec.** { *; }
-dontwarn javax.crypto.**

# Keep annotations
-keepattributes *Annotation*
-keepattributes SourceFile,LineNumberTable
-keep public class * extends java.lang.Exception

# For crash reporting
-keepattributes SourceFile,LineNumberTable
-keep public class * extends java.lang.Exception

# Remove logging in release
-assumenosideeffects class android.util.Log {
    public static *** d(...);
    public static *** v(...);
    public static *** i(...);
}



