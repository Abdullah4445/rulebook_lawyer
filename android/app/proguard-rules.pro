-dontwarn com.stripe.android.pushProvisioning.PushProvisioningActivity$g
-dontwarn com.stripe.android.pushProvisioning.PushProvisioningActivityStarter$Args
-dontwarn com.stripe.android.pushProvisioning.PushProvisioningActivityStarter$Error
-dontwarn com.stripe.android.pushProvisioning.PushProvisioningActivityStarter
-dontwarn com.stripe.android.pushProvisioning.PushProvisioningEphemeralKeyProvider
-dontwarn proguard.annotation.Keep
-dontwarn proguard.annotation.KeepClassMembers
-keep class com.hiennv.flutter_callkit_incoming.** { *; }

##---------------Begin: Firebase and FCM Configuration -----------
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-keep class io.flutter.plugins.firebase.messaging.FlutterFirebaseMessagingService { *; }
-keep class com.google.firebase.messaging.FirebaseMessagingService { *; }
-keep class com.google.firebase.messaging.RemoteMessage { *; }

# Prevent Firebase Messaging Service from being removed
-keep class com.goflowdriver.taxi.driver.services.MyFirebaseMessagingService { *; }
-keep class * extends com.google.firebase.messaging.FirebaseMessagingService { *; }

# Keep Firebase annotations
-keepattributes *Annotation*
-dontwarn com.google.firebase.**
-dontwarn com.google.android.gms.**

##---------------End: Firebase and FCM Configuration -----------

##---------------Begin: ProGuard configuration for Gson ----------
# Gson uses generic type information stored in a class file when working with fields.
# ProGuard removes such information by default, so configure it to keep all of it.
-keepattributes Signature

# For using GSON @Expose annotation
-keepattributes *Annotation*

# Gson specific classes
-dontwarn sun.misc.**

-keep class com.google.gson.examples.android.model.** { <fields>; }

-keep class * extends com.google.gson.TypeAdapter
-keep class * implements com.google.gson.TypeAdapterFactory
-keep class * implements com.google.gson.JsonSerializer
-keep class * implements com.google.gson.JsonDeserializer

# Prevent R8 from leaving Data object members always null
-keepclassmembers,allowobfuscation class * {
  @com.google.gson.annotations.SerializedName <fields>;
}

# Retain generic signatures of TypeToken and its subclasses with R8 version 3.0 and higher.
-keep,allowobfuscation,allowshrinking class com.google.gson.reflect.TypeToken
-keep,allowobfuscation,allowshrinking class * extends com.google.gson.reflect.TypeToken

##---------------End: ProGuard configuration for Gson ----------

# Please add these rules to your existing keep rules in order to suppress warnings.
# This is generated automatically by the Android Gradle plugin.
-dontwarn java.beans.ConstructorProperties
-dontwarn java.beans.Transient
-dontwarn org.w3c.dom.bootstrap.DOMImplementationRegistry
