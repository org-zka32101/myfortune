import Foundation

/// Tracks whether the user has purchased the "Remove Ads" upgrade.
///
/// This is a lightweight stub backed by `UserDefaults` so the ad-display
/// logic has something concrete to branch on today. Wiring this up to a
/// real StoreKit non-consumable purchase ("Remove Ads") is a separate task —
/// when that lands, `purchasePremium()`/`restorePurchases()` should be
/// replaced with real StoreKit transaction handling that calls
/// `setPremium(true)` on success.
final class PremiumManager {
    static let shared = PremiumManager()

    private let defaultsKey = "isPremiumUser"
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    /// `true` once the user has purchased "Remove Ads". Defaults to `false`,
    /// meaning ads are shown until a purchase is recorded.
    var isPremium: Bool {
        defaults.bool(forKey: defaultsKey)
    }

    func setPremium(_ value: Bool) {
        defaults.set(value, forKey: defaultsKey)
    }
}
