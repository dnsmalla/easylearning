import SwiftUI
import GoogleSignInSwift

// Minimal design tokens for professional look (self-contained)
private enum TemplateTheme {
    static let brand = Color(red: 0.20, green: 0.42, blue: 0.94)
    static let spacing: CGFloat = 16
    static let cornerRadius: CGFloat = 20
    static let buttonHeight: CGFloat = 48
}

public struct LoginView: View {
    @ObservedObject var auth: AuthService = .shared
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isLoading: Bool = false
    @State private var error: String? = nil
    @State private var showPassword: Bool = false
    @State private var isSignUp: Bool = false

    public init() {}

    public var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                LinearGradient(colors: [TemplateTheme.brand.opacity(0.85), .teal.opacity(0.85)], startPoint: .topLeading, endPoint: .bottomTrailing)
                    .frame(height: 250)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: TemplateTheme.spacing) {
                        VStack(spacing: 8) {
                            Text(isSignUp ? "Create your account" : "Welcome back")
                                .font(.title.weight(.bold))
                            Text(isSignUp ? "Join and start managing your contacts" : "Sign in to continue to your account")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                        }

                        VStack(spacing: 12) {
                            if let error {
                                HStack(spacing: 12) {
                                    Image(systemName: "exclamationmark.triangle.fill").foregroundStyle(.red)
                                    Text(error).font(.subheadline).foregroundStyle(.red)
                                    Spacer()
                                }
                                .padding(12)
                                .background(Color.red.opacity(0.08))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }

                            GoogleSignInButton(scheme: .light, style: .wide, state: isLoading ? .disabled : .normal) {
                                withAnimation(.easeInOut(duration: 0.2)) { isLoading = true; error = nil }
                                auth.signInWithGoogle { _ in withAnimation(.easeInOut(duration: 0.2)) { isLoading = false } }
                            }
                            .frame(maxWidth: .infinity, minHeight: TemplateTheme.buttonHeight)
                            .shadow(color: .black.opacity(0.04), radius: 8, y: 2)

                            HStack(spacing: 12) {
                                VStack { Divider() }
                                Text("or continue with email").font(.caption2).foregroundStyle(.secondary)
                                VStack { Divider() }
                            }

                            // Email field
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Email").font(.subheadline).fontWeight(.semibold)
                                HStack(spacing: 12) {
                                    Image(systemName: "envelope.fill").foregroundStyle(.secondary)
                                    TextField("Enter your email address", text: $email)
                                        .textInputAutocapitalization(.never)
                                        .autocorrectionDisabled()
                                        .keyboardType(.emailAddress)
                                }
                                .padding(.horizontal, 14)
                                .padding(.vertical, 12)
                                .background(Color(uiColor: .secondarySystemBackground))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }

                            // Password field
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Password").font(.subheadline).fontWeight(.semibold)
                                ZStack(alignment: .trailing) {
                                    HStack(spacing: 12) {
                                        Image(systemName: "lock.fill").foregroundStyle(.secondary)
                                        Group {
                                            if showPassword {
                                                TextField("Enter your password", text: $password)
                                            } else {
                                                SecureField("Enter your password", text: $password)
                                            }
                                        }
                                    }
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 12)
                                    .background(Color(uiColor: .secondarySystemBackground))
                                    .clipShape(RoundedRectangle(cornerRadius: 12))

                                    Button { withAnimation(.easeInOut(duration: 0.2)) { showPassword.toggle() } } label: {
                                        Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                                            .foregroundStyle(.secondary)
                                            .padding(.trailing, 20)
                                    }
                                }
                            }

                            // Primary action
                            Button {
                                withAnimation(.easeInOut(duration: 0.2)) { isLoading = true; error = nil }
                                if isSignUp {
                                    auth.signUp(email: email, password: password) { ok in
                                        withAnimation(.easeInOut(duration: 0.2)) { isLoading = false }
                                        if !ok { error = "Sign up failed. Please try again." }
                                    }
                                } else {
                                    auth.signIn(email: email, password: password) { ok in
                                        withAnimation(.easeInOut(duration: 0.2)) { isLoading = false }
                                        if !ok { error = "Invalid email or password." }
                                    }
                                }
                            } label: {
                                HStack(spacing: 12) {
                                    if isLoading { ProgressView().progressViewStyle(.circular).tint(.white) }
                                    Text(isSignUp ? "Create Account" : "Sign In").font(.headline).fontWeight(.semibold)
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: TemplateTheme.buttonHeight)
                            }
                            .buttonStyle(.borderedProminent)
                            .disabled(isLoading || email.isEmpty || password.isEmpty)

                            // Biometrics
                            Button {
                                withAnimation(.easeInOut(duration: 0.2)) { isLoading = true; error = nil }
                                auth.signInWithBiometrics { _ in withAnimation(.easeInOut(duration: 0.2)) { isLoading = false } }
                            } label: {
                                Label("Use Face ID / Touch ID", systemImage: "faceid")
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 44)
                            }
                            .buttonStyle(.bordered)

                            // Toggle
                            HStack(spacing: 4) {
                                Text(isSignUp ? "Already have an account?" : "Don't have an account?")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Button(isSignUp ? "Sign in" : "Sign up") {
                                    withAnimation(.easeInOut(duration: 0.3)) { isSignUp.toggle(); error = nil; email = ""; password = "" }
                                }
                                .font(.caption.weight(.semibold))
                            }
                            .padding(.top, 4)
                        }
                        .padding(20)
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: TemplateTheme.cornerRadius))
                        .overlay(RoundedRectangle(cornerRadius: TemplateTheme.cornerRadius).strokeBorder(.white.opacity(0.2), lineWidth: 1))
                        .shadow(color: .black.opacity(0.1), radius: 24, y: 8)
                        .padding(.horizontal, 20)
                    }
                    .padding(.top, 12)
                    .padding(.bottom, 20)
                }
            }
            .navigationTitle("")
            .toolbar(.hidden, for: .navigationBar)
        }
        .animation(.easeInOut(duration: 0.3), value: isSignUp)
        .animation(.easeInOut(duration: 0.2), value: error)
    }
}


