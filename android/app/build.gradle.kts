plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.jaganetra"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        // --- SYNTAX KOTLIN YANG BENAR ---
        // Pakai "isCore..." dan tanda sama dengan "="
        isCoreLibraryDesugaringEnabled = true
        
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.example.jaganetra"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        
        // --- SYNTAX KOTLIN YANG BENAR ---
        // Pakai tanda sama dengan "="
        multiDexEnabled = true 
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

dependencies {
    // --- SYNTAX KOTLIN YANG BENAR ---
    // Pakai tanda kurung "()" dan tanda kutip dua ""
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}