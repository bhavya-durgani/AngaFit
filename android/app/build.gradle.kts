import org.gradle.api.JavaVersion  // Import Java version settings

plugins {  // Declare plugins used in this module
    id("com.android.application")  // Android app plugin (makes this an Android app)
    
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")  
    // Google services plugin (required for Firebase)
    // END: FlutterFire Configuration

    id("kotlin-android")  // Enables Kotlin support for Android

    id("dev.flutter.flutter-gradle-plugin")  
    // Flutter plugin to connect Flutter code with Android build
}

android {  // Main Android configuration block

    namespace = "com.example.AngaFit"  
    // Unique package name for your app

    compileSdk = 36  
    // Android SDK version used to compile the app

    ndkVersion = "27.3.13750724"  
    // Native Development Kit version (needed for Unity/native code)

    compileOptions {  
        sourceCompatibility = JavaVersion.VERSION_11  
        // Java source code version

        targetCompatibility = JavaVersion.VERSION_11  
        // Java compiled version (runs on JVM 11)
    }

    kotlinOptions {
        jvmTarget = "11"  
        // Kotlin also compiles to JVM 11 (same as Java to avoid mismatch)
    }

    defaultConfig {  // Default settings for the app

        applicationId = "com.example.AngaFit"  
        // App ID (used to identify your app on Play Store/device)

        minSdk = 24  
        // Minimum Android version supported (Android 7.0)

        targetSdk = 36  
        // Target Android version (optimized for latest OS)

        versionCode = 1  
        // Internal version number (increment for updates)

        versionName = "1.0"  
        // User-visible version name

        ndk {
            abiFilters.add("arm64-v8a")  
            // Only support 64-bit ARM devices (reduces app size, required for Unity)
        }
    }

    signingConfigs {  // Configuration for app signing (required to install/run)

        getByName("debug") {
            storeFile = file("angafit_debug.keystore")  
            // Path to debug keystore file

            storePassword = "android"  
            // Password for keystore

            keyAlias = "androiddebugkey"  
            // Alias name of key

            keyPassword = "android"  
            // Password for key
        }
    }

    buildTypes {  // Different build modes (debug & release)

        getByName("release") {
            // This is where you link the file

            isMinifyEnabled = true  
            // Enable code shrinking & obfuscation (reduces size + security)

            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),  
                // Default ProGuard rules

                "proguard-rules.pro"  
                // Your custom rules file
            )

            signingConfig = signingConfigs.getByName("debug")  
            // Use debug signing for release (only for testing, not production)
        }

        getByName("debug") {
            isMinifyEnabled = false  
            // No code shrinking in debug mode (faster builds, easier debugging)

            // Optional: you can link it here too if you want to test shrinking in debug
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),  
                "proguard-rules.pro"
            )
        }
    }
}

flutter {  
    source = "../.."  
    // Points to Flutter project root directory
}

dependencies {  // External libraries used in the project

    implementation("com.google.android.material:material:1.12.0")  
    // Material UI components (buttons, dialogs, etc.)

    implementation(project(":unityLibrary"))  
    // Link Unity module with this Android app
}
