allprojects {
    repositories {
        val isCI = System.getenv("CI") == "true"
        if (!isCI) {
            maven { url = uri("https://maven.aliyun.com/repository/google") }
            maven { url = uri("https://maven.aliyun.com/repository/public") }
        }
        google()
        mavenCentral()
        maven { url = uri("https://jitpack.io") }
    }
}

// Force Flutter SDK versions for all plugins
extra["flutter.compileSdkVersion"] = 34
extra["flutter.targetSdkVersion"] = 34
extra["flutter.minSdkVersion"] = 24

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

subprojects {
    if (project.name == "isar_flutter_libs") {
        afterEvaluate {
            project.extensions.configure<com.android.build.gradle.LibraryExtension> {
                namespace = "dev.isar.isar_flutter_libs"
            }
        }
    }
    if (project.name == "ffmpeg_kit_flutter_new") {
        afterEvaluate {
            project.extensions.configure<com.android.build.gradle.LibraryExtension> {
                namespace = "com.antonkarpenko.ffmpegkit"
            }
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
