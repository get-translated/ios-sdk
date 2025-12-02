//
//  LoggerTests.swift
//  GetTranslatedSDKTests
//
//  Created by GetTranslated SDK Test Generator
//

import XCTest
@testable import GetTranslatedSDK

final class LoggerTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Initialize logger with console disabled for testing
        Logger.initialize(level: .debug, enableConsole: false)
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    // MARK: - Logger Initialization Tests
    
    func testLoggerInitialization() {
        let logger = Logger.getInstance()
        XCTAssertNotNil(logger, "Logger instance should not be null")
        XCTAssertEqual(.debug, logger.getLevel(), "Default log level should be DEBUG")
    }
    
    func testLogLevelConfiguration() {
        Logger.initialize(level: .error, enableConsole: false)
        let logger = Logger.getInstance()
        XCTAssertEqual(.error, logger.getLevel(), "Log level should be ERROR")
        XCTAssertTrue(logger.isLevelEnabled(.error), "ERROR level should be enabled")
        XCTAssertFalse(logger.isLevelEnabled(.debug), "DEBUG level should be disabled")
    }
    
    func testLogLevelChange() {
        let logger = Logger.getInstance()
        logger.setLevel(.warn)
        XCTAssertEqual(.warn, logger.getLevel(), "Log level should be WARN")
    }
    
    // MARK: - Static Logging Methods Tests
    
    func testStaticLoggingMethods() {
        // Test that static methods don't throw exceptions when logger is initialized
        Log.error("Test error message")
        Log.warn("Test warning message")
        Log.info("Test info message")
        Log.debug("Test debug message")
        Log.verbose("Test verbose message")
        // If we get here, the methods executed without throwing exceptions
        XCTAssertTrue(true, "Static logging methods should execute without exceptions")
    }
    
    func testLoggingWithData() {
        // Test that static methods with data don't throw exceptions when logger is initialized
        Log.error("Test error with data", NSError(domain: "Test", code: 1))
        Log.warn("Test warning with data", "test data")
        Log.info("Test info with data", 123)
        Log.debug("Test debug with data", true)
        Log.verbose("Test verbose with data", nil)
        // If we get here, the methods executed without throwing exceptions
        XCTAssertTrue(true, "Static logging methods with data should execute without exceptions")
    }
    
    // MARK: - Log Level Filtering Tests
    
    func testLogLevelFiltering() {
        Logger.initialize(level: .warn, enableConsole: false)
        let logger = Logger.getInstance()
        
        // Only WARN and ERROR should be enabled
        XCTAssertTrue(logger.isLevelEnabled(.error), "ERROR should be enabled")
        XCTAssertTrue(logger.isLevelEnabled(.warn), "WARN should be enabled")
        XCTAssertFalse(logger.isLevelEnabled(.info), "INFO should be disabled")
        XCTAssertFalse(logger.isLevelEnabled(.debug), "DEBUG should be disabled")
        XCTAssertFalse(logger.isLevelEnabled(.verbose), "VERBOSE should be disabled")
    }
    
    // MARK: - Instance Logging Methods Tests
    
    func testInstanceLoggingMethods() {
        let logger = Logger.getInstance()
        
        // Test that instance methods don't throw exceptions
        logger.error("Test error message")
        logger.warn("Test warning message")
        logger.info("Test info message")
        logger.debug("Test debug message")
        logger.verbose("Test verbose message")
        XCTAssertTrue(true, "Instance logging methods should execute without exceptions")
    }
    
    func testInstanceLoggingWithData() {
        let logger = Logger.getInstance()
        
        // Test that instance methods with data don't throw exceptions
        logger.error("Test error with data", NSError(domain: "Test", code: 1))
        logger.warn("Test warning with data", "test data")
        logger.info("Test info with data", 123)
        logger.debug("Test debug with data", true)
        logger.verbose("Test verbose with data", nil)
        XCTAssertTrue(true, "Instance logging methods with data should execute without exceptions")
    }
    
    // MARK: - Log Level Comparison Tests
    
    func testLogLevelComparison() {
        XCTAssertTrue(LogLevel.error < LogLevel.warn, "ERROR should be less than WARN")
        XCTAssertTrue(LogLevel.warn < LogLevel.info, "WARN should be less than INFO")
        XCTAssertTrue(LogLevel.info < LogLevel.debug, "INFO should be less than DEBUG")
        XCTAssertTrue(LogLevel.debug < LogLevel.verbose, "DEBUG should be less than VERBOSE")
    }
}

