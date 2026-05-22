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
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

// Force Kotlin 2.0+ language/API version on any subproject still pinned to
// 1.6 (e.g. sentry_flutter 8.x). Kotlin 2.3 refuses to compile pre-2.0
// language versions, so we bump them up to the minimum it accepts.
// Uses lazy `configureEach` so it works after evaluationDependsOn(":app").
subprojects {
    plugins.withId("org.jetbrains.kotlin.android") {
        tasks.withType(org.jetbrains.kotlin.gradle.tasks.KotlinCompile::class.java)
            .configureEach {
                compilerOptions {
                    val minVersion = org.jetbrains.kotlin.gradle.dsl.KotlinVersion.KOTLIN_2_0
                    if ((languageVersion.orNull?.version?.toFloatOrNull() ?: 0f) < 2.0f) {
                        languageVersion.set(minVersion)
                    }
                    if ((apiVersion.orNull?.version?.toFloatOrNull() ?: 0f) < 2.0f) {
                        apiVersion.set(minVersion)
                    }
                }
            }
    }
}
