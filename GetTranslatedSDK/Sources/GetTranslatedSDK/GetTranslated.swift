//
//  GetTranslated.swift
//  GetTranslatedSDK
//
//  Created by GetTranslated SDK Generator
//

import Foundation

/// Callback protocol for SDK initialization completion
public protocol InitCallback: AnyObject {
    /// Called when SDK initialization succeeds
    func onInitSuccess()
    
    /// Called if there is an error during SDK initialization
    /// - Parameters:
    ///   - errorCode: The HTTP error code (e.g., 401, 403, 500), or 0 for network/parsing errors
    ///   - errorMessage: A description of the error
    func onInitError(_ errorCode: Int, _ errorMessage: String)
}

/// Callback protocol for translation completion
public protocol TranslationCallback: AnyObject {
    /// Called when the requested translation is available
    /// - Parameter translation: The requested translation
    func onTranslationReady(_ translation: String)
    
    /// Called if there is an error completing the translation request
    /// - Parameter errorMessage: A description of the error
    func onTranslationError(_ errorMessage: String)
}

/// Callback protocol for language changes
public protocol LanguageChangeCallback: AnyObject {
    /// Called when the language changes
    /// - Parameter languageCode: The new language code
    func onLanguageChanged(_ languageCode: String)
}

/// Initialization options for the GetTranslated SDK
public struct InitOptions {
    /// Custom server URL for local development/testing
    /// Defaults to production server if not provided
    public var serverUrl: String?
    
    /// Creates an InitOptions instance with the specified server URL
    /// - Parameter serverUrl: The base URL of the server (e.g., "http://localhost:8000")
    /// - Returns: InitOptions instance with serverUrl set
    public static func withServerUrl(_ serverUrl: String) -> InitOptions {
        var options = InitOptions()
        options.serverUrl = serverUrl
        return options
    }
    
    /// Creates an empty InitOptions instance
    public init() {
        self.serverUrl = nil
    }
}

/// Main SDK class for GetTranslated translations
public class GetTranslated {
    
    // MARK: - Singleton
    
    private static var instance: GetTranslated?
    
    // MARK: - Language Change Callbacks
    
    private static var languageChangeCallbacks: [LanguageChangeCallback] = []
    
    // MARK: - Properties
    
    private var userId: String
    private let isAnonymousUserId: Bool
    private let key: String
    private let logger: Logger
    
    private var appName: String = ""
    private var supportedLanguages: Set<String> = []
    private var language: String
    private var baseLanguage: String = "en"
    private var initialized: Bool = false
    
    // MARK: - Initialization
    
    private init(key: String, userId: String?) {
        self.key = key
        self.logger = Logger.getInstance()
        
        // Detect current device language
        self.language = LanguageDetection.getDeviceLanguage()
        
        // Handle user ID logic (matching Android/RN behavior)
        if let userId = userId, !userId.trimmingCharacters(in: .whitespaces).isEmpty {
            self.userId = userId.trimmingCharacters(in: .whitespaces)
            self.isAnonymousUserId = false
        } else {
            // Anonymous user handling - check for existing or generate new
            if let existingUserId = StorageKeys.getStoredUserId() {
                self.userId = existingUserId
            } else {
                self.userId = GetTranslated.generateRandomUserId()
                StorageKeys.storeUserId(self.userId)
            }
            self.isAnonymousUserId = true
        }
        
        logger.info("User id \(self.userId)")
    }
    
    /// Initializes the GetTranslated SDK
    /// - Parameters:
    ///   - key: API key for authentication
    ///   - userId: Optional user ID. If not provided, an anonymous user will be created
    ///   - logLevel: Optional log level for debugging (default: .warn)
    ///   - options: Optional initialization options (e.g., serverUrl for local development/testing)
    ///   - callback: Optional callback to receive initialization status
    public static func initialize(key: String, userId: String? = nil, logLevel: LogLevel = .warn, options: InitOptions? = nil, callback: InitCallback? = nil) {
        // Handle server URL from options
        if let serverUrl = options?.serverUrl, !serverUrl.trimmingCharacters(in: .whitespaces).isEmpty {
            Constants.setServer(serverUrl)
        }
        
        // Check if already initialized
        if instance != nil && instance?.initialized == true {
            Logger.getInstance().warn("GetTranslated: Already initialized")
            callback?.onInitSuccess()
            return
        }
        
        // If instance exists but not initialized (failed previous attempt), clear it
        if instance != nil && instance?.initialized == false {
            Logger.getInstance().debug("GetTranslated: Clearing previous failed initialization attempt")
            instance = nil
        }
        
        // Initialize logging
        Logger.initialize(level: logLevel, enableConsole: true)
        
        instance = GetTranslated(key: key, userId: userId)
        instance?.loadStoredAppName()
        instance?.performInitialization(callback: callback)
    }
    
    /// Returns whether the SDK has been successfully initialized
    /// - Returns: true if the SDK is initialized and ready to use, false otherwise
    public static func isInitialized() -> Bool {
        return instance?.initialized ?? false
    }
    
    /// Load stored app name from local storage
    private func loadStoredAppName() {
        if let storedAppName = StorageKeys.getStoredAppName() {
            self.appName = storedAppName
        }
    }
    
    /// Private initialization method
    /// - Parameter callback: Optional callback to receive initialization status
    private func performInitialization(callback: InitCallback?) {
        // Prepare initialization request
        var requestData: [String: Any] = [
            "userId": userId,
            "lang": language,
            Constants.versionKey: Constants.version
        ]
        
        // Add app name if available
        if !appName.isEmpty {
            requestData[Constants.appNameKey] = appName
        }
        
        // Add bundle identifier as app_package equivalent
        if let bundleId = Bundle.main.bundleIdentifier {
            requestData["app_package"] = bundleId
        }
        
        // Send initialization request
        makeNetworkRequest(url: Constants.initURI, data: requestData) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let response):
                self.handleInitResponse(response, callback: callback)
            case .failure(let error):
                let (errorCode, errorMessage) = self.extractErrorInfo(from: error)
                self.logger.error("GetTranslated: Initialization error code \(errorCode): \(errorMessage)", error)
                self.initialized = false
                callback?.onInitError(errorCode, errorMessage)
            }
        }
    }
    
    // MARK: - User Management
    
    /// Login with a specific user ID (transitions from anonymous to authenticated)
    /// - Parameters:
    ///   - userId: User ID for authentication
    ///   - callback: Optional callback to receive re-initialization status
    public static func login(userId: String, callback: InitCallback? = nil) {
        guard let instance = instance else {
            let errorMsg = "GetTranslated SDK has not been initialized"
            Logger.getInstance().error(errorMsg)
            callback?.onInitError(0, errorMsg)
            return
        }
        
        let trimmedUserId = userId.trimmingCharacters(in: .whitespaces)
        guard !trimmedUserId.isEmpty else {
            let errorMsg = "User id cannot be null or empty"
            Logger.getInstance().error(errorMsg)
            callback?.onInitError(0, errorMsg)
            return
        }
        
        if trimmedUserId == instance.userId {
            Logger.getInstance().info("\(trimmedUserId) already logged in")
            callback?.onInitSuccess()
            return
        }
        
        // Log the transition if coming from anonymous
        if instance.isAnonymousUserId {
            instance.logLogin(oldUserId: instance.userId, newUserId: trimmedUserId)
        }
        
        // Preserve languages from previous instance (they should be the same for the same project)
        let preservedLanguages = instance.supportedLanguages
        
        // Re-initialize with new user ID
        GetTranslated.instance = GetTranslated(key: instance.key, userId: trimmedUserId)
        // Restore languages immediately (they'll be refreshed from server, but this prevents UI flicker)
        GetTranslated.instance?.supportedLanguages = preservedLanguages
        GetTranslated.instance?.performInitialization(callback: callback)
    }
    
    /// Logout and return to anonymous user (re-initializes with anonymous user information)
    /// - Parameter callback: Optional callback to receive re-initialization status
    public static func logout(callback: InitCallback? = nil) {
        guard let instance = instance else {
            let errorMsg = "GetTranslated SDK has not been initialized"
            Logger.getInstance().error(errorMsg)
            callback?.onInitError(0, errorMsg)
            return
        }
        
        Logger.getInstance().info("Logging out and returning to anonymous user")
        
        // Preserve languages from previous instance (they should be the same for the same project)
        let preservedLanguages = instance.supportedLanguages
        
        // Clear stored user ID to force generation of new anonymous user
        StorageKeys.removeStoredUserId()
        
        // Re-initialize with anonymous user (no userId parameter)
        let key = instance.key
        GetTranslated.instance = GetTranslated(key: key, userId: nil)
        // Restore languages immediately (they'll be refreshed from server, but this prevents UI flicker)
        GetTranslated.instance?.supportedLanguages = preservedLanguages
        GetTranslated.instance?.performInitialization(callback: callback)
    }
    
    // MARK: - Testing Support
    
    #if DEBUG
    /// Reset the SDK instance (for testing purposes only)
    /// This method is only available in debug builds
    static func resetForTesting() {
        instance = nil
    }
    #endif
    
    // MARK: - Language Management
    
    /// Register a callback for language changes
    /// - Parameter callback: Callback object implementing LanguageChangeCallback protocol
    public static func onLanguageChange(_ callback: LanguageChangeCallback) {
        languageChangeCallbacks.append(callback)
    }
    
    /// Unregister a language change callback
    /// - Parameter callback: Callback object to remove
    public static func offLanguageChange(_ callback: LanguageChangeCallback) {
        languageChangeCallbacks.removeAll { callback === $0 }
    }
    
    /// Set language override programmatically
    /// - Parameter languageCode: ISO 639-1 language code (e.g., "en", "es", "fr")
    public static func setLanguage(_ languageCode: String) {
        guard let instance = instance else {
            Logger.getInstance().warn("Not initialized")
            return
        }
        
        instance.setLanguage(languageCode, savePreference: true)
    }
    
    /// Get supported languages
    /// - Returns: Set of supported language codes
    public static func getLanguages() -> Set<String> {
        guard let instance = instance else {
            return []
        }
        return instance.supportedLanguages
    }
    
    /// Get current language
    /// - Returns: Current language code (e.g., "en", "es", "fr"), or "en" if not initialized
    public static func getCurrentLanguage() -> String {
        guard let instance = instance else {
            return "en"
        }
        return instance.language
    }
    
    // MARK: - Translation Methods
    
    /// Get translation synchronously (checks cache first, returns original if not cached)
    /// - Parameter text: Text to translate
    /// - Returns: Translated text or original text if not cached
    public static func getDynamicString(_ text: String) -> String {
        return getDynamicString(text, callback: nil)
    }
    
    /// Get translation with callback for async notifications
    /// - Parameters:
    ///   - text: Text to translate
    ///   - onReady: Closure called when translation is available
    ///   - onError: Closure called if translation fails
    /// - Returns: Translated text or original text if not cached
    @discardableResult
    public static func getDynamicString(_ text: String, onReady: ((String) -> Void)? = nil, onError: ((String) -> Void)? = nil) -> String {
        guard let instance = instance else {
            let msg = "Not initialized"
            Logger.getInstance().warn(msg)
            onError?(msg)
            return text
        }
        
        // Create adapter from closures to protocol
        let callback: TranslationCallback? = (onReady != nil || onError != nil) ? ClosureCallback(onReady: onReady, onError: onError) : nil
        return instance.getTranslation(text: text, callback: callback)
    }
    
    /// Get translation with protocol-based callback (for compatibility with Android pattern)
    /// - Parameters:
    ///   - text: Text to translate
    ///   - callback: Callback object implementing TranslationCallback protocol
    /// - Returns: Translated text or original text if not cached
    @discardableResult
    public static func getDynamicString(_ text: String, callback: TranslationCallback?) -> String {
        guard let instance = instance else {
            let msg = "Not initialized"
            Logger.getInstance().warn(msg)
            callback?.onTranslationError(msg)
            return text
        }
        
        return instance.getTranslation(text: text, callback: callback)
    }
    
    /// Internal adapter class to convert closures to protocol
    private class ClosureCallback: TranslationCallback {
        let onReady: ((String) -> Void)?
        let onError: ((String) -> Void)?
        
        init(onReady: ((String) -> Void)?, onError: ((String) -> Void)?) {
            self.onReady = onReady
            self.onError = onError
        }
        
        func onTranslationReady(_ translation: String) {
            onReady?(translation)
        }
        
        func onTranslationError(_ errorMessage: String) {
            onError?(errorMessage)
        }
    }
    
    // MARK: - Private Methods
    
    /// Check if current language is base language
    private func isInBaseLanguage() -> Bool {
        if !initialized {
            return true
        }
        return language == baseLanguage
    }
    
    /// Get translation with caching and network fallback
    private func getTranslation(text: String, callback: TranslationCallback?) -> String {
        // Validate input
        if text.trimmingCharacters(in: .whitespaces).isEmpty {
            logger.warn("Empty or whitespace-only text provided for translation")
            return text
        }
        
        // Short circuit if in base language
        if isInBaseLanguage() {
            callback?.onTranslationReady(text)
            return text
        }
        
        // Check local cache
        if let cachedTranslation = StorageKeys.getCachedTranslation(language: language, text: text) {
            callback?.onTranslationReady(cachedTranslation)
            return cachedTranslation
        }
        
        // Request from server
        requestTranslationFromServer(text: text) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let translation):
                // Cache the translation
                StorageKeys.cacheTranslation(language: self.language, text: text, translation: translation)
                callback?.onTranslationReady(translation)
            case .failure(let error):
                self.logger.error("Translation error", error)
                callback?.onTranslationError(error.localizedDescription)
            }
        }
        
        return text
    }
    
    /// Request translation from server
    private func requestTranslationFromServer(text: String, completion: @escaping (Result<String, Error>) -> Void) {
        var requestData: [String: Any] = [
            "text": text,
            "lang": language,
            Constants.versionKey: Constants.version
        ]
        
        // Add app name if available
        if !appName.isEmpty {
            requestData[Constants.appNameKey] = appName
        }
        
        makeNetworkRequest(url: Constants.translateURI, data: requestData) { [weak self] result in
            guard self != nil else { return }
            
            switch result {
            case .success(let response):
                if let translation = response[Constants.translationKey] as? String,
                   !translation.isEmpty {
                    completion(.success(translation))
                } else {
                    completion(.failure(NSError(domain: "GetTranslated", code: -1, userInfo: [NSLocalizedDescriptionKey: "Empty translation response"])))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    /// Handle initialization response
    /// - Parameters:
    ///   - response: The initialization response from the server
    ///   - callback: Optional callback to notify of initialization success
    private func handleInitResponse(_ response: [String: Any], callback: InitCallback?) {
        logger.debug("Init response", response)
        
        // Store app name
        if let project = response[Constants.projectKey] as? String {
            self.appName = project
            StorageKeys.storeAppName(project)
        }
        
        // Store base language
        if let baseLang = response[Constants.baseLanguageKey] as? String {
            self.baseLanguage = baseLang
        }
        
        // Extract supported languages
        // Languages can be an array of strings or an array of objects with code/name
        if let languages = response[Constants.languagesKey] as? [String] {
            self.supportedLanguages = Set(languages)
        } else if let languagesArray = response[Constants.languagesKey] as? [[String: Any]] {
            // Handle array of objects (React Native format)
            let languageCodes = languagesArray.compactMap { lang -> String? in
                if let code = lang["code"] as? String {
                    return code
                }
                return nil
            }
            self.supportedLanguages = Set(languageCodes)
        }
        
        // Always include the base language in supported languages
        self.supportedLanguages.insert(self.baseLanguage)
        
        // Resolve the final language to use
        let targetLanguage = resolveLanguage(response)
        self.language = targetLanguage
        
        // Mark as initialized
        self.initialized = true
        
        // Notify callback of success
        callback?.onInitSuccess()
        
        // Notify language change callbacks about initial language
        notifyLanguageChangeCallbacks(targetLanguage)
        
        // Trigger initial sync
        syncTranslations()
    }
    
    /// Resolve the final language to use based on priority:
    /// 1. Server language override (persisted separately)
    /// 2. Saved user preference (if supported)
    /// 3. Device language (with fallback)
    /// 4. Base language
    private func resolveLanguage(_ response: [String: Any]) -> String {
        // 1. Handle server language override
        if let serverOverride = response[Constants.languageOverrideKey] as? String {
            StorageKeys.setServerLanguageOverride(userId: userId, language: serverOverride)
            logger.info("Using server language override: \(serverOverride)")
            return serverOverride
        } else {
            StorageKeys.removeServerLanguageOverride(userId: userId)
        }
        
        // 2. Check for saved user preference
        if let savedLang = StorageKeys.getUserLanguageOverride(userId: userId),
           supportedLanguages.contains(savedLang) {
            logger.info("Using saved language preference: \(savedLang)")
            return savedLang
        }
        
        // 3. Use default language with fallback logic
        let availableLanguages = Array(supportedLanguages)
        let defaultLanguage = getDefaultLanguage(availableLanguages: availableLanguages)
        logger.info("Using default language: \(defaultLanguage)")
        return defaultLanguage
    }
    
    /// Get default language with proper fallback logic
    private func getDefaultLanguage(availableLanguages: [String]) -> String {
        let fallbackLanguage = baseLanguage.isEmpty ? "en" : baseLanguage
        return LanguageDetection.getBestDeviceLanguage(availableLanguages: availableLanguages, fallbackLanguage: fallbackLanguage)
    }
    
    /// Sync translations from server
    private func syncTranslations() {
        if isInBaseLanguage() {
            return
        }
        
        let lastSync = StorageKeys.getLastSyncTimestamp(language: language)
        let currentTime = Int64(Date().timeIntervalSince1970 * 1000)
        
        var requestData: [String: Any] = [
            "lang": language,
            Constants.versionKey: Constants.version,
            Constants.lastSyncKey: lastSync
        ]
        
        // Add app name if available
        if !appName.isEmpty {
            requestData[Constants.appNameKey] = appName
        }
        
        makeNetworkRequest(url: Constants.syncURI, data: requestData) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let response):
                self.logger.debug("Sync response", response)
                
                // Update sync timestamp
                StorageKeys.setLastSyncTimestamp(language: self.language, timestamp: currentTime)
                
                // Cache translations if any were returned
                if let translations = response["translations"] as? [[String: Any]] {
                    for translation in translations {
                        if let lang = translation["lang"] as? String,
                           let original = translation["string"] as? String,
                           let trans = translation[Constants.translationKey] as? String {
                            StorageKeys.cacheTranslation(language: lang, text: original, translation: trans)
                        }
                    }
                }
            case .failure(let error):
                self.logger.error("Sync error", error)
            }
        }
    }
    
    /// Log user login transition
    private func logLogin(oldUserId: String, newUserId: String) {
        var requestData: [String: Any] = [
            "userId": oldUserId,
            "loginUserId": newUserId,
            Constants.versionKey: Constants.version
        ]
        
        // Add app name if available
        if !appName.isEmpty {
            requestData[Constants.appNameKey] = appName
        }
        
        makeNetworkRequest(url: Constants.loginURI, data: requestData) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success:
                self.logger.info("\(newUserId) logged in.")
            case .failure(let error):
                self.logger.error("Login for \(newUserId) error", error)
            }
        }
    }
    
    /// Set language with optional persistence
    private func setLanguage(_ languageCode: String, savePreference: Bool) {
        if !supportedLanguages.isEmpty && !supportedLanguages.contains(languageCode) {
            logger.warn("\(languageCode) is not one of \(Array(supportedLanguages).joined(separator: ", "))")
            return
        }
        
        logger.info("Setting language to: \(languageCode)")
        self.language = languageCode
        
        // Update app language
        changeApplicationLanguage(languageCode)
        
        if savePreference {
            logger.debug("Saving language preference: \(languageCode)")
            StorageKeys.setUserLanguageOverride(userId: userId, language: languageCode)
        }
        
        // Notify language change callbacks
        notifyLanguageChangeCallbacks(languageCode)
    }
    
    /// Notify all registered language change callbacks
    private func notifyLanguageChangeCallbacks(_ languageCode: String) {
        GetTranslated.languageChangeCallbacks.forEach { callback in
            callback.onLanguageChanged(languageCode)
        }
    }
    
    /// Change the application language
    private func changeApplicationLanguage(_ languageCode: String) {
        // Update UserDefaults for app language
        UserDefaults.standard.set([languageCode], forKey: "AppleLanguages")
        UserDefaults.standard.synchronize()
        
        logger.info("Language changed to \(languageCode)")
    }
    
    /// Generate random user ID for anonymous users
    private static func generateRandomUserId() -> String {
        var result = ""
        for _ in 0..<Constants.idLength {
            let randomIndex = Int.random(in: 0..<Constants.idAlphabet.count)
            let index = Constants.idAlphabet.index(Constants.idAlphabet.startIndex, offsetBy: randomIndex)
            result.append(Constants.idAlphabet[index])
        }
        
        // Use bundle identifier as package name equivalent
        let bundleId = Bundle.main.bundleIdentifier ?? "ios-app"
        return "\(result)@\(bundleId)"
    }
    
    /// Make authenticated network request
    private func makeNetworkRequest(url: String, data: [String: Any], completion: @escaping (Result<[String: Any], Error>) -> Void) {
        guard let url = URL(string: url) else {
            completion(.failure(NSError(domain: "GetTranslated", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(key)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("GetTranslated-SDK/\(Constants.version) \(appName)", forHTTPHeaderField: "User-Agent")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: data)
        } catch {
            completion(.failure(error))
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(NSError(domain: "GetTranslated", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])))
                return
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                let errorCode = httpResponse.statusCode
                let errorMessage = "HTTP \(errorCode): \(HTTPURLResponse.localizedString(forStatusCode: errorCode))"
                let error = NSError(domain: "GetTranslated", code: errorCode, userInfo: [
                    NSLocalizedDescriptionKey: errorMessage,
                    "HTTPStatusCode": errorCode
                ])
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "GetTranslated", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data in response"])))
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    completion(.success(json))
                } else {
                    completion(.failure(NSError(domain: "GetTranslated", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid JSON response"])))
                }
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    /// Extract error code and message from an error
    /// - Parameter error: The error to extract information from
    /// - Returns: Tuple of (errorCode, errorMessage) matching Android SDK format
    private func extractErrorInfo(from error: Error) -> (Int, String) {
        if let nsError = error as NSError? {
            // Check if this is an HTTP error with status code
            if let httpStatusCode = nsError.userInfo["HTTPStatusCode"] as? Int {
                let errorMessage = getErrorMessage(errorCode: httpStatusCode)
                return (httpStatusCode, errorMessage)
            }
            
            // Check if error code is in HTTP range (400-599)
            let errorCode = nsError.code
            if errorCode >= 400 && errorCode < 600 {
                let errorMessage = getErrorMessage(errorCode: errorCode)
                return (errorCode, errorMessage)
            }
            
            // For non-HTTP errors, use code 0 and the error message
            var errorMessage = error.localizedDescription
            if let localizedDescription = nsError.userInfo[NSLocalizedDescriptionKey] as? String,
               !localizedDescription.isEmpty {
                errorMessage = localizedDescription
            }
            
            return (0, errorMessage)
        }
        
        return (0, error.localizedDescription)
    }
    
    /// Converts HTTP error code to a human-readable error message (matching Android SDK)
    /// - Parameter errorCode: The HTTP error code
    /// - Returns: A descriptive error message
    private func getErrorMessage(errorCode: Int) -> String {
        switch errorCode {
        case 0:
            return "Network error or connection failed"
        case 400:
            return "Bad request - invalid parameters"
        case 401:
            return "Unauthorized - invalid API key"
        case 403:
            return "Permission denied - API key lacks required permissions"
        case 404:
            return "Not found - endpoint or resource not found"
        case 500:
            return "Internal server error"
        case 503:
            return "Service unavailable"
        default:
            return "HTTP error \(errorCode)"
        }
    }
}

