// Copyright © 2020 Roger Oba. All rights reserved.

/// The level of priority of a `Provider`.
public struct Priority : RawRepresentable, Comparable, AdditiveArithmetic, ExpressibleByIntegerLiteral {
    /// The lowest priority possible.
    public static let lowest = Priority(rawValue: .min)
    /// An average priority, right between lowest and highest.
    public static let medium = Priority(rawValue: .max / 2)
    /// The highest priority possible.
    public static let highest = Priority(rawValue: .max)

    public var rawValue: UInt

    public init(rawValue: UInt) {
        self.rawValue = rawValue
    }

    // MARK: - ExpressibleByIntegerLiteral
    public init(integerLiteral value: UInt) {
        self.init(rawValue: value)
    }

    // MARK: - Comparable
    public static func < (lhs: Priority, rhs: Priority) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }

    // MARK: - AdditiveArithmetic
    public static func - (lhs: Priority, rhs: Priority) -> Priority {
        return Priority(rawValue: lhs.rawValue - rhs.rawValue)
    }

    public static func + (lhs: Priority, rhs: Priority) -> Priority {
        return Priority(rawValue: lhs.rawValue + rhs.rawValue)
    }
}
