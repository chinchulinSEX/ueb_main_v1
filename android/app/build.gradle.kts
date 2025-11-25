/*
CAMBIOS REALIZADOS:
1. namespace = "com.suelo.y.agua.prototype"
   → Para que el proyecto Flutter tenga un identificador propio y no herede el viejo.

2. applicationId = "com.suelo.y.agua.prototype"
   → ESTE es el ID real de Android. Con esto Android reconoce esta app como NUEVA.
   → No reemplaza la anterior, no la borra, no la toca.

TODO LO DEMÁS LO DEJÉ IGUAL.
*/

plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {

    // CAMBIADO: nuevo namespace único para este proyecto
    namespace = "com.suelo.y.agua.prototype"

    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }

    kotlinOptions {
        jvmTarget = "1.8"
    }

    defaultConfig {

        // CAMBIADO: nuevo applicationId → evita reemplazar la app vieja
        applicationId = "com.suelo.y.agua.prototype"

        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        // Token de Mapbox
        manifestPlaceholders["MAPBOX_ACCESS_TOKEN"] =
            project.findProperty("MAPBOX_ACCESS_TOKEN") ?: ""
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

// Carga automática del token desde .env
val dotenvFile = rootProject.file(".env")
if (dotenvFile.exists()) {
    dotenvFile.readLines().forEach { line ->
        if (line.startsWith("MAPBOX_ACCESS_TOKEN")) {
            val token = line.split("=")[1].trim()
            project.extensions.extraProperties["MAPBOX_ACCESS_TOKEN"] = token
        }
    }
}
