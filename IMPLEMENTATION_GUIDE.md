# iOS SDK Implementation Guide

This guide explains how the iOS SDK was implemented to match the Android and React Native SDK behavior exactly, using platform-appropriate Swift/iOS patterns.

## Architecture Overview

The iOS SDK follows a singleton pattern with the following key components:

### Core Components

1. **GetTranslated**: Main SDK class with static methods
2. **Logger**: Configurable logging system with OSLog integration
3. **StorageKeys**: UserDefaults key management and data persistence
4. **LanguageDetection**: Device language detection and smart matching
5. **Constants**: SDK configuration and endpoint definitions

### Data Flow

```
User Request → GetTranslated → Cache Check → Network Request → Server → Response → Cache → UI Update
```

## Key Implementation Details

### 1. Singleton Pattern

The SDK uses a singleton pattern to ensure only one instance exists across the application:

```swift
public class GetTranslated {
    private static var instance: GetTranslated?
    
    public static func initialize(key: String, userId: String? = nil, logLevel: LogLevel = .warn, callback: InitCallback? = nil) {
        if instance != nil {
            Logger.getInstance().warn("GetTranslated: Already initialized")
            callback?.onInitSuccess()
            return
        }
        instance = GetTranslated(key: key, userId: userId)
        instance?.init(callback: callback)
    }
}
```

**Benefits:**
- Single point of configuration
- Consistent state across the app
- Memory efficient
- Thread-safe initialization

### 2. User ID Management

The SDK handles both anonymous and authenticated users seamlessly:

```swift
private init(key: String, userId: String?) {
    // Handle user ID logic
    if let userId = userId, !userId.trimmingCharacters(in: .whitespaces).isEmpty {
        self.userId = userId.trimmingCharacters(in: .whitespaces)
        self.isAnonymousUserId = false
    } else {
        // Anonymous user handling
        if let existingUserId = StorageKeys.getStoredUserId() {
            self.userId = existingUserId
        } else {
            self.userId = GetTranslated.generateRandomUserId()
            StorageKeys.storeUserId(self.userId)
        }
        self.isAnonymousUserId = true
    }
}
```

### 3. Storage Layer

**iOS**: UserDefaults  
**Android**: SharedPreferences  
**React Native**: AsyncStorage

All provide key-value storage with similar APIs:
- `string(forKey:)` → `getString(key)`
- `set(_:forKey:)` → `setItem(key, value)`
- `removeObject(forKey:)` → `removeItem(key)`

### 4. Language Detection

**iOS**: `Bundle.main.preferredLocalizations.first` or `Locale.current.languageCode`  
**Android**: `context.getResources().getConfiguration().locale.getLanguage()`  
**React Native**: `getLocales()[0]?.languageCode`

All return ISO 639-1 language codes.

### 5. Network Layer

**iOS**: `URLSession` with async/await or completion handlers  
**Android**: `HttpURLConnection` with `ExecutorService`  
**React Native**: `fetch()` with `async/await`

All provide asynchronous HTTP requests with similar error handling.

### 6. Translation Cache Key Generation

**Matches Android/RN**: Same hash algorithm as Java's `String.hashCode()`

```swift
public static func generateTranslationKey(languageCode: String, text: String) -> String {
    // Java hashCode formula: s[0]*31^(n-1) + s[1]*31^(n-2) + ... + s[n-1]
    let hash = text.utf8.reduce(0) { (result, byte) -> Int32 in
        return (result &* 31) &+ Int32(byte)
    }
    return generateKey(category: Constants.Category.translation, 
                      identifier: "\(languageCode)\(hash)", 
                      suffix: "translation")
}
```

### 7. Anonymous User ID Generation

**Format**: `{random_string}@{bundle_identifier}`

```swift
private static func generateRandomUserId() -> String {
    var result = ""
    for _ in 0..<Constants.idLength {
        let randomIndex = Int.random(in: 0..<Constants.idAlphabet.count)
        let index = Constants.idAlphabet.index(Constants.idAlphabet.startIndex, offsetBy: randomIndex)
        result.append(Constants.idAlphabet[index])
    }
    let bundleId = Bundle.main.bundleIdentifier ?? "ios-app"
    return "\(result)@\(bundleId)"
}
```

**Matches Android/RN**: Same 12-character random string + identifier format.

### 8. Language Resolution Priority

Both SDKs implement the same priority order:
1. Server language override (highest priority)
2. Saved user preference (if supported)
3. Device language with smart matching
4. Base language (final fallback)

## Platform-Specific Implementation Notes

### Storage
- Uses `UserDefaults.standard` for persistent storage
- Same key schema as Android/RN: `{PREFIX}_{CATEGORY}_{IDENTIFIER}_{SUFFIX}`
- Thread-safe operations (UserDefaults is thread-safe)

### Language Detection
- Uses `Bundle.main.preferredLocalizations` (most reliable for iOS)
- Falls back to `Locale.current.languageCode`
- Supports smart language matching (e.g., "en-US" → "en")

### Network Operations
- Uses `URLSession` for HTTP requests
- Supports async/await (iOS 15+) and completion handlers
- Automatic JSON serialization/deserialization
- Bearer token authentication

### Logging
- Uses `OSLog` for system-level logging
- Configurable log levels (Error, Warn, Info, Debug, Verbose)
- Console output for debugging
- Platform-appropriate logging format

## Testing

The SDK is designed to be testable:
- Dependency injection for network layer (can be extended)
- Mockable storage layer
- Configurable logging for test mode

## Distribution

### Swift Package Manager
- Package.swift configuration
- Supports iOS 13+, macOS 10.15+, tvOS 13+, watchOS 6+

### CocoaPods
- Podspec configuration (to be added)
- Easy integration for existing projects

## Migration from Android/React Native SDK

### API Compatibility

The iOS SDK provides the same API surface as the Android SDK:

```swift
// iOS - Initialization
GetTranslated.initialize(key: "api-key")
GetTranslated.initialize(key: "api-key", userId: "user-123")
GetTranslated.initialize(key: "api-key", userId: "user-123", logLevel: .debug)
GetTranslated.initialize(key: "api-key", callback: initCallback) // With callback

// iOS - User Management
GetTranslated.login(userId: "user-123")
GetTranslated.login(userId: "user-123", callback: initCallback) // With callback
GetTranslated.logout()
GetTranslated.logout(callback: initCallback) // With callback

// iOS - Translation
GetTranslated.getDynamicString("Hello")
GetTranslated.getDynamicString("Hello") { translation in } onError: { error in }
GetTranslated.getDynamicString("Hello", callback: translationCallback) // Protocol-based
```

### InitCallback Protocol

The iOS SDK includes `InitCallback` protocol matching Android's `InitCallback` interface:

```swift
public protocol InitCallback: AnyObject {
    func onInitSuccess()
    func onInitError(_ errorCode: Int, _ errorMessage: String)
}
```

This provides consistent error handling across platforms with detailed error codes and messages.

### Key Differences
1. **Swift syntax**: Uses Swift conventions (optionals, closures, etc.)
2. **Callback pattern**: Uses closures instead of Java interfaces
3. **Error handling**: Uses Swift's Result type and Error protocol
4. **Storage**: Uses UserDefaults instead of SharedPreferences/AsyncStorage

### Data Compatibility
- **Cache format**: Identical cache key generation
- **Storage keys**: Same naming conventions
- **User IDs**: Same format and persistence
- **Language codes**: Same ISO 639-1 codes

This implementation ensures that iOS apps can seamlessly integrate with the GetTranslated platform while maintaining identical behavior to the Android and React Native SDKs.

