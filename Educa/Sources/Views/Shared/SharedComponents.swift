//
//  SharedComponents.swift
//  Educa
//
//  Premium reusable UI components
//

import SwiftUI

// MARK: - Toast View

struct ToastView: View {
    let message: String
    let icon: String
    let type: ToastType
    
    var body: some View {
        HStack(spacing: Spacing.sm) {
            Image(systemName: icon)
                .font(.body.weight(.semibold))
                .foregroundColor(type.color)
            
            Text(message)
                .font(.appSubheadline)
                .foregroundColor(.textPrimary)
        }
        .padding(.horizontal, Spacing.lg)
        .padding(.vertical, Spacing.md)
        .background(.ultraThinMaterial)
        .clipShape(Capsule())
        .shadow(color: .black.opacity(0.15), radius: 20, x: 0, y: 10)
    }
}

// MARK: - Empty State View

struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    var action: (() -> Void)? = nil
    var actionTitle: String? = nil
    
    var body: some View {
        VStack(spacing: Spacing.xl) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(Color.brand.opacity(0.1))
                    .frame(width: 120, height: 120)
                
                Image(systemName: icon)
                    .font(.system(size: 48, weight: .medium))
                    .foregroundStyle(LinearGradient.brandGradient)
            }
            
            VStack(spacing: Spacing.sm) {
                Text(title)
                    .font(.appTitle3)
                    .foregroundColor(.textPrimary)
                
                Text(message)
                    .font(.appBody)
                    .foregroundColor(.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, Spacing.xl)
            }
            
            if let action = action, let actionTitle = actionTitle {
                Button(actionTitle, action: action)
                    .buttonStyle(PrimaryButtonStyle())
                    .padding(.top, Spacing.md)
            }
            
            Spacer()
        }
        .padding(Spacing.xl)
    }
}

// MARK: - University Card (Premium)

struct UniversityCard: View {
    let university: University
    @State private var isHovered = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Image Section
            ZStack(alignment: .topTrailing) {
                AsyncImage(url: URL(string: university.image)) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    default:
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.brand.opacity(0.2), Color.brand.opacity(0.1)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .overlay {
                                Image(systemName: "building.columns")
                                    .font(.system(size: 32))
                                    .foregroundColor(.brand.opacity(0.4))
                            }
                    }
                }
                .frame(width: 220, height: 140)
                .clipShape(RoundedRectangle(cornerRadius: CornerRadius.large, style: .continuous))
                
                // Rating Badge
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .font(.caption2)
                        .foregroundColor(.yellow)
                    Text(String(format: "%.1f", university.rating))
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.textPrimary)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(.ultraThinMaterial)
                .clipShape(Capsule())
                .padding(10)
            }
            
            // Info Section
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text(university.title)
                    .font(.appSubheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.textPrimary)
                    .lineLimit(2)
                    .frame(height: 40, alignment: .top)
                
                HStack(spacing: 4) {
                    Image(systemName: "mappin.circle.fill")
                        .font(.caption)
                        .foregroundColor(.brand)
                    Text(university.location)
                        .font(.appCaption)
                        .foregroundColor(.textSecondary)
                        .lineLimit(1)
                }
                
                HStack {
                    Text(university.annualFee)
                        .font(.appCaption)
                        .fontWeight(.bold)
                        .foregroundColor(.brand)
                    
                    Spacer()
                    
                    if let ranking = university.ranking {
                        HStack(spacing: 2) {
                            Image(systemName: "chart.line.uptrend.xyaxis")
                                .font(.caption2)
                            Text("#\(ranking)")
                                .font(.appCaption2)
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.secondary)
                    }
                }
            }
            .padding(Spacing.md)
        }
        .frame(width: 220)
        .background(Color.surface)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.xl, style: .continuous))
        .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 6)
    }
}

// MARK: - Guide Card (Premium)

struct GuideCard: View {
    let guide: StudentGuide
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Image
            ZStack(alignment: .topLeading) {
                AsyncImage(url: URL(string: guide.imageUrl)) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    default:
                        LinearGradient(
                            colors: [categoryColor.opacity(0.3), categoryColor.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        .overlay {
                            Image(systemName: "doc.text.fill")
                                .font(.largeTitle)
                                .foregroundColor(categoryColor.opacity(0.5))
                        }
                    }
                }
                .frame(width: 200, height: 110)
                .clipShape(RoundedRectangle(cornerRadius: CornerRadius.large, style: .continuous))
                
                // Category Tag
                TagView(text: guide.category, color: categoryColor, style: .filled)
                    .padding(Spacing.sm)
            }
            
            // Info
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text(guide.title)
                    .font(.appSubheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.textPrimary)
                    .lineLimit(2)
                    .frame(height: 40, alignment: .top)
                
                HStack(spacing: Spacing.sm) {
                    HStack(spacing: 3) {
                        Image(systemName: "clock")
                            .font(.caption2)
                        Text("\(guide.readTime) min")
                            .font(.appCaption2)
                    }
                    .foregroundColor(.textTertiary)
                    
                    Spacer()
                    
                    if let author = guide.author {
                        Text(author)
                            .font(.appCaption2)
                            .foregroundColor(.textTertiary)
                            .lineLimit(1)
                    }
                }
            }
            .padding(Spacing.md)
        }
        .frame(width: 200)
        .background(Color.surface)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.xl, style: .continuous))
        .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 6)
    }
    
    private var categoryColor: Color {
        switch guide.category.lowercased() {
        case "visa": return .brand
        case "application": return .secondary
        case "scholarships": return .tertiary
        case "test prep": return .premium
        case "finance": return .accent
        default: return .brand
        }
    }
}


// MARK: - Loading Skeleton

struct SkeletonView: View {
    @State private var isAnimating = false
    
    var body: some View {
        RoundedRectangle(cornerRadius: CornerRadius.small, style: .continuous)
            .fill(Color.gray.opacity(0.15))
            .overlay {
                GeometryReader { geometry in
                    RoundedRectangle(cornerRadius: CornerRadius.small, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [.clear, .white.opacity(0.4), .clear],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .offset(x: isAnimating ? geometry.size.width : -geometry.size.width)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.small, style: .continuous))
            .onAppear {
                withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                    isAnimating = true
                }
            }
    }
}

// MARK: - Stat Box (Shared)

struct StatBox: View {
    let icon: String
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: Spacing.xxs) {
            HStack(spacing: Spacing.xxs) {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundColor(.brand)
                Text(value)
                    .font(.appHeadline)
                    .fontWeight(.bold)
                    .foregroundColor(.textPrimary)
            }
            
            Text(label)
                .font(.appCaption2)
                .foregroundColor(.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Spacing.sm)
        .background(Color.backgroundSecondary)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium))
    }
}

// MARK: - Unified Profile Menu Button

struct ProfileMenuButton: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var notificationsManager: NotificationsManager
    @ObservedObject private var userData = UserDataManager.shared
    
    @State private var showNotifications = false
    @State private var showSettings = false
    @State private var showProfile = false
    @State private var showSavedUniversities = false
    @State private var showSavedJobs = false
    @State private var showSavedCourses = false
    @State private var showSavedGuides = false
    @State private var showRemittance = false
    @State private var showAbout = false
    @State private var showHelp = false
    
    var body: some View {
        Menu {
            // Profile Section - Opens full profile sheet
            Section {
                Button {
                    HapticManager.shared.tap()
                    showProfile = true
                } label: {
                    Label(appState.currentUser?.name ?? "My Profile", systemImage: "person.circle.fill")
                }
            }
            
            // Quick Actions Section
            Section {
                Button {
                    HapticManager.shared.tap()
                    showNotifications = true
                } label: {
                    HStack {
                        Label("Notifications", systemImage: "bell.fill")
                        if notificationsManager.showBadge {
                            Text("•")
                                .foregroundColor(.red)
                        }
                    }
                }
                
                Button {
                    HapticManager.shared.tap()
                    showSettings = true
                } label: {
                    Label("Settings", systemImage: "gearshape.fill")
                }
            }
            
            // Saved Items Section
            Section("Saved Items") {
                Button {
                    HapticManager.shared.tap()
                    showSavedUniversities = true
                } label: {
                    Label("Universities (\(userData.savedUniversities.count))", systemImage: "building.columns")
                }
                
                Button {
                    HapticManager.shared.tap()
                    showSavedJobs = true
                } label: {
                    Label("Jobs (\(userData.savedJobs.count))", systemImage: "briefcase")
                }
                
                Button {
                    HapticManager.shared.tap()
                    showSavedCourses = true
                } label: {
                    Label("Courses (\(userData.savedCourses.count))", systemImage: "book")
                }
                
                Button {
                    HapticManager.shared.tap()
                    showSavedGuides = true
                } label: {
                    Label("Guides (\(userData.savedGuides.count))", systemImage: "doc.text")
                }
            }
            
            // Services Section
            Section("Services") {
                Button {
                    HapticManager.shared.tap()
                    showRemittance = true
                } label: {
                    Label("Remittance", systemImage: "dollarsign.circle")
                }
            }
            
            // Help & About
            Section {
                Button {
                    HapticManager.shared.tap()
                    showHelp = true
                } label: {
                    Label("Help & Support", systemImage: "questionmark.circle")
                }
                
                Button {
                    HapticManager.shared.tap()
                    showAbout = true
                } label: {
                    Label("About Educa", systemImage: "info.circle")
                }
            }
            
        } label: {
            ZStack(alignment: .topTrailing) {
                // Profile Avatar
                ZStack {
                    Circle()
                        .fill(LinearGradient.brandGradient)
                        .frame(width: 36, height: 36)
                    
                    Image(systemName: "person.fill")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                }
                
                // Notification Badge
                if notificationsManager.showBadge {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 12, height: 12)
                        .overlay {
                            Circle()
                                .stroke(Color.backgroundPrimary, lineWidth: 2)
                        }
                        .offset(x: 2, y: -2)
                }
            }
        }
        // Profile Sheet
        .sheet(isPresented: $showProfile) {
            ProfileSheetView()
        }
        // Notifications
        .sheet(isPresented: $showNotifications) {
            NotificationsView()
        }
        // Settings
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
        // Saved Items Sheets
        .sheet(isPresented: $showSavedUniversities) {
            NavigationStack {
                SavedUniversitiesView()
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Done") { showSavedUniversities = false }
                        }
                    }
            }
        }
        .sheet(isPresented: $showSavedJobs) {
            NavigationStack {
                SavedJobsView()
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Done") { showSavedJobs = false }
                        }
                    }
            }
        }
        .sheet(isPresented: $showSavedCourses) {
            NavigationStack {
                SavedCoursesView()
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Done") { showSavedCourses = false }
                        }
                    }
            }
        }
        .sheet(isPresented: $showSavedGuides) {
            NavigationStack {
                SavedGuidesView()
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Done") { showSavedGuides = false }
                        }
                    }
            }
        }
        // Remittance
        .sheet(isPresented: $showRemittance) {
            RemittanceView()
        }
        // Help & About
        .sheet(isPresented: $showHelp) {
            NavigationStack {
                HelpView()
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Done") { showHelp = false }
                        }
                    }
            }
        }
        .sheet(isPresented: $showAbout) {
            NavigationStack {
                AboutView()
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Done") { showAbout = false }
                        }
                    }
            }
        }
    }
}

// MARK: - Profile Sheet View (Full Profile in Sheet)

struct ProfileSheetView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var dataService: DataService
    @ObservedObject private var userData = UserDataManager.shared
    @State private var showEditProfile = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Spacing.xl) {
                    // Profile Header with Edit
                    profileHeader
                    
                    // My Journey - Country Cards (NEW!)
                    myJourneySection
                    
                    // Study Goals (if set)
                    if appState.targetDegree != nil || appState.targetField != nil {
                        studyGoalsSection
                    }
                    
                    // Profile Completion
                    if appState.profileCompletionPercentage < 1.0 {
                        profileCompletionCard
                    }
                    
                    // Stats
                    statsSection
                    
                    // Quick Actions
                    quickActionsSection
                    
                    // Saved Items Summary
                    savedItemsSummary
                    
                    // Services based on home country
                    servicesSection
                }
                .padding(Spacing.md)
                .padding(.bottom, 50)
            }
            .background(Color.backgroundPrimary)
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showEditProfile) {
                EditProfileView()
            }
        }
    }
    
    private var profileHeader: some View {
        VStack(spacing: Spacing.md) {
            // Avatar with initial
            ZStack {
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [Color.brand, Color.brandLight, Color.premium],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 3
                    )
                    .frame(width: 90, height: 90)
                
                Circle()
                    .fill(LinearGradient.brandGradient)
                    .frame(width: 80, height: 80)
                    .overlay {
                        if !appState.userName.isEmpty {
                            Text(String(appState.userName.prefix(1)).uppercased())
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.white)
                        } else {
                            Image(systemName: "person.fill")
                                .font(.system(size: 32))
                                .foregroundColor(.white)
                        }
                    }
            }
            
            // Name & Email
            VStack(spacing: Spacing.xxs) {
                Text(appState.userName.isEmpty ? "Set Up Your Profile" : appState.userName)
                    .font(.appTitle3)
                    .fontWeight(.bold)
                    .foregroundColor(.textPrimary)
                
                if !appState.userEmail.isEmpty {
                    Text(appState.userEmail)
                        .font(.appSubheadline)
                        .foregroundColor(.textSecondary)
                } else {
                    Text("Tap Edit to add your details")
                        .font(.appSubheadline)
                        .foregroundColor(.textTertiary)
                }
            }
            
            // Edit Profile Button
            Button {
                HapticManager.shared.medium()
                showEditProfile = true
            } label: {
                HStack(spacing: Spacing.xs) {
                    Image(systemName: "pencil")
                        .font(.caption.weight(.semibold))
                    Text("Edit Profile")
                        .font(.appCaption)
                        .fontWeight(.semibold)
                }
                .foregroundColor(.brand)
                .padding(.horizontal, Spacing.md)
                .padding(.vertical, Spacing.sm)
                .background(Color.brand.opacity(0.12))
                .clipShape(Capsule())
            }
        }
        .padding(Spacing.xl)
        .frame(maxWidth: .infinity)
        .background(Color.backgroundSecondary)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.large))
    }
    
    // MARK: - My Journey Section (Country Cards)
    
    private var myJourneySection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("My Journey")
                .font(.appHeadline)
                .fontWeight(.semibold)
                .foregroundColor(.textPrimary)
            
            HStack(spacing: Spacing.sm) {
                // From (Home Country)
                Button {
                    HapticManager.shared.tap()
                    showEditProfile = true
                } label: {
                    VStack(spacing: Spacing.sm) {
                        HStack {
                            Image(systemName: "house.fill")
                                .font(.caption2)
                                .foregroundColor(.green)
                            Text("FROM")
                                .font(.caption2.weight(.semibold))
                                .foregroundColor(.textSecondary)
                            Spacer()
                        }
                        
                        Text(appState.homeCountry?.flag ?? "🌍")
                            .font(.system(size: 36))
                        
                        Text(appState.homeCountry?.name ?? "Select")
                            .font(.appCaption)
                            .fontWeight(.semibold)
                            .foregroundColor(appState.homeCountry == nil ? .textTertiary : .textPrimary)
                            .lineLimit(1)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(Spacing.md)
                    .background(
                        RoundedRectangle(cornerRadius: CornerRadius.medium)
                            .fill(appState.homeCountry == nil ? Color.backgroundSecondary : Color.green.opacity(0.08))
                            .overlay(
                                RoundedRectangle(cornerRadius: CornerRadius.medium)
                                    .stroke(appState.homeCountry == nil ? Color.textTertiary.opacity(0.3) : Color.green.opacity(0.3), lineWidth: 1)
                            )
                    )
                }
                .buttonStyle(PlainButtonStyle())
                
                // Arrow
                Image(systemName: "arrow.right")
                    .font(.title3.weight(.semibold))
                    .foregroundColor(.textTertiary)
                
                // To (Destination Country)
                Button {
                    HapticManager.shared.tap()
                    showEditProfile = true
                } label: {
                    VStack(spacing: Spacing.sm) {
                        HStack {
                            Image(systemName: "graduationcap.fill")
                                .font(.caption2)
                                .foregroundColor(.brand)
                            Text("TO")
                                .font(.caption2.weight(.semibold))
                                .foregroundColor(.textSecondary)
                            Spacer()
                        }
                        
                        Text(appState.selectedCountry?.flag ?? "✈️")
                            .font(.system(size: 36))
                        
                        Text(appState.selectedCountry?.name ?? "Select")
                            .font(.appCaption)
                            .fontWeight(.semibold)
                            .foregroundColor(appState.selectedCountry == nil ? .textTertiary : .textPrimary)
                            .lineLimit(1)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(Spacing.md)
                    .background(
                        RoundedRectangle(cornerRadius: CornerRadius.medium)
                            .fill(appState.selectedCountry == nil ? Color.backgroundSecondary : Color.brand.opacity(0.08))
                            .overlay(
                                RoundedRectangle(cornerRadius: CornerRadius.medium)
                                    .stroke(appState.selectedCountry == nil ? Color.textTertiary.opacity(0.3) : Color.brand.opacity(0.3), lineWidth: 1)
                            )
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
    
    // MARK: - Study Goals Section
    
    private var studyGoalsSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Study Goals")
                .font(.appHeadline)
                .fontWeight(.semibold)
                .foregroundColor(.textPrimary)
            
            VStack(spacing: Spacing.sm) {
                if let degree = appState.targetDegree {
                    HStack(spacing: Spacing.md) {
                        ZStack {
                            Circle()
                                .fill(Color.tertiary.opacity(0.12))
                                .frame(width: 36, height: 36)
                            Image(systemName: degree.icon)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.tertiary)
                        }
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Program")
                                .font(.caption)
                                .foregroundColor(.textSecondary)
                            Text(degree.name)
                                .font(.appSubheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.textPrimary)
                        }
                        Spacer()
                    }
                }
                
                if let field = appState.targetField {
                    HStack(spacing: Spacing.md) {
                        ZStack {
                            Circle()
                                .fill(Color.secondary.opacity(0.12))
                                .frame(width: 36, height: 36)
                            Image(systemName: field.icon)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.secondary)
                        }
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Field")
                                .font(.caption)
                                .foregroundColor(.textSecondary)
                            Text(field.name)
                                .font(.appSubheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.textPrimary)
                        }
                        Spacer()
                    }
                }
                
                if !appState.targetIntake.isEmpty {
                    HStack(spacing: Spacing.md) {
                        ZStack {
                            Circle()
                                .fill(Color.premium.opacity(0.12))
                                .frame(width: 36, height: 36)
                            Image(systemName: "calendar")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.premium)
                        }
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Target Intake")
                                .font(.caption)
                                .foregroundColor(.textSecondary)
                            Text(appState.targetIntake)
                                .font(.appSubheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.textPrimary)
                        }
                        Spacer()
                    }
                }
            }
            .padding(Spacing.md)
            .background(Color.backgroundSecondary)
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium))
        }
    }
    
    // MARK: - Profile Completion Card
    
    private var profileCompletionCard: some View {
        Button {
            HapticManager.shared.tap()
            showEditProfile = true
        } label: {
            VStack(alignment: .leading, spacing: Spacing.sm) {
                HStack {
                    Image(systemName: "person.crop.circle.badge.exclamationmark")
                        .font(.title3)
                        .foregroundColor(.premium)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Complete Your Profile")
                            .font(.appSubheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.textPrimary)
                        
                        Text("Get personalized recommendations")
                            .font(.caption)
                            .foregroundColor(.textSecondary)
                    }
                    
                    Spacer()
                    
                    Text("\(Int(appState.profileCompletionPercentage * 100))%")
                        .font(.appSubheadline)
                        .fontWeight(.bold)
                        .foregroundColor(.premium)
                }
                
                // Progress Bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color.backgroundTertiary)
                            .frame(height: 6)
                        
                        RoundedRectangle(cornerRadius: 3)
                            .fill(
                                LinearGradient(
                                    colors: [.brand, .premium],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geometry.size.width * appState.profileCompletionPercentage, height: 6)
                    }
                }
                .frame(height: 6)
            }
            .padding(Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: CornerRadius.medium)
                    .fill(Color.premium.opacity(0.08))
                    .overlay(
                        RoundedRectangle(cornerRadius: CornerRadius.medium)
                            .stroke(Color.premium.opacity(0.2), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var statsSection: some View {
        HStack(spacing: Spacing.md) {
            ProfileStatBox(
                value: "\(userData.savedUniversities.count)",
                label: "Saved",
                icon: "bookmark.fill"
            )
            
            ProfileStatBox(
                value: "\(userData.savedJobs.count)",
                label: "Jobs",
                icon: "briefcase.fill"
            )
            
            ProfileStatBox(
                value: "\(userData.recentSearches.count)",
                label: "Searches",
                icon: "magnifyingglass"
            )
        }
    }
    
    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Quick Actions")
                .font(.appHeadline)
                .fontWeight(.semibold)
                .foregroundColor(.textPrimary)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: Spacing.sm) {
                NavigationLink {
                    SavedUniversitiesView()
                } label: {
                    QuickActionCard(icon: "building.columns", title: "Universities", count: userData.savedUniversities.count)
                }
                
                NavigationLink {
                    SavedJobsView()
                } label: {
                    QuickActionCard(icon: "briefcase", title: "Jobs", count: userData.savedJobs.count)
                }
                
                NavigationLink {
                    SavedCoursesView()
                } label: {
                    QuickActionCard(icon: "book", title: "Courses", count: userData.savedCourses.count)
                }
                
                NavigationLink {
                    SavedGuidesView()
                } label: {
                    QuickActionCard(icon: "doc.text", title: "Guides", count: userData.savedGuides.count)
                }
            }
        }
    }
    
    private var savedItemsSummary: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Recently Saved")
                .font(.appHeadline)
                .fontWeight(.semibold)
                .foregroundColor(.textPrimary)
            
            if userData.savedUniversities.isEmpty && userData.savedJobs.isEmpty {
                HStack {
                    Image(systemName: "bookmark")
                        .foregroundColor(.textTertiary)
                    Text("No saved items yet")
                        .font(.appSubheadline)
                        .foregroundColor(.textSecondary)
                }
                .frame(maxWidth: .infinity)
                .padding(Spacing.lg)
                .background(Color.backgroundSecondary)
                .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium))
            } else {
                // Show recent saved universities
                ForEach(dataService.universities.filter { userData.savedUniversities.contains($0.id) }.prefix(2)) { uni in
                    HStack {
                        Image(systemName: "building.columns.fill")
                            .foregroundColor(.brand)
                        Text(uni.title)
                            .font(.appSubheadline)
                            .foregroundColor(.textPrimary)
                            .lineLimit(1)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.textTertiary)
                    }
                    .padding(Spacing.md)
                    .background(Color.backgroundSecondary)
                    .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium))
                }
            }
        }
    }
    
    private var servicesSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            HStack {
                Text(appState.homeCountry?.flag ?? "🇳🇵")
                Text("\(appState.homeCountry?.name ?? "Nepal") Services")
                    .font(.appHeadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.textPrimary)
            }
            
            VStack(spacing: Spacing.sm) {
                NavigationLink {
                    NepalServicesView()
                } label: {
                    ServiceRowButton(icon: "globe.asia.australia.fill", title: "Student Hub", color: .red)
                }
                
                NavigationLink {
                    TestPrepView()
                } label: {
                    ServiceRowButton(icon: "doc.text.fill", title: "Test Preparation", color: .blue)
                }
                
                NavigationLink {
                    VisaGuideView()
                } label: {
                    ServiceRowButton(icon: "doc.badge.plus", title: "Visa Guide", color: .green)
                }
                
                NavigationLink {
                    CurrencyConverterView()
                } label: {
                    ServiceRowButton(icon: "dollarsign.arrow.circlepath", title: "Currency Converter", color: .orange)
                }
            }
        }
    }
}

// MARK: - Profile Supporting Components

struct ProfileStatBox: View {
    let value: String
    let label: String
    let icon: String
    
    var body: some View {
        VStack(spacing: Spacing.xs) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.brand)
            
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
        .background(Color.backgroundSecondary)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium))
    }
}

struct QuickActionCard: View {
    let icon: String
    let title: String
    let count: Int
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.brand)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.appSubheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.textPrimary)
                
                Text("\(count) saved")
                    .font(.appCaption2)
                    .foregroundColor(.textSecondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.textTertiary)
        }
        .padding(Spacing.md)
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium))
    }
}

struct ServiceRowButton: View {
    let icon: String
    let title: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
                .frame(width: 32)
            
            Text(title)
                .font(.appSubheadline)
                .foregroundColor(.textPrimary)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.textTertiary)
        }
        .padding(Spacing.md)
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium))
    }
}

// MARK: - Compact Toolbar Button

struct ToolbarIconButton: View {
    let icon: String
    let action: () -> Void
    var badgeCount: Int = 0
    
    var body: some View {
        Button {
            HapticManager.shared.tap()
            action()
        } label: {
            ZStack(alignment: .topTrailing) {
                Image(systemName: icon)
                    .font(.body.weight(.medium))
                    .foregroundColor(.textPrimary)
                    .frame(width: 36, height: 36)
                    .background(Color.backgroundSecondary)
                    .clipShape(Circle())
                
                if badgeCount > 0 {
                    Text(badgeCount > 9 ? "9+" : "\(badgeCount)")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white)
                        .frame(minWidth: 16, minHeight: 16)
                        .background(Color.red)
                        .clipShape(Circle())
                        .offset(x: 4, y: -4)
                }
            }
        }
    }
}

// MARK: - Enhanced Search View

struct SearchView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var dataService: DataService
    @EnvironmentObject var appState: AppState
    @ObservedObject private var userData = UserDataManager.shared
    @State private var searchText = ""
    @State private var selectedCategory = "All"
    @State private var showFilters = false
    @State private var isSearching = false
    
    // Advanced Filters
    @State private var selectedCountry: String = "All Countries"
    @State private var selectedDegreeLevel: String = "All Levels"
    @State private var sortBy: SortOption = .relevance
    @State private var priceRange: ClosedRange<Double> = 0...100000
    
    let categories = ["All", "Universities", "Courses", "Jobs", "Guides", "Scholarships"]
    let countries = ["All Countries", "Australia", "Canada", "UK", "USA", "Germany", "New Zealand", "Ireland"]
    let degreeLevels = ["All Levels", "Bachelor's", "Master's", "PhD", "Diploma", "Certificate"]
    
    enum SortOption: String, CaseIterable {
        case relevance = "Relevance"
        case rating = "Highest Rated"
        case priceAsc = "Price: Low to High"
        case priceDesc = "Price: High to Low"
        case newest = "Newest First"
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Enhanced Search Bar
                enhancedSearchBar
                
                // Category Pills with Counts
                categoryPills
                
                // Active Filters Banner
                if hasActiveFilters {
                    activeFiltersBanner
                }
                
                // Content
                if searchText.isEmpty {
                    // Show suggestions, recent searches, and trending
                    emptySearchContent
                } else {
                    // Show results
                    searchResultsContent
                }
            }
            .background(Color.backgroundPrimary)
            .navigationTitle("Search")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.brand)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showFilters.toggle()
                        HapticManager.shared.tap()
                    } label: {
                        ZStack(alignment: .topTrailing) {
                            Image(systemName: "slider.horizontal.3")
                                .font(.body.weight(.medium))
                                .foregroundColor(hasActiveFilters ? .brand : .textPrimary)
                            
                            if hasActiveFilters {
                                Circle()
                                    .fill(Color.brand)
                                    .frame(width: 8, height: 8)
                                    .offset(x: 2, y: -2)
                            }
                        }
                    }
                }
            }
            .sheet(isPresented: $showFilters) {
                advancedFiltersSheet
            }
        }
    }
    
    // MARK: - Enhanced Search Bar
    
    private var enhancedSearchBar: some View {
        HStack(spacing: Spacing.sm) {
            HStack(spacing: Spacing.sm) {
                Image(systemName: "magnifyingglass")
                    .font(.body.weight(.medium))
                    .foregroundColor(.textTertiary)
                
                TextField("Search universities, courses, jobs...", text: $searchText)
                    .font(.appBody)
                    .foregroundColor(.textPrimary)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .onChange(of: searchText) { _, newValue in
                        withAnimation(.easeInOut(duration: 0.2)) {
                            isSearching = !newValue.isEmpty
                        }
                        if !newValue.isEmpty && newValue.count >= 3 {
                            userData.addRecentSearch(newValue)
                        }
                    }
                
                if !searchText.isEmpty {
                    Button {
                        withAnimation(.spring(response: 0.3)) {
                            searchText = ""
                        }
                        HapticManager.shared.tap()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.body)
                            .foregroundColor(.textTertiary)
                    }
                }
            }
            .padding(Spacing.md)
            .background(Color.backgroundSecondary)
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.large, style: .continuous))
            
            // Voice Search Button
            Button {
                HapticManager.shared.tap()
                // Voice search placeholder
            } label: {
                Image(systemName: "mic.fill")
                    .font(.body.weight(.medium))
                    .foregroundColor(.textSecondary)
                    .frame(width: 44, height: 44)
                    .background(Color.backgroundSecondary)
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, Spacing.sm)
    }
    
    // MARK: - Category Pills
    
    private var categoryPills: some View {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: Spacing.sm) {
                        ForEach(categories, id: \.self) { category in
                    SearchCategoryPill(
                                title: category,
                        count: getCountForCategory(category),
                                isSelected: selectedCategory == category
                            ) {
                                withAnimation(.spring(response: 0.3)) {
                                    selectedCategory = category
                                }
                        HapticManager.shared.tap()
                            }
                        }
                    }
                    .padding(.horizontal, Spacing.md)
                    .padding(.vertical, Spacing.sm)
                }
        .background(Color.backgroundSecondary.opacity(0.5))
    }
    
    // MARK: - Active Filters Banner
    
    private var activeFiltersBanner: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Spacing.xs) {
                if selectedCountry != "All Countries" {
                    FilterChip(text: selectedCountry) {
                        selectedCountry = "All Countries"
                    }
                }
                
                if selectedDegreeLevel != "All Levels" {
                    FilterChip(text: selectedDegreeLevel) {
                        selectedDegreeLevel = "All Levels"
                    }
                }
                
                if sortBy != .relevance {
                    FilterChip(text: sortBy.rawValue) {
                        sortBy = .relevance
                    }
                }
                
                Button {
                    clearAllFilters()
                } label: {
                    Text("Clear All")
                        .font(.appCaption)
                        .fontWeight(.semibold)
                    .foregroundColor(.brand)
                }
                .padding(.leading, Spacing.xs)
            }
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, Spacing.sm)
        }
        .background(Color.brand.opacity(0.05))
    }
    
    // MARK: - Empty Search Content
    
    private var emptySearchContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.xl) {
                // Recent Searches
                if !userData.recentSearches.isEmpty {
                    recentSearchesSection
                }
                
                // Trending Searches
                trendingSearchesSection
                
                // Quick Suggestions
                quickSuggestionsSection
                
                // Browse Categories
                browseCategoriesSection
            }
            .padding(.vertical, Spacing.md)
        }
    }
    
    // MARK: - Recent Searches Section
    
    private var recentSearchesSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            HStack {
                HStack(spacing: Spacing.xs) {
                    Image(systemName: "clock.arrow.circlepath")
                        .font(.subheadline)
                        .foregroundColor(.textSecondary)
                Text("Recent Searches")
                    .font(.appHeadline)
                    .foregroundColor(.textPrimary)
                }
                
                Spacer()
                
                Button {
                    withAnimation {
                    userData.clearRecentSearches()
                }
                    HapticManager.shared.tap()
                } label: {
                    Text("Clear")
                .font(.appCaption)
                .fontWeight(.semibold)
                .foregroundColor(.brand)
            }
            }
            .padding(.horizontal, Spacing.md)
            
            ForEach(userData.recentSearches.prefix(5), id: \.self) { search in
                Button {
                    searchText = search
                    HapticManager.shared.tap()
                } label: {
                    HStack(spacing: Spacing.md) {
                        Image(systemName: "clock")
                            .font(.body)
                            .foregroundColor(.textTertiary)
                            .frame(width: 24)
                        
                        Text(search)
                            .font(.appBody)
                            .foregroundColor(.textPrimary)
                        
                        Spacer()
                        
                        Image(systemName: "arrow.up.left")
                            .font(.caption)
                            .foregroundColor(.textTertiary)
                    }
                    .padding(.horizontal, Spacing.md)
                    .padding(.vertical, Spacing.sm)
                }
            }
        }
    }
    
    // MARK: - Trending Searches Section
    
    private var trendingSearchesSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            HStack(spacing: Spacing.xs) {
                Image(systemName: "flame.fill")
                    .font(.subheadline)
                    .foregroundColor(.tertiary)
                Text("Trending Now")
                    .font(.appHeadline)
                    .foregroundColor(.textPrimary)
            }
            .padding(.horizontal, Spacing.md)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Spacing.sm) {
                    ForEach(trendingSearches, id: \.self) { trend in
                        Button {
                            searchText = trend
                            HapticManager.shared.tap()
                        } label: {
                            HStack(spacing: Spacing.xs) {
                                Text("🔥")
                                Text(trend)
                                    .font(.appCaption)
                                    .fontWeight(.medium)
                            }
                            .foregroundColor(.textPrimary)
                            .padding(.horizontal, Spacing.md)
                            .padding(.vertical, Spacing.sm)
                            .background(Color.tertiary.opacity(0.1))
                            .clipShape(Capsule())
                        }
                    }
                }
                .padding(.horizontal, Spacing.md)
            }
        }
    }
    
    // MARK: - Quick Suggestions Section
    
    private var quickSuggestionsSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            HStack(spacing: Spacing.xs) {
                Image(systemName: "lightbulb.fill")
                    .font(.subheadline)
                    .foregroundColor(.warning)
                Text("Suggestions")
                    .font(.appHeadline)
                    .foregroundColor(.textPrimary)
            }
            .padding(.horizontal, Spacing.md)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: Spacing.sm) {
                ForEach(quickSuggestions, id: \.title) { suggestion in
                    Button {
                        searchText = suggestion.query
                        selectedCategory = suggestion.category
                        HapticManager.shared.tap()
                    } label: {
                        HStack(spacing: Spacing.sm) {
                            Image(systemName: suggestion.icon)
                                .font(.body)
                                .foregroundColor(suggestion.color)
                            
                            Text(suggestion.title)
                                .font(.appCaption)
                                .fontWeight(.medium)
                                .foregroundColor(.textPrimary)
                                .lineLimit(1)
                            
                            Spacer()
                        }
                        .padding(Spacing.sm)
                        .background(Color.backgroundSecondary)
                        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium))
                    }
                }
            }
            .padding(.horizontal, Spacing.md)
        }
    }
    
    // MARK: - Browse Categories Section
    
    private var browseCategoriesSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            HStack(spacing: Spacing.xs) {
                Image(systemName: "square.grid.2x2.fill")
                    .font(.subheadline)
                    .foregroundColor(.brand)
                Text("Browse by Category")
                    .font(.appHeadline)
                    .foregroundColor(.textPrimary)
            }
            .padding(.horizontal, Spacing.md)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: Spacing.sm) {
                ForEach(browseCategories, id: \.title) { category in
                    Button {
                        selectedCategory = category.filterCategory
                        HapticManager.shared.tap()
                    } label: {
                        VStack(spacing: Spacing.xs) {
                            ZStack {
                                Circle()
                                    .fill(category.color.opacity(0.15))
                                    .frame(width: 50, height: 50)
                                
                                Image(systemName: category.icon)
                                    .font(.title3)
                                    .foregroundColor(category.color)
                            }
                            
                            Text(category.title)
                                .font(.appCaption)
                                .fontWeight(.medium)
                                .foregroundColor(.textPrimary)
                            
                            Text("\(category.count)")
                                .font(.appCaption2)
                                .foregroundColor(.textSecondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, Spacing.sm)
                    }
                }
            }
            .padding(.horizontal, Spacing.md)
        }
    }
    
    // MARK: - Search Results Content
    
    private var searchResultsContent: some View {
        VStack(spacing: 0) {
            // Results Header
            HStack {
                Text("\(totalResultsCount) results")
                    .font(.appCaption)
                    .foregroundColor(.textSecondary)
                
                Spacer()
                
                Menu {
                    ForEach(SortOption.allCases, id: \.self) { option in
                        Button {
                            sortBy = option
                            HapticManager.shared.tap()
                        } label: {
                            HStack {
                                Text(option.rawValue)
                                if sortBy == option {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                } label: {
                    HStack(spacing: Spacing.xxs) {
                        Text(sortBy.rawValue)
                            .font(.appCaption)
                        Image(systemName: "chevron.down")
                            .font(.caption2)
                    }
                    .foregroundColor(.brand)
                }
            }
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, Spacing.sm)
            
            // Results List
            if totalResultsCount == 0 {
                noResultsView
            } else {
        ScrollView {
            LazyVStack(spacing: Spacing.sm) {
                        // Universities
                if selectedCategory == "All" || selectedCategory == "Universities" {
                            let universities = filteredUniversities
                            if !universities.isEmpty {
                                SearchSectionHeader(title: "Universities", count: universities.count, icon: "building.columns.fill", color: .brand)
                                
                                ForEach(universities.prefix(showAllResults ? 100 : 5)) { university in
                                    EnhancedSearchResultRow(
                            icon: "building.columns.fill",
                            title: university.title,
                            subtitle: university.location,
                                        detail: university.annualFee,
                            type: "University",
                                        color: .brand,
                                        rating: university.rating
                        )
                                }
                    }
                }
                
                        // Courses
                if selectedCategory == "All" || selectedCategory == "Courses" {
                            let courses = filteredCourses
                            if !courses.isEmpty {
                                SearchSectionHeader(title: "Courses", count: courses.count, icon: "book.fill", color: .secondary)
                                
                                ForEach(courses.prefix(showAllResults ? 100 : 5)) { course in
                                    EnhancedSearchResultRow(
                            icon: "book.fill",
                            title: course.name,
                            subtitle: course.degreeLevel,
                                        detail: "\(course.duration) months",
                            type: "Course",
                            color: .secondary
                        )
                                }
                    }
                }
                
                        // Jobs
                if selectedCategory == "All" || selectedCategory == "Jobs" {
                            let jobs = filteredJobs
                            if !jobs.isEmpty {
                                SearchSectionHeader(title: "Jobs", count: jobs.count, icon: "briefcase.fill", color: .tertiary)
                                
                                ForEach(jobs.prefix(showAllResults ? 100 : 5)) { job in
                                    EnhancedSearchResultRow(
                            icon: "briefcase.fill",
                            title: job.title,
                            subtitle: job.company,
                                        detail: job.salary,
                                        type: job.type.capitalized,
                            color: .tertiary
                        )
                                }
                            }
                        }
                        
                        // Scholarships
                        if selectedCategory == "All" || selectedCategory == "Scholarships" {
                            let scholarships = filteredScholarships
                            if !scholarships.isEmpty {
                                SearchSectionHeader(title: "Scholarships", count: scholarships.count, icon: "graduationcap.fill", color: .premium)
                                
                                ForEach(scholarships.prefix(showAllResults ? 100 : 5)) { scholarship in
                                    EnhancedSearchResultRow(
                                        icon: "graduationcap.fill",
                                        title: scholarship.name,
                                        subtitle: scholarship.provider,
                                        detail: scholarship.amount,
                                        type: scholarship.isFullyFunded ? "Full Funding" : "Partial",
                                        color: .premium
                                    )
                                }
                            }
                        }
                        
                        // Guides
                        if selectedCategory == "All" || selectedCategory == "Guides" {
                            let guides = filteredGuides
                            if !guides.isEmpty {
                                SearchSectionHeader(title: "Guides", count: guides.count, icon: "doc.text.fill", color: .info)
                                
                                ForEach(guides.prefix(showAllResults ? 100 : 5)) { guide in
                                    EnhancedSearchResultRow(
                                        icon: "doc.text.fill",
                                        title: guide.title,
                                        subtitle: guide.category,
                                        detail: "\(guide.readTime) min read",
                                        type: "Guide",
                                        color: .info
                                    )
                                }
                    }
                }
            }
            .padding(Spacing.md)
                    .padding(.bottom, 100)
                }
            }
        }
    }
    
    // MARK: - No Results View
    
    private var noResultsView: some View {
        VStack(spacing: Spacing.lg) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(Color.textTertiary.opacity(0.1))
                    .frame(width: 100, height: 100)
                
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 40))
                    .foregroundColor(.textTertiary)
            }
            
            VStack(spacing: Spacing.sm) {
                Text("No results found")
                    .font(.appTitle3)
                    .fontWeight(.semibold)
                    .foregroundColor(.textPrimary)
                
                Text("Try adjusting your search or filters")
                    .font(.appBody)
                    .foregroundColor(.textSecondary)
                    .multilineTextAlignment(.center)
            }
            
            Button {
                clearAllFilters()
                searchText = ""
            } label: {
                Text("Clear Search")
            }
            .buttonStyle(SecondaryButtonStyle())
            
            Spacer()
        }
        .padding(Spacing.xl)
    }
    
    // MARK: - Advanced Filters Sheet
    
    private var advancedFiltersSheet: some View {
        NavigationStack {
            List {
                // Country Filter
                Section("Location") {
                    Picker("Country", selection: $selectedCountry) {
                        ForEach(countries, id: \.self) { country in
                            Text(country).tag(country)
                        }
                    }
                }
                
                // Degree Level Filter
                Section("Education Level") {
                    Picker("Degree Level", selection: $selectedDegreeLevel) {
                        ForEach(degreeLevels, id: \.self) { level in
                            Text(level).tag(level)
                        }
                    }
                }
                
                // Sort Options
                Section("Sort By") {
                    ForEach(SortOption.allCases, id: \.self) { option in
                        Button {
                            sortBy = option
                        } label: {
                            HStack {
                                Text(option.rawValue)
                                    .foregroundColor(.textPrimary)
                                Spacer()
                                if sortBy == option {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.brand)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Reset") {
                        clearAllFilters()
                    }
                    .foregroundColor(.brand)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        showFilters = false
                    }
                    .fontWeight(.semibold)
                    .foregroundColor(.brand)
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
    
    // MARK: - Computed Properties
    
    private var hasActiveFilters: Bool {
        selectedCountry != "All Countries" ||
        selectedDegreeLevel != "All Levels" ||
        sortBy != .relevance
    }
    
    private var showAllResults: Bool {
        selectedCategory != "All"
    }
    
    private var totalResultsCount: Int {
        var count = 0
        if selectedCategory == "All" || selectedCategory == "Universities" {
            count += filteredUniversities.count
        }
        if selectedCategory == "All" || selectedCategory == "Courses" {
            count += filteredCourses.count
        }
        if selectedCategory == "All" || selectedCategory == "Jobs" {
            count += filteredJobs.count
        }
        if selectedCategory == "All" || selectedCategory == "Scholarships" {
            count += filteredScholarships.count
        }
        if selectedCategory == "All" || selectedCategory == "Guides" {
            count += filteredGuides.count
        }
        return count
    }
    
    private var filteredUniversities: [University] {
        var results = dataService.searchUniversities(searchText)
        
        if selectedCountry != "All Countries" {
            results = results.filter { $0.country == selectedCountry }
        }
        
        switch sortBy {
        case .rating:
            results.sort { $0.rating > $1.rating }
        case .priceAsc:
            results.sort { extractPrice($0.annualFee) < extractPrice($1.annualFee) }
        case .priceDesc:
            results.sort { extractPrice($0.annualFee) > extractPrice($1.annualFee) }
        default:
            break
        }
        
        return results
    }
    
    private var filteredCourses: [Course] {
        var results = dataService.searchCourses(searchText)
        
        if selectedDegreeLevel != "All Levels" {
            results = results.filter { $0.degreeLevel == selectedDegreeLevel }
        }
        
        return results
    }
    
    private var filteredJobs: [JobListing] {
        dataService.searchJobs(searchText)
    }
    
    private var filteredScholarships: [Scholarship] {
        guard !searchText.isEmpty else { return dataService.scholarships }
        let lowercased = searchText.lowercased()
        return dataService.scholarships.filter {
            $0.name.lowercased().contains(lowercased) ||
            $0.provider.lowercased().contains(lowercased)
        }
    }
    
    private var filteredGuides: [StudentGuide] {
        guard !searchText.isEmpty else { return dataService.guides }
        let lowercased = searchText.lowercased()
        return dataService.guides.filter {
            $0.title.lowercased().contains(lowercased) ||
            $0.category.lowercased().contains(lowercased)
        }
    }
    
    private func getCountForCategory(_ category: String) -> Int {
        guard !searchText.isEmpty else { return 0 }
        
        switch category {
        case "All": return totalResultsCount
        case "Universities": return filteredUniversities.count
        case "Courses": return filteredCourses.count
        case "Jobs": return filteredJobs.count
        case "Scholarships": return filteredScholarships.count
        case "Guides": return filteredGuides.count
        default: return 0
        }
    }
    
    private func clearAllFilters() {
        withAnimation {
            selectedCountry = "All Countries"
            selectedDegreeLevel = "All Levels"
            sortBy = .relevance
        }
        HapticManager.shared.tap()
    }
    
    private func extractPrice(_ priceString: String) -> Double {
        let numbers = priceString.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        return Double(numbers) ?? 0
    }
    
    // MARK: - Sample Data
    
    private var trendingSearches: [String] {
        ["Scholarships 2025", "Computer Science", "MBA Programs", "Study in Canada", "Part-time Jobs"]
    }
    
    private var quickSuggestions: [(title: String, query: String, category: String, icon: String, color: Color)] {
        [
            ("Top Universities", "top universities", "Universities", "building.columns.fill", .brand),
            ("Free Courses", "free courses", "Courses", "book.fill", .secondary),
            ("Remote Jobs", "remote", "Jobs", "briefcase.fill", .tertiary),
            ("Full Scholarships", "full funding", "Scholarships", "graduationcap.fill", .premium),
            ("Visa Guides", "visa", "Guides", "doc.text.fill", .info),
            ("Study Abroad", "study abroad", "Universities", "globe", .brand)
        ]
    }
    
    private var browseCategories: [(title: String, filterCategory: String, icon: String, color: Color, count: Int)] {
        [
            ("Universities", "Universities", "building.columns.fill", .brand, dataService.universities.count),
            ("Courses", "Courses", "book.fill", .secondary, dataService.courses.count),
            ("Jobs", "Jobs", "briefcase.fill", .tertiary, dataService.jobs.count),
            ("Scholarships", "Scholarships", "graduationcap.fill", .premium, dataService.scholarships.count),
            ("Guides", "Guides", "doc.text.fill", .info, dataService.guides.count),
            ("Countries", "All", "globe.americas.fill", .accent, dataService.countries.count)
        ]
    }
}

// MARK: - Search Category Pill

struct SearchCategoryPill: View {
    let title: String
    let count: Int
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: Spacing.xxs) {
                Text(title)
                    .font(.appCaption)
                    .fontWeight(isSelected ? .bold : .medium)
                
                if count > 0 {
                    Text("(\(count))")
                        .font(.appCaption2)
                        .fontWeight(.medium)
                }
            }
            .foregroundColor(isSelected ? .white : .textPrimary)
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, Spacing.sm)
            .background(isSelected ? Color.brand : Color.backgroundSecondary)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(isSelected ? Color.clear : Color.cardBorder, lineWidth: 1)
            )
        }
        .animation(.spring(response: 0.3), value: isSelected)
    }
}

// MARK: - Filter Chip

struct FilterChip: View {
    let text: String
    let onRemove: () -> Void
    
    var body: some View {
        HStack(spacing: Spacing.xxs) {
            Text(text)
                .font(.appCaption2)
                .fontWeight(.medium)
            
            Button(action: onRemove) {
                Image(systemName: "xmark")
                    .font(.caption2.weight(.bold))
            }
        }
        .foregroundColor(.brand)
        .padding(.horizontal, Spacing.sm)
        .padding(.vertical, Spacing.xxs)
        .background(Color.brand.opacity(0.1))
        .clipShape(Capsule())
    }
}

// MARK: - Search Section Header

struct SearchSectionHeader: View {
    let title: String
    let count: Int
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: Spacing.sm) {
            Image(systemName: icon)
                .font(.subheadline)
                .foregroundColor(color)
            
            Text(title)
                .font(.appHeadline)
                .foregroundColor(.textPrimary)
            
            Text("(\(count))")
                .font(.appCaption)
                .foregroundColor(.textSecondary)
            
            Spacer()
        }
        .padding(.top, Spacing.md)
        .padding(.bottom, Spacing.xs)
    }
}

// MARK: - Enhanced Search Result Row

struct EnhancedSearchResultRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let detail: String
    let type: String
    var color: Color = .brand
    var rating: Double? = nil
    
    var body: some View {
        HStack(spacing: Spacing.md) {
            // Icon
            ZStack {
                RoundedRectangle(cornerRadius: CornerRadius.medium, style: .continuous)
                    .fill(color.opacity(0.12))
                    .frame(width: 50, height: 50)
                
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(color)
            }
            
            // Content
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.appSubheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.textPrimary)
                    .lineLimit(1)
                
                Text(subtitle)
                    .font(.appCaption)
                    .foregroundColor(.textSecondary)
                    .lineLimit(1)
                
                HStack(spacing: Spacing.sm) {
                    Text(detail)
                        .font(.appCaption2)
                        .fontWeight(.medium)
                        .foregroundColor(color)
                    
                    if let rating = rating {
                        HStack(spacing: 2) {
                            Image(systemName: "star.fill")
                                .font(.caption2)
                                .foregroundColor(.yellow)
                            Text(String(format: "%.1f", rating))
                                .font(.appCaption2)
                                .foregroundColor(.textSecondary)
                        }
                    }
                }
            }
            
            Spacer()
            
            // Type Badge & Arrow
            VStack(alignment: .trailing, spacing: Spacing.xs) {
                TagView(text: type, color: color, style: .soft)
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.textTertiary)
            }
        }
        .padding(Spacing.md)
        .background(Color.surface)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.large, style: .continuous))
        .shadow(color: AppShadow.subtle.color, radius: AppShadow.subtle.radius, x: AppShadow.subtle.x, y: AppShadow.subtle.y)
    }
}

// MARK: - Original Search Result Row (for compatibility)

struct SearchResultRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let type: String
    var color: Color = .brand
    
    var body: some View {
        HStack(spacing: Spacing.md) {
            ZStack {
                RoundedRectangle(cornerRadius: CornerRadius.medium, style: .continuous)
                    .fill(color.opacity(0.12))
                    .frame(width: 44, height: 44)
                
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(color)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.appSubheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.textPrimary)
                    .lineLimit(1)
                
                Text(subtitle)
                    .font(.appCaption)
                    .foregroundColor(.textSecondary)
                    .lineLimit(1)
            }
            
            Spacer()
            
            TagView(text: type, color: color, style: .soft)
        }
        .padding(Spacing.md)
        .background(Color.surface)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.large, style: .continuous))
    }
}

