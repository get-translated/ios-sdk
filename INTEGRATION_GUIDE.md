# GetTranslated iOS SDK - Complete Integration Guide

## Table of Contents

1. [Overview](#overview)
2. [Installation](#installation)
3. [Quick Start](#quick-start)
4. [API Reference](#api-reference)
5. [Advanced Usage](#advanced-usage)
6. [Best Practices](#best-practices)
7. [Troubleshooting](#troubleshooting)

## Overview

The GetTranslated iOS SDK provides real-time, AI-powered translations for iOS applications. It offers seamless integration with automatic language detection, offline caching, and support for both anonymous and authenticated users.

### Key Features

- **Real-time Translation**: Get translations on-demand with automatic caching
- **Anonymous User Support**: Automatic user ID generation with seamless login transition
- **Initialization Callbacks**: Receive initialization status and error information via callbacks
- **Language Management**: Automatic language detection based on system preferences and overrides (manual setting optional for custom selectors)
- **Offline Caching**: Persistent translation cache using UserDefaults
- **Swift Package Manager**: Easy integration via SPM
- **Comprehensive Logging**: Configurable logging levels for debugging
- **Robust Error Handling**: Detailed error codes and messages for initialization failures

### Architecture

The SDK follows a singleton pattern with the following key components:

1. **GetTranslated**: Main SDK class with static methods
2. **Logger**: Configurable logging system
3. **StorageKeys**: UserDefaults key management
4. **LanguageDetection**: Device language detection and matching

## Installation

### Prerequisites

- iOS 13.0+ / macOS 10.15+ / tvOS 13.0+ / watchOS 6.0+
- Swift 5.7+
- Xcode 14.0+

### Swift Package Manager (Recommended)

1. In Xcode, go to **File → Add Packages...**
2. Click **Add Local...** and navigate to the SDK directory
3. Or add the SDK as a local package dependency
4. Add to your target

### CocoaPods

Add to your `Podfile`:

```ruby
pod 'GetTranslatedSDK', '~> 1.0.0'
```

Then run:

```bash
pod install
```

## Quick Start

### Basic Initialization

```swift
import GetTranslatedSDK

func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    // Initialize GetTranslated SDK
    GetTranslated.initialize(key: "your-api-key")
    
    return true
}
```

### Simple Translation

```swift
// Synchronous translation
let translated = GetTranslated.getDynamicString("Hello, World!")

// Display in your UI
label.text = translated
```

### Translation with Callback

```swift
// Asynchronous translation with callback
GetTranslated.getDynamicString("Hello, World!") { translation in
    // Update UI on main thread
    DispatchQueue.main.async {
        label.text = translation
    }
} onError: { error in
    // Handle error
    print("Translation error: \(error)")
}
```

## API Reference

### Static Methods

#### `init(key:userId:logLevel:callback:)`

Initializes the GetTranslated SDK.

**Parameters:**
- `key`: API key for authentication (required)
- `userId`: Optional user ID. If not provided, an anonymous user will be created
- `logLevel`: Optional log level for debugging (default: `.warn`)
- `callback`: Optional callback to receive initialization status

**Example:**
```swift
// Anonymous user (simple)
GetTranslated.initialize(key: "your-api-key")

// With user ID
GetTranslated.initialize(key: "your-api-key", userId: "user-123")

// With custom logging
GetTranslated.initialize(key: "your-api-key", userId: "user-123", logLevel: .debug)

// With callback for initialization status
class AppDelegate: UIResponder, UIApplicationDelegate, InitCallback {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        GetTranslated.initialize(key: "your-api-key", callback: self)
        return true
    }
    
    func onInitSuccess() {
        print("SDK initialized successfully")
    }
    
    func onInitError(_ errorCode: Int, _ errorMessage: String) {
        print("Initialization failed: \(errorCode) - \(errorMessage)")
    }
}
```

#### `login(userId:callback:)`

Login with a specific user ID (transitions from anonymous to authenticated).

**Parameters:**
- `userId`: User ID for authentication
- `callback`: Optional callback to receive re-initialization status

**Example:**
```swift
// Simple login
GetTranslated.login(userId: "user-123")

// Login with callback
class MyViewController: UIViewController, InitCallback {
    func loginUser() {
        GetTranslated.login(userId: "user-123", callback: self)
    }
    
    func onInitSuccess() {
        print("Login successful")
        updateUI()
    }
    
    func onInitError(_ errorCode: Int, _ errorMessage: String) {
        print("Login failed: \(errorCode) - \(errorMessage)")
    }
}
```

#### `logout(callback:)`

Logout and return to anonymous user.

**Parameters:**
- `callback`: Optional callback to receive re-initialization status

**Example:**
```swift
// Simple logout
GetTranslated.logout()

// Logout with callback
class MyViewController: UIViewController, InitCallback {
    func logoutUser() {
        GetTranslated.logout(callback: self)
    }
    
    func onInitSuccess() {
        print("Logout successful")
        updateUI()
    }
    
    func onInitError(_ errorCode: Int, _ errorMessage: String) {
        print("Logout failed: \(errorCode) - \(errorMessage)")
    }
}
```

#### `setLanguage(_:)`

Set language override programmatically. **Note:** This is optional - the SDK automatically sets the language based on system preferences and saved overrides during initialization. Only use this method if you want to implement a custom language selector in your app.

**Parameters:**
- `languageCode`: ISO 639-1 language code (e.g., "en", "es", "fr")

**Example:**
```swift
// Optional: Only needed if implementing a language selector
GetTranslated.setLanguage("es")
```

#### `getLanguages()`

Returns the set of languages supported by the current project.

**Returns:** `Set<String>` - Supported language codes, or empty set if not initialized

**Example:**
```swift
let languages = GetTranslated.getLanguages()
```

#### `getCurrentLanguage()`

Returns the current language code being used by the SDK.

**Returns:** `String` - Current language code (e.g., "en", "es", "fr"), or "en" if not initialized

**Example:**
```swift
let currentLang = GetTranslated.getCurrentLanguage()
```

#### `getDynamicString(_:)`

Get translation synchronously (checks cache first, returns original if not cached).

**Parameters:**
- `text`: Text to translate

**Returns:** `String` - Translated text or original text if not cached

**Example:**
```swift
let translated = GetTranslated.getDynamicString("Hello, World!")
```

#### `getDynamicString(_:onReady:onError:)`

Get translation with callback for async notifications.

**Parameters:**
- `text`: Text to translate
- `onReady`: Callback when translation is available
- `onError`: Callback if translation fails

**Returns:** `String` - Translated text or original text if not cached

**Example:**
```swift
GetTranslated.getDynamicString("Hello, World!") { translation in
    label.text = translation
} onError: { error in
    print("Error: \(error)")
}
```

## Advanced Usage

### Initialization Callbacks

The SDK provides `InitCallback` protocol to receive initialization status:

```swift
public protocol InitCallback: AnyObject {
    /// Called when SDK initialization succeeds
    func onInitSuccess()
    
    /// Called if there is an error during SDK initialization
    /// - Parameters:
    ///   - errorCode: The HTTP error code (e.g., 401, 403, 500), or 0 for network/parsing errors
    ///   - errorMessage: A description of the error
    func onInitError(_ errorCode: Int, _ errorMessage: String)
}
```

**Error Codes:**
- `0`: Network error or connection failed
- `400`: Bad request - invalid parameters
- `401`: Unauthorized - invalid API key
- `403`: Permission denied - API key lacks required permissions
- `404`: Not found - endpoint or resource not found
- `500`: Internal server error
- `503`: Service unavailable

**Example:**
```swift
class AppDelegate: UIResponder, UIApplicationDelegate, InitCallback {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        GetTranslated.initialize(key: "your-api-key", callback: self)
        return true
    }
    
    func onInitSuccess() {
        // SDK is ready to use
        let languages = GetTranslated.getLanguages()
        print("SDK initialized with \(languages.count) languages")
    }
    
    func onInitError(_ errorCode: Int, _ errorMessage: String) {
        switch errorCode {
        case 401:
            print("Invalid API key - check your key in settings")
        case 403:
            print("Permission denied - check API key permissions")
        case 0:
            print("Network error - check your internet connection")
        default:
            print("Initialization error: \(errorCode) - \(errorMessage)")
        }
    }
}
```

### Custom Logging

```swift
// Initialize with debug logging
GetTranslated.initialize(key: "your-api-key", logLevel: .debug)

// Or change log level at runtime
Logger.getInstance().setLevel(.verbose)
```

### Language Change Handling

**Automatic Language Detection:** The SDK automatically sets the application language during initialization based on system preferences and saved overrides. You do **not** need to manually set the language unless implementing a custom language selector.

```swift
// Get current language (automatically set by SDK)
let currentLang = GetTranslated.getCurrentLanguage()

// Get supported languages
let supported = GetTranslated.getLanguages()

// Optional: Manually set language (only if implementing a language selector)
GetTranslated.setLanguage("es")
```

### User Management

```swift
// Start as anonymous user
GetTranslated.initialize(key: "your-api-key")

// Login when user authenticates (with callback)
class UserManager: InitCallback {
    func loginUser(_ userId: String) {
        GetTranslated.login(userId: userId, callback: self)
    }
    
    func onInitSuccess() {
        print("User logged in successfully")
        // Update UI, refresh translations, etc.
    }
    
    func onInitError(_ errorCode: Int, _ errorMessage: String) {
        print("Login failed: \(errorMessage)")
        // Show error to user
    }
}

// Logout when user signs out (with callback)
func logoutUser() {
    GetTranslated.logout(callback: self)
}
```

## Best Practices

### 1. Initialize Early with Callbacks

Initialize the SDK in your `AppDelegate` or `SceneDelegate` with callbacks for better error handling:

```swift
class AppDelegate: UIResponder, UIApplicationDelegate, InitCallback {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Initialize with callback to handle errors
        GetTranslated.initialize(key: "your-api-key", callback: self)
        return true
    }
    
    func onInitSuccess() {
        // SDK ready - proceed with app initialization
    }
    
    func onInitError(_ errorCode: Int, _ errorMessage: String) {
        // Handle initialization error
        // Show alert, disable features, etc.
    }
}
```

### 2. Use Callbacks for Async Translations

For better user experience, use the callback version:

```swift
GetTranslated.getDynamicString("Hello") { translation in
    DispatchQueue.main.async {
        label.text = translation
    }
} onError: { error in
    // Handle error gracefully
}
```

### 3. Handle Errors Gracefully

Always provide fallback text:

```swift
GetTranslated.getDynamicString("Hello") { translation in
    label.text = translation
} onError: { error in
    label.text = "Hello" // Fallback to original
}
```

### 4. Set Language Based on User Preference

```swift
// Get user's preferred language from settings
let userLanguage = UserDefaults.standard.string(forKey: "userLanguage") ?? "en"
GetTranslated.setLanguage(userLanguage)
```

## Troubleshooting

### SDK Not Initialized

**Error:** "Not initialized"

**Solution:** Make sure to call `GetTranslated.initialize(key:)` before using any other methods. Use the callback version to ensure initialization completes before using the SDK.

### Initialization Errors

**Error Code 401:** Unauthorized - invalid API key
- **Solution:** Verify your API key is correct in your project settings

**Error Code 403:** Permission denied
- **Solution:** Check that your API key has the required permissions for the project

**Error Code 0:** Network error
- **Solution:** Check your internet connection and verify the server URL is accessible

**Error Code 500/503:** Server error
- **Solution:** The server may be temporarily unavailable. Retry after a few moments.

### Translation Returns Original Text

**Possible Causes:**
1. Language is the base language (no translation needed)
2. Translation not yet cached (use callback version)
3. Network error (check logs)
4. SDK not initialized (check initialization status)

**Solution:** Use the callback version to get notified when translation is available. Check that the SDK initialized successfully using `InitCallback`.

### Language Not Supported

**Error:** Language code not in supported languages

**Solution:** Check supported languages with `GetTranslated.getLanguages()` and use a supported language code.

### Login/Logout Errors

**Error:** Login or logout fails with error code

**Solution:** 
- Check that the SDK is initialized before calling login/logout
- Use the callback version to handle errors gracefully
- Verify user ID is not empty or null
- Check network connectivity

## Sample App

A complete sample application demonstrating all SDK features is available in the `sample-app` directory. The sample app includes:

- SDK initialization with callbacks
- User login/logout functionality
- Language management
- Translation testing
- Real-time logging
- Error handling examples

See [Sample App README](../sample-app/README.md) for setup instructions.

## Support

- Documentation: https://www.gettranslated.ai/docs
- Sample App: [Sample App Guide](../sample-app/README.md)

