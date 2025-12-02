//
//  ContentView.swift
//  GetTranslatedSample
//
//  Created by GetTranslated SDK Sample App
//

import SwiftUI
import GetTranslatedSDK

struct ContentView: View {
    @StateObject private var viewModel = SampleAppViewModel()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    Text("app.title", comment: "App title")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.top)
                    
                    // SDK Status Card
                    SDKStatusCard(viewModel: viewModel)
                    
                    // User Management Card
                    UserManagementCard(viewModel: viewModel)
                    
                    // Language Management Card
                    LanguageManagementCard(viewModel: viewModel)
                    
                    // Translation Testing Card
                    TranslationTestingCard(viewModel: viewModel)
                    
                    // Plural Testing Card
                    PluralTestingCard(viewModel: viewModel)
                    
                    // Log Output Card
                    LogOutputCard(viewModel: viewModel)
                    
                    // Exit Button
                    Button(NSLocalizedString("button.exit", comment: "Exit App button")) {
                        viewModel.exitApp()
                    }
                    .buttonStyle(SecondaryButtonStyle())
                    .padding(.top, 8)
                }
                .padding()
            }
            .navigationBarHidden(true)
        }
        .onAppear {
            viewModel.initializeSDK()
        }
    }
}

// MARK: - SDK Status Card

struct SDKStatusCard: View {
    @ObservedObject var viewModel: SampleAppViewModel
    
    var body: some View {
        CardView(title: NSLocalizedString("sdk.status.title", comment: "SDK Status card title")) {
            VStack(alignment: .leading, spacing: 8) {
                Text(viewModel.sdkStatus)
                    .foregroundColor(viewModel.sdkStatusColor)
                    .font(.body)
            }
        }
    }
}

// MARK: - User Management Card

struct UserManagementCard: View {
    @ObservedObject var viewModel: SampleAppViewModel
    
    var body: some View {
        CardView(title: NSLocalizedString("user.management.title", comment: "User Management card title")) {
            VStack(alignment: .leading, spacing: 12) {
                TextField(NSLocalizedString("user.management.user_id.placeholder", comment: "User ID placeholder"), text: $viewModel.userIdInput)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                HStack(spacing: 12) {
                    Button(NSLocalizedString("user.management.login", comment: "Login button")) {
                        viewModel.loginUser()
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    
                    Button(NSLocalizedString("user.management.logout", comment: "Logout button")) {
                        viewModel.logoutUser()
                    }
                    .buttonStyle(SecondaryButtonStyle())
                }
                
                Text(viewModel.currentUserText)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

// MARK: - Language Management Card

struct LanguageManagementCard: View {
    @ObservedObject var viewModel: SampleAppViewModel
    
    var body: some View {
        CardView(title: NSLocalizedString("language.management.title", comment: "Language Management card title")) {
            VStack(alignment: .leading, spacing: 12) {
                Text(viewModel.supportedLanguagesText)
                    .font(.system(.caption, design: .monospaced))
                    .padding(8)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                
                TextField(NSLocalizedString("language.management.language_code.placeholder", comment: "Language code placeholder"), text: $viewModel.languageInput)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Button(NSLocalizedString("language.management.set_language", comment: "Set Language button")) {
                    viewModel.setLanguage()
                }
                .buttonStyle(PrimaryButtonStyle())
                
                Text(viewModel.currentLanguageText)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

// MARK: - Translation Testing Card

struct TranslationTestingCard: View {
    @ObservedObject var viewModel: SampleAppViewModel
    
    var body: some View {
        CardView(title: NSLocalizedString("translation.testing.title", comment: "Translation Testing card title")) {
            VStack(alignment: .leading, spacing: 12) {
                TextField(NSLocalizedString("translation.testing.input.placeholder", comment: "Text to translate placeholder"), text: $viewModel.translationInput)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Button(NSLocalizedString("translation.testing.translate", comment: "Translate button")) {
                    viewModel.translateText()
                }
                .buttonStyle(PrimaryButtonStyle())
                
                Text(NSLocalizedString("translation.testing.result", comment: "Result label"))
                    .font(.caption)
                    .fontWeight(.semibold)
                
                Text(viewModel.translationResultText)
                    .font(.body)
                    .padding(8)
                    .frame(maxWidth: .infinity, minHeight: 48, alignment: .leading)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
            }
        }
    }
}

// MARK: - Plural Testing Card

struct PluralTestingCard: View {
    @ObservedObject var viewModel: SampleAppViewModel
    
    var body: some View {
        CardView(title: NSLocalizedString("plural.testing.title", comment: "Plural Testing card title")) {
            VStack(alignment: .leading, spacing: 12) {
                Text(NSLocalizedString("plural.testing.description", comment: "Plural forms description"))
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(viewModel.pluralResults) { result in
                        HStack {
                            Text(String(format: NSLocalizedString("plural.testing.count", comment: "Count label"), result.count))
                                .font(.system(.caption, design: .monospaced))
                                .fontWeight(.semibold)
                                .frame(width: 80, alignment: .leading)
                            
                            Spacer()
                            
                            Text(result.result)
                                .font(.system(.caption, design: .monospaced))
                                .frame(maxWidth: .infinity, alignment: .trailing)
                        }
                        .padding(.vertical, 4)
                    }
                }
                .padding(8)
                .background(Color(.systemGray6))
                .cornerRadius(8)
            }
        }
    }
}

// MARK: - Log Output Card

struct LogOutputCard: View {
    @ObservedObject var viewModel: SampleAppViewModel
    
    var body: some View {
        CardView(title: NSLocalizedString("log.output.title", comment: "Log Output card title")) {
            VStack(alignment: .leading, spacing: 12) {
                ScrollView {
                    Text(viewModel.logText)
                        .font(.system(.caption, design: .monospaced))
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(height: 200)
                .padding(8)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                
                Button(NSLocalizedString("log.output.clear", comment: "Clear Log button")) {
                    viewModel.clearLog()
                }
                .buttonStyle(SecondaryButtonStyle())
            }
        }
    }
}

// MARK: - Supporting Views

struct CardView<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .fontWeight(.bold)
            
            content
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color(.systemGray5))
            .foregroundColor(.primary)
            .cornerRadius(8)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}

// MARK: - Preview

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

