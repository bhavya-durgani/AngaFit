pluginManagement {  // Used to manage Gradle plugins and their versions

    val flutterSdkPath =
        run {
            val properties = java.util.Properties()  
            // Create a Properties object to read key-value pairs from file

            file("local.properties").inputStream().use { properties.load(it) }  
            // Open local.properties file and load its contents

            val flutterSdkPath = properties.getProperty("flutter.sdk")  
            // Get Flutter SDK path from local.properties

            require(flutterSdkPath != null) { "flutter.sdk not set in local.properties" }  
            // If path is missing, throw error and stop build

            flutterSdkPath  
            // Return Flutter SDK path
        }

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")  
    // Include Flutter's internal Gradle build tools (required for Flutter projects)

    repositories {  // Define where Gradle plugins will be downloaded from
        google()  // Google repository (Android plugins)
        mavenCentral()  // Central repository for libraries
        gradlePluginPortal()  // Official Gradle plugin repository
    }
}

plugins {  // Declare plugins used in the project

    id("dev.flutter.flutter-plugin-loader") version "1.0.0"  
    // Flutter plugin loader (helps load Flutter-specific Gradle logic)

    id("com.android.application") version "8.11.1" apply false  
    // Android app plugin (not applied here, only declared for submodules)

    // START: FlutterFire Configuration
    id("com.google.gms.google-services") version("4.3.15") apply false  
    // Google services plugin (needed for Firebase integration)
    // END: FlutterFire Configuration

    id("org.jetbrains.kotlin.android") version "2.2.20" apply false  
    // Kotlin Android plugin (used for Kotlin support)
}

include(":app")  
// Include main Flutter Android app module

// UNITY INTEGRATION
include(":unityLibrary")  
// Include Unity module as a separate Gradle project

project(":unityLibrary").projectDir = file("./unityLibrary")  
// Set actual folder location for unityLibrary module

// ADD THIS LINE TO FIX ERROR 1
include(":unityLibrary:xrmanifest.androidlib")  
// Include Unity XR manifest module (fixes missing dependency error)
