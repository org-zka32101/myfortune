package com.yourwish.cometrueaifortune.service

import android.app.Activity
import android.content.Context
import android.util.Log
import com.google.android.gms.ads.AdError
import com.google.android.gms.ads.AdRequest
import com.google.android.gms.ads.FullScreenContentCallback
import com.google.android.gms.ads.LoadAdError
import com.google.android.gms.ads.interstitial.InterstitialAd
import com.google.android.gms.ads.interstitial.InterstitialAdLoadCallback

/**
 * Loads and presents the interstitial ad shown to free (non-premium) users
 * right after they view a fortune result. Mirrors myfortune/Services/AdManager.swift.
 *
 * Uses Google's public test interstitial ad unit ID for now — swap
 * [INTERSTITIAL_AD_UNIT_ID] for the real AdMob ad unit ID before shipping to
 * the Play Store (see docs/android-setup.md).
 */
class AdManager private constructor() {

    private var interstitialAd: InterstitialAd? = null
    private var isLoading = false

    /** Kicks off loading the next interstitial. Safe to call repeatedly — no-ops
     *  while a load is already in flight or an ad is already cached. */
    fun preloadInterstitial(context: Context) {
        if (interstitialAd != null || isLoading) return
        isLoading = true

        InterstitialAd.load(
            context,
            INTERSTITIAL_AD_UNIT_ID,
            AdRequest.Builder().build(),
            object : InterstitialAdLoadCallback() {
                override fun onAdLoaded(ad: InterstitialAd) {
                    isLoading = false
                    interstitialAd = ad
                    ad.fullScreenContentCallback = object : FullScreenContentCallback() {
                        override fun onAdFailedToShowFullScreenContent(adError: AdError) {
                            Log.w(TAG, "Failed to present interstitial: ${adError.message}")
                            interstitialAd = null
                        }

                        override fun onAdDismissedFullScreenContent() {
                            interstitialAd = null
                        }
                    }
                }

                override fun onAdFailedToLoad(error: LoadAdError) {
                    isLoading = false
                    Log.w(TAG, "Failed to load interstitial: ${error.message}")
                }
            }
        )
    }

    /** Presents the interstitial if one is ready. Free users only — callers are
     *  expected to check [PremiumManager.isPremium] first. Always triggers a
     *  preload for the *next* ad, whether or not one was available to show now. */
    fun showInterstitial(activity: Activity) {
        val ad = interstitialAd
        if (ad == null) {
            Log.d(TAG, "No interstitial ready to show")
        } else {
            ad.show(activity)
        }
        preloadInterstitial(activity.applicationContext)
    }

    companion object {
        private const val TAG = "AdManager"

        // Google's public test interstitial ad unit ID.
        // TODO: replace with the real ad unit ID before release.
        private const val INTERSTITIAL_AD_UNIT_ID = "ca-app-pub-3940256099942544/1033173712"

        @Volatile
        private var instance: AdManager? = null

        val shared: AdManager
            get() = instance ?: synchronized(this) {
                instance ?: AdManager().also { instance = it }
            }
    }
}
