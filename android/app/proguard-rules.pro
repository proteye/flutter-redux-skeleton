-dontwarn android.**
-keep class com.google.android.gms.**
-dontwarn com.google.android.gms.**
-keep class com.google.firebase.** { *; }

#Flutter Wrapper
-dontwarn io.flutter.embedding.**
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }
