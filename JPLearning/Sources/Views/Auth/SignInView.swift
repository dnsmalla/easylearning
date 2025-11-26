//
//  SignInView.swift
//  JLearn
//
//  Authentication view for sign in and sign up
//

import SwiftUI

struct SignInView: View {
    @EnvironmentObject var authService: AuthService
    
    @State private var email = ""
    @State private var password = ""
    @State private var isSignUp = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                AppTheme.heroGradient
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 32) {
                        // Logo/Title
                        VStack(spacing: 16) {
                            Text("JLearn")
                                .font(AppTheme.Typography.largeTitle)
                                .foregroundColor(.white)
                            
                            Text("Master Japanese Language")
                                .font(AppTheme.Typography.title3)
                                .foregroundColor(.white.opacity(0.9))
                        }
                        .padding(.top, 60)
                        
                        // Sign In Card
                        VStack(spacing: 24) {
                            // Guest Mode Button - PROMINENT for App Review
                            VStack(spacing: 8) {
                                Button(action: continueAsGuestTapped) {
                                    HStack(spacing: 12) {
                                        Image(systemName: "person.crop.circle.fill")
                                            .font(.title2)
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text("Continue as Guest")
                                                .font(AppTheme.Typography.headline)
                                            Text("Try the app instantly - no account needed")
                                                .font(AppTheme.Typography.caption)
                                                .opacity(0.9)
                                        }
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .foregroundColor(.white)
                                    .background(
                                        LinearGradient(
                                            colors: [AppTheme.brandPrimary, AppTheme.brandPrimary.opacity(0.8)],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .cornerRadius(AppTheme.Layout.cornerRadius)
                                    .shadow(color: AppTheme.brandPrimary.opacity(0.3), radius: 8, y: 4)
                                }
                                .disabled(authService.isLoading)
                                
                                Text("✨ Full access to all features • No sign-up required")
                                    .font(AppTheme.Typography.caption)
                                    .foregroundColor(AppTheme.mutedText)
                                    .multilineTextAlignment(.center)
                            }
                            
                            // Divider
                            HStack {
                                Rectangle()
                                    .fill(AppTheme.separator)
                                    .frame(height: 1)
                                Text("OR SIGN IN")
                                    .font(AppTheme.Typography.caption)
                                    .foregroundColor(AppTheme.mutedText)
                                Rectangle()
                                    .fill(AppTheme.separator)
                                    .frame(height: 1)
                            }
                            
                            // Email TextField
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Email")
                                    .font(AppTheme.Typography.subheadline)
                                    .foregroundColor(AppTheme.mutedText)
                                
                                TextField("your@email.com", text: $email)
                                    .textFieldStyle(.plain)
                                    .padding()
                                    .background(AppTheme.secondaryBackground)
                                    .cornerRadius(AppTheme.Layout.cornerRadius)
                                    .keyboardType(.emailAddress)
                                    .autocapitalization(.none)
                                    .disabled(authService.isLoading)
                            }
                            
                            // Password TextField
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Password")
                                    .font(AppTheme.Typography.subheadline)
                                    .foregroundColor(AppTheme.mutedText)
                                
                                SecureField("Enter password", text: $password)
                                    .textFieldStyle(.plain)
                                    .padding()
                                    .background(AppTheme.secondaryBackground)
                                    .cornerRadius(AppTheme.Layout.cornerRadius)
                                    .disabled(authService.isLoading)
                            }
                            
                            // Sign In Button
                            Button(action: signInTapped) {
                                if authService.isLoading {
                                    ProgressView()
                                        .tint(.white)
                                } else {
                                    Text(isSignUp ? "Sign Up" : "Sign In")
                                }
                            }
                            .primaryButtonStyle()
                            .disabled(authService.isLoading || !isValidForm)
                            
                            // Toggle Sign Up/Sign In
                            Button(action: {
                                isSignUp.toggle()
                            }) {
                                Text(isSignUp ? "Already have an account? Sign In" : "Don't have an account? Sign Up")
                                    .font(AppTheme.Typography.subheadline)
                                    .foregroundColor(AppTheme.brandPrimary)
                            }
                            .disabled(authService.isLoading)
                        }
                        .padding(AppTheme.Layout.horizontalPadding)
                        .background(AppTheme.background)
                        .cornerRadius(AppTheme.Layout.largeCornerRadius)
                        .padding(.horizontal, AppTheme.Layout.horizontalPadding)
                    }
                }
            }
            .alert("Error", isPresented: $showError) {
                Button("OK") {}
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private var isValidForm: Bool {
        InputValidator.isValidEmail(email) && password.count >= 6
    }
    
    private func continueAsGuestTapped() {
        Task { @MainActor in
            do {
                try await authService.continueAsGuest()
                Haptics.success()
            } catch {
                errorMessage = error.localizedDescription
                showError = true
                Haptics.error()
            }
        }
    }
    
    private func signInTapped() {
        Task { @MainActor in
            do {
                if isSignUp {
                    try await authService.signUpWithEmail(email: email, password: password)
                } else {
                    try await authService.signInWithEmail(email: email, password: password)
                }
                Haptics.success()
            } catch {
                errorMessage = error.localizedDescription
                showError = true
                Haptics.error()
            }
        }
    }
}

