//
//  ProfileView.swift
//  Educa
//
//  Premium user profile and settings
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var appState: AppState
    @ObservedObject private var userData = UserDataManager.shared
    @State private var showSettings = false
    @State private var showRemittance = false
    @State private var showTravelServices = false
    @State private var showEditProfile = false
    @State private var animateContent = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Spacing.xl) {
                    // Profile Header with Edit Button
                    profileHeader
                        .opacity(animateContent ? 1 : 0)
                        .offset(y: animateContent ? 0 : 20)
                    
                    // Country Cards - Most Important Feature
                    countryCardsSection
                        .opacity(animateContent ? 1 : 0)
                        .offset(y: animateContent ? 0 : 20)
                    
                    // Study Goals
                    if appState.targetDegree != nil || appState.targetField != nil {
                        studyGoalsSection
                    }
                    
                    // Profile Completion
                    if appState.profileCompletionPercentage < 1.0 {
                        profileCompletionCard
                    }
                    
                    // Quick Stats
                    statsSection
                        .opacity(animateContent ? 1 : 0)
                        .offset(y: animateContent ? 0 : 20)
                    
                    // Saved Items
                    savedSection
                    
                    // Services Section
                    servicesSection
                    
                    // Settings
                    settingsSection
                    
                    // App Version
                    versionFooter
                }
                .padding(Spacing.md)
                .padding(.bottom, 120)
            }
            .scrollIndicators(.hidden)
            .background(Color.backgroundPrimary)
            .navigationTitle("Profile")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        HapticManager.shared.tap()
                        showSettings = true
                    } label: {
                        Image(systemName: "gearshape")
                            .font(.body.weight(.medium))
                            .foregroundColor(.textPrimary)
                            .frame(width: 36, height: 36)
                            .background(Color.backgroundSecondary)
                            .clipShape(Circle())
                    }
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
            .sheet(isPresented: $showRemittance) {
                RemittanceView()
            }
            .sheet(isPresented: $showTravelServices) {
                TravelView()
            }
            .sheet(isPresented: $showEditProfile) {
                EditProfileView()
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.5).delay(0.1)) {
                animateContent = true
            }
        }
    }
    
    // MARK: - Profile Header
    
    private var profileHeader: some View {
        VStack(spacing: Spacing.lg) {
            // Avatar with gradient ring
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
                    .frame(width: 100, height: 100)
                
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.brand, Color.brandDark],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 88, height: 88)
                    .overlay {
                        if !appState.userName.isEmpty {
                            Text(String(appState.userName.prefix(1)).uppercased())
                                .font(.system(size: 36, weight: .bold))
                                .foregroundColor(.white)
                        } else {
                            Image(systemName: "person.fill")
                                .font(.system(size: 36, weight: .medium))
                                .foregroundColor(.white)
                        }
                    }
            }
            
            VStack(spacing: Spacing.xs) {
                Text(appState.userName.isEmpty ? "Set Up Your Profile" : appState.userName)
                    .font(.appTitle2)
                    .foregroundColor(.textPrimary)
                
                if !appState.userEmail.isEmpty {
                    Text(appState.userEmail)
                        .font(.appSubheadline)
                        .foregroundColor(.textSecondary)
                } else {
                    Text("Tap to add your details")
                        .font(.appSubheadline)
                        .foregroundColor(.textSecondary)
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
                .padding(.vertical, Spacing.xs)
                .background(Color.brand.opacity(0.12))
                .clipShape(Capsule())
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Spacing.xl)
        .background(
            RoundedRectangle(cornerRadius: CornerRadius.xxl, style: .continuous)
                .fill(Color.backgroundSecondary)
        )
    }
    
    // MARK: - Country Cards Section
    
    private var countryCardsSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("My Journey")
                .font(.appTitle3)
                .foregroundColor(.textPrimary)
            
            HStack(spacing: Spacing.md) {
                // Home Country Card
                CountryInfoCard(
                    title: "From",
                    flag: appState.homeCountry?.flag ?? "🌍",
                    countryName: appState.homeCountry?.name ?? "Select Country",
                    subtitle: appState.homeCountry?.currency ?? "Set your home",
                    iconName: "house.fill",
                    accentColor: .green,
                    isEmpty: appState.homeCountry == nil
                ) {
                    showEditProfile = true
                }
                
                // Arrow
                VStack {
                    Image(systemName: "arrow.right")
                        .font(.title2.weight(.semibold))
                        .foregroundColor(.textTertiary)
                }
                .frame(width: 30)
                
                // Destination Country Card
                CountryInfoCard(
                    title: "To",
                    flag: appState.selectedCountry?.flag ?? "✈️",
                    countryName: appState.selectedCountry?.name ?? "Select Destination",
                    subtitle: appState.selectedCountry?.primaryLanguageTest ?? "Where to study?",
                    iconName: "graduationcap.fill",
                    accentColor: .brand,
                    isEmpty: appState.selectedCountry == nil
                ) {
                    showEditProfile = true
                }
            }
        }
    }
    
    // MARK: - Study Goals Section
    
    private var studyGoalsSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Study Goals")
                .font(.appTitle3)
                .foregroundColor(.textPrimary)
            
            VStack(spacing: Spacing.sm) {
                if let degree = appState.targetDegree {
                    HStack(spacing: Spacing.md) {
                        ZStack {
                            Circle()
                                .fill(Color.tertiary.opacity(0.12))
                                .frame(width: 40, height: 40)
                            
                            Image(systemName: degree.icon)
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.tertiary)
                        }
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Target Program")
                                .font(.appCaption)
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
                    Divider()
                    
                    HStack(spacing: Spacing.md) {
                        ZStack {
                            Circle()
                                .fill(Color.secondary.opacity(0.12))
                                .frame(width: 40, height: 40)
                            
                            Image(systemName: field.icon)
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.secondary)
                        }
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Field of Study")
                                .font(.appCaption)
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
                    Divider()
                    
                    HStack(spacing: Spacing.md) {
                        ZStack {
                            Circle()
                                .fill(Color.premium.opacity(0.12))
                                .frame(width: 40, height: 40)
                            
                            Image(systemName: "calendar")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.premium)
                        }
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Target Intake")
                                .font(.appCaption)
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
            .background(Color.surface)
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.xl, style: .continuous))
            .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 4)
        }
    }
    
    // MARK: - Profile Completion Card
    
    private var profileCompletionCard: some View {
        Button {
            HapticManager.shared.tap()
            showEditProfile = true
        } label: {
            VStack(alignment: .leading, spacing: Spacing.md) {
                HStack {
                    Image(systemName: "person.crop.circle.badge.exclamationmark")
                        .font(.title2)
                        .foregroundColor(.premium)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Complete Your Profile")
                            .font(.appSubheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.textPrimary)
                        
                        Text("Add more details to get personalized recommendations")
                            .font(.appCaption)
                            .foregroundColor(.textSecondary)
                    }
                    
                    Spacer()
                }
                
                // Progress Bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.backgroundTertiary)
                            .frame(height: 8)
                        
                        RoundedRectangle(cornerRadius: 4)
                            .fill(
                                LinearGradient(
                                    colors: [.brand, .premium],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geometry.size.width * appState.profileCompletionPercentage, height: 8)
                    }
                }
                .frame(height: 8)
                
                Text("\(Int(appState.profileCompletionPercentage * 100))% complete")
                    .font(.appCaption)
                    .foregroundColor(.textTertiary)
            }
            .padding(Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: CornerRadius.large, style: .continuous)
                    .fill(Color.premium.opacity(0.08))
                    .overlay(
                        RoundedRectangle(cornerRadius: CornerRadius.large, style: .continuous)
                            .stroke(Color.premium.opacity(0.2), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Stats Section
    
    private var statsSection: some View {
        HStack(spacing: Spacing.sm) {
            ProfileStatCard(
                icon: "building.columns.fill",
                value: "\(userData.savedUniversities.count)",
                label: "Saved",
                color: .brand
            )
            
            ProfileStatCard(
                icon: "book.fill",
                value: "\(userData.savedCourses.count)",
                label: "Courses",
                color: .secondary
            )
            
            ProfileStatCard(
                icon: "briefcase.fill",
                value: "\(userData.savedJobs.count)",
                label: "Jobs",
                color: .tertiary
            )
            
            ProfileStatCard(
                icon: "doc.text.fill",
                value: "\(userData.savedGuides.count)",
                label: "Guides",
                color: .premium
            )
        }
    }
    
    // MARK: - Saved Section
    
    private var savedSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Saved Items")
                .font(.appTitle3)
                .foregroundColor(.textPrimary)
            
            VStack(spacing: Spacing.xs) {
                NavigationLink {
                    SavedUniversitiesView()
                } label: {
                    ProfileMenuRow(
                        icon: "building.columns.fill",
                        title: "Saved Universities",
                        value: "\(userData.savedUniversities.count)",
                        color: .brand
                    )
                }
                
                NavigationLink {
                    SavedCoursesView()
                } label: {
                    ProfileMenuRow(
                        icon: "book.fill",
                        title: "Saved Courses",
                        value: "\(userData.savedCourses.count)",
                        color: .secondary
                    )
                }
                
                NavigationLink {
                    SavedJobsView()
                } label: {
                    ProfileMenuRow(
                        icon: "briefcase.fill",
                        title: "Saved Jobs",
                        value: "\(userData.savedJobs.count)",
                        color: .tertiary
                    )
                }
                
                NavigationLink {
                    SavedGuidesView()
                } label: {
                    ProfileMenuRow(
                        icon: "doc.text.fill",
                        title: "Saved Guides",
                        value: "\(userData.savedGuides.count)",
                        color: .premium
                    )
                }
            }
            .background(Color.surface)
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.xl, style: .continuous))
            .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
        }
    }
    
    // MARK: - Services Section
    
    private var servicesSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Quick Services")
                .font(.appTitle3)
                .foregroundColor(.textPrimary)
            
            VStack(spacing: Spacing.sm) {
                // Remittance
                Button {
                    HapticManager.shared.medium()
                    showRemittance = true
                } label: {
                    ServiceRowCard(
                        icon: "dollarsign.circle.fill",
                        title: "Remittance",
                        subtitle: "Send money abroad easily & securely",
                        color: .green
                    )
                }
                .buttonStyle(PlainButtonStyle())
                
                // Travel Services
                Button {
                    HapticManager.shared.medium()
                    showTravelServices = true
                } label: {
                    ServiceRowCard(
                        icon: "airplane",
                        title: "Travel Services",
                        subtitle: "Agencies, visa help & accommodation",
                        color: .premium
                    )
                }
                .buttonStyle(PlainButtonStyle())
                
                // Education Consultants
                NavigationLink {
                    EducationConsultantsView()
                } label: {
                    ServiceRowCard(
                        icon: "graduationcap.fill",
                        title: "Education Consultants",
                        subtitle: "Get expert guidance for admissions",
                        color: .brand
                    )
                }
                
                // Recruitment Agencies
                NavigationLink {
                    RecruitmentAgenciesView()
                } label: {
                    ServiceRowCard(
                        icon: "briefcase.fill",
                        title: "Career Services",
                        subtitle: "Find jobs & recruitment agencies",
                        color: .tertiary
                    )
                }
            }
        }
    }
    
    // MARK: - Settings Section
    
    private var settingsSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Settings")
                .font(.appTitle3)
                .foregroundColor(.textPrimary)
            
            VStack(spacing: Spacing.xs) {
                Button {
                    HapticManager.shared.tap()
                    showSettings = true
                } label: {
                    ProfileMenuRow(
                        icon: "gearshape.fill",
                        title: "App Settings",
                        value: nil,
                        color: .textSecondary
                    )
                }
                
                NavigationLink {
                    AboutView()
                } label: {
                    ProfileMenuRow(
                        icon: "info.circle.fill",
                        title: "About Educa",
                        value: nil,
                        color: .brand
                    )
                }
                
                NavigationLink {
                    HelpView()
                } label: {
                    ProfileMenuRow(
                        icon: "questionmark.circle.fill",
                        title: "Help & Support",
                        value: nil,
                        color: .secondary
                    )
                }
                
                Button {
                    HapticManager.shared.tap()
                    // Share app
                } label: {
                    ProfileMenuRow(
                        icon: "square.and.arrow.up.fill",
                        title: "Share Educa",
                        value: nil,
                        color: .tertiary
                    )
                }
            }
            .background(Color.surface)
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.xl, style: .continuous))
            .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
        }
    }
    
    // MARK: - Version Footer
    
    private var versionFooter: some View {
        VStack(spacing: Spacing.xs) {
            Image(systemName: "graduationcap.fill")
                .font(.title2)
                .foregroundStyle(LinearGradient.brandGradient)
            
            Text("Educa")
                .font(.appHeadline)
                .foregroundColor(.textPrimary)
            
            Text("Version 1.0.0")
                .font(.appCaption)
                .foregroundColor(.textTertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, Spacing.xl)
    }
}

// MARK: - Profile Stat Card

struct ProfileStatCard: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: Spacing.xs) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.12))
                    .frame(width: 40, height: 40)
                
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(color)
            }
            
            Text(value)
                .font(.appHeadline)
                .fontWeight(.bold)
                .foregroundColor(.textPrimary)
            
            Text(label)
                .font(.appCaption2)
                .foregroundColor(.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Spacing.md)
        .background(Color.surface)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.large, style: .continuous))
        .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 4)
    }
}

// MARK: - Profile Menu Row

struct ProfileMenuRow: View {
    let icon: String
    let title: String
    let value: String?
    let color: Color
    
    var body: some View {
        HStack(spacing: Spacing.md) {
            ZStack {
                RoundedRectangle(cornerRadius: CornerRadius.small, style: .continuous)
                    .fill(color.opacity(0.12))
                    .frame(width: 36, height: 36)
                
                Image(systemName: icon)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(color)
            }
            
            Text(title)
                .font(.appBody)
                .foregroundColor(.textPrimary)
            
            Spacer()
            
            if let value = value {
                Text(value)
                    .font(.appSubheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.textSecondary)
                    .padding(.horizontal, Spacing.sm)
                    .padding(.vertical, Spacing.xxs)
                    .background(Color.backgroundTertiary)
                    .clipShape(Capsule())
            }
            
            Image(systemName: "chevron.right")
                .font(.caption.weight(.semibold))
                .foregroundColor(.textTertiary)
        }
        .padding(Spacing.md)
        .contentShape(Rectangle())
    }
}

// MARK: - Stat Card (Legacy)

struct StatCard: View {
    let icon: String
    let value: String
    let label: String
    
    var body: some View {
        ProfileStatCard(
            icon: icon,
            value: value,
            label: label,
            color: .brand
        )
    }
}

// MARK: - Profile Menu Item (Legacy)

struct ProfileMenuItem: View {
    let icon: String
    let title: String
    let value: String?
    
    var body: some View {
        ProfileMenuRow(
            icon: icon,
            title: title,
            value: value,
            color: .brand
        )
    }
}

// MARK: - Service Row Card

struct ServiceRowCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    
    var body: some View {
        HStack(spacing: Spacing.md) {
            ZStack {
                RoundedRectangle(cornerRadius: CornerRadius.medium, style: .continuous)
                    .fill(color.opacity(0.15))
                    .frame(width: 48, height: 48)
                
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(color)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.appHeadline)
                    .foregroundColor(.textPrimary)
                
                Text(subtitle)
                    .font(.appCaption)
                    .foregroundColor(.textSecondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption.weight(.semibold))
                .foregroundColor(.textTertiary)
        }
        .padding(Spacing.md)
        .background(Color.surface)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.large, style: .continuous))
        .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 4)
    }
}

// MARK: - Education Consultants View

struct EducationConsultantsView: View {
    @EnvironmentObject var dataService: DataService
    @State private var searchText = ""
    
    var filteredConsultants: [EducationConsultant] {
        if searchText.isEmpty {
            return dataService.educationConsultants.sorted { $0.rating > $1.rating }
        }
        return dataService.educationConsultants.filter {
            $0.name.lowercased().contains(searchText.lowercased()) ||
            $0.countriesServed.joined().lowercased().contains(searchText.lowercased())
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Stats
            HStack(spacing: Spacing.md) {
                StatBox(icon: "person.2.fill", value: "\(dataService.educationConsultants.count)", label: "Consultants")
                StatBox(icon: "building.columns", value: "\(totalPartnerships)", label: "Universities")
                StatBox(icon: "person.3.fill", value: "\(totalStudents)", label: "Students Placed")
            }
            .padding(Spacing.md)
            
            // Search
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.textTertiary)
                TextField("Search consultants...", text: $searchText)
            }
            .padding(Spacing.sm)
            .background(Color.backgroundSecondary)
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium))
            .padding(.horizontal, Spacing.md)
            .padding(.bottom, Spacing.sm)
            
            // List
            if dataService.educationConsultants.isEmpty {
                Spacer()
                EmptyStateView(
                    icon: "graduationcap",
                    title: "No Consultants Found",
                    message: "Education consultants will appear here"
                )
                Spacer()
            } else {
                ScrollView {
                    LazyVStack(spacing: Spacing.md) {
                        ForEach(filteredConsultants) { consultant in
                            EducationConsultantCard(consultant: consultant)
                        }
                    }
                    .padding(Spacing.md)
                    .padding(.bottom, 100)
                }
            }
        }
        .background(Color.backgroundPrimary)
        .navigationTitle("Education Consultants")
    }
    
    private var totalPartnerships: Int {
        dataService.educationConsultants.reduce(0) { $0 + $1.universitiesPartnered }
    }
    
    private var totalStudents: String {
        let total = dataService.educationConsultants.reduce(0) { $0 + $1.studentsPlaced }
        if total >= 1000 {
            return "\(total / 1000)k+"
        }
        return "\(total)"
    }
}

struct EducationConsultantCard: View {
    let consultant: EducationConsultant
    
    var body: some View {
        NavigationLink {
            EducationConsultantDetailView(consultant: consultant)
        } label: {
            HStack(spacing: Spacing.md) {
                AsyncImage(url: URL(string: consultant.logo)) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    default:
                        Circle()
                            .fill(Color.brand.opacity(0.1))
                            .overlay {
                                Image(systemName: "graduationcap.fill")
                                    .foregroundColor(.brand)
                            }
                    }
                }
                .frame(width: 50, height: 50)
                .clipShape(RoundedRectangle(cornerRadius: CornerRadius.small))
                
                VStack(alignment: .leading, spacing: Spacing.xxs) {
                    HStack {
                        Text(consultant.name)
                            .font(.appSubheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.textPrimary)
                        
                        if consultant.isRegistered {
                            Image(systemName: "checkmark.seal.fill")
                                .font(.caption2)
                                .foregroundColor(.green)
                        }
                    }
                    
                    HStack(spacing: Spacing.md) {
                        HStack(spacing: 3) {
                            Image(systemName: "star.fill")
                                .font(.caption2)
                                .foregroundColor(.yellow)
                            Text(String(format: "%.1f", consultant.rating))
                                .font(.appCaption)
                                .foregroundColor(.textSecondary)
                        }
                        
                        Text("\(consultant.universitiesPartnered) universities")
                            .font(.appCaption)
                            .foregroundColor(.textSecondary)
                    }
                    
                    Text(consultant.countriesServed.prefix(3).joined(separator: ", "))
                        .font(.appCaption)
                        .foregroundColor(.textSecondary)
                        .lineLimit(1)
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text(consultant.consultationFee)
                        .font(.appCaption)
                        .fontWeight(.medium)
                        .foregroundColor(.brand)
                    
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.textTertiary)
                }
            }
            .padding(Spacing.md)
            .background(Color.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.large))
            .cardShadow()
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct EducationConsultantDetailView: View {
    let consultant: EducationConsultant
    
    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.lg) {
                // Header
                VStack(spacing: Spacing.md) {
                    AsyncImage(url: URL(string: consultant.logo)) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        default:
                            Circle()
                                .fill(Color.brand.opacity(0.1))
                                .overlay {
                                    Image(systemName: "graduationcap.fill")
                                        .font(.largeTitle)
                                        .foregroundColor(.brand)
                                }
                        }
                    }
                    .frame(width: 80, height: 80)
                    .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium))
                    
                    HStack {
                        Text(consultant.name)
                            .font(.appTitle2)
                            .fontWeight(.bold)
                        
                        if consultant.isRegistered {
                            Image(systemName: "checkmark.seal.fill")
                                .foregroundColor(.green)
                        }
                    }
                    .foregroundColor(.textPrimary)
                    
                    HStack(spacing: Spacing.lg) {
                        VStack {
                            Text("\(consultant.universitiesPartnered)")
                                .fontWeight(.bold)
                                .foregroundColor(.brand)
                            Text("Universities")
                                .font(.appCaption)
                                .foregroundColor(.textSecondary)
                        }
                        
                        VStack {
                            Text("\(consultant.studentsPlaced)")
                                .fontWeight(.bold)
                                .foregroundColor(.green)
                            Text("Placed")
                                .font(.appCaption)
                                .foregroundColor(.textSecondary)
                        }
                        
                        VStack {
                            HStack(spacing: 3) {
                                Image(systemName: "star.fill")
                                    .foregroundColor(.yellow)
                                Text(String(format: "%.1f", consultant.rating))
                                    .fontWeight(.bold)
                            }
                            Text("\(consultant.reviewCount) reviews")
                                .font(.appCaption)
                                .foregroundColor(.textSecondary)
                        }
                    }
                    .font(.appSubheadline)
                }
                .padding(Spacing.lg)
                .frame(maxWidth: .infinity)
                .background(Color.backgroundSecondary)
                .clipShape(RoundedRectangle(cornerRadius: CornerRadius.large))
                
                // Description
                InfoSection(title: "About") {
                    Text(consultant.description)
                        .font(.appBody)
                        .foregroundColor(.textSecondary)
                }
                
                // Services
                InfoSection(title: "Services") {
                    ForEach(consultant.servicesOffered, id: \.self) { service in
                        HStack(spacing: Spacing.sm) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text(service)
                                .font(.appBody)
                                .foregroundColor(.textPrimary)
                        }
                    }
                }
                
                // Countries
                InfoSection(title: "Countries Served") {
                    FlowLayout(spacing: Spacing.xs) {
                        ForEach(consultant.countriesServed, id: \.self) { country in
                            Text(country)
                                .font(.appCaption)
                                .padding(.horizontal, Spacing.sm)
                                .padding(.vertical, Spacing.xxs)
                                .background(Color.brand.opacity(0.1))
                                .foregroundColor(.brand)
                                .clipShape(Capsule())
                        }
                    }
                }
                
                // Features
                InfoSection(title: "Features") {
                    ForEach(consultant.features, id: \.self) { feature in
                        HStack(spacing: Spacing.sm) {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                            Text(feature)
                                .font(.appBody)
                                .foregroundColor(.textPrimary)
                        }
                    }
                }
                
                // Contact
                InfoSection(title: "Contact") {
                    if let email = consultant.contactEmail {
                        InfoRow(label: "Email", value: email)
                    }
                    if let phone = consultant.contactPhone {
                        InfoRow(label: "Phone", value: phone)
                    }
                    if let address = consultant.address {
                        InfoRow(label: "Address", value: address)
                    }
                    InfoRow(label: "Consultation", value: consultant.consultationFee)
                }
                
                // Actions
                Link(destination: URL(string: consultant.website)!) {
                    Label("Visit Website", systemImage: "globe")
                }
                .buttonStyle(PrimaryButtonStyle(isFullWidth: true))
            }
            .padding(Spacing.md)
            .padding(.bottom, Spacing.xxl)
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Recruitment Agencies View

struct RecruitmentAgenciesView: View {
    @EnvironmentObject var dataService: DataService
    @State private var searchText = ""
    @State private var selectedIndustry = "All"
    
    var industries: [String] {
        var allIndustries = ["All"]
        let unique = Set(dataService.recruitmentAgencies.flatMap { $0.industries })
        allIndustries.append(contentsOf: unique.sorted())
        return allIndustries
    }
    
    var filteredAgencies: [RecruitmentAgency] {
        var result = dataService.recruitmentAgencies
        
        if !searchText.isEmpty {
            result = result.filter {
                $0.name.lowercased().contains(searchText.lowercased()) ||
                $0.industries.joined().lowercased().contains(searchText.lowercased())
            }
        }
        
        if selectedIndustry != "All" {
            result = result.filter { $0.industries.contains(selectedIndustry) }
        }
        
        return result.sorted { $0.rating > $1.rating }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Stats
            HStack(spacing: Spacing.md) {
                StatBox(icon: "building.2", value: "\(dataService.recruitmentAgencies.count)", label: "Agencies")
                StatBox(icon: "globe", value: "\(uniqueLocations)", label: "Locations")
                StatBox(icon: "checkmark.seal.fill", value: "\(licensedAgencies)", label: "Licensed")
            }
            .padding(Spacing.md)
            
            // Industry Filter
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Spacing.sm) {
                    ForEach(industries.prefix(6), id: \.self) { industry in
                        FilterPill(
                            title: industry,
                            isSelected: selectedIndustry == industry
                        ) {
                            selectedIndustry = industry
                        }
                    }
                }
                .padding(.horizontal, Spacing.md)
                .padding(.vertical, Spacing.sm)
            }
            .background(Color.backgroundSecondary.opacity(0.5))
            
            // List
            if dataService.recruitmentAgencies.isEmpty {
                Spacer()
                EmptyStateView(
                    icon: "briefcase",
                    title: "No Agencies Found",
                    message: "Recruitment agencies will appear here"
                )
                Spacer()
            } else {
                ScrollView {
                    LazyVStack(spacing: Spacing.md) {
                        ForEach(filteredAgencies) { agency in
                            RecruitmentAgencyCard(agency: agency)
                        }
                    }
                    .padding(Spacing.md)
                    .padding(.bottom, 100)
                }
            }
        }
        .background(Color.backgroundPrimary)
        .navigationTitle("Career Services")
    }
    
    private var uniqueLocations: Int {
        Set(dataService.recruitmentAgencies.flatMap { $0.locations }).count
    }
    
    private var licensedAgencies: Int {
        dataService.recruitmentAgencies.filter { $0.isLicensed }.count
    }
}

struct RecruitmentAgencyCard: View {
    let agency: RecruitmentAgency
    
    var body: some View {
        NavigationLink {
            RecruitmentAgencyDetailView(agency: agency)
        } label: {
            HStack(spacing: Spacing.md) {
                AsyncImage(url: URL(string: agency.logo)) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    default:
                        Circle()
                            .fill(Color.tertiary.opacity(0.1))
                            .overlay {
                                Image(systemName: "briefcase.fill")
                                    .foregroundColor(.tertiary)
                            }
                    }
                }
                .frame(width: 50, height: 50)
                .clipShape(RoundedRectangle(cornerRadius: CornerRadius.small))
                
                VStack(alignment: .leading, spacing: Spacing.xxs) {
                    HStack {
                        Text(agency.name)
                            .font(.appSubheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.textPrimary)
                        
                        if agency.isLicensed {
                            Image(systemName: "checkmark.seal.fill")
                                .font(.caption2)
                                .foregroundColor(.green)
                        }
                    }
                    
                    HStack(spacing: Spacing.md) {
                        HStack(spacing: 3) {
                            Image(systemName: "star.fill")
                                .font(.caption2)
                                .foregroundColor(.yellow)
                            Text(String(format: "%.1f", agency.rating))
                                .font(.appCaption)
                                .foregroundColor(.textSecondary)
                        }
                        
                        Text("\(agency.industries.count) industries")
                            .font(.appCaption)
                            .foregroundColor(.textSecondary)
                    }
                    
                    // Industries
                    HStack(spacing: Spacing.xs) {
                        ForEach(agency.industries.prefix(2), id: \.self) { industry in
                            Text(industry)
                                .font(.appCaption2)
                                .foregroundColor(.tertiary)
                                .padding(.horizontal, Spacing.xs)
                                .padding(.vertical, 2)
                                .background(Color.tertiary.opacity(0.1))
                                .clipShape(Capsule())
                        }
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text(agency.placementFee)
                        .font(.appCaption)
                        .fontWeight(.medium)
                        .foregroundColor(.green)
                    
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.textTertiary)
                }
            }
            .padding(Spacing.md)
            .background(Color.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.large))
            .cardShadow()
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct RecruitmentAgencyDetailView: View {
    let agency: RecruitmentAgency
    
    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.lg) {
                // Header
                VStack(spacing: Spacing.md) {
                    AsyncImage(url: URL(string: agency.logo)) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        default:
                            Circle()
                                .fill(Color.tertiary.opacity(0.1))
                                .overlay {
                                    Image(systemName: "briefcase.fill")
                                        .font(.largeTitle)
                                        .foregroundColor(.tertiary)
                                }
                        }
                    }
                    .frame(width: 80, height: 80)
                    .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium))
                    
                    HStack {
                        Text(agency.name)
                            .font(.appTitle2)
                            .fontWeight(.bold)
                        
                        if agency.isLicensed {
                            Image(systemName: "checkmark.seal.fill")
                                .foregroundColor(.green)
                        }
                    }
                    .foregroundColor(.textPrimary)
                    
                    HStack(spacing: Spacing.lg) {
                        VStack {
                            HStack(spacing: 3) {
                                Image(systemName: "star.fill")
                                    .foregroundColor(.yellow)
                                Text(String(format: "%.1f", agency.rating))
                                    .fontWeight(.bold)
                            }
                            Text("\(agency.reviewCount) reviews")
                                .font(.appCaption)
                                .foregroundColor(.textSecondary)
                        }
                        
                        VStack {
                            Text("\(agency.industries.count)")
                                .fontWeight(.bold)
                                .foregroundColor(.brand)
                            Text("Industries")
                                .font(.appCaption)
                                .foregroundColor(.textSecondary)
                        }
                        
                        VStack {
                            Text(agency.placementFee)
                                .fontWeight(.bold)
                                .foregroundColor(.green)
                            Text("Fee")
                                .font(.appCaption)
                                .foregroundColor(.textSecondary)
                        }
                    }
                    .font(.appSubheadline)
                }
                .padding(Spacing.lg)
                .frame(maxWidth: .infinity)
                .background(Color.backgroundSecondary)
                .clipShape(RoundedRectangle(cornerRadius: CornerRadius.large))
                
                // Description
                InfoSection(title: "About") {
                    Text(agency.description)
                        .font(.appBody)
                        .foregroundColor(.textSecondary)
                }
                
                // Industries
                InfoSection(title: "Industries") {
                    FlowLayout(spacing: Spacing.xs) {
                        ForEach(agency.industries, id: \.self) { industry in
                            Text(industry)
                                .font(.appCaption)
                                .padding(.horizontal, Spacing.sm)
                                .padding(.vertical, Spacing.xxs)
                                .background(Color.tertiary.opacity(0.1))
                                .foregroundColor(.tertiary)
                                .clipShape(Capsule())
                        }
                    }
                }
                
                // Job Types
                InfoSection(title: "Job Types") {
                    FlowLayout(spacing: Spacing.xs) {
                        ForEach(agency.jobTypes, id: \.self) { type in
                            Text(type)
                                .font(.appCaption)
                                .padding(.horizontal, Spacing.sm)
                                .padding(.vertical, Spacing.xxs)
                                .background(Color.brand.opacity(0.1))
                                .foregroundColor(.brand)
                                .clipShape(Capsule())
                        }
                    }
                }
                
                // Locations
                InfoSection(title: "Locations") {
                    FlowLayout(spacing: Spacing.xs) {
                        ForEach(agency.locations, id: \.self) { location in
                            Text(location)
                                .font(.appCaption)
                                .padding(.horizontal, Spacing.sm)
                                .padding(.vertical, Spacing.xxs)
                                .background(Color.premium.opacity(0.1))
                                .foregroundColor(.premium)
                                .clipShape(Capsule())
                        }
                    }
                }
                
                // Features
                InfoSection(title: "Features") {
                    ForEach(agency.features, id: \.self) { feature in
                        HStack(spacing: Spacing.sm) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text(feature)
                                .font(.appBody)
                                .foregroundColor(.textPrimary)
                        }
                    }
                }
                
                // Partner Companies
                if let partners = agency.partneredCompanies {
                    InfoSection(title: "Partnered Companies") {
                        FlowLayout(spacing: Spacing.xs) {
                            ForEach(partners, id: \.self) { company in
                                Text(company)
                                    .font(.appCaption)
                                    .fontWeight(.medium)
                                    .padding(.horizontal, Spacing.sm)
                                    .padding(.vertical, Spacing.xxs)
                                    .background(Color.backgroundTertiary)
                                    .foregroundColor(.textPrimary)
                                    .clipShape(Capsule())
                            }
                        }
                    }
                }
                
                // Contact
                InfoSection(title: "Contact") {
                    if let email = agency.contactEmail {
                        InfoRow(label: "Email", value: email)
                    }
                    if let phone = agency.contactPhone {
                        InfoRow(label: "Phone", value: phone)
                    }
                    if let address = agency.address {
                        InfoRow(label: "Address", value: address)
                    }
                }
                
                // Actions
                Link(destination: URL(string: agency.website)!) {
                    Label("Visit Website", systemImage: "globe")
                }
                .buttonStyle(PrimaryButtonStyle(isFullWidth: true))
            }
            .padding(Spacing.md)
            .padding(.bottom, Spacing.xxl)
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Country Info Card

struct CountryInfoCard: View {
    let title: String
    let flag: String
    let countryName: String
    let subtitle: String
    let iconName: String
    let accentColor: Color
    let isEmpty: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: Spacing.sm) {
                // Label
                HStack {
                    Image(systemName: iconName)
                        .font(.caption)
                        .foregroundColor(accentColor)
                    
                    Text(title)
                        .font(.appCaption)
                        .foregroundColor(.textSecondary)
                    
                    Spacer()
                }
                
                // Flag
                Text(flag)
                    .font(.system(size: 40))
                
                // Country Name
                Text(countryName)
                    .font(.appSubheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(isEmpty ? .textTertiary : .textPrimary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                
                // Subtitle
                Text(subtitle)
                    .font(.appCaption)
                    .foregroundColor(.textSecondary)
            }
            .frame(maxWidth: .infinity)
            .padding(Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: CornerRadius.large, style: .continuous)
                    .fill(isEmpty ? Color.backgroundSecondary : accentColor.opacity(0.08))
                    .overlay(
                        RoundedRectangle(cornerRadius: CornerRadius.large, style: .continuous)
                            .stroke(isEmpty ? Color.textTertiary.opacity(0.3) : accentColor.opacity(0.3), lineWidth: isEmpty ? 1 : 1.5)
                            .strokeBorder(style: isEmpty ? StrokeStyle(lineWidth: 1, dash: [5]) : StrokeStyle(lineWidth: 1.5))
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Preview

#Preview {
    ProfileView()
        .environmentObject(AppState())
}
