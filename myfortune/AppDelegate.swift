import UIKit
import Firebase
import FirebaseAppCheck
import FirebaseAuth
import GoogleMobileAds

/// Debug builds use the App Check debug provider (register the printed debug
/// token in the Firebase console for simulators/dev devices). Release builds
/// use App Attest so only genuine App Store/TestFlight builds can call the
/// AI fortune backend.
final class MyFortuneAppCheckProviderFactory: NSObject, AppCheckProviderFactory {
    func createProvider(with app: FirebaseApp) -> AppCheckProvider? {
        #if DEBUG
        return AppCheckDebugProvider(app: app)
        #else
        return AppAttestProvider(app: app)
        #endif
    }
}

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // App Check's provider factory must be set before FirebaseApp.configure().
        AppCheck.setAppCheckProviderFactory(MyFortuneAppCheckProviderFactory())

        // Initialize Firebase
        FirebaseApp.configure()

        // The AI fortune backend just needs to know "which caller" for
        // per-user caching/history — anonymous auth is enough, no account
        // or sign-in UI required.
        if Auth.auth().currentUser == nil {
            Auth.auth().signInAnonymously()
        }

        // Initialize AdMob and warm up the first interstitial for free users
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        AdManager.shared.preloadInterstitial()

        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
    }
}
