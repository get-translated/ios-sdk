//
//  Constants.swift
//  GetTranslatedSDK
//
//  Created by GetTranslated SDK Generator
//

import Foundation

/// Constants for the GetTranslated iOS SDK
public enum Constants {
    /// SDK Version
    public static let version = "I1.0.0"
    
    /// Server Configuration
    private static var _server = "https://www.gettranslated.ai"
    
    /// Get the current server URL
    internal static var server: String {
        return _server
    }
    
    /// Set a custom server URL for local development or testing
    /// - Parameter serverUrl: The base URL of the server (e.g., "http://localhost:8000")
    internal static func setServer(_ serverUrl: String) {
        var url = serverUrl.trimmingCharacters(in: .whitespaces)
        // Remove trailing slash if present
        if url.hasSuffix("/") {
            url = String(url.dropLast())
        }
        guard !url.isEmpty else {
            return // Don't set empty URLs
        }
        _server = url
    }
    
    /// API Endpoints
    public static var initURI: String {
        return "\(server)/client/init"
    }
    public static var loginURI: String {
        return "\(server)/client/login"
    }
    public static var translateURI: String {
        return "\(server)/client/string"
    }
    public static var syncURI: String {
        return "\(server)/client/sync"
    }
    
    /// Storage Keys
    public static let prefix = "ai.gettranslated.sdk"
    
    /// Storage Categories
    public enum Category {
        public static let user = "user"
        public static let language = "lang"
        public static let translation = "trans"
        public static let sync = "sync"
        public static let config = "config"
    }
    
    /// Request Keys
    public static let versionKey = "version"
    public static let appNameKey = "app_name"
    public static let lastSyncKey = "last_sync"
    
    /// Response Keys
    public static let languagesKey = "languages"
    public static let baseLanguageKey = "base_language"
    public static let languageOverrideKey = "language_override"
    public static let translationKey = "translation"
    public static let projectKey = "project"
    
    /// Anonymous User ID Configuration
    public static let idAlphabet = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890"
    public static let idLength = 12
}

