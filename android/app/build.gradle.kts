plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("com.google.gms.google-services")
}

android {
    namespace = "com.yourwish.cometrueaifortune"
    compileSdk = 35

    defaultConfig {
        applicationId = "com.yourwish.cometrueaifortune"
        // 26+ (Android 8.0, 2017) covers the vast majority of active devices and
        // keeps launcher-icon resources to a single adaptive-icon definition.
        minSdk = 26
        targetSdk = 35
        versionCode = 1
        versionName = "1.0"

        testInstrumentationRunner = "androidx.test.runner.AndroidJUnitRunner"
    }

    // Release (upload key) signing, sourced from environment variables so the
    // keystore itself never touches the repo. Populated in CI from the
    // ANDROID_KEYSTORE_BASE64 / ANDROID_KEYSTORE_PASSWORD / ANDROID_KEY_ALIAS /
    // ANDROID_KEY_PASSWORD secrets (see .github/workflows/android-build.yml and
    // docs/android-setup.md). Locally, export the same env vars if you need to
    // produce a signed build outside CI.
    val releaseKeystorePath = System.getenv("ANDROID_KEYSTORE_PATH")

    signingConfigs {
        if (releaseKeystorePath != null) {
            create("release") {
                storeFile = file(releaseKeystorePath)
                storePassword = System.getenv("ANDROID_KEYSTORE_PASSWORD")
                keyAlias = System.getenv("ANDROID_KEY_ALIAS")
                keyPassword = System.getenv("ANDROID_KEY_PASSWORD")
            }
        }
    }

    buildTypes {
        release {
            isMinifyEnabled = false
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
            if (releaseKeystorePath != null) {
                signingConfig = signingConfigs.getByName("release")
            }
        }
        debug {
            // AdMob test ad unit IDs work in both configurations; App Check uses the
            // debug provider here (see MyFortuneApplication) so debug builds don't
            // need a real attestation setup.
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    buildFeatures {
        viewBinding = true
        buildConfig = true
    }
}

dependencies {
    implementation("androidx.core:core-ktx:1.13.1")
    implementation("androidx.appcompat:appcompat:1.7.0")
    implementation("com.google.android.material:material:1.12.0")
    implementation("androidx.constraintlayout:constraintlayout:2.1.4")
    implementation("androidx.lifecycle:lifecycle-runtime-ktx:2.8.6")

    // Firebase (AI fortune backend — mirrors the iOS Podfile's Firebase deps)
    implementation(platform("com.google.firebase:firebase-bom:33.5.1"))
    implementation("com.google.firebase:firebase-analytics")
    implementation("com.google.firebase:firebase-auth-ktx")
    implementation("com.google.firebase:firebase-functions-ktx")
    implementation("com.google.firebase:firebase-appcheck")
    implementation("com.google.firebase:firebase-appcheck-playintegrity")
    implementation("com.google.firebase:firebase-appcheck-debug")

    // AdMob (interstitial ads for free users — mirrors AdManager.swift)
    implementation("com.google.android.gms:play-services-ads:23.5.0")

    testImplementation("junit:junit:4.13.2")
    testImplementation("org.mockito:mockito-core:5.14.2")
    androidTestImplementation("androidx.test.ext:junit:1.2.1")
    androidTestImplementation("androidx.test.espresso:espresso-core:3.6.1")
}
