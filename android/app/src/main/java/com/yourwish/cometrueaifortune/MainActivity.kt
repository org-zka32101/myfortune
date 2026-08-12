package com.yourwish.cometrueaifortune

import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import androidx.appcompat.app.AlertDialog
import com.yourwish.cometrueaifortune.databinding.ActivityMainBinding
import com.yourwish.cometrueaifortune.model.Fortune
import com.yourwish.cometrueaifortune.service.AdManager
import com.yourwish.cometrueaifortune.service.FortuneService
import com.yourwish.cometrueaifortune.service.PremiumManager

/** Mirrors myfortune/Views/HomeViewController.swift. */
class MainActivity : AppCompatActivity() {

    private lateinit var binding: ActivityMainBinding
    private lateinit var premiumManager: PremiumManager
    private var adShownForCurrentResult = false

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityMainBinding.inflate(layoutInflater)
        setContentView(binding.root)

        premiumManager = PremiumManager(applicationContext)

        binding.welcomeLabel.text = getString(R.string.welcome_title)
        binding.subtitleLabel.text = getString(R.string.welcome_subtitle)
        binding.startButton.text = getString(R.string.get_fortune)
        binding.startButton.setOnClickListener { onStartButtonTapped() }

        AdManager.shared.preloadInterstitial(applicationContext)
    }

    private fun onStartButtonTapped() {
        adShownForCurrentResult = false
        setLoading(true)

        FortuneService.shared.fetchFortune { result ->
            runOnUiThread {
                setLoading(false)
                result.fold(
                    onSuccess = { fortune -> showFortune(fortune) },
                    onFailure = { showFortune(text = getString(R.string.fetch_error)) }
                )
            }
        }
    }

    /** The fortune comes from a network call (Cloud Function), so guard against
     *  double taps and give the user something to look at while it loads. */
    private fun setLoading(isLoading: Boolean) {
        binding.startButton.isEnabled = !isLoading
        binding.loadingIndicator.visibility = if (isLoading) android.view.View.VISIBLE else android.view.View.GONE
    }

    private fun showFortune(fortune: Fortune) {
        showFortune(text = fortune.text)
    }

    private fun showFortune(text: String) {
        AlertDialog.Builder(this)
            .setTitle(getString(R.string.fortune_title))
            .setMessage(text)
            .setPositiveButton(getString(R.string.ok)) { dialog, _ ->
                dialog.dismiss()
                showAdIfNeeded()
            }
            .setOnDismissListener { showAdIfNeeded() }
            .show()
    }

    /** Free users see an interstitial ad right after viewing their fortune
     *  result. Premium users (see [PremiumManager]) never see it. */
    private fun showAdIfNeeded() {
        if (adShownForCurrentResult) return
        adShownForCurrentResult = true
        if (!premiumManager.isPremium) {
            AdManager.shared.showInterstitial(this)
        }
    }
}
