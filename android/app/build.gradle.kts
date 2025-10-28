plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("dev.flutter.flutter-gradle-plugin")
}


android {
    namespace = "com.example.jewellery"
    compileSdk = 36
    ndkVersion = null
    
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    defaultConfig {
        applicationId = "com.example.jewellery"
        minSdk = 21
        targetSdk = 36
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }

    applicationVariants.all {
        outputs.all {
            if (this is com.android.build.gradle.internal.api.BaseVariantOutputImpl) {
                outputFileName = "Jewellery.apk"
            }
        }
    }
}

flutter {
    source = "../.."
}

tasks.whenTaskAdded {
    if (name == "packageRelease") {
        doLast {
            val apkDir = file("$buildDir/outputs/flutter-apk")
            val oldApk = file("$apkDir/app-release.apk")
            val newApk = file("$apkDir/Jewellery.apk")
            if (oldApk.exists()) {
                oldApk.renameTo(newApk)
                println("APK renamed to: ${newApk.absolutePath}")
            }
        }
    }
}
