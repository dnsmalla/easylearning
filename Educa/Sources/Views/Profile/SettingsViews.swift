//
//  SettingsViews.swift
//  Educa
//
//  Settings, About, and Help views
//

import SwiftUI

// MARK: - Settings View

struct SettingsView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var dataService: DataService
    @Environment(\.dismiss) private var dismiss
    @AppStorage("notificationsEnabled") private var notificationsEnabled = true
    @AppStorage("hapticFeedback") private var hapticFeedback = true
    @AppStorage("autoRefresh") private var autoRefresh = true
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = true
    @State private var showResetAlert = false
    
    var body: some View {
        NavigationStack {
            List {
                // Appearance
                Section("Appearance") {
                    Toggle(isOn: $appState.isDarkMode) {
                        Label("Dark Mode", systemImage: appState.isDarkMode ? "moon.fill" : "sun.max.fill")
                    }
                    .tint(.brand)
                    .onChange(of: appState.isDarkMode) { _, newValue in
                        HapticManager.shared.tap()
                    }
                }
                
                // App Preferences
                Section("Preferences") {
                    Toggle(isOn: $notificationsEnabled) {
                        Label("Push Notifications", systemImage: "bell.badge")
                    }
                    .tint(.brand)
                    
                    Toggle(isOn: $hapticFeedback) {
                        Label("Haptic Feedback", systemImage: "hand.tap")
                    }
                    .tint(.brand)
                    .onChange(of: hapticFeedback) { _, newValue in
                        if newValue {
                            HapticManager.shared.success()
                        }
                    }
                    
                    Toggle(isOn: $autoRefresh) {
                        Label("Auto Refresh Data", systemImage: "arrow.clockwise")
                    }
                    .tint(.brand)
                }
                
                // Data Management
                Section("Data") {
                    HStack {
                        Label("Data Version", systemImage: "doc.text")
                        Spacer()
                        Text(dataService.dataVersion)
                            .foregroundColor(.textSecondary)
                    }
                    
                    if let lastSync = dataService.lastSyncDate {
                        HStack {
                            Label("Last Sync", systemImage: "clock")
                            Spacer()
                            Text(lastSync, style: .relative)
                                .foregroundColor(.textSecondary)
                        }
                    }
                    
                    Button {
                        Task {
                            HapticManager.shared.medium()
                            await dataService.forceRefresh()
                            appState.showSuccess("Data refreshed!")
                        }
                    } label: {
                        Label("Refresh All Data", systemImage: "arrow.triangle.2.circlepath")
                    }
                    
                    Button(role: .destructive) {
                        HapticManager.shared.warning()
                        // Clear cache
                    } label: {
                        Label("Clear Cache", systemImage: "trash")
                    }
                }
                
                // Account
                Section("Account") {
                    if appState.currentUser != nil {
                        Button(role: .destructive) {
                            HapticManager.shared.warning()
                            appState.currentUser = nil
                            appState.isLoggedIn = false
                            dismiss()
                        } label: {
                            Label("Sign Out", systemImage: "rectangle.portrait.and.arrow.right")
                        }
                    } else {
                        Button {
                            // Sign in
                        } label: {
                            Label("Sign In", systemImage: "person.circle")
                        }
                    }
                }
                
                // Legal
                Section("Legal") {
                    NavigationLink {
                        LegalTextView(title: "Terms of Service", content: termsText)
                    } label: {
                        Label("Terms of Service", systemImage: "doc.text")
                    }
                    
                    NavigationLink {
                        LegalTextView(title: "Privacy Policy", content: privacyText)
                    } label: {
                        Label("Privacy Policy", systemImage: "hand.raised")
                    }
                }
                
                // Advanced
                Section("Advanced") {
                    Button {
                        HapticManager.shared.tap()
                        hasCompletedOnboarding = false
                        dismiss()
                    } label: {
                        Label("Replay Onboarding", systemImage: "arrow.counterclockwise")
                    }
                    
                    Button(role: .destructive) {
                        showResetAlert = true
                    } label: {
                        Label("Reset All Settings", systemImage: "exclamationmark.triangle")
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.brand)
                }
            }
            .alert("Reset All Settings?", isPresented: $showResetAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Reset", role: .destructive) {
                    resetAllSettings()
                }
            } message: {
                Text("This will reset all preferences to their default values. Your saved items will not be affected.")
            }
        }
    }
    
    private func resetAllSettings() {
        HapticManager.shared.warning()
        appState.isDarkMode = false
        notificationsEnabled = true
        hapticFeedback = true
        autoRefresh = true
        appState.showSuccess("Settings reset to defaults")
    }
    
    private var termsText: String {
        """
        Terms of Service for Educa App
        
        Last Updated: December 5, 2025
        
        1. Acceptance of Terms
        By using the Educa app, you agree to these terms of service.
        
        2. Use of Service
        Educa provides educational information aggregation services. The information provided is for reference only.
        
        3. User Responsibilities
        Users are responsible for verifying information with official sources before making decisions.
        
        4. Data Accuracy
        While we strive for accuracy, we cannot guarantee the completeness or currency of all information.
        
        5. Third-Party Services
        Links to external services are provided for convenience. We are not responsible for third-party content.
        
        6. Changes to Terms
        We reserve the right to modify these terms at any time.
        
        Contact: support@educaapp.com
        """
    }
    
    private var privacyText: String {
        """
        Privacy Policy for Educa App
        
        Last Updated: December 5, 2025
        
        1. Information Collection
        We collect usage data to improve our services. Personal information is only collected when you create an account.
        
        2. Data Usage
        Your data is used to personalize your experience and provide relevant recommendations.
        
        3. Data Sharing
        We do not sell your personal information. Data may be shared with service providers as necessary.
        
        4. Data Security
        We implement industry-standard security measures to protect your information.
        
        5. Your Rights
        You can request access to, correction of, or deletion of your personal data.
        
        6. Cookies
        We use cookies and similar technologies to enhance your experience.
        
        Contact: privacy@educaapp.com
        """
    }
}

// MARK: - About View

struct AboutView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.xl) {
                // Logo
                VStack(spacing: Spacing.md) {
                    ZStack {
                        Circle()
                            .fill(LinearGradient.brandGradient)
                            .frame(width: 100, height: 100)
                        
                        Image(systemName: "graduationcap.fill")
                            .font(.system(size: 44))
                            .foregroundColor(.white)
                    }
                    
                    Text("Educa")
                        .font(.appTitle)
                        .foregroundColor(.textPrimary)
                    
                    Text("Your Global Education Partner")
                        .font(.appSubheadline)
                        .foregroundColor(.textSecondary)
                    
                    Text("Version 1.0.0")
                        .font(.appCaption)
                        .foregroundColor(.textTertiary)
                }
                .padding(.top, Spacing.xxl)
                
                // Description
                VStack(alignment: .leading, spacing: Spacing.md) {
                    Text("About Educa")
                        .font(.appTitle3)
                        .foregroundColor(.textPrimary)
                    
                    Text("""
                    Educa is a comprehensive platform designed to help international students navigate their educational journey. We connect students with universities, scholarships, job opportunities, and essential services worldwide.
                    
                    Our mission is to make global education accessible and stress-free by providing reliable information and trusted service providers all in one place.
                    """)
                        .font(.appBody)
                        .foregroundColor(.textSecondary)
                }
                .padding(Spacing.lg)
                .background(Color.backgroundSecondary)
                .clipShape(RoundedRectangle(cornerRadius: CornerRadius.large))
                
                // Features
                VStack(alignment: .leading, spacing: Spacing.md) {
                    Text("Key Features")
                        .font(.appTitle3)
                        .foregroundColor(.textPrimary)
                    
                    FeatureRow(icon: "building.columns.fill", title: "Universities", description: "Browse top universities worldwide", color: .brand)
                    FeatureRow(icon: "dollarsign.circle.fill", title: "Scholarships", description: "Find funding opportunities", color: .green)
                    FeatureRow(icon: "briefcase.fill", title: "Career Services", description: "Jobs and recruitment agencies", color: .tertiary)
                    FeatureRow(icon: "airplane", title: "Travel Support", description: "Visa and travel services", color: .premium)
                    FeatureRow(icon: "banknote", title: "Remittance", description: "Send money internationally", color: .secondary)
                }
                .padding(Spacing.lg)
                .background(Color.backgroundSecondary)
                .clipShape(RoundedRectangle(cornerRadius: CornerRadius.large))
                
                // Credits
                VStack(spacing: Spacing.sm) {
                    Text("Made with ❤️ for students worldwide")
                        .font(.appSubheadline)
                        .foregroundColor(.textSecondary)
                    
                    Text("© 2025 Educa. All rights reserved.")
                        .font(.appCaption)
                        .foregroundColor(.textTertiary)
                }
                .padding(.top, Spacing.lg)
            }
            .padding(Spacing.md)
            .padding(.bottom, Spacing.xxl)
        }
        .background(Color.backgroundPrimary)
        .navigationTitle("About")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    
    var body: some View {
        HStack(spacing: Spacing.md) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 44, height: 44)
                
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(color)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.appSubheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.textPrimary)
                
                Text(description)
                    .font(.appCaption)
                    .foregroundColor(.textSecondary)
            }
            
            Spacer()
        }
    }
}

// MARK: - Help View

struct HelpView: View {
    @State private var expandedSection: String?
    
    let faqs = [
        HelpFAQ(question: "How do I save universities?", answer: "Tap the heart icon on any university card to save it. You can view saved universities in your Profile."),
        HelpFAQ(question: "How accurate is the information?", answer: "We update our data regularly from official sources. However, always verify important details with the institution directly."),
        HelpFAQ(question: "Can I compare universities?", answer: "Yes! Use the Compare feature in Study Hub to compare up to 3 universities side by side."),
        HelpFAQ(question: "How do remittance rates work?", answer: "We show indicative exchange rates from various providers. Actual rates may vary at the time of transfer."),
        HelpFAQ(question: "Is my data secure?", answer: "Yes, we use industry-standard encryption to protect your data. See our Privacy Policy for details."),
        HelpFAQ(question: "How do I contact support?", answer: "Email us at support@educaapp.com or use the feedback form below.")
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.lg) {
                // Header
                VStack(spacing: Spacing.sm) {
                    Image(systemName: "questionmark.circle.fill")
                        .font(.system(size: 50))
                        .foregroundStyle(LinearGradient.brandGradient)
                    
                    Text("How can we help?")
                        .font(.appTitle2)
                        .foregroundColor(.textPrimary)
                }
                .padding(.top, Spacing.lg)
                
                // Quick Actions
                HStack(spacing: Spacing.md) {
                    HelpActionCard(icon: "envelope.fill", title: "Email Us", color: .brand) {
                        // Open email
                    }
                    
                    HelpActionCard(icon: "bubble.left.fill", title: "Chat", color: .secondary) {
                        // Open chat
                    }
                    
                    HelpActionCard(icon: "doc.text.fill", title: "Guides", color: .tertiary) {
                        // Open guides
                    }
                }
                
                // FAQs
                VStack(alignment: .leading, spacing: Spacing.md) {
                    Text("Frequently Asked Questions")
                        .font(.appTitle3)
                        .foregroundColor(.textPrimary)
                    
                    VStack(spacing: Spacing.sm) {
                        ForEach(faqs) { faq in
                            FAQRow(faq: faq, isExpanded: expandedSection == faq.id) {
                                withAnimation(.spring(response: 0.3)) {
                                    if expandedSection == faq.id {
                                        expandedSection = nil
                                    } else {
                                        expandedSection = faq.id
                                    }
                                }
                            }
                        }
                    }
                }
                
                // Contact Info
                VStack(alignment: .leading, spacing: Spacing.md) {
                    Text("Contact Us")
                        .font(.appTitle3)
                        .foregroundColor(.textPrimary)
                    
                    VStack(spacing: Spacing.sm) {
                        ContactRow(icon: "envelope", label: "Email", value: "support@educaapp.com")
                        ContactRow(icon: "globe", label: "Website", value: "www.educaapp.com")
                        ContactRow(icon: "clock", label: "Response Time", value: "Within 24 hours")
                    }
                    .padding(Spacing.md)
                    .background(Color.backgroundSecondary)
                    .clipShape(RoundedRectangle(cornerRadius: CornerRadius.large))
                }
            }
            .padding(Spacing.md)
            .padding(.bottom, Spacing.xxl)
        }
        .background(Color.backgroundPrimary)
        .navigationTitle("Help & Support")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct HelpFAQ: Identifiable {
    let id = UUID().uuidString
    let question: String
    let answer: String
}

struct FAQRow: View {
    let faq: HelpFAQ
    let isExpanded: Bool
    let onTap: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Button(action: onTap) {
                HStack {
                    Text(faq.question)
                        .font(.appSubheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.textPrimary)
                        .multilineTextAlignment(.leading)
                    
                    Spacer()
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundColor(.textTertiary)
                }
            }
            
            if isExpanded {
                Text(faq.answer)
                    .font(.appBody)
                    .foregroundColor(.textSecondary)
                    .padding(.top, Spacing.xs)
            }
        }
        .padding(Spacing.md)
        .background(Color.backgroundSecondary)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium))
    }
}

struct HelpActionCard: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: Spacing.sm) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.15))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(color)
                }
                
                Text(title)
                    .font(.appCaption)
                    .fontWeight(.medium)
                    .foregroundColor(.textPrimary)
            }
            .frame(maxWidth: .infinity)
            .padding(Spacing.md)
            .background(Color.backgroundSecondary)
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.large))
        }
    }
}

struct ContactRow: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        HStack(spacing: Spacing.md) {
            Image(systemName: icon)
                .font(.body)
                .foregroundColor(.brand)
                .frame(width: 24)
            
            Text(label)
                .font(.appSubheadline)
                .foregroundColor(.textSecondary)
            
            Spacer()
            
            Text(value)
                .font(.appSubheadline)
                .foregroundColor(.textPrimary)
        }
    }
}

// MARK: - Legal Text View

struct LegalTextView: View {
    let title: String
    let content: String
    
    var body: some View {
        ScrollView {
            Text(content)
                .font(.appBody)
                .foregroundColor(.textSecondary)
                .padding(Spacing.md)
        }
        .background(Color.backgroundPrimary)
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Preview

#Preview {
    SettingsView()
        .environmentObject(AppState())
        .environmentObject(DataService.shared)
}

