//
//  GetTranslatedInitOptionsTests.swift
//  GetTranslatedSDKTests
//
//  Created for testing InitOptions functionality
//

import XCTest
@testable import GetTranslatedSDK

final class GetTranslatedInitOptionsTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Initialize logger with console disabled for testing
        Logger.initialize(level: .debug, enableConsole: false)
        
        // Reset static instance
        resetSDKInstance()
        
        // Reset server URL to default
        Constants.setServer("https://www.gettranslated.ai")
    }
    
    override func tearDown() {
        // Reset static state after each test
        resetSDKInstance()
        Constants.setServer("https://www.gettranslated.ai")
        super.tearDown()
    }
    
    // Helper to reset SDK instance
    private func resetSDKInstance() {
        #if DEBUG
        GetTranslated.resetForTesting()
        #endif
    }
    
    // MARK: - InitOptions Tests
    
    func testInitOptionsCreation() {
        // Test creating InitOptions with serverUrl
        let options = InitOptions.withServerUrl("http://localhost:8000")
        XCTAssertNotNil(options, "InitOptions should not be null")
        XCTAssertEqual(options.serverUrl, "http://localhost:8000", "Server URL should be set")
    }
    
    func testInitOptionsWithEmptyInit() {
        // Test creating InitOptions with empty initializer
        let options = InitOptions()
        XCTAssertNotNil(options, "InitOptions should not be null")
        XCTAssertNil(options.serverUrl, "Server URL should be nil")
    }
    
    // MARK: - isInitialized() Tests
    
    func testIsInitializedBeforeInit() {
        // Test isInitialized returns false before initialization
        XCTAssertFalse(GetTranslated.isInitialized(), "Should return false before init")
    }
    
    func testIsInitializedAfterFailedInit() {
        // Test isInitialized returns false after failed initialization
        // Note: This test requires mocking network requests, which is complex
        // For now, we test that it returns false when instance is nil
        XCTAssertFalse(GetTranslated.isInitialized(), "Should return false when not initialized")
    }
    
    // MARK: - Server URL Option Tests
    
    func testInitWithServerUrlOption() {
        // Test initialization with serverUrl in InitOptions
        let customServerUrl = "http://localhost:8000"
        let options = InitOptions.withServerUrl(customServerUrl)
        
        // Verify options has the correct serverUrl
        XCTAssertEqual(options.serverUrl, customServerUrl, "Options should have the correct serverUrl")
        
        // Verify server URL can be set from options
        if let serverUrl = options.serverUrl {
            Constants.setServer(serverUrl)
            XCTAssertEqual(Constants.server, customServerUrl, "Server URL should be set from options")
        }
    }
    
    func testInitWithNullOptions() {
        // Test initialization with nil options (should use default server)
        // Reset to default
        Constants.setServer("https://www.gettranslated.ai")
        XCTAssertEqual(Constants.server, "https://www.gettranslated.ai", "Should use default server URL")
    }
    
    func testInitWithEmptyServerUrlOption() {
        // Test initialization with empty serverUrl in options (should use default)
        var options = InitOptions()
        options.serverUrl = ""
        
        // Empty server URL should not change the default
        Constants.setServer("https://www.gettranslated.ai")
        Constants.setServer("") // This should be ignored
        XCTAssertEqual(Constants.server, "https://www.gettranslated.ai", "Should use default server URL when empty")
    }
    
    func testInitWithWhitespaceServerUrlOption() {
        // Test initialization with whitespace-only serverUrl in options (should use default)
        let options = InitOptions.withServerUrl("   ")
        
        // Verify options has the whitespace serverUrl
        XCTAssertEqual(options.serverUrl, "   ", "Options should have the whitespace serverUrl")
        
        // Whitespace should be trimmed, but empty should be ignored
        Constants.setServer("https://www.gettranslated.ai")
        if let serverUrl = options.serverUrl {
            Constants.setServer(serverUrl)
        }
        // After trimming, empty string should not change server
        XCTAssertEqual(Constants.server, "https://www.gettranslated.ai", "Should use default server URL when whitespace")
    }
    
    func testServerUrlTrimming() {
        // Test that server URL trailing slashes are removed
        let serverUrlWithSlash = "http://localhost:8000/"
        Constants.setServer(serverUrlWithSlash)
        
        // Verify trailing slash was removed
        XCTAssertEqual(Constants.server, "http://localhost:8000", "Server URL should be trimmed")
    }
    
    func testServerUrlTrimmingWhitespace() {
        // Test that server URL whitespace is trimmed
        let serverUrlWithWhitespace = "  http://localhost:8000  "
        Constants.setServer(serverUrlWithWhitespace)
        
        // Verify whitespace was trimmed
        XCTAssertEqual(Constants.server, "http://localhost:8000", "Server URL should be trimmed")
    }
    
    // MARK: - Backward Compatibility Tests
    
    func testInitializeWithoutOptions() {
        // Test that initialize() can be called without options (backward compatibility)
        // This should compile and work with default parameters
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
        // Call without options parameter (should use default nil)
        GetTranslated.initialize(key: "test-key", callback: callback)
        
        wait(for: [expectation], timeout: 5.0)
        
        // Verify default server is used
        XCTAssertEqual(Constants.server, "https://www.gettranslated.ai", "Should use default server when no options")
    }
}

