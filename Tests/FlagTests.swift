// Copyright © 2020 Roger Oba. All rights reserved.

@testable import FeatureConfig
import XCTest

final class ConfigTests: XCTestCase {
    func test_expressibleByIntegerLiteral_shouldHaveTheRightValueAndNilExplanation() {
        let config: Config = 77
        XCTAssertEqual(config.value, 77)
        XCTAssertNil(config.explanation)
    }

    func test_expressibleByFloatLiteral_shouldHaveTheRightValueAndNilExplanation() {
        let config: Config = 24.46
        XCTAssertEqual(config.value, 24.46)
        XCTAssertNil(config.explanation)
    }

    func test_expressibleByStringLiteral_shouldHaveTheRightValueAndNilExplanation() {
        let config: Config = "string literal"
        XCTAssertEqual(config.value, "string literal")
        XCTAssertNil(config.explanation)
    }

    func test_expressibleByBooleanLiteral_shouldHaveTheRightValueAndNilExplanation() {
        let config: Config = true
        // swiftlint:disable:next xct_specific_matcher
        XCTAssertEqual(config.value, true)
        XCTAssertNil(config.explanation)
    }

    func test_expressibleByArrayLiteral_shouldHaveTheRightValueAndNilExplanation() {
        let config: Config = [ "this", "is", "an", "array" ]
        XCTAssertEqual(config.value, [ "this", "is", "an", "array" ])
        XCTAssertNil(config.explanation)
    }

    func test_expressibleByDictionaryLiteral_shouldHaveTheRightValueAndNilExplanation() {
        let config: Config = [ "this is it" : .string("some value") ]
        XCTAssertEqual(config.value, [ "this is it" : .string("some value") ])
        XCTAssertNil(config.explanation)
    }

    func test_expressibleByNilLiteral_shouldHaveTheRightValueAndNilExplanation() {
        let config: Config = nil
        XCTAssertNil(config.value)
        XCTAssertNil(config.explanation)
    }
}
