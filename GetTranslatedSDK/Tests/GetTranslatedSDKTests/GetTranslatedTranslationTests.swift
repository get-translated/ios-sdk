//
//  GetTranslatedTranslationTests.swift
//  GetTranslatedSDKTests
//
//  Created by GetTranslated SDK Test Generator
//

import XCTest
@testable import GetTranslatedSDK

final class GetTranslatedTranslationTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        Logger.initialize(level: .debug, enableConsole: false)
        
        // Clear translation cache
        if let bundleID = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: bundleID)
        }
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
    
    // MARK: - Translation Tests
    
    func testGetDynamicStringBeforeInit() {
        // Test getDynamicString before initialization
        let result = GetTranslated.getDynamicString("Hello World")
        XCTAssertEqual("Hello World", result, "Should return original string before init")
    }
    
    func testGetDynamicStringWithCallbackBeforeInit() {
        // Test getDynamicString with callback before initialization
        let expectation = XCTestExpectation(description: "Translation callback")
        var callbackCalled = false
        var errorReceived = false
        
        let result = GetTranslated.getDynamicString("Hello World") { translation in
            callbackCalled = true
            expectation.fulfill()
        } onError: { error in
            errorReceived = true
            callbackCalled = true
            expectation.fulfill()
        }
        
        XCTAssertEqual("Hello World", result, "Should return original string")
        
        wait(for: [expectation], timeout: 1.0)
        XCTAssertTrue(callbackCalled, "Callback should be called")
        XCTAssertTrue(errorReceived, "Should receive error when not initialized")
    }
    
    func testGetDynamicStringWithEmptyText() {
        // Test getDynamicString with empty text
        let result = GetTranslated.getDynamicString("")
        XCTAssertEqual("", result, "Should return empty string")
    }
    
    func testGetDynamicStringWithWhitespaceText() {
        // Test getDynamicString with whitespace-only text
        let result = GetTranslated.getDynamicString("   ")
        XCTAssertEqual("   ", result, "Should return whitespace string")
    }
    
    func testTranslationCache() {
        // Test translation caching
        let language = "es"
        let text = "Hello World"
        let translation = "Hola Mundo"
        
        // Cache translation
        StorageKeys.cacheTranslation(language: language, text: text, translation: translation)
        
        // Retrieve cached translation
        let cached = StorageKeys.getCachedTranslation(language: language, text: text)
        XCTAssertEqual(translation, cached, "Should retrieve cached translation")
    }
    
    func testTranslationCacheKeyConsistency() {
        // Test that same text produces same cache key
        let language = "en"
        let text = "Test String"
        
        // Generate key twice
        let key1 = StorageKeys.generateTranslationKey(languageCode: language, text: text)
        let key2 = StorageKeys.generateTranslationKey(languageCode: language, text: text)
        
        XCTAssertEqual(key1, key2, "Same text should produce same cache key")
    }
    
    func testTranslationCacheKeyUniqueness() {
        // Test that different texts produce different cache keys
        let language = "en"
        let text1 = "Hello"
        let text2 = "World"
        
        let key1 = StorageKeys.generateTranslationKey(languageCode: language, text: text1)
        let key2 = StorageKeys.generateTranslationKey(languageCode: language, text: text2)
        
        XCTAssertNotEqual(key1, key2, "Different texts should produce different cache keys")
    }
    
    func testTranslationCacheWithDifferentLanguages() {
        // Test that same text in different languages uses different cache keys
        let text = "Hello"
        let language1 = "es"
        let language2 = "fr"
        
        let key1 = StorageKeys.generateTranslationKey(languageCode: language1, text: text)
        let key2 = StorageKeys.generateTranslationKey(languageCode: language2, text: text)
        
        XCTAssertNotEqual(key1, key2, "Different languages should produce different cache keys")
    }
    
    func testGetDynamicStringWithProtocolCallback() {
        // Test getDynamicString with protocol-based callback
        let expectation = XCTestExpectation(description: "Translation callback")
        
        class TestTranslationCallback: TranslationCallback {
            var expectation: XCTestExpectation
            var translationReceived: String?
            var errorReceived: String?
            
            init(expectation: XCTestExpectation) {
                self.expectation = expectation
            }
            
            func onTranslationReady(_ translation: String) {
                translationReceived = translation
                expectation.fulfill()
            }
            
            func onTranslationError(_ errorMessage: String) {
                errorReceived = errorMessage
                expectation.fulfill()
            }
        }
        
        let callback = TestTranslationCallback(expectation: expectation)
        let result = GetTranslated.getDynamicString("Hello", callback: callback)
        
        XCTAssertEqual("Hello", result, "Should return original string")
        
        wait(for: [expectation], timeout: 1.0)
        // Should receive error since not initialized
        XCTAssertNotNil(callback.errorReceived, "Should receive error when not initialized")
    }
}

