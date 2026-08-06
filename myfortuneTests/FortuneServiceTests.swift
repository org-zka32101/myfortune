import XCTest
@testable import myfortune

class FortuneServiceTests: XCTestCase {

    var service: FortuneService!

    override func setUp() {
        super.setUp()
        service = FortuneService.shared
    }

    override func tearDown() {
        service = nil
        super.tearDown()
    }

    func testFetchFortune() {
        let expectation = XCTestExpectation(description: "Fetch fortune")

        service.fetchFortune { result in
            switch result {
            case .success(let fortune):
                XCTAssertNotNil(fortune.id)
                XCTAssertNotNil(fortune.text)
                XCTAssertFalse(fortune.text.isEmpty)
            case .failure(let error):
                XCTFail("Failed to fetch fortune: \(error)")
            }
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 5.0)
    }
}
