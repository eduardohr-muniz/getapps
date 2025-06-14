# ProGuard rules for Flutter apps

# Keep Flutter Framework
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.embedding.** { *; }
-dontwarn io.flutter.**

# Keep all plugin classes
-keep class com.** { *; }
-keep class io.** { *; }

# Keep package info classes specifically for android_package plugin
-keep class android.content.pm.** { *; }
-keep class android.content.** { *; }

# Keep HTTP and networking
-keep class okhttp3.** { *; }
-keep class okio.** { *; }
-keep class retrofit2.** { *; }

# Keep reflection-based code
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes Exceptions
-keepattributes InnerClasses
-keepattributes SourceFile,LineNumberTable

# Keep native methods
-keepclassmembers class * {
    native <methods>;
}

# Keep enum values
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

# CRITICAL: Disable all optimizations that can break Flutter
-dontoptimize
-dontobfuscate
-dontshrink

# Keep everything for safety in release builds
-keep class ** { *; }
-keepclassmembers class ** { *; } 