# Setting Up the iOS Sample App

This guide will help you set up the GetTranslated iOS sample app in Xcode.

## Prerequisites

- Xcode 14.0 or later
- iOS 13.0+ deployment target
- A GetTranslated API key

## Step 1: Create Xcode Project

1. Open Xcode
2. Select **File → New → Project...**
3. Choose **iOS → App**
4. Fill in the project details:
   - **Product Name:** `GetTranslatedSample`
   - **Interface:** SwiftUI
   - **Language:** Swift
   - **Storage:** None (we'll add files manually)
5. Choose a location to save the project
6. Click **Create**

## Step 2: Add SDK Files

1. In Xcode, right-click on the project navigator
2. Select **Add Files to "GetTranslatedSample"...**
3. Navigate to `sdk/ios/sample-app/GetTranslatedSample/`
4. Select all Swift files:
   - `GetTranslatedSampleApp.swift`
   - `ContentView.swift`
   - `SampleAppViewModel.swift`
5. Make sure **"Copy items if needed"** is checked
6. Click **Add**

## Step 3: Add Info.plist

1. Right-click on the project in the navigator
2. Select **Add Files to "GetTranslatedSample"...**
3. Navigate to `sdk/ios/sample-app/GetTranslatedSample/`
4. Select `Info.plist`
5. Make sure **"Copy items if needed"** is checked
6. Click **Add**

## Step 4: Add GetTranslated SDK

The sample app is already configured to use the GetTranslated SDK from GitHub. The package dependency is set up in the Xcode project.

If you need to update or re-add the dependency:

1. In Xcode, go to **File → Add Packages...**
2. Enter the repository URL: `https://github.com/get-translated/ios-sdk.git`
3. Select version: `1.0.0` or `Up to Next Major Version`
4. In the package products, select **GetTranslatedSDK**
5. Add it to your **GetTranslatedSample** target
6. Click **Add Package**

## Step 5: Configure API Key

1. Get your API key from your [dashboard](https://www.gettranslated.ai/home/). Don't have an account? [Sign up for free](https://www.gettranslated.ai/signup/).
2. In Xcode, select `Info.plist` in the project navigator
3. Find the `GetTranslatedAPIKey` key
4. Replace `YOUR_API_KEY_HERE` with your actual API key

Alternatively, you can set it as an environment variable:
1. In Xcode, go to **Product → Scheme → Edit Scheme...**
2. Select **Run** in the left sidebar
3. Go to the **Arguments** tab
4. Under **Environment Variables**, add:
   - **Name:** `GETTRANSLATED_API_KEY`
   - **Value:** Your API key

## Step 6: Configure Build Settings

1. Select your project in the navigator
2. Select the **GetTranslatedSample** target
3. Go to **Build Settings**
4. Ensure **iOS Deployment Target** is set to **13.0** or higher

## Step 7: Build and Run

1. Select a simulator or connected device
2. Click the **Run** button (▶️) or press `Cmd+R`
3. The app should build and launch

## Troubleshooting

### "No such module 'GetTranslatedSDK'"

- Make sure you've added the SDK package correctly
- Try cleaning the build folder: **Product → Clean Build Folder** (Shift+Cmd+K)
- Restart Xcode

### "API key not configured"

- Make sure you've set the API key in Info.plist or as an environment variable
- Check that the key name matches exactly: `GetTranslatedAPIKey`
- Get your API key from your [dashboard](https://www.gettranslated.ai/home/)

### Build Errors

- Make sure all Swift files are added to the target
- Check that the deployment target is iOS 13.0+
- Verify that SwiftUI is available (requires iOS 13.0+)

## Next Steps

Once the app is running, you can:
1. Test SDK initialization
2. Try logging in with a user ID
3. Test language switching
4. Test translations
5. Monitor logs in real-time

For more information, see the [README.md](README.md) file.

