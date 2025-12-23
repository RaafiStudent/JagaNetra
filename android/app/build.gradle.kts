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
        // --- PERBAIKAN 1: Mengaktifkan Desugaring ---
        coreLibraryDesugaringEnabled true
        
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
        
        // --- PERBAIKAN 2: Mengaktifkan MultiDex (Penting) ---
        multiDexEnabled true 
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

// --- PERBAIKAN 3: Menambahkan Library Desugar ---
dependencies {
    // Library ini wajib ada untuk flutter_local_notifications di Android lama/baru
    coreLibraryDesugaring 'com.android.tools:desugar_jdk_libs:2.0.4'
}