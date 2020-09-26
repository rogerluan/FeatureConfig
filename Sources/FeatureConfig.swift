// Copyright © 2020 Roger Oba. All rights reserved.

import Combine
import Foundation
import JSEN

public class FeatureConfig {
    public static var shared: FeatureConfig!
    /// Sorted providers.
    internal let providers: [Provider]
    private var cancellables = Set<AnyCancellable>()

    public var configs = CurrentValueSubject<[String:JSEN], Never>([:])

    private init(providers: [Provider]) {
        self.providers = providers
        let publishers = providers.map(\.configsPublisher)
        Publishers.MergeMany(publishers)
            .map { _ in publishers }
            .map { subjects in subjects.map(\.value) }
            .map { allProvidersCurrentConfigs in
                allProvidersCurrentConfigs.reduce(into: [:]) { previousResult, config in
                    let jsenValuesDictionary: [String:JSEN] = config.compactMapValues { $0.value }
                    return previousResult.merge(jsenValuesDictionary, uniquingKeysWith: { firstValue, _ in firstValue })
                }
            }
            .sink { [unowned self] latestConfigs in
                self.configs.value = latestConfigs
            }
            .store(in: &cancellables)
    }

    public static func initialize(providers: [Provider]) {
        shared = FeatureConfig(providers: providers.sorted { $0.priority > $1.priority })
    }

    internal static func tearDown() {
        shared = nil
    }
}
