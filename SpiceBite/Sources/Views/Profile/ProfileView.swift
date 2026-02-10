//
//  ProfileView.swift
//  SpiceBite
//
//  User profile and settings
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var dataService: DataService
    @State private var showClearDataAlert = false
    @State private var showClearSavedAlert = false
    @State private var showClearCompareAlert = false
    @State private var showRefreshAlert = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Spacing.xl) {
                    // Header
                    headerSection
                    
                    // Quick Stats
                    statsSection
                    
                    // Settings
                    settingsSection
                    
                    // Data Management
                    dataManagementSection
                    
                    // About
                    aboutSection
                }
                .padding(Spacing.md)
            }
            .safeAreaInset(edge: .bottom) {
                Color.clear.frame(height: 90) // Space for tab bar
            }
            .background(Color.backgroundPrimary)
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
            .alert("Clear Saved Restaurants", isPresented: $showClearSavedAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Clear All", role: .destructive) {
                    HapticManager.shared.warning()
                    appState.clearAllSaved()
                }
            } message: {
                Text("This will remove all \(appState.savedRestaurantIds.count) saved restaurants. This action cannot be undone.")
            }
            .alert("Clear Comparison List", isPresented: $showClearCompareAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Clear All", role: .destructive) {
                    HapticManager.shared.warning()
                    appState.clearCompare()
                }
            } message: {
                Text("This will remove all restaurants from your comparison list.")
            }
            .alert("Refresh Data", isPresented: $showRefreshAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Refresh", role: .destructive) {
                    HapticManager.shared.medium()
                    Task {
                        await dataService.forceRefresh()
                    }
                }
            } message: {
                Text("This will clear cached data and download fresh data from the server.")
            }
            .alert("Clear All Data", isPresented: $showClearDataAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Clear Everything", role: .destructive) {
                    HapticManager.shared.error()
                    clearAllData()
                }
            } message: {
                Text("This will remove all saved restaurants, comparison list, and cached data. This action cannot be undone.")
            }
        }
    }
    
    private func clearAllData() {
        // Clear saved restaurants
        appState.clearAllSaved()
        // Clear comparison list
        appState.clearCompare()
        // Reset filters
        appState.activeFilter.reset()
        // Clear cached data
        Task {
            await dataService.forceRefresh()
        }
        appState.showToastMessage("All data cleared")
    }
    
    // MARK: - Header
    
    private var headerSection: some View {
        VStack(spacing: Spacing.md) {
            // Avatar
            ZStack {
                Circle()
                    .fill(LinearGradient.brandGradient)
                    .frame(width: 80, height: 80)
                
                Text("🍛")
                    .font(.system(size: 40))
            }
            
            Text("SpiceBite User")
                .font(.appTitle3)
                .fontWeight(.bold)
                .foregroundColor(.textPrimary)
            
            Text("Finding the best flavors of home worldwide")
                .font(.appSubheadline)
                .foregroundColor(.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(Spacing.xl)
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.xl))
    }
    
    // MARK: - Stats
    
    private var statsSection: some View {
        HStack(spacing: Spacing.md) {
            ProfileStatCard(
                value: "\(appState.savedRestaurantIds.count)",
                label: "Saved",
                icon: "heart.fill",
                color: .accent
            )
            
            ProfileStatCard(
                value: "\(appState.compareList.count)",
                label: "Comparing",
                icon: "arrow.left.arrow.right",
                color: .brand
            )
            
            ProfileStatCard(
                value: "\(dataService.restaurants.count)",
                label: "Available",
                icon: "fork.knife",
                color: .tertiary
            )
        }
    }
    
    // MARK: - Settings
    
    private var settingsSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Settings")
                .font(.appHeadline)
                .foregroundColor(.textPrimary)
            
            VStack(spacing: 0) {
                // Theme
                SettingsToggle(
                    icon: "moon.circle",
                    title: "Dark Mode",
                    subtitle: appState.useSystemTheme ? "Using system setting" : nil,
                    isOn: $appState.isDarkMode,
                    disabled: appState.useSystemTheme
                )
                
                Divider().padding(.leading, 52)
                
                SettingsToggle(
                    icon: "gear",
                    title: "Use System Theme",
                    isOn: $appState.useSystemTheme
                )
                
                Divider().padding(.leading, 52)
                
                // Currency Display
                SettingsToggle(
                    icon: "indianrupeesign.circle",
                    title: "Show Price in INR",
                    isOn: Binding(
                        get: { appState.showPriceInINR },
                        set: { newValue in
                            appState.showPriceInINR = newValue
                            if newValue { appState.showPriceInNPR = false }
                        }
                    )
                )
                
                Divider().padding(.leading, 52)
                
                SettingsToggle(
                    icon: "r.circle",
                    title: "Show Price in NPR",
                    isOn: Binding(
                        get: { appState.showPriceInNPR },
                        set: { newValue in
                            appState.showPriceInNPR = newValue
                            if newValue { appState.showPriceInINR = false }
                        }
                    )
                )
            }
            .background(Color.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.large))
        }
    }
    
    // MARK: - Data Management
    
    private var dataManagementSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Data Management")
                .font(.appHeadline)
                .foregroundColor(.textPrimary)
            
            VStack(spacing: 0) {
                // Clear Saved
                SettingsButton(
                    icon: "heart.slash",
                    title: "Clear Saved Restaurants",
                    subtitle: "\(appState.savedRestaurantIds.count) saved",
                    color: .accent,
                    disabled: appState.savedRestaurantIds.isEmpty
                ) {
                    showClearSavedAlert = true
                }
                
                Divider().padding(.leading, 52)
                
                // Clear Comparison
                SettingsButton(
                    icon: "arrow.left.arrow.right.circle",
                    title: "Clear Comparison List",
                    subtitle: "\(appState.compareList.count) restaurants",
                    color: .brand,
                    disabled: appState.compareList.isEmpty
                ) {
                    showClearCompareAlert = true
                }
                
                Divider().padding(.leading, 52)
                
                // Refresh Data
                SettingsButton(
                    icon: "arrow.clockwise.circle",
                    title: "Refresh Data",
                    subtitle: dataService.lastSyncDate != nil ? "Last: \(formatDate(dataService.lastSyncDate!))" : "Never synced",
                    color: .tertiary
                ) {
                    showRefreshAlert = true
                }
                
                Divider().padding(.leading, 52)
                
                // Clear All Data
                SettingsButton(
                    icon: "trash.circle",
                    title: "Clear All Data",
                    subtitle: "Remove everything",
                    color: .red,
                    isDestructive: true
                ) {
                    showClearDataAlert = true
                }
            }
            .background(Color.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.large))
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
    
    // MARK: - About
    
    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("About")
                .font(.appHeadline)
                .foregroundColor(.textPrimary)
            
            VStack(spacing: 0) {
                SettingsLink(
                    icon: "star.circle",
                    title: "Rate App",
                    action: {}
                )
                
                Divider().padding(.leading, 52)
                
                SettingsLink(
                    icon: "square.and.arrow.up",
                    title: "Share App",
                    action: {}
                )
                
                Divider().padding(.leading, 52)
                
                SettingsLink(
                    icon: "envelope.circle",
                    title: "Contact Us",
                    action: {}
                )
                
                Divider().padding(.leading, 52)
                
                SettingsLink(
                    icon: "doc.text",
                    title: "Privacy Policy",
                    action: {}
                )
            }
            .background(Color.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.large))
            
            // Version
            HStack {
                Spacer()
                Text("SpiceBite v1.0.0")
                    .font(.appCaption)
                    .foregroundColor(.textTertiary)
                Spacer()
            }
            .padding(.top, Spacing.md)
        }
    }
}

// MARK: - Supporting Views

struct ProfileStatCard: View {
    let value: String
    let label: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: Spacing.xs) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
            
            Text(value)
                .font(.appTitle3)
                .fontWeight(.bold)
                .foregroundColor(.textPrimary)
            
            Text(label)
                .font(.appCaption2)
                .foregroundColor(.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(Spacing.md)
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.large))
    }
}

struct SettingsToggle: View {
    let icon: String
    let title: String
    var subtitle: String? = nil
    @Binding var isOn: Bool
    var disabled: Bool = false
    
    var body: some View {
        HStack(spacing: Spacing.md) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.brand)
                .frame(width: 28)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.appSubheadline)
                    .foregroundColor(disabled ? .textTertiary : .textPrimary)
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.appCaption2)
                        .foregroundColor(.textTertiary)
                }
            }
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .tint(.brand)
                .disabled(disabled)
        }
        .padding(Spacing.md)
    }
}

struct SettingsLink: View {
    let icon: String
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: Spacing.md) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(.brand)
                    .frame(width: 28)
                
                Text(title)
                    .font(.appSubheadline)
                    .foregroundColor(.textPrimary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.textTertiary)
            }
            .padding(Spacing.md)
        }
    }
}

struct SettingsButton: View {
    let icon: String
    let title: String
    var subtitle: String? = nil
    var color: Color = .brand
    var disabled: Bool = false
    var isDestructive: Bool = false
    let action: () -> Void
    
    var body: some View {
        Button {
            HapticManager.shared.tap()
            action()
        } label: {
            HStack(spacing: Spacing.md) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(disabled ? .textTertiary : (isDestructive ? .red : color))
                    .frame(width: 28)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.appSubheadline)
                        .foregroundColor(disabled ? .textTertiary : (isDestructive ? .red : .textPrimary))
                    
                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(.appCaption2)
                            .foregroundColor(.textTertiary)
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.textTertiary)
            }
            .padding(Spacing.md)
        }
        .disabled(disabled)
    }
}

#Preview {
    ProfileView()
        .environmentObject(AppState())
        .environmentObject(DataService.shared)
}
