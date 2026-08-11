import XCTest
@testable import myfortune

class PremiumManagerTests: XCTestCase {

    var defaults: UserDefaults!
    var manager: PremiumManager!

    override func setUp() {
        super.setUp()
        defaults = UserDefaults(suiteName: #file)
        defaults.removePersistentDomain(forName: #file)
        manager = PremiumManager(defaults: defaults)
    }

    override func tearDown() {
        defaults.removePersistentDomain(forName: #file)
        defaults = nil
        manager = nil
        super.tearDown()
    }

    func testDefaultsToFree() {
        XCTAssertFalse(manager.isPremium)
    }

    func testSetPremiumTruePersists() {
        manager.setPremium(true)
        XCTAssertTrue(manager.isPremium)
    }

    func testSetPremiumFalseAfterTrue() {
        manager.setPremium(true)
        manager.setPremium(false)
        XCTAssertFalse(manager.isPremium)
    }
}
