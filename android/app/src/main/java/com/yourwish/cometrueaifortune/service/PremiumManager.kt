package com.yourwish.cometrueaifortune.service

import android.content.Context
import android.content.SharedPreferences

/**
 * Tracks whether the user has purchased the "Remove Ads" upgrade.
 *
 * Mirrors myfortune/Services/PremiumManager.swift: a lightweight stub backed by
 * SharedPreferences so the ad-display logic has something concrete to branch on
 * today. Wiring this up to a real Google Play Billing non-consumable purchase
 * ("Remove Ads") is a separate task — when that lands, `setPremium(true)` should
 * be called from the Billing purchase-acknowledgement callback.
 */
class PremiumManager(context: Context) {

    private val prefs: SharedPreferences =
        context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)

    /** `true` once the user has purchased "Remove Ads". Defaults to `false`. */
    val isPremium: Boolean
        get() = prefs.getBoolean(KEY_IS_PREMIUM, false)

    fun setPremium(value: Boolean) {
        prefs.edit().putBoolean(KEY_IS_PREMIUM, value).apply()
    }

    companion object {
        private const val PREFS_NAME = "myfortune_premium"
        private const val KEY_IS_PREMIUM = "isPremiumUser"
    }
}
