import XCTest
@testable import myfortune

// `FortuneService.fetchFortune` now calls the `analyzeFortune` Cloud
// Function over the network (via Firebase Auth + Functions), which needs a
// configured `FirebaseApp` (GoogleService-Info.plist) and a live backend —
// neither of which is available in a plain unit test target. Exercising it
// here would crash (Firebase fatal-errors without a configured app) or hang
// waiting on the network, so there is intentionally no test for it in this
// target. Cover it with an integration/UI test against the Firebase
// emulator suite instead, once that's set up.
class FortuneServiceTests: XCTestCase {
}
