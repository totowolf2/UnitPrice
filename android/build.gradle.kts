allprojects {
    repositories {
        google()
        mavenCentral()
    }
}


val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
    
    // Fix namespace issue for isar_flutter_libs
    afterEvaluate {
        if (project.name == "isar_flutter_libs") {
            if (project.hasProperty("android")) {
                project.extensions.getByType<com.android.build.gradle.LibraryExtension>().apply {
                    namespace = "dev.isar.isar_flutter_libs"
                }
            }
        }
    }
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
