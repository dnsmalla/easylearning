//
//  ProfileView.swift
//  JLearn
//
//  Professional user profile with rich features and stats
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authService: AuthService
    @EnvironmentObject var learningDataService: LearningDataService
    @EnvironmentObject var errorHandler: ErrorHandler
    
    @State private var showingSettings = false
    @State private var showingWebSearch = false
    @State private var showingLogoutAlert = false
    @State private var showingEditProfile = false
    @State private var showingDeleteAlert = false
    @State private var isDeletingAccount = false
    @State private var deleteError: String?
    @State private var showDeleteError = false
    @State private var showingImagePicker = false
    @State private var selectedImage: UIImage?
    @State private var showingHelpSupport = false
    @State private var showingAnalytics = false
    
    var user: UserModel? {
        authService.currentUser
    }
    
    var progress: UserProgress? {
        learningDataService.userProgress
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    // Header with gradient and profile photo
                    profileHeader
                    
                    // Stats cards
                    statsSection
                    
                    // Rest of content
                    VStack(spacing: 20) {
                        quickActionsCard
                        personalInfoCard
                        preferencesCard
                        aboutCard
                        dangerZoneCard
                    }
                    .padding()
                }
            }
            .background(AppTheme.groupedBackground)
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
            .sheet(isPresented: $showingWebSearch) {
                WebSearchView()
                    .environmentObject(learningDataService)
            }
            .sheet(isPresented: $showingEditProfile) {
                EditProfileView(selectedImage: $selectedImage)
            }
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(image: $selectedImage, sourceType: .photoLibrary)
            }
            .sheet(isPresented: $showingHelpSupport) {
                HelpSupportView()
                    .environmentObject(authService)
            }
            .sheet(isPresented: $showingAnalytics) {
                AnalyticsView()
                    .environmentObject(learningDataService)
            }
            .alert("Sign Out", isPresented: $showingLogoutAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Sign Out", role: .destructive) {
                    signOut()
                }
            } message: {
                Text("Are you sure you want to sign out?")
            }
            .alert("Delete Account", isPresented: $showingDeleteAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive) {
                    deleteAccount()
                }
            } message: {
                Text("This will permanently delete your account and all associated data. This action cannot be undone.")
            }
            .alert("Error", isPresented: $showDeleteError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(deleteError ?? "An error occurred")
            }
            .onAppear {
                AnalyticsService.shared.trackScreen("Profile", screenClass: "ProfileView")
            }
        }
    }
    
    // MARK: - Profile Header
    
    private var profileHeader: some View {
        ZStack(alignment: .bottom) {
            // Gradient background
            LinearGradient(
                colors: [AppTheme.brandPrimary, AppTheme.brandSecondary],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .frame(height: 200)
            
            // Profile content
            VStack(spacing: 12) {
                // Profile photo with edit button
                ZStack(alignment: .bottomTrailing) {
                    if let image = selectedImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(Color.white, lineWidth: 4)
                            )
                    } else {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 100, height: 100)
                            .overlay(
                                Text(user?.displayName?.prefix(1).uppercased() ?? "U")
                                    .font(.system(size: 40, weight: .bold))
                                    .foregroundStyle(AppTheme.brandPrimary)
                            )
                            .overlay(
                                Circle()
                                    .stroke(Color.white, lineWidth: 4)
                            )
                    }
                    
                    // Camera button
                    Button {
                        showingImagePicker = true
                    } label: {
                        Circle()
                            .fill(AppTheme.brandPrimary)
                            .frame(width: 32, height: 32)
                            .overlay(
                                Image(systemName: "camera.fill")
                                    .font(.system(size: 14))
                                    .foregroundStyle(.white)
                            )
                            .overlay(
                                Circle()
                                    .stroke(Color.white, lineWidth: 2)
                            )
                    }
                }
                
                // Name and info
                VStack(spacing: 4) {
                    Text(user?.displayName ?? "User")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.caption)
                        Text("Member since \(memberSinceDate)")
                            .font(.subheadline)
                    }
                    .foregroundStyle(.white.opacity(0.9))
                }
                
                // Edit profile button
                Button {
                    showingEditProfile = true
                } label: {
                    HStack {
                        Image(systemName: "pencil")
                            .font(.subheadline)
                        Text("Edit Profile")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.white.opacity(0.2))
                    .foregroundStyle(.white)
                    .cornerRadius(20)
                }
            }
            .padding(.bottom, 30)
        }
    }
    
    // MARK: - Stats Section
    
    private var statsSection: some View {
        HStack(spacing: 12) {
            StatCard(
                icon: "star.fill",
                value: "\(progress?.totalPoints ?? 0)",
                label: "Points",
                color: .yellow
            )
            
            StatCard(
                icon: "flame.fill",
                value: "\(progress?.streak ?? 0) days",
                label: "Streak",
                color: .orange
            )
            
            StatCard(
                icon: "checkmark.circle.fill",
                value: "\(progress?.completedLessons.count ?? 0)",
                label: "Lessons",
                color: .green
            )
        }
        .padding(.horizontal)
        .padding(.top, -20)
    }
    
    // MARK: - Quick Actions Card
    
    private var quickActionsCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Quick Actions")
                .font(.headline)
                .fontWeight(.bold)
            
            VStack(spacing: 12) {
                QuickActionButton(
                    icon: "magnifyingglass.circle.fill",
                    title: "Web Search",
                    subtitle: "Add new words from online",
                    color: .purple,
                    action: { showingWebSearch = true }
                )
                
                QuickActionButton(
                    icon: "bell.fill",
                    title: "Notifications",
                    subtitle: "Manage your alerts",
                    color: .orange,
                    action: { showingSettings = true }
                )
                
                QuickActionButton(
                    icon: "chart.line.uptrend.xyaxis",
                    title: "Analytics Dashboard",
                    subtitle: "View your learning statistics",
                    color: .blue,
                    action: { showingAnalytics = true }
                )
            }
        }
        .padding()
        .background(AppTheme.surface)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 10, y: 5)
    }
    
    // MARK: - Personal Info Card
    
    private var personalInfoCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Personal Information")
                .font(.headline)
                .fontWeight(.bold)
            
            VStack(spacing: 12) {
                InfoRow(icon: "envelope.fill", title: "Email", value: user?.email ?? "")
                InfoRow(icon: "book.fill", title: "Current Level", value: learningDataService.currentLevel.rawValue)
                InfoRow(icon: "calendar", title: "Member Since", value: memberSinceDate)
            }
        }
        .padding()
        .background(AppTheme.surface)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 10, y: 5)
    }
    
    // MARK: - Preferences Card
    
    private var preferencesCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Preferences")
                .font(.headline)
                .fontWeight(.bold)
            
            VStack(spacing: 12) {
                Button {
                    showingSettings = true
                } label: {
                    PreferenceRow(icon: "gearshape.fill", title: "Settings", color: .gray)
                }
                
                Button {
                    // Navigate to language settings
                } label: {
                    PreferenceRow(icon: "globe", title: "Language", color: .blue)
                }
                
                Button {
                    // Navigate to theme settings
                } label: {
                    PreferenceRow(icon: "paintbrush.fill", title: "Appearance", color: .purple)
                }
            }
        }
        .padding()
        .background(AppTheme.surface)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 10, y: 5)
    }
    
    // MARK: - About Card
    
    private var aboutCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("About")
                .font(.headline)
                .fontWeight(.bold)
            
            VStack(spacing: 12) {
                Button {
                    showingHelpSupport = true
                } label: {
                    PreferenceRow(icon: "questionmark.circle.fill", title: "Help & Support", color: .blue)
                }
                
                InfoRow(icon: "info.circle.fill", title: "Version", value: AppConfiguration.appVersion)
                
                Button {
                    if let url = URL(string: "https://easylearning.app/terms") {
                        UIApplication.shared.open(url)
                    }
                } label: {
                    PreferenceRow(icon: "doc.text.fill", title: "Terms of Service", color: .gray)
                }
                
                Button {
                    if let url = URL(string: "https://easylearning.app/privacy") {
                        UIApplication.shared.open(url)
                    }
                } label: {
                    PreferenceRow(icon: "hand.raised.fill", title: "Privacy Policy", color: .green)
                }
            }
        }
        .padding()
        .background(AppTheme.surface)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 10, y: 5)
    }
    
    // MARK: - Danger Zone Card
    
    private var dangerZoneCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Danger Zone")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundStyle(.red)
            
            VStack(spacing: 12) {
                Button {
                    showingLogoutAlert = true
                } label: {
                    HStack {
                        Image(systemName: "arrow.right.square")
                        Text("Sign Out")
                            .fontWeight(.semibold)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding()
                    .background(Color.red.opacity(0.1))
                    .foregroundStyle(.red)
                    .cornerRadius(12)
                }
                
                Button {
                    showingDeleteAlert = true
                } label: {
                    HStack {
                        if isDeletingAccount {
                            ProgressView()
                        } else {
                            Image(systemName: "trash")
                            Text("Delete Account")
                                .fontWeight(.semibold)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding()
                    .background(Color.red.opacity(0.1))
                    .foregroundStyle(.red)
                    .cornerRadius(12)
                }
                .disabled(isDeletingAccount)
                
                Text("Deleting your account will permanently remove all your data. This action cannot be undone.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(AppTheme.surface)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 10, y: 5)
    }
    
    // MARK: - Computed Properties
    
    private var memberSinceDate: String {
        guard let createdAt = user?.createdAt else { return "Recently" }
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: createdAt)
    }
    
    // MARK: - Helper Methods
    
    private func signOut() {
        do {
            try authService.signOut()
            Haptics.success()
        } catch {
            errorHandler.handle(error)
            Haptics.error()
        }
    }
    
    private func deleteAccount() {
        isDeletingAccount = true
        Haptics.warning()
        
        Task {
            do {
                try await authService.deleteAccount()
                Haptics.success()
                isDeletingAccount = false
                // User will automatically be logged out and redirected to sign-in
            } catch {
                Haptics.error()
                deleteError = error.localizedDescription
                showDeleteError = true
                isDeletingAccount = false
            }
        }
    }
}

// MARK: - Stat Card Component (using consolidated version from ReusableCards)

// MARK: - Quick Action Button

struct QuickActionButton: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(color)
                    .frame(width: 30)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding()
            .background(color.opacity(0.1))
            .cornerRadius(12)
        }
    }
}

// MARK: - Info Row Component

private struct InfoRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.body)
                .foregroundStyle(AppTheme.brandPrimary)
                .frame(width: 30)
            
            Text(title)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(.primary)
                .lineLimit(1)
        }
    }
}

// MARK: - Preference Row Component

struct PreferenceRow: View {
    let icon: String
    let title: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)
                .frame(width: 30)
            
            Text(title)
                .font(.body)
                .foregroundStyle(.primary)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(12)
    }
}

// MARK: - Image Picker

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    let sourceType: UIImagePickerController.SourceType
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        picker.allowsEditing = true
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let editedImage = info[.editedImage] as? UIImage {
                parent.image = editedImage
            } else if let originalImage = info[.originalImage] as? UIImage {
                parent.image = originalImage
            }
            
            parent.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

// MARK: - Edit Profile View

struct EditProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authService: AuthService
    @EnvironmentObject var errorHandler: ErrorHandler
    @Binding var selectedImage: UIImage?
    
    @State private var displayName: String = ""
    @State private var isLoading = false
    @State private var showingSaved = false
    @State private var showingImagePicker = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    // Profile photo
                    HStack {
                        Spacer()
                        
                        Button {
                            showingImagePicker = true
                        } label: {
                            ZStack(alignment: .bottomTrailing) {
                                if let image = selectedImage {
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 100, height: 100)
                                        .clipShape(Circle())
                                } else {
                                    Circle()
                                        .fill(AppTheme.brandPrimary.opacity(0.2))
                                        .frame(width: 100, height: 100)
                                        .overlay(
                                            Text(authService.currentUser?.displayName?.prefix(1).uppercased() ?? "U")
                                                .font(.system(size: 40, weight: .bold))
                                                .foregroundStyle(AppTheme.brandPrimary)
                                        )
                                }
                                
                                Circle()
                                    .fill(AppTheme.brandPrimary)
                                    .frame(width: 32, height: 32)
                                    .overlay(
                                        Image(systemName: "camera.fill")
                                            .font(.system(size: 14))
                                            .foregroundStyle(.white)
                                    )
                            }
                        }
                        
                        Spacer()
                    }
                    .padding(.vertical, 8)
                }
                
                Section("Personal Information") {
                    TextField("Display Name", text: $displayName)
                        .autocorrectionDisabled()
                }
                
                Section {
                    HStack {
                        Text("Email")
                        Spacer()
                        Text(authService.currentUser?.email ?? "")
                            .foregroundStyle(.secondary)
                    }
                } header: {
                    Text("Account")
                } footer: {
                    Text("Email cannot be changed.")
                        .font(.caption)
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveProfile()
                    }
                    .disabled(isLoading || displayName.isEmpty)
                }
            }
            .onAppear {
                displayName = authService.currentUser?.displayName ?? ""
            }
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(image: $selectedImage, sourceType: .photoLibrary)
            }
            .alert("Saved", isPresented: $showingSaved) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text("Your profile has been updated successfully")
            }
        }
    }
    
    private func saveProfile() {
        let validation = InputValidator.isValidDisplayName(displayName)
        guard validation.isValid else {
            errorHandler.handle(.validation(validation.message))
            return
        }
        
        isLoading = true
        
        Task {
            do {
                // Update profile (note: image upload removed - Auth only version)
                try await authService.updateProfile(displayName: displayName)
                
                Haptics.success()
                showingSaved = true
                
                // Reset selected image after successful upload
                selectedImage = nil
            } catch {
                errorHandler.handle(error)
                Haptics.error()
            }
            isLoading = false
        }
    }
}

// MARK: - Settings View

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("theme") private var selectedTheme: String = "system"
    @AppStorage("language") private var selectedLanguage: String = "en"
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Appearance") {
                    Picker("Theme", selection: $selectedTheme) {
                        Text("System").tag("system")
                        Text("Light").tag("light")
                        Text("Dark").tag("dark")
                    }
                    
                    Picker("Language", selection: $selectedLanguage) {
                        Text("English").tag("en")
                        Text("Japanese").tag("ja")
                        Text("Spanish").tag("es")
                    }
                }
                
                Section("Data & Updates") {
                    NavigationLink(destination: DataManagementView()) {
                        HStack {
                            Image(systemName: "arrow.down.circle.fill")
                                .foregroundColor(AppTheme.brandPrimary)
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Data Management")
                                    .font(AppTheme.Typography.body)
                                Text("Check for updates from GitHub")
                                    .font(AppTheme.Typography.caption)
                                    .foregroundColor(AppTheme.mutedText)
                            }
                        }
                    }
                    
                    Button("Clear Cache") {
                        clearCache()
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func clearCache() {
        TranslatorService.shared.clearCache()
        Haptics.success()
    }
}

// MARK: - Help & Support View

struct HelpSupportView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                Section("Support") {
                    Link(destination: URL(string: "mailto:support@company.com")!) {
                        Label("Email Support", systemImage: "envelope")
                    }
                }
                
                Section("Resources") {
                    Link(destination: URL(string: "https://company.com/help")!) {
                        Label("Help Center", systemImage: "questionmark.circle")
                    }
                    Link(destination: URL(string: "https://company.com/tutorials")!) {
                        Label("Video Tutorials", systemImage: "play.circle")
                    }
                }
                
                Section("Legal") {
                    Link(destination: URL(string: "https://company.com/privacy")!) {
                        Label("Privacy Policy", systemImage: "hand.raised")
                    }
                    Link(destination: URL(string: "https://company.com/terms")!) {
                        Label("Terms of Service", systemImage: "doc.text")
                    }
                }
            }
            .navigationTitle("Help & Support")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

