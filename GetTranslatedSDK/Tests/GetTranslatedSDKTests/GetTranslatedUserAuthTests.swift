//
//  GetTranslatedUserAuthTests.swift
//  GetTranslatedSDKTests
//
//  Created by GetTranslated SDK Test Generator
//

import XCTest
@testable import GetTranslatedSDK

final class GetTranslatedUserAuthTests: XCTestCase {
    
    // Helper class for initialization callbacks with error tracking
    private class TestInitCallback: InitCallback {
        var expectation: XCTestExpectation
        var errorReceived = false
        
        init(expectation: XCTestExpectation) {
            self.expectation = expectation
        }
        
        func onInitSuccess() {
            expectation.fulfill()
        }
        
        func onInitError(_ errorCode: Int, _ errorMessage: String) {
            errorReceived = true
            expectation.fulfill()
        }
    }
    
    // Helper class for simple initialization callbacks
    private class SimpleInitCallback: InitCallback {
        let expectation: XCTestExpectation
        init(expectation: XCTestExpectation) { self.expectation = expectation }
        func onInitSuccess() { expectation.fulfill() }
        func onInitError(_ errorCode: Int, _ errorMessage: String) { expectation.fulfill() }
    }
    
    override func setUp() {
        super.setUp()
        Logger.initialize(level: .debug, enableConsole: false)
    }
    
    override func tearDown() {
        resetSDKInstance()
        super.tearDown()
    }
    
    private func resetSDKInstance() {
        #if DEBUG
        GetTranslated.resetForTesting()
        #endif
    }
    
    // MARK: - Login Tests
    
    func testLoginBeforeInit() {
        // Test login before initialization should handle gracefully
        let expectation = XCTestExpectation(description: "Login callback")
        
        let callback = TestInitCallback(expectation: expectation)
        GetTranslated.login(userId: "user-123", callback: callback)
        
        wait(for: [expectation], timeout: 1.0)
        XCTAssertTrue(callback.errorReceived, "Should receive error when not initialized")
    }
    
    func testLoginWithEmptyUserId() {
        // Test login with empty user ID
        let expectation = XCTestExpectation(description: "Login callback")
        
        // First initialize
        let initExpectation = XCTestExpectation(description: "Init")
        let initCallback = SimpleInitCallback(expectation: initExpectation)
        GetTranslated.initialize(key: "test-key", callback: initCallback)
        wait(for: [initExpectation], timeout: 5.0)
        
        // Then try login with empty ID
        let callback = TestInitCallback(expectation: expectation)
        GetTranslated.login(userId: "", callback: callback)
        
        wait(for: [expectation], timeout: 1.0)
        XCTAssertTrue(callback.errorReceived, "Should receive error for empty user ID")
    }
    
    func testLoginWithWhitespaceUserId() {
        // Test login with whitespace-only user ID
        let expectation = XCTestExpectation(description: "Login callback")
        
        // First initialize
        let initExpectation = XCTestExpectation(description: "Init")
        GetTranslated.initialize(key: "test-key", callback: SimpleInitCallback(expectation: initExpectation))
        wait(for: [initExpectation], timeout: 5.0)
        
        // Then try login with whitespace
        let callback = TestInitCallback(expectation: expectation)
        GetTranslated.login(userId: "   ", callback: callback)
        
        wait(for: [expectation], timeout: 1.0)
        XCTAssertTrue(callback.errorReceived, "Should receive error for whitespace-only user ID")
    }
    
    // MARK: - Logout Tests
    
    func testLogoutBeforeInit() {
        // Test logout before initialization should handle gracefully
        let expectation = XCTestExpectation(description: "Logout callback")
        
        let callback = TestInitCallback(expectation: expectation)
        GetTranslated.logout(callback: callback)
        
        wait(for: [expectation], timeout: 1.0)
        XCTAssertTrue(callback.errorReceived, "Should receive error when not initialized")
    }
    
    // MARK: - User ID Generation Tests
    
    func testAnonymousUserIdFormat() {
        // Test that anonymous user IDs follow the expected format
        // Note: This tests the format, not the actual generation (which is private)
        // We can test by initializing and checking the stored user ID
        
        // Clear any existing stored user ID
        StorageKeys.removeStoredUserId()
        
        let expectation = XCTestExpectation(description: "Init")
        GetTranslated.initialize(key: "test-key", callback: SimpleInitCallback(expectation: expectation))
        
        wait(for: [expectation], timeout: 5.0)
        
        // Check if user ID was stored (format: random_string@bundle_id)
        if let storedUserId = StorageKeys.getStoredUserId() {
            XCTAssertTrue(storedUserId.contains("@"), "User ID should contain @")
            let components = storedUserId.split(separator: "@")
            XCTAssertEqual(components.count, 2, "User ID should have format: random@bundle")
        }
    }
}

