//
//  JLearnApp.swift
//  JLearn
//
//  Main application entry point for Japanese Learning App
//

import SwiftUI
import FirebaseCore

// MARK: - Main App

@main
struct JLearnApp: App {
    @StateObject private var authService = AuthService.shared
    @StateObject private var learningDataService = LearningDataService.shared
    @StateObject private var audioService = AudioService.shared
    @StateObject private var errorHandler = ErrorHandler.shared
    @StateObject private var achievementService = AchievementService.shared
    @StateObject private var timerService = StudyTimerService.shared
    
    init() {
        // Configure Firebase (only if valid GoogleService-Info.plist exists)
        if let path = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist"),
           let plist = NSDictionary(contentsOfFile: path),
           let googleAppID = plist["GOOGLE_APP_ID"] as? String,
           !googleAppID.contains("YOUR_") && !googleAppID.isEmpty {
            FirebaseApp.configure()
            print("✅ Firebase configured successfully")
        } else {
            print("⚠️ Firebase not configured. Running in DEMO MODE without Firebase.")
            print("📝 This is normal! The app works perfectly in demo mode.")
            print("📝 To enable Firebase (optional): Download real GoogleService-Info.plist from Firebase Console")
        }
        
        print("🚀 JLearn launched - Japanese Learning App")
        print("📂 Bundle path: \(Bundle.main.resourcePath ?? "NONE")")
        
        // List JSON files in bundle
        if let resourcePath = Bundle.main.resourcePath,
           let files = try? FileManager.default.contentsOfDirectory(atPath: resourcePath) {
            let jsonFiles = files.filter { $0.hasSuffix(".json") }
            print("📋 JSON files in bundle: \(jsonFiles.count)")
            for file in jsonFiles {
                print("  - \(file)")
            }
        }
    }
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(authService)
                .environmentObject(learningDataService)
                .environmentObject(audioService)
                .environmentObject(errorHandler)
                .environmentObject(achievementService)
                .environmentObject(timerService)
                .tint(AppTheme.brandPrimary)
                .monitorNetwork()
                .alert("Error", isPresented: $errorHandler.showError, presenting: errorHandler.currentError) { error in
                    Button("OK") {
                        errorHandler.clearError()
                    }
                } message: { error in
                    VStack {
                        Text(error.errorDescription ?? "An error occurred")
                        if let suggestion = error.recoverySuggestion {
                            Text(suggestion)
                                .font(.caption)
                        }
                    }
                }
                .onAppear {
                    // Services are initialized automatically
                }
        }
    }
}

// MARK: - Root View

private struct RootView: View {
    @EnvironmentObject var authService: AuthService
    @State private var forceShowContent = false
    
    var body: some View {
        Group {
            if authService.isLoading && !forceShowContent {
                LoadingView()
                    .task {
                        // Safety timeout: Force show content after 4 seconds
                        do {
                            try await Task.sleep(nanoseconds: 4_000_000_000)
                        } catch {
                            // Task was cancelled, which is fine
                            return
                        }
                        if authService.isLoading {
                            AppLogger.warning("⚠️ Loading timeout reached, forcing content display")
                            await MainActor.run {
                                forceShowContent = true
                                // If still loading, stop it
                                authService.isLoading = false
                            }
                        }
                    }
            } else if authService.isAuthenticated {
                MainTabView()
            } else {
                SignInView()
            }
        }
    }
}

// MARK: - Main Tab View

struct MainTabView: View {
    @State private var selectedTab: Tab = .home
    @EnvironmentObject var learningDataService: LearningDataService
    @State private var initializationAttempted = false
    
    enum Tab {
        case home
        case practice
        case flashcards
        case games
        case profile
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: selectedTab == .home ? "house.fill" : "house")
                }
                .tag(Tab.home)
            
            PracticeView()
                .tabItem {
                    Label("Practice", systemImage: selectedTab == .practice ? "book.fill" : "book")
                }
                .tag(Tab.practice)
            
            FlashcardsListView()
                .tabItem {
                    Label("Flashcards", systemImage: selectedTab == .flashcards ? "rectangle.stack.fill" : "rectangle.stack")
                }
                .tag(Tab.flashcards)
            
            GamesView()
                .tabItem {
                    Label("Games", systemImage: selectedTab == .games ? "gamecontroller.fill" : "gamecontroller")
                }
                .tag(Tab.games)
            
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: selectedTab == .profile ? "person.fill" : "person")
                }
                .tag(Tab.profile)
        }
        .accentColor(AppTheme.brandPrimary)
        .task {
            guard !initializationAttempted else { return }
            initializationAttempted = true
            
            AppLogger.info("🚀 ========== APP INITIALIZATION START ==========")
            AppLogger.info("📍 Current thread: \(Thread.isMainThread ? "MAIN" : "BACKGROUND")")
            AppLogger.info("📂 Bundle path: \(Bundle.main.resourcePath ?? "NONE")")
            
            // List all JSON files
            if let resourcePath = Bundle.main.resourcePath {
                if let files = try? FileManager.default.contentsOfDirectory(atPath: resourcePath) {
                    let jsonFiles = files.filter { $0.hasSuffix(".json") }
                    AppLogger.info("📋 JSON files found: \(jsonFiles.count)")
                    for file in jsonFiles {
                        if let url = Bundle.main.url(forResource: file.replacingOccurrences(of: ".json", with: ""), withExtension: "json") {
                            let size = (try? Data(contentsOf: url).count) ?? 0
                            AppLogger.info("   ✅ \(file) (\(size) bytes)")
                        }
                    }
                }
            }
            
            AppLogger.info("📊 BEFORE initialization:")
            AppLogger.info("   - Current level: \(learningDataService.currentLevel.rawValue)")
            AppLogger.info("   - Flashcards: \(learningDataService.flashcards.count)")
            AppLogger.info("   - Grammar: \(learningDataService.grammarPoints.count)")
            AppLogger.info("   - Kanji: \(learningDataService.kanji.count)")
            
            await learningDataService.initialize()
            
            AppLogger.info("📊 AFTER initialization:")
            AppLogger.info("   - Current level: \(learningDataService.currentLevel.rawValue)")
            AppLogger.info("   - Flashcards: \(learningDataService.flashcards.count)")
            AppLogger.info("   - Grammar: \(learningDataService.grammarPoints.count)")
            AppLogger.info("   - Kanji: \(learningDataService.kanji.count)")
            AppLogger.info("   - Practice: \(learningDataService.practiceQuestions.count)")
            AppLogger.info("   - Games: \(learningDataService.games.count)")
            
            if learningDataService.flashcards.isEmpty {
                AppLogger.error("❌❌❌ CRITICAL: STILL NO DATA AFTER INITIALIZATION!")
            } else {
                AppLogger.info("✅✅✅ SUCCESS: Data loaded correctly!")
            }
            
            AppLogger.info("🏁 ========== APP INITIALIZATION END ==========")
        }
    }
}

// MARK: - Loading View

struct LoadingView: View {
    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()
            
            VStack(spacing: 24) {
                ProgressView()
                    .scaleEffect(1.5)
                    .tint(AppTheme.brandPrimary)
                
                Text("こんにちは...")
                    .font(.system(size: 36, weight: .medium))
                    .foregroundColor(AppTheme.brandPrimary)
                
                Text("Loading")
                    .font(AppTheme.Typography.headline)
                    .foregroundColor(AppTheme.mutedText)
            }
        }
    }
}
