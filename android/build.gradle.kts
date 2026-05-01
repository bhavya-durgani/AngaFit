import org.gradle.api.JavaVersion  // Import JavaVersion class to set Java compatibility

allprojects {  // Applies to all projects/modules in this build
    repositories {  // Define where dependencies (libraries) are downloaded from
        google()  // Google's repository (needed for Android libraries)
        mavenCentral()  // Main public repository for most libraries
        flatDir {  // Used to include local .jar/.aar files
            dirs(file("${project(":unityLibrary").projectDir}/libs"))  // Points to Unity library's local libs folder
        }
    }
}

subprojects {  // Applies settings to all submodules (like app, plugins, etc.)
    afterEvaluate {  // Runs this block after each project is fully evaluated
        if (hasProperty("android")) {  // Check if this module is an Android module
            val android = extensions.getByName("android") as com.android.build.gradle.BaseExtension  
            // Get Android configuration object to modify settings

            // FIX 1: Force NDK Version globally
            android.ndkVersion = "27.3.13750724"  
            // Set specific NDK version (needed for Unity/native code compatibility)

            // FORCES Stripe and all other plugins to use SDK 36
            android.compileSdkVersion(36)  
            // Set Android SDK version used to compile the app (latest features)

            // Optional: Force build tools version as well
            android.buildToolsVersion("35.0.0")  
            // Set version of build tools used during compilation

            // FIX 2: Inject missing Namespace for older plugins
            if (android.namespace == null) {  // If plugin/module doesn't define namespace
                if (project.name == "flutter_unity_widget") {  
                    // Special case for flutter_unity_widget plugin
                    android.namespace = "com.xraph.plugin.flutter_unity_widget"  
                    // Manually set correct namespace
                } else {
                    // Fallback for any other plugins with this error
                    android.namespace = "com.example.AngaFit.${project.name.replace("-", "_")}"  
                    // Generate a namespace dynamically using project name
                }
            }

            // FIX 3: Align Java and Kotlin JVM targets to prevent mismatch errors
            android.compileOptions {  
                sourceCompatibility = JavaVersion.VERSION_11  
                // Set Java source code compatibility to Java 11

                targetCompatibility = JavaVersion.VERSION_11  
                // Set compiled bytecode to run on Java 11
            }

            // FIX 4: Also force Kotlin jvmTarget to match Java (11)
            tasks.withType<org.jetbrains.kotlin.gradle.tasks.KotlinCompile>().configureEach {  
                // Apply this to all Kotlin compile tasks
                compilerOptions {
                    jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_11)  
                    // Set Kotlin to also compile to JVM 11 (avoid mismatch with Java)
                }
            }
        }
    }
}

rootProject.buildDir = file("../build")  
// Set root build folder outside default location (cleaner project structure)

subprojects {
    project.buildDir = file("${rootProject.buildDir}/${project.name}")  
    // Each subproject will have its own build folder inside main build directory
}

subprojects {
    project.evaluationDependsOn(":app")  
    // Ensure all subprojects are evaluated after the main app module
}

tasks.register<Delete>("clean") {  
    // Create a "clean" task to delete build files
    delete(layout.buildDirectory)  
    // Deletes the build directory to reset the project
}
