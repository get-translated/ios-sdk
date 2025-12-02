//
//  StorageKeysTests.swift
//  GetTranslatedSDKTests
//
//  Created by GetTranslated SDK Test Generator
//

import XCTest
@testable import GetTranslatedSDK

final class StorageKeysTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Clear UserDefaults before each test
        if let bundleID = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: bundleID)
        }
    }
    
    override func tearDown() {
        // Clean up after each test
        if let bundleID = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: bundleID)
        }
        super.tearDown()
    }
    
    // MARK: - Key Generation Tests
    
    func testGenerateKey() {
        let result = StorageKeys.generateKey(category: "user", identifier: "test123", suffix: "language_override")
        XCTAssertEqual("ai.gettranslated.sdk_user_test123_language_override", result)
    }
    
    func testGenerateUserKey() {
        let result = StorageKeys.generateUserKey(userId: "test123", suffix: "language_override")
        XCTAssertEqual("ai.gettranslated.sdk_user_test123_language_override", result)
    }
    
    func testGenerateLanguageKey() {
        let result = StorageKeys.generateLanguageKey(language: "en", suffix: "last_sync")
        XCTAssertEqual("ai.gettranslated.sdk_lang_en_last_sync", result)
    }
    
    func testGenerateTranslationKey() {
        let result = StorageKeys.generateTranslationKey(languageCode: "en", text: "Hello World")
        XCTAssertTrue(result.hasPrefix("ai.gettranslated.sdk_trans_"), "Translation key should contain prefix and category")
        XCTAssertTrue(result.contains("en"), "Translation key should contain language code")
        XCTAssertTrue(result.hasSuffix("_translation"), "Translation key should end with translation suffix")
    }
    
    func testKeyGenerationConsistency() {
        // Test that key generation is consistent
        let key1 = StorageKeys.generateKey(category: "user", identifier: "test123", suffix: "language_override")
        let key2 = StorageKeys.generateKey(category: "user", identifier: "test123", suffix: "language_override")
        XCTAssertEqual(key1, key2, "Keys should be consistent")
    }
    
    func testUserKeyGeneration() {
        let result = StorageKeys.generateUserKey(userId: "user123", suffix: "language_override")
        let expected = "ai.gettranslated.sdk_user_user123_language_override"
        XCTAssertEqual(expected, result)
    }
    
    func testLanguageKeyGeneration() {
        let result = StorageKeys.generateLanguageKey(language: "es", suffix: "last_sync")
        let expected = "ai.gettranslated.sdk_lang_es_last_sync"
        XCTAssertEqual(expected, result)
    }
    
    func testTranslationKeyGeneration() {
        let result = StorageKeys.generateTranslationKey(languageCode: "en", text: "Hello World")
        XCTAssertTrue(result.hasPrefix("ai.gettranslated.sdk_trans_"), "Translation key should contain prefix")
        XCTAssertTrue(result.contains("en"), "Translation key should contain language code")
        XCTAssertTrue(result.hasSuffix("_translation"), "Translation key should end with translation suffix")
    }
    
    func testTranslationKeyConsistency() {
        // Same input should produce same key
        let key1 = StorageKeys.generateTranslationKey(languageCode: "en", text: "Hello World")
        let key2 = StorageKeys.generateTranslationKey(languageCode: "en", text: "Hello World")
        XCTAssertEqual(key1, key2, "Translation keys should be consistent")
    }
    
    func testTranslationKeyUniqueness() {
        // Different inputs should produce different keys
        let key1 = StorageKeys.generateTranslationKey(languageCode: "en", text: "Hello World")
        let key2 = StorageKeys.generateTranslationKey(languageCode: "es", text: "Hello World")
        let key3 = StorageKeys.generateTranslationKey(languageCode: "en", text: "Hola Mundo")
        
        XCTAssertNotEqual(key1, key2, "Different languages should produce different keys")
        XCTAssertNotEqual(key1, key3, "Different texts should produce different keys")
        XCTAssertNotEqual(key2, key3, "Different languages and texts should produce different keys")
    }
    
    // MARK: - User Language Override Tests
    
    func testUserLanguageOverride() {
        let userId = "test-user-123"
        let language = "es"
        
        StorageKeys.setUserLanguageOverride(userId: userId, language: language)
        let retrieved = StorageKeys.getUserLanguageOverride(userId: userId)
        
        XCTAssertEqual(language, retrieved)
    }
    
    func testRemoveUserLanguageOverride() {
        let userId = "test-user-123"
        let language = "es"
        
        StorageKeys.setUserLanguageOverride(userId: userId, language: language)
        StorageKeys.removeUserLanguageOverride(userId: userId)
        let retrieved = StorageKeys.getUserLanguageOverride(userId: userId)
        
        XCTAssertNil(retrieved)
    }
    
    // MARK: - Server Language Override Tests
    
    func testServerLanguageOverride() {
        let userId = "test-user-123"
        let language = "fr"
        
        StorageKeys.setServerLanguageOverride(userId: userId, language: language)
        let retrieved = StorageKeys.getServerLanguageOverride(userId: userId)
        
        XCTAssertEqual(language, retrieved)
    }
    
    func testRemoveServerLanguageOverride() {
        let userId = "test-user-123"
        let language = "fr"
        
        StorageKeys.setServerLanguageOverride(userId: userId, language: language)
        StorageKeys.removeServerLanguageOverride(userId: userId)
        let retrieved = StorageKeys.getServerLanguageOverride(userId: userId)
        
        XCTAssertNil(retrieved)
    }
    
    // MARK: - Sync Timestamp Tests
    
    func testSyncTimestamp() {
        let language = "es"
        let timestamp: Int64 = 1234567890
        
        StorageKeys.setLastSyncTimestamp(language: language, timestamp: timestamp)
        let retrieved = StorageKeys.getLastSyncTimestamp(language: language)
        
        XCTAssertEqual(timestamp, retrieved)
    }
    
    // MARK: - User ID Management Tests
    
    func testStoreAndRetrieveUserId() {
        let userId = "test-user-456"
        
        StorageKeys.storeUserId(userId)
        let retrieved = StorageKeys.getStoredUserId()
        
        XCTAssertEqual(userId, retrieved)
    }
    
    func testRemoveStoredUserId() {
        let userId = "test-user-456"
        
        StorageKeys.storeUserId(userId)
        StorageKeys.removeStoredUserId()
        let retrieved = StorageKeys.getStoredUserId()
        
        XCTAssertNil(retrieved)
    }
    
    // MARK: - App Name Management Tests
    
    func testStoreAndRetrieveAppName() {
        let appName = "TestApp"
        
        StorageKeys.storeAppName(appName)
        let retrieved = StorageKeys.getStoredAppName()
        
        XCTAssertEqual(appName, retrieved)
    }
    
    // MARK: - Translation Cache Tests
    
    func testCacheTranslation() {
        let language = "es"
        let text = "Hello World"
        let translation = "Hola Mundo"
        
        StorageKeys.cacheTranslation(language: language, text: text, translation: translation)
        let retrieved = StorageKeys.getCachedTranslation(language: language, text: text)
        
        XCTAssertEqual(translation, retrieved)
    }
    
    func testRemoveCachedTranslation() {
        let language = "es"
        let text = "Hello World"
        let translation = "Hola Mundo"
        
        StorageKeys.cacheTranslation(language: language, text: text, translation: translation)
        StorageKeys.removeCachedTranslation(language: language, text: text)
        let retrieved = StorageKeys.getCachedTranslation(language: language, text: text)
        
        XCTAssertNil(retrieved)
    }
}

