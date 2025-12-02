//
//  Logger.swift
//  GetTranslatedSDK
//
//  Created by GetTranslated SDK Generator
//

import Foundation
import os.log

/// Logging utility for GetTranslated iOS SDK
/// Provides configurable log levels and different logging strategies
public enum LogLevel: Int, Comparable {
    case error = 0
    case warn = 1
    case info = 2
    case debug = 3
    case verbose = 4
    
    public static func < (lhs: LogLevel, rhs: LogLevel) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
}

/// Logger class for the GetTranslated SDK
public class Logger {
    private static var instance: Logger?
    private var level: LogLevel
    private var enableConsole: Bool
    private let subsystem = "ai.gettranslated.sdk"
    private let category = "GetTranslated"
    
    private init(level: LogLevel, enableConsole: Bool) {
        self.level = level
        self.enableConsole = enableConsole
    }
    
    /// Initialize the logger with configuration
    public static func initialize(level: LogLevel, enableConsole: Bool = true) {
        instance = Logger(level: level, enableConsole: enableConsole)
    }
    
    /// Get the logger instance
    public static func getInstance() -> Logger {
        if instance == nil {
            initialize(level: .warn, enableConsole: true)
        }
        return instance!
    }
    
    /// Check if a log level should be logged
    private func shouldLog(_ level: LogLevel) -> Bool {
        return level <= self.level
    }
    
    /// Log an entry
    private func log(_ level: LogLevel, _ message: String, _ data: Any? = nil) {
        guard shouldLog(level) else { return }
        
        if enableConsole {
            logToConsole(level, message, data)
        }
    }
    
    /// Log to console with appropriate OSLog method
    private func logToConsole(_ level: LogLevel, _ message: String, _ data: Any?) {
        let log = OSLog(subsystem: subsystem, category: category)
        let dataStr = data != nil ? " \(String(describing: data!))" : ""
        let fullMessage = "[GetTranslated] \(message)\(dataStr)"
        
        switch level {
        case .error:
            os_log("%{public}@", log: log, type: .error, fullMessage)
        case .warn:
            os_log("%{public}@", log: log, type: .default, fullMessage)
        case .info:
            os_log("%{public}@", log: log, type: .info, fullMessage)
        case .debug:
            os_log("%{public}@", log: log, type: .debug, fullMessage)
        case .verbose:
            os_log("%{public}@", log: log, type: .debug, fullMessage)
        }
    }
    
    /// Error level logging
    public func error(_ message: String, _ data: Any? = nil) {
        log(.error, message, data)
    }
    
    /// Warning level logging
    public func warn(_ message: String, _ data: Any? = nil) {
        log(.warn, message, data)
    }
    
    /// Info level logging
    public func info(_ message: String, _ data: Any? = nil) {
        log(.info, message, data)
    }
    
    /// Debug level logging
    public func debug(_ message: String, _ data: Any? = nil) {
        log(.debug, message, data)
    }
    
    /// Verbose level logging
    public func verbose(_ message: String, _ data: Any? = nil) {
        log(.verbose, message, data)
    }
    
    /// Get current log level
    public func getLevel() -> LogLevel {
        return level
    }
    
    /// Set log level
    public func setLevel(_ level: LogLevel) {
        self.level = level
    }
    
    /// Check if a specific level is enabled
    public func isLevelEnabled(_ level: LogLevel) -> Bool {
        return shouldLog(level)
    }
}

/// Convenience functions for direct logging
public enum Log {
    public static func error(_ message: String, _ data: Any? = nil) {
        Logger.getInstance().error(message, data)
    }
    
    public static func warn(_ message: String, _ data: Any? = nil) {
        Logger.getInstance().warn(message, data)
    }
    
    public static func info(_ message: String, _ data: Any? = nil) {
        Logger.getInstance().info(message, data)
    }
    
    public static func debug(_ message: String, _ data: Any? = nil) {
        Logger.getInstance().debug(message, data)
    }
    
    public static func verbose(_ message: String, _ data: Any? = nil) {
        Logger.getInstance().verbose(message, data)
    }
}

