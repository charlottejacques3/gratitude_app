# Flutter
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.embedding.** { *; }
-dontwarn io.flutter.embedding.**

# Firebase
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.android.gms.**

# Firebase Messaging (notifications)
-keep class com.google.firebase.messaging.FirebaseMessagingService { *; }
-keep class com.google.firebase.messaging.FirebaseMessage { *; }

# Firebase Analytics
-keep class com.google.firebase.analytics.** { *; }

# Firebase Auth
-keep class com.google.firebase.auth.** { *; }

# Firebase Storage
-keep class com.google.firebase.storage.** { *; }

# Firebase Realtime Database
-keep class com.google.firebase.database.** { *; }

# flutter_local_notifications & timezone
-keep class com.dexterous.flutterlocalnotifications.** { *; }
-dontwarn com.dexterous.flutterlocalnotifications.**
-keep class org.joda.time.** { *; }

# android_alarm_manager_plus
-keep class io.flutter.plugins.androidalarmmanager.** { *; }

# image_picker & photo_manager
-keep class com.zhihu.matisse.** { *; }
-dontwarn com.zhihu.matisse.**
-keep class top.kikt.imagescanner.** { *; }

# flutter_image_compress
-keep class com.github.bumptech.glide.** { *; }
-dontwarn com.github.bumptech.glide.**

# get_it
-keep class **.ServiceLocator { *; }

# cached_network_image (uses Glide)
-keep class com.bumptech.glide.** { *; }
-dontwarn com.bumptech.glide.**

# encrypt (uses reflection)
-keep class org.bouncycastle.** { *; }
-dontwarn org.bouncycastle.**

# pdfrx / pdf
-keep class org.apache.pdfbox.** { *; }
-dontwarn org.apache.pdfbox.**

# fluttertoast
-keep class io.github.ponnamkarthik.toast.fluttertoast.FlutterToastPlugin { *; }

# General reflection handling
-keepattributes *Annotation*
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}
-keepclassmembers class * {
    @androidx.annotation.Keep <fields>;
    @androidx.annotation.Keep <methods>;
}
-keep class * {
    @androidx.annotation.Keep *;
}
