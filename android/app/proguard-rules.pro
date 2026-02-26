# Tell R8 to completely ignore and preserve the Google AR and Sceneform rendering engines
-dontwarn com.google.ar.**
-keep class com.google.ar.** { *; }

# Tell R8 to ignore the older Java desugaring extensions the plugin relies on
-dontwarn com.google.devtools.build.android.desugar.runtime.**
-keep class com.google.devtools.build.android.desugar.runtime.** { *; }