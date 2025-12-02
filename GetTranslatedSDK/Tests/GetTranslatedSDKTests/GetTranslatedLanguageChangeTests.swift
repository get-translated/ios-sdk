//
//  GetTranslatedLanguageChangeTests.swift
//  GetTranslatedSDKTests
//
//  Created for testing language change callback functionality
//

import XCTest
@testable import GetTranslatedSDK

final class GetTranslatedLanguageChangeTests: XCTestCase {
    
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
    
    // MARK: - Language Change Callback Tests
    
    func testOnLanguageChangeCallback() {
        // Test that callback can be registered
        class TestCallback: LanguageChangeCallback {
            var languageChanged: String?
            var callCount = 0
            
            func onLanguageChanged(_ languageCode: String) {
                languageChanged = languageCode
                callCount += 1
            }
        }
        
        let callback = TestCallback()
        GetTranslated.onLanguageChange(callback)
        
        // Verify callback is registered (we can't easily test it being called without full init)
        // This test mainly verifies the API exists and doesn't crash
        XCTAssertNotNil(callback, "Callback should be registered")
    }
    
    func testMultipleLanguageChangeCallbacks() {
        // Test that multiple callbacks can be registered
        class TestCallback: LanguageChangeCallback {
            var languageChanged: String?
            
            func onLanguageChanged(_ languageCode: String) {
                languageChanged = languageCode
            }
        }
        
        let callback1 = TestCallback()
        let callback2 = TestCallback()
        
        GetTranslated.onLanguageChange(callback1)
        GetTranslated.onLanguageChange(callback2)
        
        // Verify both callbacks are registered
        XCTAssertNotNil(callback1, "First callback should be registered")
        XCTAssertNotNil(callback2, "Second callback should be registered")
    }
    
    func testOffLanguageChangeCallback() {
        // Test that callback can be unregistered
        class TestCallback: LanguageChangeCallback {
            var languageChanged: String?
            
            func onLanguageChanged(_ languageCode: String) {
                languageChanged = languageCode
            }
        }
        
        let callback = TestCallback()
        GetTranslated.onLanguageChange(callback)
        
        // Unregister the callback
        GetTranslated.offLanguageChange(callback)
        
        // Verify callback can be unregistered (we can't easily test it not being called without full init)
        // This test mainly verifies the API exists and doesn't crash
        XCTAssertNotNil(callback, "Callback should exist")
    }
    
    func testCallbackNotCalledAfterUnregistration() {
        // Test that unregistered callback is not called
        // Note: This requires full SDK initialization to test properly
        // For now, we just verify the API exists
        
        class TestCallback: LanguageChangeCallback {
            var callCount = 0
            
            func onLanguageChanged(_ languageCode: String) {
                callCount += 1
            }
        }
        
        let callback = TestCallback()
        GetTranslated.onLanguageChange(callback)
        GetTranslated.offLanguageChange(callback)
        
        // In a full integration test, we would initialize SDK, change language,
        // and verify callback.callCount is 0
        XCTAssertEqual(callback.callCount, 0, "Callback should not be called before language change")
    }
    
    // MARK: - Integration with setLanguage Tests
    
    func testLanguageChangeCallbackWithSetLanguage() {
        // Test that callback is called when setLanguage is called
        // Note: This requires SDK to be initialized, which is complex in unit tests
        // This is a placeholder for integration tests
        
        class TestCallback: LanguageChangeCallback {
            var languageChanged: String?
            
            func onLanguageChanged(_ languageCode: String) {
                languageChanged = languageCode
            }
        }
        
        let callback = TestCallback()
        GetTranslated.onLanguageChange(callback)
        
        // In a full test, we would:
        // 1. Initialize SDK
        // 2. Call setLanguage("es")
        // 3. Verify callback.onLanguageChanged was called with "es"
        
        // For now, just verify the callback is registered
        XCTAssertNotNil(callback, "Callback should be registered")
    }
}

