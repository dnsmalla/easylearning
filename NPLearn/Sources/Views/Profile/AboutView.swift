//
//  AboutView.swift
//  NPLearn
//
//  About the app, version, and credits
//

import SwiftUI

// MARK: - About View

struct AboutView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                // App Icon and Name
                VStack(spacing: 16) {
                    // You can replace this with actual app icon if available
                    ZStack {
                        RoundedRectangle(cornerRadius: 24)
                            .fill(LinearGradient(
                                colors: [AppTheme.brandPrimary, AppTheme.brandSecondary],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))
                            .frame(width: 100, height: 100)
                        
                        Text("नेपाली")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .shadow(color: AppTheme.brandPrimary.opacity(0.3), radius: 12, y: 8)
                    
                    Text("NPLearn")
                        .font(AppTheme.Typography.largeTitle)
                    
                    Text("Master Nepali Language")
                        .font(AppTheme.Typography.body)
                        .foregroundColor(AppTheme.mutedText)
                    
                    Text("Version 1.0")
                        .font(AppTheme.Typography.caption)
                        .foregroundColor(AppTheme.mutedText)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(AppTheme.secondaryBackground)
                        .clipShape(Capsule())
                }
                .padding(.vertical, 20)
                
                // Mission Statement
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "heart.fill")
                            .foregroundColor(AppTheme.danger)
                        Text("Our Mission")
                            .font(AppTheme.Typography.title2)
                    }
                    
                    Text("NPLearn is dedicated to making Nepali language learning accessible, engaging, and effective for everyone. Whether you're connecting with your heritage, preparing for travel, or expanding your linguistic skills, we're here to help you succeed.")
                        .font(AppTheme.Typography.body)
                        .foregroundColor(AppTheme.mutedText)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding()
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shadow(color: Color.black.opacity(0.05), radius: 4, y: 2)
                .padding(.horizontal, AppTheme.Layout.horizontalPadding)
                
                // What Makes Us Special
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Image(systemName: "star.fill")
                            .foregroundColor(AppTheme.brandGold)
                        Text("What Makes Us Special")
                            .font(AppTheme.Typography.title2)
                    }
                    .padding(.horizontal, AppTheme.Layout.horizontalPadding)
                    
                    VStack(spacing: 12) {
                        SpecialFeatureCard(
                            icon: "brain.head.profile",
                            title: "Comprehensive Learning",
                            description: "All six language skills in one app: reading, writing, listening, speaking, vocabulary, and grammar",
                            color: AppTheme.vocabularyColor
                        )
                        
                        SpecialFeatureCard(
                            icon: "textformat.abc",
                            title: "Devanagari Mastery",
                            description: "Complete guide to learning and practicing the Nepali script with interactive writing practice",
                            color: AppTheme.writingColor
                        )
                        
                        SpecialFeatureCard(
                            icon: "speaker.wave.2.fill",
                            title: "Native Audio",
                            description: "Learn authentic pronunciation with native Nepali speaker recordings",
                            color: AppTheme.listeningColor
                        )
                        
                        SpecialFeatureCard(
                            icon: "gamecontroller.fill",
                            title: "Fun & Interactive",
                            description: "Games and interactive exercises make learning enjoyable and engaging",
                            color: AppTheme.speakingColor
                        )
                        
                        SpecialFeatureCard(
                            icon: "heart.fill",
                            title: "100% Free",
                            description: "All features available at no cost. Quality education should be accessible to everyone",
                            color: AppTheme.danger
                        )
                        
                        SpecialFeatureCard(
                            icon: "lock.shield.fill",
                            title: "Privacy Focused",
                            description: "Your data is secure and private. We never sell your information",
                            color: AppTheme.info
                        )
                    }
                }
                .padding(.horizontal, AppTheme.Layout.horizontalPadding)
                
                // Technology
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "cpu.fill")
                            .foregroundColor(AppTheme.brandPrimary)
                        Text("Built With")
                            .font(AppTheme.Typography.title2)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        TechnologyRow(name: "SwiftUI", description: "Modern UI Framework")
                        TechnologyRow(name: "Firebase", description: "Secure Backend")
                        TechnologyRow(name: "AVFoundation", description: "Audio & Speech")
                        TechnologyRow(name: "Combine", description: "Reactive Programming")
                    }
                }
                .padding()
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shadow(color: Color.black.opacity(0.05), radius: 4, y: 2)
                .padding(.horizontal, AppTheme.Layout.horizontalPadding)
                
                // Contact & Support
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Image(systemName: "envelope.fill")
                            .foregroundColor(AppTheme.brandPrimary)
                        Text("Get in Touch")
                            .font(AppTheme.Typography.title2)
                    }
                    .padding(.horizontal, AppTheme.Layout.horizontalPadding)
                    
                    VStack(spacing: 12) {
                        ContactCard(
                            icon: "envelope.fill",
                            title: "Email Support",
                            detail: "support@nplearn.app",
                            action: {
                                if let url = URL(string: "mailto:support@nplearn.app") {
                                    UIApplication.shared.open(url)
                                }
                            }
                        )
                        
                        ContactCard(
                            icon: "exclamationmark.bubble.fill",
                            title: "Report a Bug",
                            detail: "Help us improve",
                            action: {
                                if let url = URL(string: "mailto:support@nplearn.app?subject=Bug%20Report") {
                                    UIApplication.shared.open(url)
                                }
                            }
                        )
                        
                        ContactCard(
                            icon: "lightbulb.fill",
                            title: "Suggest a Feature",
                            detail: "We'd love to hear your ideas",
                            action: {
                                if let url = URL(string: "mailto:support@nplearn.app?subject=Feature%20Suggestion") {
                                    UIApplication.shared.open(url)
                                }
                            }
                        )
                    }
                }
                .padding(.horizontal, AppTheme.Layout.horizontalPadding)
                
                // Legal
                VStack(spacing: 12) {
                    Button(action: {
                        // Privacy Policy
                    }) {
                        Text("Privacy Policy")
                            .font(AppTheme.Typography.caption)
                            .foregroundColor(AppTheme.brandPrimary)
                    }
                    
                    Button(action: {
                        // Terms of Service
                    }) {
                        Text("Terms of Service")
                            .font(AppTheme.Typography.caption)
                            .foregroundColor(AppTheme.brandPrimary)
                    }
                }
                
                // Footer
                VStack(spacing: 8) {
                    Text("Made with ❤️ for Nepali learners")
                        .font(AppTheme.Typography.caption)
                        .foregroundColor(AppTheme.mutedText)
                    
                    Text("© 2025 NPLearn. All rights reserved.")
                        .font(AppTheme.Typography.caption2)
                        .foregroundColor(AppTheme.mutedText)
                }
                .padding(.top, 8)
            }
            .padding(.vertical, 24)
        }
        .background(AppTheme.background)
        .navigationTitle("About")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Special Feature Card

struct SpecialFeatureCard: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 44, height: 44)
                
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(color)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(AppTheme.Typography.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(AppTheme.Typography.caption)
                    .foregroundColor(AppTheme.mutedText)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding()
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: Color.black.opacity(0.05), radius: 4, y: 2)
    }
}

// MARK: - Technology Row

struct TechnologyRow: View {
    let name: String
    let description: String
    
    var body: some View {
        HStack {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(AppTheme.success)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .font(AppTheme.Typography.subheadline)
                    .fontWeight(.medium)
                
                Text(description)
                    .font(AppTheme.Typography.caption2)
                    .foregroundColor(AppTheme.mutedText)
            }
            
            Spacer()
        }
    }
}

// MARK: - Contact Card

struct ContactCard: View {
    let icon: String
    let title: String
    let detail: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(AppTheme.brandPrimary.opacity(0.15))
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: icon)
                        .font(.system(size: 20))
                        .foregroundColor(AppTheme.brandPrimary)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(AppTheme.Typography.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Text(detail)
                        .font(AppTheme.Typography.caption)
                        .foregroundColor(AppTheme.mutedText)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14)) // Changed from 12 for better visibility
                    .foregroundColor(AppTheme.mutedText)
            }
            .padding()
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(color: Color.black.opacity(0.05), radius: 4, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    NavigationStack {
        AboutView()
    }
}

