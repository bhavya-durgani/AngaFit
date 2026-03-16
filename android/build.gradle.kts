import org.gradle.api.JavaVersion

allprojects {
    repositories {
        google()
        mavenCentral()
        flatDir {
            dirs(file("${project(":unityLibrary").projectDir}/libs"))
        }
    }
}

subprojects {
    afterEvaluate {
        if (hasProperty("android")) {
            val android = extensions.getByName("android") as com.android.build.gradle.BaseExtension

            // FIX 1: Force NDK Version globally
            android.ndkVersion = "27.3.13750724"

            // FORCES Stripe and all other plugins to use SDK 36
            android.compileSdkVersion(36)

            // Optional: Force build tools version as well
            android.buildToolsVersion("35.0.0")

            // FIX 2: Inject missing Namespace for older plugins
            if (android.namespace == null) {
                if (project.name == "flutter_unity_widget") {
                    android.namespace = "com.xraph.plugin.flutter_unity_widget"
                } else {
                    // Fallback for any other plugins with this error
                    android.namespace = "com.example.AngaFit.${project.name.replace("-", "_")}"
                }
            }

            // FIX 3: Align Java and Kotlin JVM targets to prevent mismatch errors
            android.compileOptions {
                sourceCompatibility = JavaVersion.VERSION_11
                targetCompatibility = JavaVersion.VERSION_11
            }

            // FIX 4: Also force Kotlin jvmTarget to match Java (11)
            tasks.withType<org.jetbrains.kotlin.gradle.tasks.KotlinCompile>().configureEach {
                compilerOptions {
                    jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_11)
                }
            }
        }
    }
}

rootProject.buildDir = file("../build")
subprojects {
    project.buildDir = file("${rootProject.buildDir}/${project.name}")
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(layout.buildDirectory)
}
