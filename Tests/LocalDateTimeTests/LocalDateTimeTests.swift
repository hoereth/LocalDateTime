import XCTest
@testable import LocalDateTime

final class LocalDateTimeTests: XCTestCase {
    func testComparison() {
        XCTAssertTrue(LocalDateTime(year: 2022, month: 2, day: 1) > LocalDateTime(year: 2021, month: 12, day: 12))
        XCTAssertTrue(LocalDateTime(year: 2021, month: 2, day: 1) < LocalDateTime(year: 2021, month: 12, day: 12))
    }

    static var allTests = [
        ("testExample", testComparison),
    ]
}

