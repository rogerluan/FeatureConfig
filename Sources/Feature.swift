// Copyright © 2020 Roger Oba. All rights reserved.

import Foundation
import JSEN

@propertyWrapper
public struct Feature<Value : Codable> {
    private let key: String
    private let defaultExpression: () -> Value

    /// The wrapped value getter of this property wrapper fetches the config value from the highest priority provider,
    /// while its setter will set the value on all the mutable providers configured.
    public var wrappedValue: Value {
        get {
            // We must guard the config value here in this separate guard statement.
            // If you concatenate the entire optional chain in one expression, `valueAsJSEN` will
            // have a `nil` value with an Optional type for Optional Features, thus resulting in `nil`
            // return values while it should actually fallback to the default values.
            guard let valueAsJSEN = FeatureConfig.shared.configs.value[key] else { return defaultExpression() }
            if let result = valueAsJSEN.valueType as? Value {
                // If the value is simple enough that can be simply casted, return it.
                // This is ~200% more performant than the decoding operation below.
                return result
            } else if let result = valueAsJSEN.decode(as: Value.self) {
                // Otherwise, this value might need some parsing. Let's decode it.
                return result
            }
            return defaultExpression()
        }
        set {
            // NOTE: This setter is only accessed in debug environments. This is not enforced in any way, but
            // it's just something to keep in mind when assessing the performance of the code below. It may be
            // a little bit bad in performance, but this is not a problem since this code doesn't run in production builds.
            let mutableProviders = FeatureConfig.shared.providers.compactMap { $0 as? MutableProvider }
            for provider in mutableProviders {
                guard let newValueAsJSEN = JSEN(from: newValue) else { continue }
                provider.configsPublisher.value[key] = Config(value: newValueAsJSEN, explanation: provider.configsPublisher.value[key]?.explanation)
            }
        }
    }

    /// Instantiates a feature config property wrapper.
    /// - Parameters:
    ///   - key: the key of this feature config, as configured in the providers' end.
    ///   - defaultExpression: the fallback value of this feature, in case none of the providers are able to
    ///   provide a valid value for this feature during runtime. This expression is evaluated only when and if needed.
    public init(_ key: String, default defaultExpression: @autoclosure @escaping () -> Value) {
        self.key = key
        self.defaultExpression = defaultExpression
    }
}

public extension Feature where Value : ExpressibleByNilLiteral {
    init(_ key: String) {
        self.init(key, default: nil)
    }
}

private extension JSEN {
    init?<T : Codable>(from codable: T) {
        guard let data = try? JSONEncoder().encode(codable) else { return nil }
        guard let result = try? JSONDecoder().decode(JSEN.self, from: data) else { return nil }
        self = result
    }
}
