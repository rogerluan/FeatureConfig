// Copyright © 2020 Roger Oba. All rights reserved.

@testable import FeatureConfig
import JSEN
import XCTest

final class FeatureTests: XCTestCase {
    private var provider: MutableProvider!

    enum Testing {
        @Feature("int", default: 2) static var int: Int
        @Feature("optionalInt") static var optionalInt: Int?
        @Feature("double", default: 2.5) static var double: Double
        @Feature("optionalDouble") static var optionalDouble: Double?
        @Feature("string", default: "fallback value") static var string: String
        @Feature("optionalString") static var optionalString: String?
        @Feature("bool", default: false) static var bool: Bool
        @Feature("optionalBool") static var optionalBool: Bool?
        @Feature("array", default: ["fallback value"]) static var array: [String]
        @Feature("optionalArray") static var optionalArray: [String]?
        @Feature("dictionary", default: ["my_key" : "my_value"]) static var dictionary: [String:String]
        @Feature("optionalDictionary") static var optionalDictionary: [String:String]?
        @Feature("customDecodable", default: Model(string: "fallback value", int: 5)) static var customDecodable: Model
        @Feature("optionalCustomDecodable") static var optionalCustomDecodable: Model?

        struct Model : Codable, Equatable {
            var string: String
            var int: Int?
        }
    }

    override func setUp() {
        super.setUp()
        let configs = [
            "testing" : Config(value: "simple value", explanation: "Explanation for the testing config"),
        ]
        provider = EphemeralProvider()
        provider.configsPublisher.value = configs
        FeatureConfig.initialize(providers: [
            provider,
        ])
    }

    override func tearDown() {
        provider = nil
        FeatureConfig.tearDown()
        super.tearDown()
    }

    func test_parseIntTypesAndSetThemToNil_shouldSucceedThenMatchDefaultValues() {
        provider.configsPublisher.value["int"] = 42
        XCTAssertEqual(Testing.int, 42)
        Testing.int = 45
        XCTAssertEqual(Testing.int, 45)
        provider.configsPublisher.value["optionalInt"] = 43
        XCTAssertEqual(Testing.optionalInt, 43)
        provider.configsPublisher.value["int"] = nil
        XCTAssertEqual(Testing.int, 2)
        provider.configsPublisher.value["optionalInt"] = nil
        XCTAssertNil(Testing.optionalInt)
    }

    func test_parseDoubleTypesAndSetThemToNil_shouldSucceedThenMatchDefaultValues() {
        provider.configsPublisher.value["double"] = 42.42
        XCTAssertEqual(Testing.double, 42.42)
        Testing.double = 50.50
        XCTAssertEqual(Testing.double, 50.50)
        provider.configsPublisher.value["optionalDouble"] = 43.43
        XCTAssertEqual(Testing.optionalDouble, 43.43)
        provider.configsPublisher.value["double"] = nil
        XCTAssertEqual(Testing.double, 2.5)
        provider.configsPublisher.value["optionalDouble"] = nil
        XCTAssertNil(Testing.optionalDouble)
    }

    func test_parseStringTypesAndSetThemToNil_shouldSucceedThenMatchDefaultValues() {
        provider.configsPublisher.value["string"] = "something else"
        XCTAssertEqual(Testing.string, "something else")
        Testing.string = "direct assignment"
        XCTAssertEqual(Testing.string, "direct assignment")
        provider.configsPublisher.value["optionalString"] = "optional string test"
        XCTAssertEqual(Testing.optionalString, "optional string test")
        provider.configsPublisher.value["string"] = nil
        XCTAssertEqual(Testing.string, "fallback value")
        provider.configsPublisher.value["optionalString"] = nil
        XCTAssertNil(Testing.optionalString)
    }

    func test_parseBoolTypesAndSetThemToNil_shouldSucceedThenMatchDefaultValues() {
        provider.configsPublisher.value["bool"] = true
        XCTAssertTrue(Testing.bool)
        Testing.bool = false
        XCTAssertFalse(Testing.bool)
        provider.configsPublisher.value["optionalBool"] = true
        // swiftlint:disable:next xct_specific_matcher
        XCTAssertEqual(Testing.optionalBool, true)
        provider.configsPublisher.value["bool"] = nil
        XCTAssertFalse(Testing.bool)
        provider.configsPublisher.value["optionalBool"] = nil
        XCTAssertNil(Testing.optionalBool)
    }

    func test_parseArrayTypesAndSetThemToNil_shouldSucceedThenMatchDefaultValues() {
        provider.configsPublisher.value["array"] = ["testing array of strings", "testing array again"]
        XCTAssertEqual(Testing.array, ["testing array of strings", "testing array again"])
        Testing.array = ["direct assignment"]
        XCTAssertEqual(Testing.array, ["direct assignment"])
        provider.configsPublisher.value["optionalArray"] = ["testing array of strings"]
        XCTAssertEqual(Testing.optionalArray, ["testing array of strings"])
        provider.configsPublisher.value["array"] = nil
        XCTAssertEqual(Testing.array, ["fallback value"])
        provider.configsPublisher.value["optionalArray"] = nil
        XCTAssertNil(Testing.optionalArray)
    }

    func test_parseDictionaryTypesAndSetThemToNil_shouldSucceedThenMatchDefaultValues() {
        provider.configsPublisher.value["dictionary"] = [ "this's my key" : "and a value" ]
        XCTAssertEqual(Testing.dictionary, [ "this's my key" : "and a value" ])
        Testing.dictionary = [ "this's" : "direct assignment value" ]
        XCTAssertEqual(Testing.dictionary, [ "this's" : "direct assignment value" ])
        provider.configsPublisher.value["optionalDictionary"] = [ "this's my key of optional dictionary" : "and a value" ]
        XCTAssertEqual(Testing.optionalDictionary, [ "this's my key of optional dictionary" : "and a value" ])
        provider.configsPublisher.value["dictionary"] = nil
        XCTAssertEqual(Testing.dictionary, ["my_key" : "my_value"])
        provider.configsPublisher.value["optionalDictionary"] = nil
        XCTAssertNil(Testing.optionalDictionary)
    }

    func test_parseCustomDecodableTypesFromJSENAndSetThemToNil_shouldSucceedThenMatchDefaultValues() {
        let json: [String:JSEN] = [
            "string": "my custom string",
            "int": 42,
        ]
        provider.configsPublisher.value["customDecodable"] = Config(value: .dictionary(json))
        XCTAssertEqual(Testing.customDecodable, Testing.Model(string: "my custom string", int: 42))
        Testing.customDecodable = Testing.Model(string: "direct assignment string", int: 59)
        XCTAssertEqual(Testing.customDecodable, Testing.Model(string: "direct assignment string", int: 59))
        provider.configsPublisher.value["optionalCustomDecodable"] = Config(value: .dictionary(json))
        XCTAssertEqual(Testing.optionalCustomDecodable, Testing.Model(string: "my custom string", int: 42))
        provider.configsPublisher.value["customDecodable"] = nil
        XCTAssertEqual(Testing.customDecodable, Testing.Model(string: "fallback value", int: 5))
        provider.configsPublisher.value["optionalCustomDecodable"] = nil
        XCTAssertNil(Testing.optionalCustomDecodable)
    }

    func test_parseCustomDecodableTypesFromEncodedStringAndSetThemToNil_shouldSucceedThenMatchDefaultValues() {
        let jsonAsString = "{\"string\":\"my custom string\",\"int\":42}"
        provider.configsPublisher.value["customDecodable"] = Config(value: JSEN(stringLiteral: jsonAsString))
        XCTAssertEqual(Testing.customDecodable, Testing.Model(string: "my custom string", int: 42))
        provider.configsPublisher.value["optionalCustomDecodable"] = Config(value: JSEN(stringLiteral: jsonAsString))
        XCTAssertEqual(Testing.optionalCustomDecodable, Testing.Model(string: "my custom string", int: 42))
        provider.configsPublisher.value["customDecodable"] = nil
        XCTAssertEqual(Testing.customDecodable, Testing.Model(string: "fallback value", int: 5))
        provider.configsPublisher.value["optionalCustomDecodable"] = nil
        XCTAssertNil(Testing.optionalCustomDecodable)
    }

    func test_parseCustomDecodableTypesFromInvalidJSENAndSetThemToNil_shouldFallbackToDefaultValue() {
        let json: [String:JSEN] = [
            "string_with_a_typo": "my custom string",
            "int": 42,
        ]
        provider.configsPublisher.value["customDecodable"] = Config(value: .dictionary(json))
        XCTAssertEqual(Testing.customDecodable, Testing.Model(string: "fallback value", int: 5))
        provider.configsPublisher.value["optionalCustomDecodable"] = Config(value: .dictionary(json))
        XCTAssertNil(Testing.optionalCustomDecodable)
    }
}
