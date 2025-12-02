//
//  StorageKeys.swift
//  GetTranslatedSDK
//
//  Created by GetTranslated SDK Generator
//

import Foundation

/// Standardized storage key management for GetTranslated iOS SDK
/// Provides consistent key generation and storage operations following the pattern:
/// {PREFIX}_{CATEGORY}_{IDENTIFIER}_{SUFFIX}
public enum StorageKeys {
    
    // MARK: - Key Generation
    
    /// Generate standardized key following pattern: {PREFIX}_{CATEGORY}_{IDENTIFIER}_{SUFFIX}
    public static func generateKey(category: String, identifier: String, suffix: String) -> String {
        return "\(Constants.prefix)_\(category)_\(identifier)_\(suffix)"
    }
    
    /// Generate user-specific key following pattern: {PREFIX}_user_{userId}_{suffix}
    public static func generateUserKey(userId: String, suffix: String) -> String {
        return generateKey(category: Constants.Category.user, identifier: userId, suffix: suffix)
    }
    
    /// Generate language-specific key following pattern: {PREFIX}_lang_{language}_{suffix}
    public static func generateLanguageKey(language: String, suffix: String) -> String {
        return generateKey(category: Constants.Category.language, identifier: language, suffix: suffix)
    }
    
    /// Generate translation cache key following pattern: {PREFIX}_trans_{languageCode}{hash}_translation
    /// Uses the same hash algorithm as Java's String.hashCode() to ensure consistency across platforms
    /// Java hashCode formula: s[0]*31^(n-1) + s[1]*31^(n-2) + ... + s[n-1]
    public static func generateTranslationKey(languageCode: String, text: String) -> String {
        let hash = text.utf8.reduce(0) { (result, byte) -> Int32 in
            return (result &* 31) &+ Int32(byte)
        }
        return generateKey(category: Constants.Category.translation, identifier: "\(languageCode)\(hash)", suffix: "translation")
    }
    
    // MARK: - User Language Override
    
    /// Get user language override using standardized key
    public static func getUserLanguageOverride(userId: String) -> String? {
        let key = generateUserKey(userId: userId, suffix: "language_override")
        return UserDefaults.standard.string(forKey: key)
    }
    
    /// Set user language override using standardized key
    public static func setUserLanguageOverride(userId: String, language: String) {
        let key = generateUserKey(userId: userId, suffix: "language_override")
        UserDefaults.standard.set(language, forKey: key)
    }
    
    /// Remove user language override using standardized key
    public static func removeUserLanguageOverride(userId: String) {
        let key = generateUserKey(userId: userId, suffix: "language_override")
        UserDefaults.standard.removeObject(forKey: key)
    }
    
    // MARK: - Server Language Override
    
    /// Get server language override using standardized key
    public static func getServerLanguageOverride(userId: String) -> String? {
        let key = generateUserKey(userId: userId, suffix: "server_override")
        return UserDefaults.standard.string(forKey: key)
    }
    
    /// Set server language override using standardized key
    public static func setServerLanguageOverride(userId: String, language: String) {
        let key = generateUserKey(userId: userId, suffix: "server_override")
        UserDefaults.standard.set(language, forKey: key)
    }
    
    /// Remove server language override using standardized key
    public static func removeServerLanguageOverride(userId: String) {
        let key = generateUserKey(userId: userId, suffix: "server_override")
        UserDefaults.standard.removeObject(forKey: key)
    }
    
    // MARK: - Sync Timestamps
    
    /// Get last sync timestamp using standardized key
    public static func getLastSyncTimestamp(language: String) -> Int64 {
        let key = generateLanguageKey(language: language, suffix: "last_sync")
        return Int64(UserDefaults.standard.integer(forKey: key))
    }
    
    /// Set last sync timestamp using standardized key
    public static func setLastSyncTimestamp(language: String, timestamp: Int64) {
        let key = generateLanguageKey(language: language, suffix: "last_sync")
        UserDefaults.standard.set(Int(timestamp), forKey: key)
    }
    
    // MARK: - User ID Management
    
    /// Get stored user ID using standardized key
    public static func getStoredUserId() -> String? {
        let key = generateKey(category: Constants.Category.config, identifier: "global", suffix: "user_id")
        return UserDefaults.standard.string(forKey: key)
    }
    
    /// Store user ID using standardized key
    public static func storeUserId(_ userId: String) {
        let key = generateKey(category: Constants.Category.config, identifier: "global", suffix: "user_id")
        UserDefaults.standard.set(userId, forKey: key)
    }
    
    /// Remove stored user ID
    public static func removeStoredUserId() {
        let key = generateKey(category: Constants.Category.config, identifier: "global", suffix: "user_id")
        UserDefaults.standard.removeObject(forKey: key)
    }
    
    // MARK: - App Name Management
    
    /// Get stored app name using standardized key
    public static func getStoredAppName() -> String? {
        let key = generateKey(category: Constants.Category.config, identifier: "global", suffix: "app_name")
        return UserDefaults.standard.string(forKey: key)
    }
    
    /// Store app name using standardized key
    public static func storeAppName(_ appName: String) {
        let key = generateKey(category: Constants.Category.config, identifier: "global", suffix: "app_name")
        UserDefaults.standard.set(appName, forKey: key)
    }
    
    // MARK: - Translation Cache
    
    /// Get cached translation using standardized key
    public static func getCachedTranslation(language: String, text: String) -> String? {
        let key = generateTranslationKey(languageCode: language, text: text)
        return UserDefaults.standard.string(forKey: key)
    }
    
    /// Cache translation using standardized key
    public static func cacheTranslation(language: String, text: String, translation: String) {
        let key = generateTranslationKey(languageCode: language, text: text)
        UserDefaults.standard.set(translation, forKey: key)
    }
    
    /// Remove cached translation using standardized key
    public static func removeCachedTranslation(language: String, text: String) {
        let key = generateTranslationKey(languageCode: language, text: text)
        UserDefaults.standard.removeObject(forKey: key)
    }
}

