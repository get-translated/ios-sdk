//
//  LanguageDetection.swift
//  GetTranslatedSDK
//
//  Created by GetTranslated SDK Generator
//

import Foundation

/// Language detection utility for GetTranslated iOS SDK
/// Provides comprehensive language detection using iOS native APIs
public enum LanguageDetection {
    
    /// Get device language using iOS native APIs
    /// Returns ISO 639-1 language code (e.g., "en", "es", "fr")
    public static func getDeviceLanguage() -> String {
        // Method 1: Try preferred language from bundle (most reliable for iOS)
        if let preferredLanguage = Bundle.main.preferredLocalizations.first {
            let language = preferredLanguage.components(separatedBy: "-").first ?? preferredLanguage
            if !language.isEmpty {
                Logger.getInstance().debug("Using Bundle preferred language: \(language)")
                return language
            }
        }
        
        // Method 2: Try current locale
        if let languageCode = Locale.current.languageCode {
            Logger.getInstance().debug("Using Locale.current: \(languageCode)")
            return languageCode
        }
        
        Logger.getInstance().warn("All language detection methods failed, using fallback: en")
        return "en"
    }
    
    /// Find the best matching language from available options
    /// - Parameters:
    ///   - availableLanguages: Array of supported language codes
    ///   - fallbackLanguage: Language to use if no match found
    /// - Returns: Best matching language code
    public static func findBestLanguageMatch(availableLanguages: [String], fallbackLanguage: String = "en") -> String {
        guard !availableLanguages.isEmpty else {
            return fallbackLanguage
        }
        
        let supportedLanguages = Set(availableLanguages)
        let deviceLanguage = getDeviceLanguage()
        
        // Check if we support this exact language
        if supportedLanguages.contains(deviceLanguage) {
            Logger.getInstance().debug("Exact language match found: \(deviceLanguage)")
            return deviceLanguage
        }
        
        // Try to find a supported language with the same base (e.g., 'en-US' -> 'en', 'en_US' -> 'en')
        let baseLanguage = deviceLanguage.components(separatedBy: CharacterSet(charactersIn: "-_")).first ?? deviceLanguage
        if supportedLanguages.contains(baseLanguage) {
            Logger.getInstance().debug("Base language match found: \(baseLanguage)")
            return baseLanguage
        }
        
        // Check if any supported language starts with the same base
        for supportedLang in supportedLanguages {
            if supportedLang.hasPrefix(baseLanguage) {
                Logger.getInstance().debug("Partial language match found: \(supportedLang)")
                return supportedLang
            }
        }
        
        // Fallback to provided fallback language if available, otherwise first supported language
        if supportedLanguages.contains(fallbackLanguage) {
            Logger.getInstance().debug("Using fallback language: \(fallbackLanguage)")
            return fallbackLanguage
        }
        
        let firstSupported = availableLanguages[0]
        Logger.getInstance().debug("Using first supported language: \(firstSupported)")
        return firstSupported
    }
    
    /// Get device language with fallback to available languages
    /// - Parameters:
    ///   - availableLanguages: Array of supported language codes
    ///   - fallbackLanguage: Language to use if no match found
    /// - Returns: Best matching language code
    public static func getBestDeviceLanguage(availableLanguages: [String] = [], fallbackLanguage: String = "en") -> String {
        if availableLanguages.isEmpty {
            return fallbackLanguage
        }
        
        return findBestLanguageMatch(availableLanguages: availableLanguages, fallbackLanguage: fallbackLanguage)
    }
}

