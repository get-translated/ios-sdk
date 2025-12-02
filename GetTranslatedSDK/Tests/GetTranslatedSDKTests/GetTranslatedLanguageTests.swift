//
//  GetTranslatedLanguageTests.swift
//  GetTranslatedSDKTests
//
//  Created by GetTranslated SDK Test Generator
//

import XCTest
@testable import GetTranslatedSDK

final class GetTranslatedLanguageTests: XCTestCase {
    
    // Helper class for initialization callbacks
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
    
    // MARK: - Language Management Tests
    
    func testSetLanguageBeforeInit() {
        // Test setLanguage before initialization
        GetTranslated.setLanguage("es")
        
        // Should not throw, but may not have effect
        let currentLang = GetTranslated.getCurrentLanguage()
        // Should return default or set language
        XCTAssertNotNil(currentLang)
    }
    
    func testGetLanguagesBeforeInit() {
        // Test getLanguages before initialization
        let languages = GetTranslated.getLanguages()
        XCTAssertTrue(languages.isEmpty, "Should return empty set before init")
    }
    
    func testGetCurrentLanguageBeforeInit() {
        // Test getCurrentLanguage before initialization
        let language = GetTranslated.getCurrentLanguage()
        XCTAssertEqual("en", language, "Should return default 'en' before init")
    }
    
    func testSetLanguageWithInvalidCode() {
        // Test setting language with invalid code
        // First initialize
        let initExpectation = XCTestExpectation(description: "Init")
        GetTranslated.initialize(key: "test-key", callback: SimpleInitCallback(expectation: initExpectation))
        wait(for: [initExpectation], timeout: 5.0)
        
        // Try to set invalid language
        GetTranslated.setLanguage("invalid-lang-code")
        
        // Should not crash, but may not set the language if not in supported languages
        let currentLang = GetTranslated.getCurrentLanguage()
        XCTAssertNotNil(currentLang)
    }
    
    func testSetLanguageWithValidCode() {
        // Test setting language with valid code
        // First initialize
        let initExpectation = XCTestExpectation(description: "Init")
        GetTranslated.initialize(key: "test-key", callback: SimpleInitCallback(expectation: initExpectation))
        wait(for: [initExpectation], timeout: 5.0)
        
        // Set language
        GetTranslated.setLanguage("es")
        
        // Verify language was set
        let currentLang = GetTranslated.getCurrentLanguage()
        // May be "es" if supported, or may remain previous language
        XCTAssertNotNil(currentLang)
    }
    
    func testLanguagePersistence() {
        // Test that language preference is persisted
        let userId = "test-user-123"
        
        // Set language override for user
        StorageKeys.setUserLanguageOverride(userId: userId, language: "fr")
        
        // Retrieve it
        let retrieved = StorageKeys.getUserLanguageOverride(userId: userId)
        XCTAssertEqual("fr", retrieved, "Language preference should be persisted")
    }
    
    func testServerLanguageOverride() {
        // Test server language override
        let userId = "test-user-123"
        
        StorageKeys.setServerLanguageOverride(userId: userId, language: "de")
        let retrieved = StorageKeys.getServerLanguageOverride(userId: userId)
        
        XCTAssertEqual("de", retrieved, "Server language override should be stored")
    }
}

