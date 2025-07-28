# Add project specific ProGuard rules here.
# You can control the set of applied configuration files using the
# proguardFiles setting in build.gradle.
#
# For more details, see
#   http://developer.android.com/guide/developing/tools/proguard.html

# Keep TensorFlow Lite classes
-keep class org.tensorflow.lite.** { *; }
-keep class org.tensorflow.lite.gpu.** { *; }
-keep class org.tensorflow.lite.nnapi.** { *; }
-keep class org.tensorflow.lite.delegates.** { *; }

# Keep TensorFlow Lite GPU delegate classes specifically
-keep class org.tensorflow.lite.gpu.GpuDelegate { *; }
-keep class org.tensorflow.lite.gpu.GpuDelegateFactory { *; }
-keep class org.tensorflow.lite.gpu.GpuDelegateFactory$Options { *; }
-keep class org.tensorflow.lite.gpu.GpuDelegateV2 { *; }

# Keep XNNPACK delegate classes
-keep class org.tensorflow.lite.delegates.xnnpack.** { *; }

# Keep native method names for TensorFlow Lite
-keepclassmembers class * {
    native <methods>;
}

# Keep Flutter TensorFlow Lite plugin classes
-keep class tflite_flutter.** { *; }

# Additional rules from R8 missing_rules.txt
-dontwarn org.tensorflow.lite.gpu.GpuDelegateFactory$Options

# More comprehensive TensorFlow Lite rules
-keep class org.tensorflow.lite.** { *; }
-keep interface org.tensorflow.lite.** { *; }
-keepclassmembers class org.tensorflow.lite.** { *; }

# Keep all TensorFlow Lite native libraries
-keep class org.tensorflow.lite.NativeInterpreterWrapper { *; }
-keep class org.tensorflow.lite.Tensor { *; }
-keep class org.tensorflow.lite.InterpreterApi { *; }
-keep class org.tensorflow.lite.InterpreterApi$Options { *; } 