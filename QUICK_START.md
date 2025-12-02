# GetTranslated iOS SDK - Quick Start Guide

Get up and running with the GetTranslated iOS SDK in under 5 minutes! 🚀

## Prerequisites

- iOS 13.0+
- Swift 5.7+
- A GetTranslated account and API key

## Step 1: Installation

### Swift Package Manager

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

## Step 2: Basic Setup

### Initialize the SDK

Add the initialization code to your `AppDelegate` or `SceneDelegate`:

```swift
import GetTranslatedSDK

func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    // Initialize GetTranslated SDK (simple version)
    GetTranslated.initialize(key: "your-api-key")
    
    return true
}
```

**Important:** Get your API key from your project settings.

### Initialize with Callback (Recommended)

For better error handling and initialization status tracking, use the callback version:

```swift
import GetTranslatedSDK

class AppDelegate: UIResponder, UIApplicationDelegate, InitCallback {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Initialize with callback to handle success/error
        GetTranslated.initialize(key: "your-api-key", callback: self)
        
        return true
    }
    
    // InitCallback implementation
    func onInitSuccess() {
        print("SDK initialized successfully")
        // Update UI or proceed with app initialization
    }
    
    func onInitError(_ errorCode: Int, _ errorMessage: String) {
        print("SDK initialization failed: \(errorCode) - \(errorMessage)")
        // Handle initialization error
        if errorCode == 401 {
            // Invalid API key
        } else if errorCode == 403 {
            // Permission denied
        }
    }
}
```

## Step 3: Basic Translation

### Simple Translation

```swift
// Get a translation (synchronous)
let translated = GetTranslated.getDynamicString("Hello, World!")

// Display in your UI
label.text = translated
```

### Translation with Callback

```swift
// Get a translation with callback (asynchronous)
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

## Step 4: Language Management

### Automatic Language Detection

**Important:** The SDK automatically sets the application language during initialization based on:
- System preferences (device language)
- Saved user overrides (if previously set)
- Server language overrides (if provided)

You do **not** need to manually set the language unless you want to implement a custom language selector.

### Manual Language Setting (Optional)

If you want to implement a language selector in your app, you can manually set the language:

```swift
// Optional: Only needed if implementing a language selector
GetTranslated.setLanguage("es")

// Get supported languages
let languages = GetTranslated.getLanguages()

// Get current language (automatically set by SDK)
let currentLang = GetTranslated.getCurrentLanguage()
```

## Step 5: User Management

### Login with Callback

```swift
// Login with callback to handle success/error
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

### Logout with Callback

```swift
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

## 🎉 You're Done!

Your app is now ready to use GetTranslated for real-time translations. Check out the [Complete Integration Guide](INTEGRATION_GUIDE.md) for more advanced features.

## Next Steps

- Learn about [initialization callbacks](INTEGRATION_GUIDE.md#initialization-callbacks)
- Explore [user management](INTEGRATION_GUIDE.md#user-management)
- See [error handling](INTEGRATION_GUIDE.md#error-handling)
- Check out the [sample app](../sample-app/README.md) for a complete working example
- See [best practices](INTEGRATION_GUIDE.md#best-practices)

