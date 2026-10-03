allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

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
    val configureAndroid: () -> Unit = {
        val android = project.extensions.findByName("android")
        if (android != null) {
            try {
                val method = android.javaClass.getMethod("setCompileSdkVersion", Int::class.javaPrimitiveType)
                method.invoke(android, 36)
            } catch (e: Exception) {
                try {
                    val method2 = android.javaClass.getMethod("compileSdkVersion", Int::class.javaPrimitiveType)
                    method2.invoke(android, 36)
                } catch (e2: Exception) {}
            }
        }
    }
    project.plugins.withId("com.android.library") { configureAndroid() }
    project.plugins.withId("com.android.application") { configureAndroid() }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
