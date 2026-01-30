allprojects {
    repositories {
        google()
        mavenCentral()
        flatDir {
            dirs(file("${project(":unityLibrary").projectDir}/libs"))
        }
    }
}

// FIX FOR "Namespace not specified" in plugins
subprojects {
    afterEvaluate {
        if (hasProperty("android")) {
            val android = extensions.getByName("android") as com.android.build.gradle.BaseExtension

            // This fixes the error by providing the namespace Gradle is looking for
            if (project.name == "flutter_unity_widget") {
                android.namespace = "com.xraph.plugin.flutter_unity_widget"
            }

            // General fix for other plugins
            if (android.namespace == null) {
                android.namespace = "com.example.angafit.${project.name.replace("-", "_")}"
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
    delete(rootProject.buildDir)
}
