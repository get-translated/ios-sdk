# Publishing GetTranslated iOS SDK

This guide covers publishing the iOS SDK to Swift Package Manager (SPM) and CocoaPods.

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Publishing to Swift Package Manager (SPM)](#publishing-to-swift-package-manager-spm)
3. [Publishing to CocoaPods](#publishing-to-cocoapods)
4. [Version Management](#version-management)
5. [Pre-Publish Checklist](#pre-publish-checklist)
6. [Testing Published Versions](#testing-published-versions)
7. [Troubleshooting](#troubleshooting)

## Prerequisites

1. **GitHub Repository**: The SDK must be in a public GitHub repository
2. **GitHub Account**: With write access to the repository
3. **CocoaPods Account** (for CocoaPods publishing):
   - Register at https://trunk.cocoapods.org/
   - Verify your email address
   - Get your session token: `pod trunk register your-email@example.com 'Your Name'`

## Publishing to Swift Package Manager (SPM)

SPM is the recommended distribution method for iOS SDKs. It's built into Xcode and doesn't require external tools.

### Step 1: Prepare the Package

Ensure your `Package.swift` is properly configured:

```swift
// swift-tools-version: 5.8
import PackageDescription

let package = Package(
    name: "GetTranslatedSDK",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15),
        .tvOS(.v13),
        .watchOS(.v6)
    ],
    products: [
        .library(
            name: "GetTranslatedSDK",
            targets: ["GetTranslatedSDK"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "GetTranslatedSDK",
            dependencies: []),
        .testTarget(
            name: "GetTranslatedSDKTests",
            dependencies: ["GetTranslatedSDK"]),
    ]
)
```

### Step 2: Update Version and Tag

1. **Update Version** (if needed):
   - Update any version references in documentation
   - Update CHANGELOG.md if you maintain one

2. **Commit Changes**:
   ```bash
   git add .
   git commit -m "Prepare for release v1.0.0"
   ```

3. **Create Git Tag**:
   ```bash
   # Create an annotated tag (recommended)
   git tag -a v1.0.0 -m "Release version 1.0.0"
   
   # Or create a lightweight tag
   git tag v1.0.0
   ```

4. **Push Tag to GitHub**:
   ```bash
   git push origin v1.0.0
   # Or push all tags
   git push --tags
   ```

### Step 3: Verify Package on GitHub

1. Go to your GitHub repository
2. Click on **Releases** → **Tags**
3. Verify your tag exists
4. The package is now available via SPM!

### Step 4: Test SPM Installation

Users can now add your package in Xcode:

1. **File → Add Packages...**
2. Enter your repository URL: `https://github.com/get-translated/ios-sdk.git`
3. Select the version/tag
4. Click **Add Package**

Or add to `Package.swift`:
```swift
dependencies: [
    .package(url: "https://github.com/get-translated/ios-sdk.git", from: "1.0.0")
]
```

### Step 5: Create GitHub Release (Optional but Recommended)

1. Go to your GitHub repository
2. Click **Releases** → **Create a new release**
3. Select your tag (e.g., `v1.0.0`)
4. Add release notes (copy from CHANGELOG.md if available)
5. Click **Publish release**

## Publishing to CocoaPods

CocoaPods is an alternative package manager for iOS/macOS projects.

### Step 1: Create Podspec File

Create `GetTranslatedSDK.podspec` in the root of your SDK directory:

```ruby
Pod::Spec.new do |spec|
  spec.name         = "GetTranslatedSDK"
  spec.version      = "1.0.0"
  spec.summary      = "GetTranslated iOS SDK for translation management"
  spec.description  = <<-DESC
    A native iOS SDK for the GetTranslated translation management platform,
    providing real-time, AI-powered translations for iOS applications.
  DESC
  
  spec.homepage     = "https://github.com/get-translated/ios-sdk"
  spec.license      = { :type => "MIT", :file => "LICENSE" }
  spec.author       = { "GetTranslated" => "support@gettranslated.ai" }
  
  spec.platform     = :ios, "13.0"
  spec.swift_version = "5.7"
  
  spec.source       = { 
    :git => "https://github.com/get-translated/ios-sdk.git",
    :tag => "#{spec.version}"
  }
  
  spec.source_files = "GetTranslatedSDK/Sources/**/*.swift"
  spec.exclude_files = "GetTranslatedSDK/Tests/**/*"
  
  spec.frameworks   = "Foundation"
  spec.requires_arc = true
end
```

**Important**: Adjust paths based on your actual directory structure. The `source_files` path should point to your Swift source files.

### Step 2: Validate Podspec

```bash
# Install CocoaPods if not already installed
sudo gem install cocoapods

# Validate the podspec
pod spec lint GetTranslatedSDK.podspec
```

Fix any errors before proceeding.

### Step 3: Register with CocoaPods Trunk (First Time Only)

```bash
# Register your email (one-time setup)
pod trunk register your-email@example.com 'Your Name'

# Check your email and click the verification link
# Then verify your session
pod trunk me
```

### Step 4: Publish to CocoaPods

```bash
# Publish the podspec
pod trunk push GetTranslatedSDK.podspec

# This will:
# 1. Validate the podspec
# 2. Push it to the CocoaPods Specs repository
# 3. Make it available to all users
```

### Step 5: Verify Publication

After publishing, verify your pod is available:

```bash
# Search for your pod
pod search GetTranslatedSDK

# Or check online at:
# https://cocoapods.org/pods/GetTranslatedSDK
```

Users can now install via CocoaPods:

```ruby
# In their Podfile
pod 'GetTranslatedSDK', '~> 1.0.0'
```

## Version Management

### Semantic Versioning

Follow [Semantic Versioning](https://semver.org/):
- **MAJOR** (1.0.0): Breaking changes
- **MINOR** (0.1.0): New features, backward compatible
- **PATCH** (0.0.1): Bug fixes, backward compatible

### Version Tags

- Use annotated tags: `git tag -a v1.0.0 -m "Release 1.0.0"`
- Tag format: `v1.0.0` (with 'v' prefix)
- Push tags: `git push --tags`

### Updating Versions

For **SPM**:
- Update tag: `git tag -a v1.0.1 -m "Release 1.0.1"`
- Push tag: `git push origin v1.0.1`

For **CocoaPods**:
- Update `spec.version` in `.podspec`
- Commit and tag: `git tag v1.0.1`
- Push: `pod trunk push GetTranslatedSDK.podspec`

## Pre-Publish Checklist

Before publishing, ensure:

- [ ] All tests pass: Run tests in Xcode or `swift test`
- [ ] Code compiles without warnings
- [ ] Version number is updated
- [ ] CHANGELOG.md is updated (if maintained)
- [ ] README.md is up to date
- [ ] LICENSE file exists and is correct
- [ ] Package.swift is properly configured
- [ ] All source files are included
- [ ] Documentation is complete
- [ ] Sample app works with the SDK

### Running Tests

```bash
# From the GetTranslatedSDK directory
swift test

# Or in Xcode
# Product → Test (Cmd+U)
```

## Testing Published Versions

### Test SPM Installation

1. Create a test Xcode project
2. **File → Add Packages...**
3. Enter: `https://github.com/get-translated/ios-sdk.git`
4. Select version: `1.0.0`
5. Add to target
6. Verify it compiles and works

### Test CocoaPods Installation

1. Create a test project with a `Podfile`:
   ```ruby
   platform :ios, '13.0'
   use_frameworks!
   
   target 'TestApp' do
     pod 'GetTranslatedSDK', '~> 1.0.0'
   end
   ```

2. Install:
   ```bash
   pod install
   ```

3. Open `.xcworkspace` and verify it works

## Troubleshooting

### SPM Issues

**"No such module 'GetTranslatedSDK'"**
- Verify the tag exists on GitHub
- Check the repository URL is correct
- Ensure the tag points to a commit with Package.swift

**"Package.swift not found"**
- Ensure Package.swift is in the repository root
- Verify the tag includes Package.swift

**Version not found**
- Check the tag exists: `git ls-remote --tags origin`
- Verify tag format: `v1.0.0` (with 'v' prefix)

### CocoaPods Issues

**"Unable to find a specification"**
- Wait a few minutes after publishing (specs repository sync)
- Verify: `pod search GetTranslatedSDK`
- Check: https://cocoapods.org/pods/GetTranslatedSDK

**Podspec validation fails**
- Run: `pod spec lint GetTranslatedSDK.podspec --verbose`
- Fix all errors and warnings
- Ensure source_files paths are correct

**"Session expired"**
- Re-authenticate: `pod trunk register your-email@example.com 'Your Name'`
- Check email for verification link

### General Issues

**Tag not appearing on GitHub**
- Verify you pushed: `git push origin v1.0.0`
- Check GitHub → Releases → Tags

**Wrong files included**
- Review `.gitignore` to ensure necessary files are committed
- For CocoaPods, check `source_files` in podspec

## CI/CD Integration

### GitHub Actions Example

Create `.github/workflows/publish.yml`:

```yaml
name: Publish iOS SDK

on:
  push:
    tags:
      - 'v*'

jobs:
  publish-spm:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Verify Package
        run: |
          swift package resolve
          swift build
          swift test
  
  publish-cocoapods:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v3
      - name: Setup CocoaPods
        run: gem install cocoapods
      - name: Validate Podspec
        run: pod spec lint GetTranslatedSDK.podspec
      - name: Publish to CocoaPods
        env:
          COCOAPODS_TRUNK_TOKEN: ${{ secrets.COCOAPODS_TRUNK_TOKEN }}
        run: pod trunk push GetTranslatedSDK.podspec
```

## Best Practices

1. **Always test locally** before publishing
2. **Use semantic versioning** consistently
3. **Create GitHub releases** with release notes
4. **Update CHANGELOG.md** for each release
5. **Tag releases** immediately after publishing
6. **Test installation** in a fresh project
7. **Monitor for issues** after publishing
8. **Document breaking changes** clearly

## Next Steps

After publishing:

1. Update documentation with installation instructions
2. Announce the release (blog, social media, etc.)
3. Monitor for user feedback and issues
4. Plan the next release

## Additional Resources

- [Swift Package Manager Documentation](https://swift.org/package-manager/)
- [CocoaPods Guides](https://guides.cocoapods.org/)
- [Semantic Versioning](https://semver.org/)
- [Git Tagging Best Practices](https://git-scm.com/book/en/v2/Git-Basics-Tagging)

