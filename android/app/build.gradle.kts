import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}
val keystoreProperties = Properties().apply {
    val keystorePropertiesFile = rootProject.file("android/key.properties")
    if (keystorePropertiesFile.exists()) {
        load(keystorePropertiesFile.inputStream())
    }
}
android {
    namespace = "com.meetclic.meetclic"
    testNamespace = "com.meetclic.meetclic"
    compileSdk = flutter.compileSdkVersion
    //  ndkVersion = flutter.ndkVersion TODO FIX
    ndkVersion = "27.0.12077973"
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.meetclic.meetclic"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
      //  minSdk = flutter.minSdkVersion TODO FIX
        minSdk = 24
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
//ARCORE
dependencies {
    // Provides ARCore Session and related resources.
   // implementation 'com.google.ar:core:1.15.0'
    // Provides ArFragment, and other UX resources.
   // implementation 'com.google.ar.sceneform.ux:sceneform-ux:1.15.0'
    // Alternatively, use ArSceneView without the UX dependency.
    //implementation 'com.google.ar.sceneform:core:1.15.0'
    // ARCore Session y recursos relacionados
    implementation("com.google.ar:core:1.15.0")
    // ArFragment y recursos de UX
    implementation("com.google.ar.sceneform.ux:sceneform-ux:1.15.0")

    // Alternativa: ArSceneView sin el paquete UX
    implementation("com.google.ar.sceneform:core:1.15.0")
}