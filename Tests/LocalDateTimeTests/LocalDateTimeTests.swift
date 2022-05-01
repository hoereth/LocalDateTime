import XCTest
@testable import LocalDateTime

final class LocalDateTimeTests: XCTestCase {
    func testToDate() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(LocalDateTime(year: 2022, month: 2).asDate(), Date())
        XCTAssertEqual(LocalDateTime(hour: 10, minute:  30).asDate(), Date())
    }

    static var allTests = [
        ("testExample", testToDate),
    ]
}
