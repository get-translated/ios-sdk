# GetTranslated SDK Sample iOS App

This is a sample iOS application that demonstrates the functionality of the GetTranslated SDK.

## Features

The sample app includes the following features to test the GetTranslated SDK:

### 1. SDK Status
- Shows the initialization status of the SDK
- Displays success/failure messages with color coding

### 2. User Management
- Login with a custom user ID
- Logout to return to anonymous user
- Display current user status

### 3. Language Management
- View supported languages from the server
- Set the current language for translations
- Display current language status

### 4. Translation Testing
- Enter text to translate
- Get translation results with callback handling
- Display translation errors if they occur

### 5. Log Output
- Real-time logging of SDK operations
- Clear log functionality
- Timestamped log entries

## Setup

### 1. API Key Configuration

You need to configure your GetTranslated API key. You can do this in one of two ways:

#### Option A: Info.plist (Recommended for Development)

1. Open `GetTranslatedSample/Info.plist` in Xcode
2. Find the `GetTranslatedAPIKey` key
3. Replace `YOUR_API_KEY_HERE` with your actual API key

#### Option B: Environment Variable (Recommended for CI/CD)

Set the `GETTRANSLATED_API_KEY` environment variable before running the app:

```bash
export GETTRANSLATED_API_KEY="your-api-key-here"
```

**Important:** Get your API key from your [dashboard](https://www.gettranslated.ai/home/). Don't have an account? [Sign up for free](https://www.gettranslated.ai/signup/).

### 2. Add SDK Dependency

The sample app references the GetTranslated SDK from GitHub. The package dependency is already configured in the Xcode project.

If you need to update or re-add the dependency:

1. In Xcode, go to **File → Add Packages...**
2. Enter the repository URL: `https://github.com/get-translated/ios-sdk.git`
3. Select version: `1.0.0` or `Up to Next Major Version`
4. Add to your target

## Building and Running

### Using Xcode

1. Open `GetTranslatedSample.xcodeproj` in Xcode
2. Select a simulator or connected device
3. Click the Run button (▶️) or press `Cmd+R`

### Using Command Line

```bash
# Build the project
xcodebuild -project GetTranslatedSample.xcodeproj \
           -scheme GetTranslatedSample \
           -sdk iphonesimulator \
           -destination 'platform=iOS Simulator,name=iPhone 14' \
           build

# Run on simulator (requires Xcode)
open -a Simulator
xcodebuild -project GetTranslatedSample.xcodeproj \
           -scheme GetTranslatedSample \
           -sdk iphonesimulator \
           -destination 'platform=iOS Simulator,name=iPhone 14' \
           test
```

## Usage

1. **Initialize**: The app automatically initializes the SDK when it starts.

2. **Test User Management**: 
   - Enter a user ID and click "Login"
   - Click "Logout" to return to anonymous user

3. **Test Language Management**:
   - Enter a language code (e.g., "es", "fr", "de") and click "Set Language"
   - View supported languages from the server

4. **Test Translations**:
   - Enter text to translate
   - Click "Translate" to get the translation
   - View results in the translation result area

5. **Monitor Logs**: 
   - View real-time logs of all SDK operations
   - Use "Clear Log" to reset the log display

## SDK Features Tested

- ✅ SDK initialization with callbacks
- ✅ User login/logout with callbacks
- ✅ Language switching
- ✅ Translation with callbacks
- ✅ Error handling
- ✅ Logging
- ✅ Anonymous user support

## Requirements

- iOS 13.0+
- Swift 5.7+
- Xcode 14.0+
- Internet connection for SDK operations
- Valid GetTranslated API key

## Troubleshooting

### SDK Not Initializing

**Error:** "API key not configured"

**Solution:** Make sure you've set the `GetTranslatedAPIKey` in Info.plist or the `GETTRANSLATED_API_KEY` environment variable. Get your API key from your [dashboard](https://www.gettranslated.ai/home/).

### Translation Returns Original Text

**Possible Causes:**
1. Language is the base language (no translation needed)
2. Translation not yet cached (use callback version)
3. Network error (check logs)

**Solution:** Use the callback version to get notified when translation is available.

### Language Not Supported

**Error:** Language code not in supported languages

**Solution:** Check supported languages displayed in the Language Management section and use a supported language code.

### Network Errors

**Error:** "Network error or connection failed"

**Solution:** 
- Check your internet connection
- Verify the API key is correct in your [dashboard](https://www.gettranslated.ai/home/)
- Check the server URL in the SDK configuration

## Project Structure

```
GetTranslatedSample/
├── GetTranslatedSampleApp.swift    # App entry point
├── ContentView.swift               # Main UI view
├── SampleAppViewModel.swift        # View model with business logic
└── Info.plist                      # App configuration
```

## Notes

- The sample app uses SwiftUI for the user interface
- All SDK operations are handled through the ViewModel
- The ViewModel implements both `InitCallback` and `TranslationCallback` protocols
- Logs are displayed in real-time in the Log Output section
- The app automatically updates the UI when SDK state changes

## Support

- [Documentation](https://www.gettranslated.ai/docs/) - Complete API reference and guides
- [Dashboard](https://www.gettranslated.ai/home/) - Manage your projects and API keys
- [Feedback & Support](https://www.gettranslated.ai/account/feedback) - Get help and contact support

