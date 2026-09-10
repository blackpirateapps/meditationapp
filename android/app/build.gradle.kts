import java.io.File
import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.blackpirateapps.meditationapp.meditationapp"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.blackpirateapps.meditationapp"
        minSdk = 24
        targetSdk = flutter.targetSdkVersion
        // Uses the version code from pubspec.yaml. When using split APKs, 1000 * ABI_VERSION
        // is added automatically by Flutter. (https://developer.android.com/studio/build/configure-apk-splits#configure-APK-versions)
        // You can force using the value of versionCode by specifying the `-P force-version-code-ignoring-abi=true`
        // flag during build.
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            val keyAliasVal = keystoreProperties.getProperty("keyAlias") ?: System.getenv("KEY_ALIAS")
            val keyPasswordVal = keystoreProperties.getProperty("keyPassword") ?: System.getenv("KEY_PASSWORD")
            val storeFileVal = keystoreProperties.getProperty("storeFile") ?: System.getenv("KEYSTORE_PATH")
            val storePasswordVal = keystoreProperties.getProperty("storePassword") ?: System.getenv("KEYSTORE_PASSWORD")

            val keystoreFile = if (storeFileVal != null) {
                val f = File(storeFileVal)
                if (f.isAbsolute) {
                    f
                } else if (file(storeFileVal).exists()) {
                    file(storeFileVal)
                } else {
                    rootProject.file(storeFileVal)
                }
            } else null

            if (keystoreFile != null && keystoreFile.exists() && keyAliasVal != null && keyPasswordVal != null && storePasswordVal != null) {
                storeFile = keystoreFile
                storePassword = storePasswordVal
                keyAlias = keyAliasVal
                keyPassword = keyPasswordVal
            } else {
                initWith(getByName("debug"))
            }
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
