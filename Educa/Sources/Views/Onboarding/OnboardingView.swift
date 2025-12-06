//
//  OnboardingView.swift
//  Educa
//
//  Premium onboarding experience with setup wizard
//

import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var dataService: DataService
    @Binding var showOnboarding: Bool
    
    @State private var currentPhase: OnboardingPhase = .welcome
    @State private var currentPage = 0
    @State private var animateContent = false
    @State private var setupComplete = false
    
    enum OnboardingPhase {
        case welcome
        case setup
    }
    
    let pages: [OnboardingPage] = [
        OnboardingPage(
            icon: "graduationcap.fill",
            iconColor: .brand,
            title: "Welcome to Educa",
            subtitle: "Your Global Education Partner",
            description: "Discover universities, scholarships, and opportunities worldwide. We're here to guide you every step of the way.",
            backgroundGradient: [Color(hex: "0A84FF").opacity(0.15), Color(hex: "5AC8FA").opacity(0.1)]
        ),
        OnboardingPage(
            icon: "building.columns.fill",
            iconColor: .secondary,
            title: "Find Your Dream University",
            subtitle: "500+ Universities Worldwide",
            description: "Browse top universities from Japan, Australia, Canada, UK, Germany and more. Compare programs, fees, and rankings.",
            backgroundGradient: [Color(hex: "34C759").opacity(0.15), Color(hex: "5CD67A").opacity(0.1)]
        ),
        OnboardingPage(
            icon: "chart.line.uptrend.xyaxis",
            iconColor: .tertiary,
            title: "Personalized Journey",
            subtitle: "Data-Driven Guidance",
            description: "Get personalized visa info, cost estimates, scholarships, and job opportunities based on your destination.",
            backgroundGradient: [Color(hex: "FF9F0A").opacity(0.15), Color(hex: "FFB340").opacity(0.1)]
        ),
        OnboardingPage(
            icon: "sparkles",
            iconColor: .premium,
            title: "Let's Personalize!",
            subtitle: "Tell Us About Your Goals",
            description: "Choose your home country, destination, and study preferences. We'll tailor everything just for you.",
            backgroundGradient: [Color(hex: "BF5AF2").opacity(0.15), Color(hex: "9945C2").opacity(0.1)]
        )
    ]
    
    var body: some View {
        ZStack {
            switch currentPhase {
            case .welcome:
                welcomePhaseView
                    .transition(.asymmetric(
                        insertion: .opacity,
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))
                
            case .setup:
                SetupWizardView(isComplete: $setupComplete)
                    .environmentObject(appState)
                    .environmentObject(dataService)
                    .transition(.move(edge: .trailing).combined(with: .opacity))
            }
        }
        .onChange(of: setupComplete) { _, complete in
            if complete {
                completeOnboarding()
            }
        }
    }
    
    // MARK: - Welcome Phase
    
    private var welcomePhaseView: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: pages[currentPage].backgroundGradient,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 0.5), value: currentPage)
            
            VStack(spacing: 0) {
                // Skip button
                HStack {
                    Spacer()
                    if currentPage < pages.count - 1 {
                        Button {
                            HapticManager.shared.tap()
                            goToSetup()
                        } label: {
                            Text("Skip")
                                .font(.appSubheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.textSecondary)
                        }
                        .padding(.trailing, Spacing.lg)
                        .padding(.top, Spacing.md)
                    }
                }
                
                // Page content
                TabView(selection: $currentPage) {
                    ForEach(Array(pages.enumerated()), id: \.offset) { index, page in
                        OnboardingPageView(page: page, isActive: currentPage == index)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.spring(response: 0.5, dampingFraction: 0.8), value: currentPage)
                
                // Bottom section
                VStack(spacing: Spacing.xl) {
                    // Page indicators
                    HStack(spacing: Spacing.sm) {
                        ForEach(0..<pages.count, id: \.self) { index in
                            Capsule()
                                .fill(index == currentPage ? pages[currentPage].iconColor : Color.gray.opacity(0.3))
                                .frame(width: index == currentPage ? 24 : 8, height: 8)
                                .animation(.spring(response: 0.3), value: currentPage)
                        }
                    }
                    
                    // Action button
                    Button {
                        HapticManager.shared.medium()
                        if currentPage < pages.count - 1 {
                            withAnimation {
                                currentPage += 1
                            }
                        } else {
                            goToSetup()
                        }
                    } label: {
                        HStack(spacing: Spacing.sm) {
                            Text(currentPage == pages.count - 1 ? "Set Up My Profile" : "Continue")
                                .font(.appHeadline)
                                .fontWeight(.semibold)
                            
                            Image(systemName: currentPage == pages.count - 1 ? "arrow.right.circle.fill" : "chevron.right")
                                .font(.subheadline.weight(.semibold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, Spacing.md)
                        .background(
                            LinearGradient(
                                colors: [pages[currentPage].iconColor, pages[currentPage].iconColor.opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.large, style: .continuous))
                        .shadow(color: pages[currentPage].iconColor.opacity(0.3), radius: 10, x: 0, y: 5)
                    }
                    .padding(.horizontal, Spacing.xl)
                }
                .padding(.bottom, Spacing.xxl)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) {
                animateContent = true
            }
        }
    }
    
    private func goToSetup() {
        HapticManager.shared.medium()
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            currentPhase = .setup
        }
    }
    
    private func completeOnboarding() {
        HapticManager.shared.success()
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            showOnboarding = false
        }
    }
}

// MARK: - Onboarding Page Model

struct OnboardingPage {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String
    let description: String
    let backgroundGradient: [Color]
}

// MARK: - Onboarding Page View

struct OnboardingPageView: View {
    let page: OnboardingPage
    let isActive: Bool
    @State private var animateIcon = false
    
    var body: some View {
        VStack(spacing: Spacing.xl) {
            Spacer()
            
            // Icon with animation
            ZStack {
                // Outer glow
                Circle()
                    .fill(page.iconColor.opacity(0.1))
                    .frame(width: 180, height: 180)
                    .scaleEffect(animateIcon ? 1.1 : 0.9)
                    .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: animateIcon)
                
                // Inner circle
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [page.iconColor, page.iconColor.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 140, height: 140)
                    .shadow(color: page.iconColor.opacity(0.4), radius: 20, x: 0, y: 10)
                
                Image(systemName: page.icon)
                    .font(.system(size: 60, weight: .semibold))
                    .foregroundColor(.white)
                    .scaleEffect(isActive ? 1 : 0.8)
                    .animation(.spring(response: 0.5, dampingFraction: 0.7), value: isActive)
            }
            .padding(.bottom, Spacing.xl)
            
            // Text content
            VStack(spacing: Spacing.md) {
                Text(page.subtitle)
                    .font(.appSubheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(page.iconColor)
                    .opacity(isActive ? 1 : 0)
                    .offset(y: isActive ? 0 : 10)
                    .animation(.easeOut(duration: 0.4).delay(0.1), value: isActive)
                
                Text(page.title)
                    .font(.appTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.textPrimary)
                    .multilineTextAlignment(.center)
                    .opacity(isActive ? 1 : 0)
                    .offset(y: isActive ? 0 : 10)
                    .animation(.easeOut(duration: 0.4).delay(0.2), value: isActive)
                
                Text(page.description)
                    .font(.appBody)
                    .foregroundColor(.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, Spacing.xl)
                    .opacity(isActive ? 1 : 0)
                    .offset(y: isActive ? 0 : 10)
                    .animation(.easeOut(duration: 0.4).delay(0.3), value: isActive)
            }
            
            Spacer()
            Spacer()
        }
        .padding(Spacing.lg)
        .onAppear {
            animateIcon = true
        }
    }
}

// MARK: - Onboarding Wrapper

struct OnboardingWrapper: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var showOnboarding = false
    
    var body: some View {
        ContentView()
            .fullScreenCover(isPresented: $showOnboarding) {
                OnboardingView(showOnboarding: $showOnboarding)
            }
            .onAppear {
                if !hasCompletedOnboarding {
                    showOnboarding = true
                }
            }
    }
}

// MARK: - Preview

#Preview {
    OnboardingView(showOnboarding: .constant(true))
        .environmentObject(AppState())
}

