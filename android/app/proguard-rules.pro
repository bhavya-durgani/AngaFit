# Keep Unity Player classes
-keep class com.unity3d.player.** { *; }

# Keep Flutter Unity Widget classes
-keep class com.xraph.plugin.flutter_unity_widget.** { *; }

# Keep the Unity Integration bridge
-keep class Unity.Flutter.Integration.** { *; }

# Prevent shrinking of native library calls
-keepattributes Signature, InnerClasses, EnclosingMethod, AnnotationDefault
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}
