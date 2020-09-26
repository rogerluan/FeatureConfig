// Copyright © 2020 Roger Oba. All rights reserved.

import Combine
import Foundation

public protocol Provider {
    var logsPublisher: PassthroughSubject<Log, Never> { get }
    var configsPublisher: CurrentValueSubject<[String:Config], Never> { get }
    var priority: Priority { get }
    mutating func refresh()
}

public protocol MutableProvider : Provider {
    var configsPublisher: CurrentValueSubject<[String:Config], Never> { get set }
}

public typealias Log = (
    message: String,
    logLevel: LogLevel,
    error: NSError?,
    userInfo: [String:Encodable]?,
    file: StaticString,
    function: StaticString,
    line: UInt
)

public extension Provider {
    func log(message: String, logLevel: LogLevel, error: NSError? = nil, userInfo: [String : Encodable]? = nil, file: StaticString = #file, function: StaticString = #function, line: UInt = #line) {
        logsPublisher.send((
            message: message,
            logLevel: logLevel,
            error: error,
            userInfo: userInfo,
            file: file,
            function: function,
            line: line
        ))
    }
}

/// Determines the priority and severity of a log.
public enum LogLevel: Int {
    /// Attempts to log every action in the module.
    case verbose
    /// Logs messages that are used only for (temporary) debugging purposes.
    case debug
    /// Regular logs that don't mean any harm - they're purely informative.
    case info
    /// Logs something to pay attention to, but not critical.
    case warning
    /// Logs critical issues and errors that must be investigated.
    case error
}
