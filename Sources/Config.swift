// Copyright © 2020 Roger Oba. All rights reserved.

import JSEN

public struct Config : Equatable {
    public var value: JSEN?
    public var explanation: String?

    public init(value: JSEN?, explanation: String? = nil) {
        self.value = value
        self.explanation = explanation
    }
}

// MARK: ExpressibleByIntegerLiteral

extension Config: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: Int) {
        self.init(value: .int(value), explanation: nil)
    }
}

// MARK: ExpressibleByFloatLiteral

extension Config: ExpressibleByFloatLiteral {
    public init(floatLiteral value: Double) {
        self.init(value: .double(value), explanation: nil)
    }
}

// MARK: ExpressibleByStringLiteral

extension Config: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self.init(value: .string(value), explanation: nil)
    }
}

// MARK: ExpressibleByBooleanLiteral

extension Config: ExpressibleByBooleanLiteral {
    public init(booleanLiteral value: Bool) {
        self.init(value: .bool(value), explanation: nil)
    }
}

// MARK: ExpressibleByArrayLiteral

extension Config: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: JSEN...) {
        self.init(value: .array(elements), explanation: nil)
    }
}

// MARK: ExpressibleByDictionaryLiteral

extension Config: ExpressibleByDictionaryLiteral {
    public init(dictionaryLiteral elements: (String, JSEN)...) {
        self.init(value: .dictionary(elements.reduce(into: [:]) { $0[$1.0] = $1.1 }), explanation: nil)
    }
}

// MARK: ExpressibleByNilLiteral

extension Config: ExpressibleByNilLiteral {
    public init(nilLiteral: ()) {
        self.init(value: nil, explanation: nil)
    }
}
