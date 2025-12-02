Pod::Spec.new do |spec|
  spec.name         = "GetTranslatedSDK"
  spec.version      = "1.0.0"
  spec.summary      = "GetTranslated iOS SDK for translation management"
  spec.description  = <<-DESC
    A native iOS SDK for the GetTranslated translation management platform,
    providing real-time, AI-powered translations for iOS applications.
    
    Features:
    - Real-time translation with automatic caching
    - Anonymous user support with seamless login transition
    - Initialization callbacks for error handling
    - Automatic language detection with override support
    - Offline caching using UserDefaults
    - Comprehensive logging system
    - Robust error handling
  DESC
  
  spec.homepage     = "https://github.com/get-translated/ios-sdk"
  spec.license      = { :type => "MIT", :file => "LICENSE" }
  spec.author       = { "GetTranslated" => "support@gettranslated.ai" }
  
  spec.platforms    = { 
    :ios => "13.0",
    :osx => "10.15",
    :tvos => "13.0",
    :watchos => "6.0"
  }
  spec.swift_version = "5.7"
  
  spec.source       = { 
    :git => "https://github.com/get-translated/ios-sdk.git",
    :tag => "#{spec.version}"
  }
  
  spec.source_files = "GetTranslatedSDK/Sources/GetTranslatedSDK/**/*.swift"
  spec.exclude_files = "GetTranslatedSDK/Tests/**/*"
  
  spec.frameworks   = "Foundation"
  spec.requires_arc = true
  
  # Add any dependencies here if needed
  # spec.dependency 'SomeOtherPod', '~> 1.0'
end

