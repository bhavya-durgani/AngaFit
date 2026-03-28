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

# ── Firebase / Firestore (prevents release build breakage) ────────────────────
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-keep class io.grpc.** { *; }
-dontwarn com.google.firebase.**
-dontwarn com.google.android.gms.**

# Keep Kotlin coroutines (used internally by Firebase SDKs)
-keepclassmembernames class kotlinx.** {
    volatile <fields>;
}
