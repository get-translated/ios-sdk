# GetTranslated iOS SDK Unit Tests

This directory contains comprehensive unit tests for the GetTranslated iOS SDK, ensuring consistency with the Android SDK implementation.

## Test Structure

The test suite is organized into the following test files:

### Core Component Tests

- **StorageKeysTests.swift** - Tests for storage key generation and UserDefaults operations
- **LanguageDetectionTests.swift** - Tests for device language detection and matching
- **LoggerTests.swift** - Tests for logging functionality and log levels

### SDK Functionality Tests

- **GetTranslatedInitTests.swift** - Tests for SDK initialization and state management
- **GetTranslatedUserAuthTests.swift** - Tests for user login/logout functionality
- **GetTranslatedLanguageTests.swift** - Tests for language management and overrides
- **GetTranslatedTranslationTests.swift** - Tests for translation functionality and caching

## Running Tests

### Using Xcode

1. Open the `GetTranslatedSDK` package in Xcode
2. Select the `GetTranslatedSDKTests` scheme
3. Press `Cmd+U` to run all tests
4. Or use `Cmd+Option+U` to run tests with coverage

### Using Command Line

**Note:** There is a known issue with the Swift Package Manager test runner (`swift test`) on some macOS systems that causes a crash (signal 11). If you encounter this issue, please use Xcode to run tests instead.

```bash
# From the sdk/ios/GetTranslatedSDK directory
swift test

# With verbose output
swift test --verbose

# Run specific test
swift test --filter StorageKeysTests
```

**If `swift test` crashes:** Use Xcode instead (see "Using Xcode" section above). The tests work correctly when run through Xcode's test runner.

## Test Coverage

The test suite covers:

- ✅ Storage key generation and consistency
- ✅ UserDefaults operations (get, set, remove)
- ✅ Language detection and matching
- ✅ Logger configuration and filtering
- ✅ SDK initialization (with and without callbacks)
- ✅ User authentication (login/logout)
- ✅ Language management and persistence
- ✅ Translation caching and retrieval
- ✅ Error handling and edge cases

## Test Patterns

### Async Testing

Tests use `XCTestExpectation` for async operations:

```swift
let expectation = XCTestExpectation(description: "Async operation")
// ... perform async operation ...
wait(for: [expectation], timeout: 5.0)
```

### Test Isolation

Each test:
- Sets up clean state in `setUp()`
- Cleans up in `tearDown()`
- Resets SDK instance between tests using `GetTranslated.resetForTesting()`

### Mocking

For network-dependent tests, the tests handle real network calls but verify behavior through callbacks and expectations. In a production test suite, you might want to add URLSession mocking.

## Notes

- Tests that require network access may fail in environments without internet connectivity
- Some tests verify behavior rather than exact network responses
- The `resetForTesting()` method is only available in debug builds
- UserDefaults are cleared between tests to ensure isolation

## Adding New Tests

When adding new tests:

1. Follow the existing test file structure
2. Use descriptive test method names starting with `test`
3. Add appropriate setup and teardown
4. Use XCTestExpectation for async operations
5. Verify both success and error cases
6. Test edge cases (empty strings, nil values, etc.)

## Test Consistency with Android SDK

These tests are designed to match the Android SDK test coverage:

- Same test scenarios and edge cases
- Similar test organization
- Consistent test naming conventions
- Equivalent coverage of core functionality

