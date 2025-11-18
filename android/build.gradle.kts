allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

// Configure Java toolchain for all subprojects
subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
    
    afterEvaluate {
        // Configure Android compile options
        if (project.hasProperty("android")) {
            extensions.findByType<com.android.build.gradle.BaseExtension>()?.apply {
                compileOptions {
                    sourceCompatibility = JavaVersion.VERSION_17
                    targetCompatibility = JavaVersion.VERSION_17
                }
            }
        }
        
        // Configure Kotlin JVM target
        tasks.withType<org.jetbrains.kotlin.gradle.tasks.KotlinCompile>().configureEach {
            kotlinOptions {
                jvmTarget = "17"
            }
        }
        
        // Configure Java compilation tasks
        tasks.withType<JavaCompile>().configureEach {
            sourceCompatibility = "17"
            targetCompatibility = "17"
            options.compilerArgs.add("-Xlint:-options") // Suppress obsolete options warnings
        }
    }
    
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
