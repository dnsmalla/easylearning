//
//  SpiceBiteApp.swift
//  SpiceBite
//
//  Indian & Nepali Restaurant Comparison App (Worldwide)
//

import SwiftUI

@main
struct SpiceBiteApp: App {
    @StateObject private var appState = AppState()
    @StateObject private var dataService = DataService.shared
    @StateObject private var locationService = LocationService.shared
    
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var showOnboarding = false
    
    init() {
        configureAppearance()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .environmentObject(dataService)
                .environmentObject(locationService)
                .preferredColorScheme(appState.useSystemTheme ? nil : (appState.isDarkMode ? .dark : .light))
                .task {
                    await initializeApp()
                }
                .fullScreenCover(isPresented: $showOnboarding) {
                    OnboardingView(showOnboarding: $showOnboarding)
                        .environmentObject(appState)
                }
                .onAppear {
                    if !hasCompletedOnboarding {
                        showOnboarding = true
                    }
                }
                .overlay {
                    // Toast Overlay
                    if appState.showToast, let message = appState.toastMessage {
                        VStack {
                            Spacer()
                            ToastView(message: message)
                                .padding(.bottom, 100)
                        }
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .animation(.spring(response: 0.3), value: appState.showToast)
                    }
                }
        }
    }
    
    private func initializeApp() async {
        locationService.requestAuthorization()
        locationService.startUpdating()
        await dataService.loadAllData()
    }
    
    private func configureAppearance() {
        // Navigation Bar
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.systemBackground
        appearance.titleTextAttributes = [
            .font: UIFont.systemFont(ofSize: 18, weight: .semibold)
        ]
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        
        // Tab Bar
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        UITabBar.appearance().standardAppearance = tabBarAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
    }
}

// MARK: - Toast View

struct ToastView: View {
    let message: String
    
    var body: some View {
        Text(message)
            .font(.appSubheadline)
            .fontWeight(.medium)
            .foregroundColor(.white)
            .padding(.horizontal, Spacing.lg)
            .padding(.vertical, Spacing.md)
            .background(Color.black.opacity(0.85))
            .clipShape(Capsule())
            .shadow(radius: 10)
    }
}

// MARK: - Onboarding View

struct OnboardingView: View {
    @Binding var showOnboarding: Bool
    @EnvironmentObject var appState: AppState
    @State private var currentPage = 0
    
    let pages = [
        OnboardingPage(
            icon: "🍛",
            title: "Discover Authentic Flavors",
            description: "Find the best Indian and Nepali restaurants worldwide, from big cities to hidden gems.",
            color: Color.brand
        ),
        OnboardingPage(
            icon: "🔍",
            title: "Compare & Choose",
            description: "Side-by-side comparison of prices, ratings, menus, and features to find your perfect dining spot.",
            color: Color.secondary
        ),
        OnboardingPage(
            icon: "⭐",
            title: "Read Real Reviews",
            description: "Honest reviews from the Nepali and Indian community. Know what to expect before you go.",
            color: Color.accent
        ),
        OnboardingPage(
            icon: "🇳🇵🇮🇳",
            title: "Your Taste of Home",
            description: "Whether you crave Nepali momo or South Indian dosa, find it all in SpiceBite.",
            color: Color.tertiary
        )
    ]
    
    var body: some View {
        ZStack {
            Color.backgroundPrimary.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Page Content
                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        OnboardingPageView(page: pages[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                
                // Bottom Section
                VStack(spacing: Spacing.lg) {
                    // Page Indicator
                    HStack(spacing: Spacing.xs) {
                        ForEach(0..<pages.count, id: \.self) { index in
                            Circle()
                                .fill(index == currentPage ? Color.brand : Color.gray.opacity(0.3))
                                .frame(width: 8, height: 8)
                                .animation(.smoothSpring, value: currentPage)
                        }
                    }
                    
                    // Buttons
                    if currentPage == pages.count - 1 {
                        Button("Get Started") {
                            HapticManager.shared.medium()
                            appState.hasCompletedOnboarding = true
                            showOnboarding = false
                        }
                        .buttonStyle(PrimaryButtonStyle(isFullWidth: true))
                    } else {
                        HStack(spacing: Spacing.md) {
                            Button("Skip") {
                                HapticManager.shared.tap()
                                appState.hasCompletedOnboarding = true
                                showOnboarding = false
                            }
                            .font(.appSubheadline)
                            .foregroundColor(.textSecondary)
                            .frame(maxWidth: .infinity)
                            
                            Button("Next") {
                                HapticManager.shared.tap()
                                withAnimation {
                                    currentPage += 1
                                }
                            }
                            .buttonStyle(PrimaryButtonStyle(isFullWidth: true))
                        }
                    }
                }
                .padding(.horizontal, Spacing.xl)
                .padding(.bottom, Spacing.xxl)
            }
        }
    }
}

struct OnboardingPage {
    let icon: String
    let title: String
    let description: String
    let color: Color
}

struct OnboardingPageView: View {
    let page: OnboardingPage
    
    var body: some View {
        VStack(spacing: Spacing.xxl) {
            Spacer()
            
            // Icon
            Text(page.icon)
                .font(.system(size: 80))
                .padding(Spacing.xxl)
                .background(
                    Circle()
                        .fill(page.color.opacity(0.15))
                )
            
            VStack(spacing: Spacing.md) {
                Text(page.title)
                    .font(.appTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.textPrimary)
                    .multilineTextAlignment(.center)
                
                Text(page.description)
                    .font(.appBody)
                    .foregroundColor(.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, Spacing.lg)
            }
            
            Spacer()
            Spacer()
        }
        .padding(Spacing.xl)
    }
}
