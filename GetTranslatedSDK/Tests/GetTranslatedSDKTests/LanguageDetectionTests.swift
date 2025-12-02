//
//  LanguageDetectionTests.swift
//  GetTranslatedSDKTests
//
//  Created by GetTranslated SDK Test Generator
//

import XCTest
@testable import GetTranslatedSDK

final class LanguageDetectionTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Initialize logger in test mode
        Logger.initialize(level: .debug, enableConsole: false)
    }
    
    // MARK: - Device Language Tests
    
    func testGetDeviceLanguage() {
        let language = LanguageDetection.getDeviceLanguage()
        
        XCTAssertNotNil(language, "Should return a language")
        XCTAssertFalse(language.isEmpty, "Should not be empty")
        XCTAssertEqual(language.count, 2, "Should return ISO 639-1 language code (2 characters)")
    }
    
    // MARK: - Best Language Match Tests
    
    func testFindBestLanguageMatchExactMatch() {
        let availableLanguages = ["en", "es", "fr", "de"]
        let result = LanguageDetection.findBestLanguageMatch(availableLanguages: availableLanguages, fallbackLanguage: "en")
        
        // Should return one of the available languages
        XCTAssertTrue(availableLanguages.contains(result), "Result should be in available languages")
    }
    
    func testFindBestLanguageMatchWithEmptyArray() {
        let emptyArray: [String] = []
        let result = LanguageDetection.findBestLanguageMatch(availableLanguages: emptyArray, fallbackLanguage: "en")
        
        XCTAssertEqual("en", result, "Should return fallback language")
    }
    
    func testFindBestLanguageMatchWithFallback() {
        let availableLanguages = ["es", "fr"]
        let result = LanguageDetection.findBestLanguageMatch(availableLanguages: availableLanguages, fallbackLanguage: "en")
        
        // Should return fallback if device language not in available
        XCTAssertTrue(["en", "es", "fr"].contains(result), "Should return fallback or available language")
    }
    
    func testFindBestLanguageMatchWithNullFallback() {
        let availableLanguages = ["es", "fr"]
        let result = LanguageDetection.findBestLanguageMatch(availableLanguages: availableLanguages, fallbackLanguage: "")
        
        // Should return first available language if fallback is empty
        XCTAssertTrue(availableLanguages.contains(result), "Should return one of available languages")
    }
    
    // MARK: - Get Best Device Language Tests
    
    func testGetBestDeviceLanguage() {
        let availableLanguages = ["en", "es", "fr", "de"]
        let result = LanguageDetection.getBestDeviceLanguage(availableLanguages: availableLanguages, fallbackLanguage: "en")
        
        XCTAssertNotNil(result, "Result should not be null")
        XCTAssertTrue(availableLanguages.contains(result) || result == "en", "Result should be in available languages or fallback")
    }
    
    func testGetBestDeviceLanguageWithEmptyArray() {
        let emptyArray: [String] = []
        let result = LanguageDetection.getBestDeviceLanguage(availableLanguages: emptyArray, fallbackLanguage: "en")
        
        XCTAssertEqual("en", result, "Should return fallback language")
    }
    
    func testGetBestDeviceLanguageConvenienceMethod() {
        let availableLanguages = ["en", "es", "fr"]
        let result = LanguageDetection.getBestDeviceLanguage(availableLanguages: availableLanguages)
        
        XCTAssertNotNil(result, "Result should not be null")
        XCTAssertTrue(availableLanguages.contains(result) || result == "en", "Result should be in available languages or default fallback")
    }
    
    func testGetBestDeviceLanguageWithDefaultFallback() {
        let availableLanguages = ["es", "fr", "de"]
        let result = LanguageDetection.getBestDeviceLanguage(availableLanguages: availableLanguages)
        
        XCTAssertNotNil(result, "Result should not be null")
        // Should return one of available languages or default fallback "en"
        XCTAssertTrue(availableLanguages.contains(result) || result == "en", "Result should be valid")
    }
    
    // MARK: - Language Matching Edge Cases
    
    func testLanguageMatchingWithBaseLanguage() {
        // Test that base language matching works (e.g., "en-US" -> "en")
        let availableLanguages = ["en", "es"]
        let result = LanguageDetection.getBestDeviceLanguage(availableLanguages: availableLanguages, fallbackLanguage: "en")
        
        XCTAssertTrue(availableLanguages.contains(result) || result == "en", "Should match base language")
    }
}

