import XCTest
@testable import LocalDateTime

final class LocalDateTimeTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(LocalDateTime().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
