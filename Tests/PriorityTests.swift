// Copyright © 2020 Roger Oba. All rights reserved.

@testable import FeatureConfig
import XCTest

final class PriorityTests: XCTestCase {
    func test_expressibleByIntegerLiteral() {
        let priority: Priority = 77
        XCTAssertEqual(priority, 77)
        XCTAssertEqual(priority.rawValue, 77)
    }

    func test_comparable() {
        let lhs = Priority(rawValue: 5)
        let rhs = Priority(rawValue: 3)
        XCTAssertGreaterThan(lhs, rhs)
        XCTAssertLessThanOrEqual(rhs, lhs)
        XCTAssertNotEqual(lhs, rhs)
    }

    func test_additiveArithmetic() {
        let lhs = Priority(rawValue: 5)
        let rhs = Priority(rawValue: 3)
        XCTAssertEqual(lhs + rhs, Priority(rawValue: 8))
        XCTAssertEqual(lhs - rhs, Priority(rawValue: 2))
    }
}
