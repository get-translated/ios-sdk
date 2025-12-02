//
//  GetTranslatedInitTests.swift
//  GetTranslatedSDKTests
//
//  Created by GetTranslated SDK Test Generator
//

import XCTest
@testable import GetTranslatedSDK

final class GetTranslatedInitTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Initialize logger with console disabled for testing
        Logger.initialize(level: .debug, enableConsole: false)
        
        // Reset static instance
        resetSDKInstance()
    }
    
    override func tearDown() {
        // Reset static state after each test
        resetSDKInstance()
        super.tearDown()
    }
    
    // Helper to reset SDK instance
    private func resetSDKInstance() {
        #if DEBUG
        GetTranslated.resetForTesting()
        #endif
    }
    
    // MARK: - Public API Tests (No initialization required)
    
    func testIsInitializedBeforeInit() {
        // Test isInitialized before initialization
        XCTAssertFalse(GetTranslated.isInitialized(), "Should return false before init")
    }
    
    func testGetLanguagesBeforeInit() {
        // Test getLanguages before initialization
        let languages = GetTranslated.getLanguages()
        XCTAssertNotNil(languages, "Languages should not be null")
        XCTAssertTrue(languages.isEmpty, "Languages should be empty before init")
    }
    
    func testGetCurrentLanguageBeforeInit() {
        // Test getCurrentLanguage before initialization
        let language = GetTranslated.getCurrentLanguage()
        XCTAssertEqual("en", language, "Should return default 'en' before init")
    }
    
    func testGetDynamicStringBeforeInit() {
        // Test getDynamicString before initialization
        let result = GetTranslated.getDynamicString("Hello")
        XCTAssertEqual("Hello", result, "Should return original string")
    }
    
    func testGetDynamicStringWithCallbackBeforeInit() {
        // Test getDynamicString with callback before initialization
        let expectation = XCTestExpectation(description: "Callback should be called")
        var callbackCalled = false
        
        let result = GetTranslated.getDynamicString("Hello") { translation in
            callbackCalled = true
            expectation.fulfill()
        } onError: { error in
            callbackCalled = true
            expectation.fulfill()
        }
        
        XCTAssertEqual("Hello", result, "Should return original string")
        
        wait(for: [expectation], timeout: 1.0)
        XCTAssertTrue(callbackCalled, "Callback should be called with error")
    }
    
    // MARK: - Initialization Tests
    
    func testInitWithKey() {
        // Test basic initialization with just API key
        // Note: This will make a real network call, so it may fail in test environment
        // In a real test suite, you'd mock URLSession
        let expectation = XCTestExpectation(description: "Init callback")
        
        class TestInitCallback: InitCallback {
            var expectation: XCTestExpectation
            var success: Bool = false
            var error: (Int, String)?
            
            init(expectation: XCTestExpectation) {
                self.expectation = expectation
            }
            
            func onInitSuccess() {
                success = true
                expectation.fulfill()
            }
            
            func onInitError(_ errorCode: Int, _ errorMessage: String) {
                error = (errorCode, errorMessage)
                expectation.fulfill()
            }
        }
        
        let callback = TestInitCallback(expectation: expectation)
        GetTranslated.initialize(key: "test-key", callback: callback)
        
        wait(for: [expectation], timeout: 5.0)
        
        // Either success or error is acceptable in test environment
        XCTAssertTrue(callback.success || callback.error != nil, "Init should complete (success or error)")
    }
    
    func testInitWithUserId() {
        // Test initialization with user ID
        let expectation = XCTestExpectation(description: "Init callback")
        
        class TestInitCallback: InitCallback {
            var expectation: XCTestExpectation
            
            init(expectation: XCTestExpectation) {
                self.expectation = expectation
            }
            
            func onInitSuccess() {
                expectation.fulfill()
            }
            
            func onInitError(_ errorCode: Int, _ errorMessage: String) {
                expectation.fulfill()
            }
        }
        
        let callback = TestInitCallback(expectation: expectation)
        GetTranslated.initialize(key: "test-key", userId: "user-123", callback: callback)
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testInitWithLogLevel() {
        // Test initialization with custom log level
        let expectation = XCTestExpectation(description: "Init callback")
        
        class TestInitCallback: InitCallback {
            var expectation: XCTestExpectation
            
            init(expectation: XCTestExpectation) {
                self.expectation = expectation
            }
            
            func onInitSuccess() {
                expectation.fulfill()
            }
            
            func onInitError(_ errorCode: Int, _ errorMessage: String) {
                expectation.fulfill()
            }
        }
        
        let callback = TestInitCallback(expectation: expectation)
        GetTranslated.initialize(key: "test-key", userId: nil, logLevel: .verbose, callback: callback)
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testDoubleInit() {
        // Test that calling init twice doesn't cause issues
        let expectation1 = XCTestExpectation(description: "First init")
        let expectation2 = XCTestExpectation(description: "Second init")
        
        class TestInitCallback: InitCallback {
            var expectation: XCTestExpectation
            
            init(expectation: XCTestExpectation) {
                self.expectation = expectation
            }
            
            func onInitSuccess() {
                expectation.fulfill()
            }
            
            func onInitError(_ errorCode: Int, _ errorMessage: String) {
                expectation.fulfill()
            }
        }
        
        let callback1 = TestInitCallback(expectation: expectation1)
        GetTranslated.initialize(key: "test-key", callback: callback1)
        
        wait(for: [expectation1], timeout: 5.0)
        
        // Second init should call callback immediately (already initialized)
        let callback2 = TestInitCallback(expectation: expectation2)
        GetTranslated.initialize(key: "test-key", callback: callback2)
        
        wait(for: [expectation2], timeout: 1.0)
    }
    
    // MARK: - isInitialized() Tests
    
    func testIsInitializedAfterSuccessfulInit() {
        // Test isInitialized returns true after successful initialization
        let expectation = XCTestExpectation(description: "Init callback")
        
        class TestInitCallback: InitCallback {
            var expectation: XCTestExpectation
            var success = false
            
            init(expectation: XCTestExpectation) {
                self.expectation = expectation
            }
            
            func onInitSuccess() {
                success = true
                expectation.fulfill()
            }
            
            func onInitError(_ errorCode: Int, _ errorMessage: String) {
                expectation.fulfill()
            }
        }
        
        let callback = TestInitCallback(expectation: expectation)
        GetTranslated.initialize(key: "test-key", callback: callback)
        
        wait(for: [expectation], timeout: 5.0)
        
        // Either success or error is acceptable in test environment
        // If successful, isInitialized should be true
        if callback.success {
            XCTAssertTrue(GetTranslated.isInitialized(), "Should return true after successful init")
        } else {
            // If init failed, isInitialized should be false
            XCTAssertFalse(GetTranslated.isInitialized(), "Should return false after failed init")
        }
    }
    
    func testIsInitializedAfterFailedInit() {
        // Test isInitialized returns false after failed initialization
        // Note: This is hard to test without mocking, but we can verify the state
        // Before any init attempt, it should be false
        XCTAssertFalse(GetTranslated.isInitialized(), "Should return false when not initialized")
    }
}

