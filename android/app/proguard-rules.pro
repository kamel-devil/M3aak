# Flutter Engine & Plugins
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.provider.** { *; }
-keep class io.flutter.plugin.editing.** { *; }

-keepclasseswithmembernames class * {
    native <methods>;
}

-dontwarn io.flutter.embedding.**

# Attributes & Annotations
-keepattributes *Annotation*,Signature,InnerClasses,EnclosingMethod

# Firebase
-dontwarn com.google.firebase.**
-keep class com.google.firebase.** { *; }

# General Webview / Android
-dontwarn com.pichillilorenzo.flutter_inappwebview_android.**
