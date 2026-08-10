import GoogleMobileAds
import UIKit

/// Loads and presents the interstitial ad shown to free (non-premium) users
/// right after they view a fortune result.
///
/// Uses Google's public test ad unit ID for now — swap
/// `interstitialAdUnitID` for the real AdMob ad unit ID before shipping to
/// the App Store (see `docs/admob-setup.md` if present, or the AdMob
/// console for this app's ad unit).
final class AdManager: NSObject {
    static let shared = AdManager()

    /// Google's public test interstitial ad unit ID.
    /// TODO: replace with the real ad unit ID before release.
    private let interstitialAdUnitID = "ca-app-pub-3940256099942544/4411468910"

    private var interstitialAd: GADInterstitialAd?
    private var isLoading = false

    private override init() {
        super.init()
    }

    /// Kicks off loading the next interstitial. Safe to call repeatedly —
    /// no-ops while a load is already in flight or an ad is already cached.
    func preloadInterstitial() {
        guard interstitialAd == nil, !isLoading else { return }
        isLoading = true

        GADInterstitialAd.load(withAdUnitID: interstitialAdUnitID, request: GADRequest()) { [weak self] ad, error in
            guard let self else { return }
            self.isLoading = false

            if let error {
                print("AdManager: failed to load interstitial: \(error.localizedDescription)")
                return
            }

            self.interstitialAd = ad
            self.interstitialAd?.fullScreenContentDelegate = self
        }
    }

    /// Presents the interstitial if one is ready. Free users only — callers
    /// are expected to check `PremiumManager.shared.isPremium` first.
    /// Always triggers a preload for the *next* ad, whether or not one was
    /// available to show right now.
    func showInterstitial(from viewController: UIViewController) {
        defer { preloadInterstitial() }

        guard let interstitialAd else {
            print("AdManager: no interstitial ready to show")
            return
        }

        interstitialAd.present(fromRootViewController: viewController)
    }
}

extension AdManager: GADFullScreenContentDelegate {
    func adDidRecordImpression(_ ad: GADFullScreenPresentingAd) {}

    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("AdManager: failed to present interstitial: \(error.localizedDescription)")
        interstitialAd = nil
    }

    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        interstitialAd = nil
    }
}
