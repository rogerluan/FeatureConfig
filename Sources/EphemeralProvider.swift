// Copyright © 2020 Roger Oba. All rights reserved.

import Combine
import Foundation

public struct EphemeralProvider : MutableProvider {
    public var configsPublisher = CurrentValueSubject<[String:Config], Never>([:])
    public let logsPublisher = PassthroughSubject<Log, Never>()
    public var priority: Priority { .highest }

    public init() {
        log(message: "Initializing EphemeralProvider", logLevel: .verbose)
    }

    public func refresh() {
        log(message: "Attempted to call '\(#function)' in EphemeralProvider but this class doesn't need its configs to be refreshed.", logLevel: .verbose)
    }
}
