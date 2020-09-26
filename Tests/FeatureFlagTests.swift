// Copyright © 2020 Roger Oba. All rights reserved.

@testable import FeatureConfig
import Combine
import XCTest

final class FeatureConfigTests: XCTestCase {
    enum Testing {
        @Feature("testing", default: "fallback default value")
        static var testing: String?
    }

    private class TestProviderWithLowestPriority : MutableProvider {
        var configsPublisher = CurrentValueSubject<[String:Config], Never>([:])
        let logsPublisher = PassthroughSubject<Log, Never>()
        var priority: Priority { .lowest }

        func refresh() { }
    }

    private final class TestProviderWithMediumPriority : TestProviderWithLowestPriority {
        override var priority: Priority { .medium }
    }

    private var ephemeralProvider: MutableProvider!
    private var lowestPriorityProvider: MutableProvider!
    private var mediumPriorityProvider: MutableProvider!

    override func setUp() {
        super.setUp()
        let configs = [
            "testing" : Config(value: "simple value", explanation: "Explanation for the testing config"),
        ]
        ephemeralProvider = EphemeralProvider()
        ephemeralProvider.configsPublisher.value = configs
        ephemeralProvider.refresh()
        lowestPriorityProvider = TestProviderWithLowestPriority()
        lowestPriorityProvider.configsPublisher.value = configs
        mediumPriorityProvider = TestProviderWithMediumPriority()
        mediumPriorityProvider.configsPublisher.value = configs
        FeatureConfig.initialize(providers: [
            ephemeralProvider,
            lowestPriorityProvider,
            mediumPriorityProvider,
        ])
    }

    override func tearDown() {
        mediumPriorityProvider = nil
        lowestPriorityProvider = nil
        ephemeralProvider = nil
        FeatureConfig.tearDown()
        super.tearDown()
    }

    func test_providerPriority_shouldBeLowestToHighest() {
        lowestPriorityProvider.configsPublisher.value["testing"] = Config(value: "L", explanation: "This is the lowest priority value")
        mediumPriorityProvider.configsPublisher.value["testing"] = Config(value: "M", explanation: "this is the medium priority value")
        ephemeralProvider.configsPublisher.value["testing"] = Config(value: "E", explanation: "this is the value from ephemeral provider which has the highest priority")
        XCTAssertEqual(Testing.testing, "E")
        ephemeralProvider.configsPublisher.value["testing"] = nil
        XCTAssertEqual(Testing.testing, "M")
        mediumPriorityProvider.configsPublisher.value["testing"] = nil
        XCTAssertEqual(Testing.testing, "L")
        lowestPriorityProvider.configsPublisher.value["testing"] = nil
        XCTAssertEqual(Testing.testing, "fallback default value")
        mediumPriorityProvider.configsPublisher.value["testing"] = Config(value: "Medium", explanation: "Adding again the medium priority value")
        XCTAssertEqual(Testing.testing, "Medium")
    }

    func test_configsPublisher_shouldReceiveAllAccumulatedValuesWhenAnyProviderPublishes() {
        let expect = expectation(description: name)
        expect.expectedFulfillmentCount = 3
        var count = 0
        var cancellable = Set<AnyCancellable>()
        FeatureConfig.shared.configs
            .sink { values in
                switch count {
                case 0:
                    XCTAssertNotNil(values["testing"])
                case 1:
                    XCTAssertNotNil(values["testing"])
                    XCTAssertNotNil(values["a new key"])
                case 2:
                    XCTAssertNotNil(values["testing"])
                    XCTAssertNotNil(values["a new key"])
                    XCTAssertNotNil(values["3rd key"])
                default: XCTFail("Received more updates than expected")
                }
                count += 1
                expect.fulfill()
            }
            .store(in: &cancellable)
        ephemeralProvider.configsPublisher.value["a new key"] = 42
        ephemeralProvider.configsPublisher.value["3rd key"] = 22
        waitForExpectations(timeout: 3)
    }
}
