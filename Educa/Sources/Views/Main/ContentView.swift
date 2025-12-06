//
//  ContentView.swift
//  Educa
//
//  Premium main app container with custom tab bar and data-driven onboarding
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var dataService: DataService
    @StateObject private var notificationsManager = NotificationsManager.shared
    @State private var showOnboarding = false
    @State private var hasLoadedData = false
    
    var body: some View {
        mainContent
            .fullScreenCover(isPresented: $showOnboarding) {
                OnboardingView(showOnboarding: $showOnboarding)
                    .environmentObject(appState)
                    .environmentObject(dataService)
            }
            .onChange(of: showOnboarding) { _, isShowing in
                // When onboarding completes, load data for selected country
                if !isShowing && appState.hasCompletedOnboarding {
                    loadUserData()
                }
            }
            .onChange(of: appState.selectedCountry) { _, newCountry in
                // When country changes, reload data
                if let country = newCountry {
                    Task {
                        await dataService.loadCountryData(for: country)
                    }
                }
            }
            .onAppear {
                if !appState.hasCompletedOnboarding {
                    showOnboarding = true
                } else if !hasLoadedData {
                    loadUserData()
                }
            }
            .environmentObject(notificationsManager)
    }
    
    private var mainContent: some View {
        ZStack(alignment: .bottom) {
            // Main Content
            TabView(selection: $appState.selectedTab) {
                HomeView()
                    .tag(AppState.Tab.home)
                
                StudyHubView()
                    .tag(AppState.Tab.studyHub)
                
                JourneyView()
                    .tag(AppState.Tab.journey)
                
                PlacementView()
                    .tag(AppState.Tab.placement)
                
                RemittanceTabView()
                    .tag(AppState.Tab.remittance)
            }
            .toolbar(.hidden, for: .tabBar)
            
            // Custom Tab Bar (5 tabs - Profile is in top-right menu)
            CustomTabBar(selectedTab: $appState.selectedTab)
            
            // Toast Overlay
            if appState.showToast {
                VStack {
                    ToastView(
                        message: appState.toastMessage,
                        icon: appState.toastType.icon,
                        type: appState.toastType
                    )
                    .padding(.top, 60)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    
                    Spacer()
                }
                .animation(.spring(response: 0.4, dampingFraction: 0.8), value: appState.showToast)
            }
        }
        .ignoresSafeArea(edges: .bottom)
    }
    
    // MARK: - Load Data Based on User Preferences
    
    private func loadUserData() {
        hasLoadedData = true
        Task {
            await dataService.loadDataForUserPreferences(
                destination: appState.selectedCountry,
                homeCountry: appState.homeCountry
            )
        }
    }
}

// MARK: - Custom Tab Bar

struct CustomTabBar: View {
    @Binding var selectedTab: AppState.Tab
    @State private var animateSelection = false
    
    private let tabs: [(tab: AppState.Tab, icon: String, selectedIcon: String, label: String)] = [
        (.home, "house", "house.fill", "Home"),
        (.studyHub, "book", "book.fill", "Study"),
        (.journey, "airplane", "airplane.departure", "Journey"),
        (.placement, "briefcase", "briefcase.fill", "Jobs"),
        (.remittance, "dollarsign.circle", "dollarsign.circle.fill", "Remit")
    ]
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(tabs, id: \.tab) { item in
                TabBarButton(
                    icon: selectedTab == item.tab ? item.selectedIcon : item.icon,
                    label: item.label,
                    isSelected: selectedTab == item.tab
                ) {
                    HapticManager.shared.selection()
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedTab = item.tab
                    }
                }
            }
        }
        .padding(.horizontal, Spacing.md)
        .padding(.top, Spacing.sm)
        .padding(.bottom, 24)
        .background(
            TabBarBackground()
        )
    }
}

// MARK: - Tab Bar Button

struct TabBarButton: View {
    let icon: String
    let label: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: Spacing.xxs) {
                ZStack {
                    // Selection indicator
                    if isSelected {
                        Circle()
                            .fill(Color.brand.opacity(0.15))
                            .frame(width: 48, height: 48)
                            .transition(.scale.combined(with: .opacity))
                    }
                    
                    Image(systemName: icon)
                        .font(.system(size: 20, weight: isSelected ? .semibold : .regular))
                        .foregroundColor(isSelected ? .brand : .textSecondary)
                        .frame(width: 48, height: 48)
                }
                .frame(height: 48)
                
                Text(label)
                    .font(.system(size: 10, weight: isSelected ? .semibold : .medium))
                    .foregroundColor(isSelected ? .brand : .textTertiary)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(TabBarButtonStyle())
    }
}

struct TabBarButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
            .animation(.spring(response: 0.3), value: configuration.isPressed)
    }
}

// MARK: - Tab Bar Background

struct TabBarBackground: View {
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            // Blur background
            if colorScheme == .dark {
                Rectangle()
                    .fill(.ultraThinMaterial)
            } else {
                Rectangle()
                    .fill(Color.white.opacity(0.9))
                    .background(.ultraThinMaterial)
            }
            
            // Top border
            VStack {
                Rectangle()
                    .fill(Color.cardBorder)
                    .frame(height: 0.5)
                Spacer()
            }
        }
        .shadow(color: .black.opacity(0.08), radius: 20, x: 0, y: -5)
    }
}

// MARK: - Floating Tab Bar (Alternative Style)

struct FloatingTabBar: View {
    @Binding var selectedTab: AppState.Tab
    
    private let tabs: [(tab: AppState.Tab, icon: String, selectedIcon: String)] = [
        (.home, "house", "house.fill"),
        (.studyHub, "book", "book.fill"),
        (.journey, "airplane", "airplane.departure"),
        (.placement, "briefcase", "briefcase.fill"),
        (.remittance, "dollarsign.circle", "dollarsign.circle.fill")
    ]
    
    var body: some View {
        HStack(spacing: Spacing.lg) {
            ForEach(tabs, id: \.tab) { item in
                Button {
                    HapticManager.shared.selection()
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedTab = item.tab
                    }
                } label: {
                    ZStack {
                        if selectedTab == item.tab {
                            Capsule()
                                .fill(Color.brand)
                                .frame(width: 56, height: 36)
                                .transition(.scale.combined(with: .opacity))
                        }
                        
                        Image(systemName: selectedTab == item.tab ? item.selectedIcon : item.icon)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(selectedTab == item.tab ? .white : .textSecondary)
                    }
                    .frame(width: 56, height: 36)
                }
            }
        }
        .padding(.horizontal, Spacing.lg)
        .padding(.vertical, Spacing.sm)
        .background(
            Capsule()
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.15), radius: 20, x: 0, y: 10)
        )
        .padding(.bottom, Spacing.xl)
    }
}

#Preview {
    ContentView()
        .environmentObject(AppState())
        .environmentObject(DataService.shared)
}
