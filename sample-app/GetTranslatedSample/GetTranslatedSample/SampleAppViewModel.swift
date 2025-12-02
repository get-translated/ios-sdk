//
//  SampleAppViewModel.swift
//  GetTranslatedSample
//
//  Created by GetTranslated SDK Sample App
//

import Foundation
import SwiftUI
import Combine
import GetTranslatedSDK

class SampleAppViewModel: NSObject, ObservableObject, InitCallback, TranslationCallback {
    
    // MARK: - Published Properties
    
    @Published var sdkStatus: String = NSLocalizedString("sdk.status.initializing", comment: "Initializing status")
    @Published var sdkStatusColor: Color = .orange
    @Published var userIdInput: String = NSLocalizedString("default.user_id", comment: "Default user ID")
    @Published var currentUserText: String = String(format: NSLocalizedString("user.management.current_user", comment: "Current user text"), NSLocalizedString("user.management.anonymous", comment: "Anonymous"))
    @Published var supportedLanguagesText: String = NSLocalizedString("language.management.supported_languages.loading", comment: "Loading languages")
    @Published var languageInput: String = NSLocalizedString("default.language_code", comment: "Default language code")
    @Published var currentLanguageText: String = NSLocalizedString("language.management.current_language.default", comment: "Default current language")
    @Published var translationInput: String = NSLocalizedString("default.translation_input", comment: "Default translation input")
    @Published var translationResultText: String = NSLocalizedString("translation.testing.no_translation", comment: "No translation yet")
    @Published var pluralResults: [PluralResult] = []
    @Published var logText: String = ""
    
    // MARK: - Private Properties
    
    private var currentUserId: String? = nil
    private var sdkInitialized: Bool = false
    private var logBuilder: NSMutableString = NSMutableString()
    private var pendingLoginUserId: String? = nil
    private var isLoggingOut: Bool = false
    
    // MARK: - Plural Result Model
    
    struct PluralResult: Identifiable {
        let id = UUID()
        let count: Int
        let result: String
    }
    
    // MARK: - API Key Configuration
    
    // IMPORTANT: Replace this with your actual API key
    // You can also load it from a configuration file or environment variable
    private let apiKey: String = {
        // Try to load from Info.plist or environment
        if let key = Bundle.main.object(forInfoDictionaryKey: "GetTranslatedAPIKey") as? String,
           !key.isEmpty && key != "YOUR_API_KEY_HERE" {
            return key
        }
        // Fallback to environment variable
        if let key = ProcessInfo.processInfo.environment["GETTRANSLATED_API_KEY"],
           !key.isEmpty {
            return key
        }
        // Default placeholder - replace this!
        return "YOUR_API_KEY_HERE"
    }()
    
    // MARK: - Server URL Configuration
    
    private let serverUrl: String? = {
        // Try to load from Info.plist
        if let url = Bundle.main.object(forInfoDictionaryKey: "GetTranslatedServerURL") as? String,
           !url.isEmpty {
            return url
        }
        // Fallback to environment variable
        if let url = ProcessInfo.processInfo.environment["GETTRANSLATED_SERVER_URL"],
           !url.isEmpty {
            return url
        }
        // Use default (production server)
        return nil
    }()
    
    // MARK: - Initialization
    
    override init() {
        super.init()
        logMessage(NSLocalizedString("sdk.init.started", comment: "SDK started"))
    }
    
    func initializeSDK() {
        logMessage(NSLocalizedString("sdk.init.initializing", comment: "Initializing SDK"))
        sdkStatus = NSLocalizedString("sdk.status.initializing", comment: "Initializing status")
        sdkStatusColor = .orange
        
        // Check if API key is set
        if apiKey == "YOUR_API_KEY_HERE" || apiKey.isEmpty {
            let errorMsg = NSLocalizedString("sdk.init.api_key.not_configured", comment: "API key not configured")
            logMessage("ERROR: \(errorMsg)")
            sdkStatus = NSLocalizedString("sdk.status.failed.api_key", comment: "Failed: API key not configured")
            sdkStatusColor = .red
            return
        }
        
        // Log server URL if custom
        if let serverUrl = serverUrl, !serverUrl.isEmpty {
            logMessage(String(format: NSLocalizedString("sdk.init.custom_server", comment: "Using custom server"), serverUrl))
        }
        
        // Create InitOptions if server URL is configured
        var options: InitOptions? = nil
        if let serverUrl = serverUrl, !serverUrl.isEmpty {
            options = InitOptions.withServerUrl(serverUrl)
        }
        
        // Initialize SDK with callback and options
        GetTranslated.initialize(key: apiKey, userId: nil, logLevel: .debug, options: options, callback: self)
    }
    
    // MARK: - InitCallback Implementation
    
    func onInitSuccess() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            // Handle login/logout operations
            if let userId = self.pendingLoginUserId {
                self.currentUserId = userId
                self.pendingLoginUserId = nil
                self.logMessage(String(format: NSLocalizedString("user.management.login_success", comment: "Login success"), userId))
            } else if self.isLoggingOut {
                self.currentUserId = nil
                self.isLoggingOut = false
                self.logMessage(NSLocalizedString("user.management.logout_success", comment: "Logout success"))
            }
            
            // Only update SDK status if this is initial initialization
            if !self.sdkInitialized {
                self.sdkInitialized = true
                self.sdkStatus = NSLocalizedString("sdk.status.initialized", comment: "SDK initialized")
                self.sdkStatusColor = .green
                
                let languages = GetTranslated.getLanguages()
                let languageCount = languages.count
                self.logMessage(NSLocalizedString("sdk.init.success", comment: "SDK initialized successfully"))
                self.logMessage(String(format: NSLocalizedString("language.management.languages_loaded", comment: "Languages loaded"), languageCount))
                
                if !languages.isEmpty {
                    let sortedLanguages = languages.sorted()
                    let languagesList = sortedLanguages.joined(separator: ", ")
                    self.logMessage(String(format: NSLocalizedString("sdk.init.available_languages", comment: "Available languages"), languageCount))
                    self.logMessage(String(format: NSLocalizedString("sdk.init.languages_list", comment: "Languages list"), languagesList))
                    self.supportedLanguagesText = String(format: NSLocalizedString("language.management.supported_languages.format", comment: "Supported languages format"), languageCount, languagesList)
                } else {
                    self.supportedLanguagesText = NSLocalizedString("language.management.supported_languages.none", comment: "No languages loaded")
                    self.logMessage(NSLocalizedString("language.management.no_languages_warning", comment: "No languages warning"))
                }
            } else {
                // Update languages after login/logout
                let languages = GetTranslated.getLanguages()
                if !languages.isEmpty {
                    let sortedLanguages = languages.sorted()
                    let languagesList = sortedLanguages.joined(separator: ", ")
                    self.supportedLanguagesText = String(format: NSLocalizedString("language.management.supported_languages.format", comment: "Supported languages format"), languages.count, languagesList)
                    self.logMessage(String(format: NSLocalizedString("language.management.languages_refreshed", comment: "Languages refreshed"), languages.count))
                }
            }
            
            self.updateUI()
            self.updatePluralForms()
        }
    }
    
    func onInitError(_ errorCode: Int, _ errorMessage: String) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            // Handle login/logout errors
            if self.pendingLoginUserId != nil {
                self.logMessage(NSLocalizedString("user.management.login_failed", comment: "Login failed"))
                self.pendingLoginUserId = nil
            } else if self.isLoggingOut {
                self.logMessage(NSLocalizedString("user.management.logout_failed", comment: "Logout failed"))
                self.isLoggingOut = false
            } else {
                // Initial SDK initialization error
                self.sdkInitialized = false
                self.sdkStatus = NSLocalizedString("sdk.status.failed", comment: "SDK initialization failed")
                self.sdkStatusColor = .red
                
                self.logMessage(NSLocalizedString("sdk.init.failed", comment: "SDK initialization failed"))
            }
            
            self.logMessage(String(format: NSLocalizedString("sdk.init.error.code", comment: "Error code"), errorCode))
            self.logMessage(String(format: NSLocalizedString("sdk.init.error.message", comment: "Error message"), errorMessage))
            
            // Provide helpful error messages based on error code
            if errorCode == 401 {
                self.logMessage(NSLocalizedString("sdk.init.error.invalid_key", comment: "Invalid API key"))
            } else if errorCode == 403 {
                self.logMessage(NSLocalizedString("sdk.init.error.permission_denied", comment: "Permission denied"))
                self.logMessage(NSLocalizedString("sdk.init.error.check_permissions", comment: "Check permissions"))
            } else if errorCode == 0 {
                self.logMessage(NSLocalizedString("sdk.init.error.network", comment: "Network error"))
            } else {
                self.logMessage(NSLocalizedString("sdk.init.error.server", comment: "Server error"))
            }
            
            if self.pendingLoginUserId == nil && !self.isLoggingOut {
                let apiKeyDisplay = self.apiKey.count > 8 
                    ? String(self.apiKey.prefix(8)) + "..." 
                    : NSLocalizedString("sdk.init.api_key.not_set", comment: "API key not set")
                self.logMessage(String(format: NSLocalizedString("sdk.init.api_key", comment: "Current API key"), apiKeyDisplay))
            }
            
            self.updateUI()
        }
    }
    
    // MARK: - User Management
    
    func loginUser() {
        let userId = userIdInput.trimmingCharacters(in: .whitespaces)
        if userId.isEmpty {
            logMessage(NSLocalizedString("user.management.enter_user_id", comment: "Please enter user ID"))
            return
        }
        
        logMessage(String(format: NSLocalizedString("user.management.logging_in", comment: "Logging in user"), userId))
        pendingLoginUserId = userId
        isLoggingOut = false
        
        GetTranslated.login(userId: userId, callback: self)
    }
    
    func logoutUser() {
        logMessage(NSLocalizedString("user.management.logging_out", comment: "Logging out user"))
        pendingLoginUserId = nil
        isLoggingOut = true
        
        GetTranslated.logout(callback: self)
    }
    
    // MARK: - Language Management
    
    func setLanguage() {
        let language = languageInput.trimmingCharacters(in: .whitespaces)
        if language.isEmpty {
            logMessage(NSLocalizedString("language.management.enter_language_code", comment: "Please enter language code"))
            return
        }
        
        logMessage(String(format: NSLocalizedString("language.management.setting_language", comment: "Setting language"), language))
        
        GetTranslated.setLanguage(language)
        updateUI()
        updatePluralForms()
        
        logMessage(String(format: NSLocalizedString("language.management.language_set_success", comment: "Language set successfully"), language))
    }
    
    // MARK: - Translation
    
    func translateText() {
        let text = translationInput.trimmingCharacters(in: .whitespaces)
        if text.isEmpty {
            logMessage(NSLocalizedString("translation.testing.enter_text", comment: "Please enter text to translate"))
            return
        }
        
        if !sdkInitialized {
            let errorMsg = NSLocalizedString("translation.testing.not_initialized", comment: "SDK not initialized")
            translationResultText = String(format: NSLocalizedString("translation.testing.error.not_initialized", comment: "Error prefix"), errorMsg)
            logMessage("ERROR: \(errorMsg)")
            return
        }
        
        logMessage(String(format: NSLocalizedString("translation.testing.translating_text", comment: "Translating text"), text))
        translationResultText = NSLocalizedString("translation.testing.translating", comment: "Translating…")
        
        GetTranslated.getDynamicString(text, callback: self)
    }
    
    // MARK: - TranslationCallback Implementation
    
    func onTranslationReady(_ translation: String) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.translationResultText = translation
            self.logMessage(String(format: NSLocalizedString("translation.testing.translation_received", comment: "Translation received"), translation))
        }
    }
    
    func onTranslationError(_ errorMessage: String) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            let errorText = String(format: NSLocalizedString("translation.testing.translation_failed", comment: "Translation failed"), errorMessage)
            self.translationResultText = errorText
            self.logMessage(String(format: NSLocalizedString("translation.testing.translation_error", comment: "Translation error"), errorMessage))
            
            // Show more detailed error info
            if errorMessage.contains("Not initialized") {
                self.logMessage(NSLocalizedString("translation.testing.error.init_not_complete", comment: "Init not complete"))
                self.logMessage(NSLocalizedString("translation.testing.error.wait_for_init", comment: "Wait for init"))
            } else if errorMessage.contains("403") || errorMessage.contains("permission") {
                self.logMessage(NSLocalizedString("translation.testing.error.permission_denied", comment: "Permission denied"))
            } else if errorMessage.contains("401") {
                self.logMessage(NSLocalizedString("translation.testing.error.unauthorized", comment: "Unauthorized"))
            } else if errorMessage.contains("error code") {
                self.logMessage(NSLocalizedString("translation.testing.error.server_error", comment: "Server error"))
            }
        }
    }
    
    // MARK: - UI Updates
    
    private func updateUI() {
        // Update current user
        let userDisplay = currentUserId ?? NSLocalizedString("user.management.anonymous", comment: "Anonymous")
        currentUserText = String(format: NSLocalizedString("user.management.current_user", comment: "Current user text"), userDisplay)
        
        // Update supported languages (only if not already set in callback)
        let languages = GetTranslated.getLanguages()
        if !languages.isEmpty {
            let sortedLanguages = languages.sorted()
            let languagesList = sortedLanguages.joined(separator: ", ")
            let currentText = supportedLanguagesText
            let loadingText = NSLocalizedString("language.management.supported_languages.loading", comment: "Loading languages")
            if currentText == loadingText || currentText.contains(NSLocalizedString("language.management.supported_languages.none", comment: "No languages")) {
                supportedLanguagesText = String(format: NSLocalizedString("language.management.supported_languages.format", comment: "Supported languages format"), languages.count, languagesList)
            }
        } else {
            if sdkInitialized {
                supportedLanguagesText = NSLocalizedString("language.management.supported_languages.none", comment: "No languages loaded")
            } else {
                supportedLanguagesText = NSLocalizedString("language.management.supported_languages.loading", comment: "Loading languages")
            }
        }
        
        // Update current language
        let currentLanguage = GetTranslated.getCurrentLanguage()
        if currentLanguage.isEmpty {
            currentLanguageText = NSLocalizedString("language.management.current_language.default", comment: "Default current language")
        } else {
            currentLanguageText = String(format: NSLocalizedString("language.management.current_language", comment: "Current language"), currentLanguage)
        }
    }
    
    // MARK: - Plural Forms Testing
    
    private func updatePluralForms() {
        // Test counts matching Android app: [0, 1, 2, 5, 10, 100]
        let testCounts = [0, 1, 2, 5, 10, 100]
        var results: [PluralResult] = []
        
        // Check if SDK is initialized
        if !sdkInitialized {
            results.append(PluralResult(count: 0, result: NSLocalizedString("plural.testing.not_initialized", comment: "SDK not initialized")))
            DispatchQueue.main.async { [weak self] in
                self?.pluralResults = results
            }
            return
        }
        
        // For iOS, we'll use a simple format string approach
        // In a real app, you'd use .stringsdict files for proper plural rules
        for count in testCounts {
            // Use a simple format that demonstrates plural handling
            // In production, this would use NSLocalizedString with plural rules
            let result: String
            if count == 0 {
                result = NSLocalizedString("plural.testing.no_items", comment: "No items")
            } else if count == 1 {
                result = NSLocalizedString("plural.testing.one_item", comment: "1 item")
            } else {
                result = String(format: NSLocalizedString("plural.testing.items", comment: "Items"), count)
            }
            results.append(PluralResult(count: count, result: result))
        }
        
        DispatchQueue.main.async { [weak self] in
            self?.pluralResults = results
        }
    }
    
    // MARK: - Logging
    
    func logMessage(_ message: String) {
        let timestamp = DateFormatter.timeFormatter.string(from: Date())
        let logEntry = "[\(timestamp)] \(message)\n"
        logBuilder.append(logEntry)
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.logText = self.logBuilder as String
        }
        
        print("[GetTranslatedSample] \(message)")
    }
    
    func clearLog() {
        logBuilder = NSMutableString()
        logText = ""
    }
    
    func exitApp() {
        logMessage(NSLocalizedString("button.exit", comment: "Exit App"))
        // Note: exit(0) works in development but is not recommended for production apps
        // Apple's guidelines discourage programmatic app termination
        exit(0)
    }
}

// MARK: - DateFormatter Extension

extension DateFormatter {
    static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        return formatter
    }()
}

