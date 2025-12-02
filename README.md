# GetTranslated iOS SDK

A native iOS SDK for the [GetTranslated](https://www.gettranslated.ai) translation management platform, providing real-time, AI-powered translations for iOS applications.

## 🚀 Quick Start

Get up and running in under 5 minutes with our [Quick Start Guide](QUICK_START.md).

## 📚 Documentation

- **[Complete Integration Guide](INTEGRATION_GUIDE.md)** - Comprehensive documentation with examples and best practices
- **[Quick Start Guide](QUICK_START.md)** - Get started in 5 minutes
- **[Implementation Guide](IMPLEMENTATION_GUIDE.md)** - Architecture and implementation details

## 🎯 Key Features

- **Real-time Translation**: Get translations on-demand with automatic caching
- **Anonymous User Support**: Automatic user ID generation with seamless login transition
- **Initialization Callbacks**: Receive initialization status and error information via callbacks
- **Language Management**: Automatic language detection with override support
- **Offline Caching**: Persistent translation cache using UserDefaults
- **Swift Package Manager**: Easy integration via SPM
- **Comprehensive Logging**: Configurable logging levels for debugging
- **Robust Error Handling**: Detailed error codes and messages for initialization failures

## 📦 Installation

### Swift Package Manager (Recommended)

Add the SDK as a local package dependency:

1. In Xcode, go to **File → Add Packages...**
2. Click **Add Local...** and navigate to the SDK directory
3. Add to your target

Or add to your `Package.swift` file:

```swift
dependencies: [
    .package(path: "../GetTranslatedSDK")
]
```

### CocoaPods

```ruby
pod 'GetTranslatedSDK', '~> 1.0.0'
```

### Manual Installation

1. Download the SDK source code
2. Add the `GetTranslatedSDK` folder to your Xcode project
3. Link the framework to your target

## 🔧 Basic Usage

### Initialization

```swift
import GetTranslatedSDK

// In your AppDelegate or SceneDelegate
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    // Initialize with API key
    GetTranslated.initialize(key: "your-api-key")
    
    // Or with a specific user ID
    GetTranslated.initialize(key: "your-api-key", userId: "user-123")
    
    // Or with custom logging
    GetTranslated.initialize(key: "your-api-key", userId: "user-123", logLevel: .debug)
    
    return true
}
```

### Getting Translations

```swift
// Synchronous translation (returns immediately, may return original if not cached)
let translated = GetTranslated.getDynamicString("Hello, World!")

// Asynchronous translation with callback
GetTranslated.getDynamicString("Hello, World!") { translation in
    // Use the translation
    label.text = translation
} onError: { error in
    // Handle error
    print("Translation error: \(error)")
}
```

### Language Management

```swift
// Set language
GetTranslated.setLanguage("es")

// Get supported languages
let languages = GetTranslated.getLanguages()

// Get current language
let currentLang = GetTranslated.getCurrentLanguage()
```

### User Management

```swift
// Login with user ID
GetTranslated.login(userId: "user-123")

// Login with callback
GetTranslated.login(userId: "user-123", callback: initCallback)

// Logout and return to anonymous user
GetTranslated.logout()

// Logout with callback
GetTranslated.logout(callback: initCallback)
```

### Initialization Callbacks

```swift
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

## 🔑 Getting Your API Key

Get your API key from your project settings.

## 📋 Requirements

- iOS 13.0+ / macOS 10.15+ / tvOS 13.0+ / watchOS 6.0+
- Swift 5.7+
- Xcode 14.0+

## 🤝 Support

- Documentation: https://www.gettranslated.ai/docs

## 📄 License

See [LICENSE](LICENSE) file for details.

