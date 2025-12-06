//
//  EducaApp.swift
//  Educa - Student Information Aggregator
//
//  JSON-driven iOS app converted from Flutter
//  Enhanced with onboarding, offline mode, and improved UX
//

import SwiftUI

@main
struct EducaApp: App {
    @StateObject private var appState = AppState()
    @StateObject private var dataService = DataService.shared
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
                .preferredColorScheme(appState.isDarkMode ? .dark : .light)
                .task {
                    await dataService.loadAllData()
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
        }
    }
    
    private func configureAppearance() {
        // Configure navigation bar appearance
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.systemBackground
        appearance.titleTextAttributes = [
            .font: UIFont.systemFont(ofSize: 18, weight: .semibold),
            .foregroundColor: UIColor.label
        ]
        appearance.largeTitleTextAttributes = [
            .font: UIFont.systemFont(ofSize: 34, weight: .bold),
            .foregroundColor: UIColor.label
        ]
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        
        // Configure tab bar appearance
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        UITabBar.appearance().standardAppearance = tabBarAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
    }
}

// MARK: - App Loading View

struct AppLoadingView: View {
    @State private var isAnimating = false
    @State private var loadingText = "Loading"
    
    let loadingMessages = [
        "Loading universities...",
        "Fetching scholarships...",
        "Preparing your journey...",
        "Almost there..."
    ]
    
    var body: some View {
        ZStack {
            Color.backgroundPrimary
                .ignoresSafeArea()
            
            VStack(spacing: Spacing.xl) {
                // Animated Logo
                ZStack {
                    Circle()
                        .fill(Color.brand.opacity(0.1))
                        .frame(width: 120, height: 120)
                        .scaleEffect(isAnimating ? 1.2 : 1.0)
                        .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: isAnimating)
                    
                    Circle()
                        .fill(LinearGradient.brandGradient)
                        .frame(width: 80, height: 80)
                        .shadow(color: Color.brand.opacity(0.3), radius: 15, x: 0, y: 8)
                    
                    Image(systemName: "graduationcap.fill")
                        .font(.system(size: 36, weight: .semibold))
                        .foregroundColor(.white)
                        .rotationEffect(.degrees(isAnimating ? 10 : -10))
                        .animation(.easeInOut(duration: 1).repeatForever(autoreverses: true), value: isAnimating)
                }
                
                VStack(spacing: Spacing.sm) {
                    Text("Educa")
                        .font(.appTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.textPrimary)
                    
                    // Loading dots animation
                    HStack(spacing: 4) {
                        ForEach(0..<3, id: \.self) { index in
                            Circle()
                                .fill(Color.brand)
                                .frame(width: 8, height: 8)
                                .scaleEffect(isAnimating ? 1.0 : 0.5)
                                .animation(
                                    .easeInOut(duration: 0.6)
                                    .repeatForever(autoreverses: true)
                                    .delay(Double(index) * 0.2),
                                    value: isAnimating
                                )
                        }
                    }
                    .padding(.top, Spacing.sm)
                }
            }
        }
        .onAppear {
            isAnimating = true
        }
    }
}

// MARK: - Skeleton Loading Components

struct SkeletonCardView: View {
    @State private var isAnimating = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            // Image placeholder
            RoundedRectangle(cornerRadius: CornerRadius.large)
                .fill(Color.gray.opacity(0.2))
                .frame(height: 120)
                .shimmerEffect(isAnimating: isAnimating)
            
            // Title placeholder
            RoundedRectangle(cornerRadius: CornerRadius.xs)
                .fill(Color.gray.opacity(0.2))
                .frame(height: 16)
                .frame(maxWidth: .infinity)
                .shimmerEffect(isAnimating: isAnimating)
            
            // Subtitle placeholder
            RoundedRectangle(cornerRadius: CornerRadius.xs)
                .fill(Color.gray.opacity(0.2))
                .frame(height: 12)
                .frame(width: 120)
                .shimmerEffect(isAnimating: isAnimating)
        }
        .padding(Spacing.md)
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.xl))
        .onAppear {
            isAnimating = true
        }
    }
}

struct SkeletonListRowView: View {
    @State private var isAnimating = false
    
    var body: some View {
        HStack(spacing: Spacing.md) {
            // Avatar placeholder
            Circle()
                .fill(Color.gray.opacity(0.2))
                .frame(width: 50, height: 50)
                .shimmerEffect(isAnimating: isAnimating)
            
            VStack(alignment: .leading, spacing: Spacing.xs) {
                RoundedRectangle(cornerRadius: CornerRadius.xs)
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 14)
                    .frame(maxWidth: .infinity)
                    .shimmerEffect(isAnimating: isAnimating)
                
                RoundedRectangle(cornerRadius: CornerRadius.xs)
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 10)
                    .frame(width: 100)
                    .shimmerEffect(isAnimating: isAnimating)
            }
        }
        .padding(Spacing.md)
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.large))
        .onAppear {
            isAnimating = true
        }
    }
}

// MARK: - Shimmer Effect Modifier

extension View {
    func shimmerEffect(isAnimating: Bool) -> some View {
        self.modifier(ShimmerEffectModifier(isAnimating: isAnimating))
    }
}

struct ShimmerEffectModifier: ViewModifier {
    let isAnimating: Bool
    @State private var phase: CGFloat = 0
    
    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geometry in
                    LinearGradient(
                        colors: [
                            .clear,
                            .white.opacity(0.4),
                            .clear
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: geometry.size.width * 2)
                    .offset(x: -geometry.size.width + (geometry.size.width * 2 * phase))
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.small))
            .onAppear {
                guard isAnimating else { return }
                withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                    phase = 1
                }
            }
    }
}

