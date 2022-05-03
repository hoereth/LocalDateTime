import XCTest
@testable import LocalDateTime

final class LocalDateTimeTests: XCTestCase {
    func testComparison() {
        XCTAssertTrue(LocalDateTime(year: 2022, month: 2, day: 1) > LocalDateTime(year: 2021, month: 12, day: 12))
        XCTAssertTrue(LocalDateTime(year: 2021, month: 2, day: 1) < LocalDateTime(year: 2021, month: 12, day: 12))
        
        XCTAssertTrue(LocalDateTime(year: 2022, month: 5, day: 7, hour: 23, minute: 59, second: 59) < LocalDateTime(year: 2022, month: 5, day: 8))
    }

    static var allTests = [
        ("testExample", testComparison),
    ]
    
}

