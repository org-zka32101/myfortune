package com.example.myfortune

import android.app.Application
import com.example.myfortune.service.AdManager
import com.google.android.gms.ads.MobileAds
import com.google.firebase.Firebase
import com.google.firebase.appcheck.appCheck
import com.google.firebase.appcheck.debug.DebugAppCheckProviderFactory
import com.google.firebase.appcheck.playintegrity.PlayIntegrityAppCheckProviderFactory

/**
 * Mirrors myfortune/AppDelegate.swift: configures App Check (debug provider in
 * debug builds, Play Integrity in release — Android's equivalent of App Attest)
 * and warms up the first interstitial ad for free users.
 *
 * Firebase itself doesn't need an explicit configure() call here — the
 * `com.google.gms.google-services` plugin + `google-services.json` make the
 * FirebaseApp available automatically on process start.
 */
class MyFortuneApplication : Application() {

    override fun onCreate() {
        super.onCreate()

        // App Check's provider must be installed before any Firebase Functions/
        // Auth calls that require it, so do this as early as possible.
        Firebase.appCheck.installAppCheckProviderFactory(
            if (BuildConfig.DEBUG) {
                DebugAppCheckProviderFactory.getInstance()
            } else {
                PlayIntegrityAppCheckProviderFactory.getInstance()
            }
        )

        // Initialize AdMob and warm up the first interstitial for free users.
        MobileAds.initialize(this)
        AdManager.shared.preloadInterstitial(this)
    }
}
