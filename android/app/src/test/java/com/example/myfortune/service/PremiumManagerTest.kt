package com.example.myfortune.service

import android.content.Context
import android.content.SharedPreferences
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Before
import org.junit.Test
import org.mockito.Mockito.mock
import org.mockito.Mockito.`when`

/** Mirrors myfortuneTests/PremiumManagerTests.swift. */
class PremiumManagerTest {

    private lateinit var prefs: FakeSharedPreferences
    private lateinit var manager: PremiumManager

    @Before
    fun setUp() {
        prefs = FakeSharedPreferences()
        val context = mock(Context::class.java)
        `when`(context.getSharedPreferences("myfortune_premium", Context.MODE_PRIVATE)).thenReturn(prefs)
        manager = PremiumManager(context)
    }

    @Test
    fun testDefaultsToFree() {
        assertFalse(manager.isPremium)
    }

    @Test
    fun testSetPremiumTruePersists() {
        manager.setPremium(true)
        assertTrue(manager.isPremium)
    }

    @Test
    fun testSetPremiumFalseAfterTrue() {
        manager.setPremium(true)
        manager.setPremium(false)
        assertFalse(manager.isPremium)
    }

    /** Minimal in-memory SharedPreferences fake — avoids pulling in Robolectric
     *  just to test a single boolean flag. */
    private class FakeSharedPreferences : SharedPreferences {
        private val values = mutableMapOf<String, Boolean>()

        override fun getBoolean(key: String, defValue: Boolean) = values[key] ?: defValue

        override fun edit(): SharedPreferences.Editor = object : SharedPreferences.Editor {
            override fun putBoolean(key: String, value: Boolean): SharedPreferences.Editor {
                values[key] = value
                return this
            }

            override fun apply() {}
            override fun commit() = true
            override fun putString(key: String?, value: String?) = this
            override fun putStringSet(key: String?, values: MutableSet<String>?) = this
            override fun putInt(key: String?, value: Int) = this
            override fun putLong(key: String?, value: Long) = this
            override fun putFloat(key: String?, value: Float) = this
            override fun remove(key: String?) = this
            override fun clear() = this
        }

        override fun getAll() = mutableMapOf<String, Any?>()
        override fun getString(key: String?, defValue: String?) = defValue
        override fun getStringSet(key: String?, defValues: MutableSet<String>?) = defValues
        override fun getInt(key: String?, defValue: Int) = defValue
        override fun getLong(key: String?, defValue: Long) = defValue
        override fun getFloat(key: String?, defValue: Float) = defValue
        override fun contains(key: String?) = values.containsKey(key)
        override fun registerOnSharedPreferenceChangeListener(listener: SharedPreferences.OnSharedPreferenceChangeListener?) {}
        override fun unregisterOnSharedPreferenceChangeListener(listener: SharedPreferences.OnSharedPreferenceChangeListener?) {}
    }
}
