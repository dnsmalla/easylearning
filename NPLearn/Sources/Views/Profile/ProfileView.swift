//
//  ProfileView.swift
//  NPLearn
//
//  User profile and settings
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authService: AuthService
    @EnvironmentObject var learningDataService: LearningDataService
    
    @State private var showSignOutConfirmation = false
    @State private var showDeleteAccountConfirmation = false
    @State private var showDeleteAccountError = false
    @State private var deleteErrorMessage = ""
    
    var body: some View {
        NavigationView {
            Form {
                // User Info Section
                Section {
                    HStack {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(AppTheme.brandPrimary)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(authService.currentUser?.displayName ?? "Learner")
                                .font(AppTheme.Typography.title3)
                            
                            Text(authService.currentUser?.email ?? "")
                                .font(AppTheme.Typography.caption)
                                .foregroundColor(AppTheme.mutedText)
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                // Progress Section
                Section("Progress") {
                    HStack {
                        Image(systemName: "flame.fill")
                            .foregroundColor(.orange)
                        Text("Study Streak")
                        Spacer()
                        Text("\(learningDataService.userProgress?.streak ?? 0) days")
                            .foregroundColor(AppTheme.mutedText)
                    }
                    
                    HStack {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                        Text("Total Points")
                        Spacer()
                        Text("\(learningDataService.userProgress?.totalPoints ?? 0)")
                            .foregroundColor(AppTheme.mutedText)
                    }
                    
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("Lessons Completed")
                        Spacer()
                        Text("\(learningDataService.userProgress?.completedLessons.count ?? 0)")
                            .foregroundColor(AppTheme.mutedText)
                    }
                }
                
                // Settings Section
                Section("Settings") {
                    NavigationLink(destination: Text("Settings")) {
                        Label("Preferences", systemImage: "gearshape.fill")
                    }
                    
                    NavigationLink(destination: Text("Help & Support - Feature Coming Soon!")) {
                        Label("Help & Support", systemImage: "questionmark.circle.fill")
                    }
                    
                    NavigationLink(destination: Text("How to Use Guide - Feature Coming Soon!")) {
                        Label("How to Use", systemImage: "book.fill")
                    }
                    
                    NavigationLink(destination: Text("Features Guide - Feature Coming Soon!")) {
                        Label("Features Guide", systemImage: "sparkles")
                    }
                    
                    NavigationLink(destination: AboutAppView()) {
                        Label("About NPLearn", systemImage: "info.circle.fill")
                    }
                }
                
                // Account Section
                Section("Account") {
                    Button(action: {
                        showSignOutConfirmation = true
                    }) {
                        Label("Sign Out", systemImage: "arrow.right.square.fill")
                            .foregroundColor(.orange)
                    }
                    
                    Button(action: {
                        showDeleteAccountConfirmation = true
                    }) {
                        Label("Delete Account", systemImage: "trash.fill")
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("Profile")
            .confirmationDialog("Sign Out", isPresented: $showSignOutConfirmation) {
                Button("Sign Out", role: .destructive) {
                    do {
                        try authService.signOut()
                    } catch {
                        print("Error signing out: \(error)")
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Are you sure you want to sign out?")
            }
            .confirmationDialog("Delete Account", isPresented: $showDeleteAccountConfirmation) {
                Button("Delete Account", role: .destructive) {
                    Task {
                        do {
                            try await authService.deleteAccount()
                        } catch {
                            deleteErrorMessage = error.localizedDescription
                            showDeleteAccountError = true
                        }
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Are you sure you want to permanently delete your account? This action cannot be undone. All your progress and data will be permanently deleted.")
            }
            .alert("Error Deleting Account", isPresented: $showDeleteAccountError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(deleteErrorMessage)
            }
        }
    }
}

// MARK: - Simple About View

struct AboutAppView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(spacing: 16) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 24)
                            .fill(AppTheme.heroGradient)
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
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Our Mission")
                        .font(AppTheme.Typography.title2)
                    
                    Text("NPLearn is dedicated to making Nepali language learning accessible, engaging, and effective for everyone.")
                        .font(AppTheme.Typography.body)
                        .foregroundColor(AppTheme.mutedText)
                }
                .padding()
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shadow(color: Color.black.opacity(0.05), radius: 4, y: 2)
                
                VStack(spacing: 12) {
                    Button(action: {
                        if let url = URL(string: "mailto:support@nplearn.app") {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        HStack {
                            Image(systemName: "envelope.fill")
                            Text("Contact Support")
                        }
                        .font(AppTheme.Typography.button)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(AppTheme.brandPrimary)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    
                    Text("support@nplearn.app")
                        .font(AppTheme.Typography.caption)
                        .foregroundColor(AppTheme.mutedText)
                }
                
                VStack(spacing: 8) {
                    Text("Made with ❤️ for Nepali learners")
                        .font(AppTheme.Typography.caption)
                        .foregroundColor(AppTheme.mutedText)
                    
                    Text("© 2025 NPLearn. All rights reserved.")
                        .font(AppTheme.Typography.caption2)
                        .foregroundColor(AppTheme.mutedText)
                }
            }
            .padding(.horizontal, AppTheme.Layout.horizontalPadding)
            .padding(.vertical, 24)
        }
        .background(AppTheme.background)
        .navigationTitle("About")
        .navigationBarTitleDisplayMode(.inline)
    }
}

