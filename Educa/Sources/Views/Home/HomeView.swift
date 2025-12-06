//
//  HomeView.swift
//  Educa
//
//  Premium home screen with country-specific content
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var dataService: DataService
    @State private var showSearch = false
    @State private var showCountrySelector = false
    @State private var scrollOffset: CGFloat = 0
    @State private var animateContent = false
    
    var hasSelectedCountry: Bool {
        appState.selectedCountry != nil
    }
    
    // Filter universities by selected country
    var filteredUniversities: [University] {
        guard let country = appState.selectedCountry else {
            return dataService.universities
        }
        return dataService.universities.filter { $0.country == country.name }
    }
    
    // Filter scholarships by selected country
    var filteredScholarships: [Scholarship] {
        guard let country = appState.selectedCountry else {
            return dataService.scholarships
        }
        return dataService.scholarships.filter { $0.country == country.name }
    }
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                // Background
                backgroundGradient
                
                ScrollView {
                    VStack(spacing: Spacing.xxl) {
                        // Country-specific Hero or Default Hero
                        if let country = appState.selectedCountry {
                            countryHeroSection(country)
                                .opacity(animateContent ? 1 : 0)
                                .offset(y: animateContent ? 0 : 20)
                        } else {
                        heroSection
                            .opacity(animateContent ? 1 : 0)
                            .offset(y: animateContent ? 0 : 20)
                        }
                        
                        // Quick Actions
                        quickActionsSection
                            .opacity(animateContent ? 1 : 0)
                            .offset(y: animateContent ? 0 : 20)
                        
                        // Country Dashboard (if country selected)
                        if hasSelectedCountry {
                            countryQuickInfoSection
                                .opacity(animateContent ? 1 : 0)
                                .offset(y: animateContent ? 0 : 20)
                        }
                        
                        // Nepal Services Hub
                        nepalServicesSection
                            .opacity(animateContent ? 1 : 0)
                            .offset(y: animateContent ? 0 : 20)
                        
                        // Services Grid
                        servicesSection
                            .opacity(animateContent ? 1 : 0)
                            .offset(y: animateContent ? 0 : 20)
                        
                        // Featured Universities (country-filtered if selected)
                        featuredUniversitiesSection
                        
                        // Recent Updates
                        updatesSection
                        
                        // Scholarships (country-filtered if selected)
                        scholarshipsSection
                        
                        // Student Guides
                        guidesSection
                    }
                    .padding(.horizontal, Spacing.md)
                    .padding(.top, Spacing.md)
                    .padding(.bottom, 120)
                }
                .scrollIndicators(.hidden)
                .refreshable {
                    await dataService.refresh()
                    if let country = appState.selectedCountry {
                        await dataService.loadCountryData(for: country)
                    }
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    // Country Selector or Educa Logo
                    if let country = appState.selectedCountry {
                        Button {
                            showCountrySelector = true
                        } label: {
                            HStack(spacing: Spacing.xs) {
                                Text(country.flag)
                                    .font(.title2)
                                Text(country.name)
                                    .font(.appHeadline)
                                    .foregroundColor(.textPrimary)
                                Image(systemName: "chevron.down")
                                    .font(.caption)
                                    .foregroundColor(.textTertiary)
                            }
                        }
                    } else {
                    HStack(spacing: Spacing.xs) {
                        Image(systemName: "graduationcap.fill")
                            .font(.title2)
                            .foregroundStyle(LinearGradient.brandGradient)
                        Text("Educa")
                            .font(.appTitle2)
                            .foregroundColor(.textPrimary)
                        }
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: Spacing.sm) {
                        // Search Button
                        ToolbarIconButton(icon: "magnifyingglass") {
                            showSearch = true
                        }
                        
                        // Unified Profile Menu (Profile + Settings + Notifications)
                        ProfileMenuButton()
                    }
                }
            }
            .sheet(isPresented: $showSearch) {
                SearchView()
            }
            .sheet(isPresented: $showCountrySelector) {
                CountrySelectionView { selectedCountry in
                    Task {
                        await dataService.loadCountryData(for: selectedCountry)
                    }
                }
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.6).delay(0.1)) {
                animateContent = true
            }
            // Load country data if selected
            if let country = appState.selectedCountry, dataService.currentCountry != country {
                Task {
                    await dataService.loadCountryData(for: country)
                }
            }
        }
    }
    
    // MARK: - Background
    
    private var backgroundGradient: some View {
        Color.backgroundPrimary
            .ignoresSafeArea()
    }
    
    // MARK: - Hero Section
    
    private var heroSection: some View {
        ZStack(alignment: .bottomLeading) {
            // Background Image with Parallax
            GeometryReader { geometry in
                AsyncImage(url: URL(string: "https://images.unsplash.com/photo-1523050854058-8df90110c9f1")) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: geometry.size.width)
                    case .failure:
                        heroPlaceholder
                    case .empty:
                        heroPlaceholder
                            .overlay {
                                ProgressView()
                                    .tint(.white)
                            }
                    @unknown default:
                        heroPlaceholder
                    }
                }
            }
            .frame(height: 260)
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.xxl, style: .continuous))
            .overlay {
                // Gradient overlay
                RoundedRectangle(cornerRadius: CornerRadius.xxl, style: .continuous)
                    .fill(LinearGradient.heroOverlay)
            }
            
            // Content
            VStack(alignment: .leading, spacing: Spacing.md) {
                // Badge
                HStack(spacing: Spacing.xs) {
                    Image(systemName: "sparkles")
                        .font(.caption)
                    Text("Start Your Journey")
                        .font(.appCaption)
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .padding(.horizontal, Spacing.sm)
                .padding(.vertical, Spacing.xxs)
                .background(.white.opacity(0.2))
                .clipShape(Capsule())
                
                Text("Your Global\nEducation Partner")
                    .font(.appTitle)
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
                
                Text("Discover universities, scholarships, and opportunities worldwide")
                    .font(.appSubheadline)
                    .foregroundColor(.white.opacity(0.9))
                    .lineLimit(2)
                
                HStack(spacing: Spacing.sm) {
                    Button("Explore Universities") {
                        HapticManager.shared.medium()
                        appState.selectedTab = .studyHub
                    }
                    .buttonStyle(PrimaryButtonStyle(size: .small))
                    
                    Button {
                        HapticManager.shared.tap()
                        appState.selectedTab = .journey
                    } label: {
                        HStack(spacing: Spacing.xxs) {
                            Text("Learn More")
                            Image(systemName: "arrow.right")
                        }
                        .font(.appCaption)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal, Spacing.md)
                        .padding(.vertical, Spacing.xs)
                        .background(.white.opacity(0.2))
                        .clipShape(Capsule())
                    }
                }
            }
            .padding(Spacing.xl)
        }
        .shadow(color: .black.opacity(0.15), radius: 20, x: 0, y: 10)
    }
    
    private var heroPlaceholder: some View {
        LinearGradient(
            colors: [Color.brand, Color.brandDark],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    // MARK: - Country Hero Section
    
    private func countryHeroSection(_ country: DestinationCountry) -> some View {
        ZStack(alignment: .bottomLeading) {
            // Background Image
            GeometryReader { geometry in
                AsyncImage(url: URL(string: country.heroImage)) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: geometry.size.width)
                    case .failure, .empty:
                        LinearGradient(
                            colors: [Color(hex: country.colorHex), Color(hex: country.colorHex).opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    @unknown default:
                        Color.brand.opacity(0.2)
                    }
                }
            }
            .frame(height: 240)
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.xxl, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: CornerRadius.xxl, style: .continuous)
                    .fill(LinearGradient.heroOverlay)
            }
            
            // Content
            VStack(alignment: .leading, spacing: Spacing.md) {
                // Country Badge
                HStack(spacing: Spacing.xs) {
                    Text(country.flag)
                    Text("Study in \(country.name)")
                        .font(.appCaption)
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .padding(.horizontal, Spacing.sm)
                .padding(.vertical, Spacing.xxs)
                .background(.white.opacity(0.2))
                .clipShape(Capsule())
                
                if let overview = dataService.countryOverview {
                    Text(overview.description)
                        .font(.appSubheadline)
                        .foregroundColor(.white.opacity(0.9))
                        .lineLimit(2)
                } else {
                    Text("Explore universities, scholarships, and career opportunities")
                        .font(.appSubheadline)
                        .foregroundColor(.white.opacity(0.9))
                        .lineLimit(2)
                }
                
                // Quick info chips
                HStack(spacing: Spacing.sm) {
                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                            .font(.caption2)
                        Text(country.workHoursAllowed)
                            .font(.appCaption2)
                    }
                    .foregroundColor(.white.opacity(0.9))
                    .padding(.horizontal, Spacing.sm)
                    .padding(.vertical, Spacing.xxs)
                    .background(.white.opacity(0.2))
                    .clipShape(Capsule())
                    
                    HStack(spacing: 4) {
                        Image(systemName: "doc.text")
                            .font(.caption2)
                        Text(country.primaryLanguageTest)
                            .font(.appCaption2)
                    }
                    .foregroundColor(.white.opacity(0.9))
                    .padding(.horizontal, Spacing.sm)
                    .padding(.vertical, Spacing.xxs)
                    .background(.white.opacity(0.2))
                    .clipShape(Capsule())
                }
                
                // View Dashboard Button
                NavigationLink {
                    CountryDashboardView()
                } label: {
                    HStack(spacing: Spacing.xs) {
                        Text("View Full Dashboard")
                        Image(systemName: "arrow.right")
                    }
                    .font(.appCaption)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, Spacing.md)
                    .padding(.vertical, Spacing.xs)
                    .background(.white.opacity(0.25))
                    .clipShape(Capsule())
                }
            }
            .padding(Spacing.lg)
        }
        .shadow(color: .black.opacity(0.15), radius: 20, x: 0, y: 10)
    }
    
    // MARK: - Country Quick Info Section
    
    private var countryQuickInfoSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            // Stats row
            HStack(spacing: Spacing.sm) {
                if dataService.countryUniversities.count > 0 {
                    StatBox(
                        icon: "building.columns",
                        value: "\(dataService.countryUniversities.count)",
                        label: "Universities"
                    )
                }
                
                StatBox(
                    icon: "dollarsign.circle",
                    value: "\(dataService.countryScholarships.count)",
                    label: "Scholarships"
                )
                
                if let overview = dataService.countryOverview {
                    StatBox(
                        icon: "person.3.fill",
                        value: formatStudentCount(overview.internationalStudents),
                        label: "Int'l Students"
                    )
                }
            }
            
            // Quick links to country sections
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Spacing.sm) {
                    NavigationLink {
                        CountryUniversitiesView()
                    } label: {
                        QuickCountryLink(icon: "building.columns.fill", title: "Universities", color: .blue)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    NavigationLink {
                        CountryVisaGuideView()
                    } label: {
                        QuickCountryLink(icon: "doc.badge.plus", title: "Visa Guide", color: .green)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    NavigationLink {
                        CountryScholarshipsView()
                    } label: {
                        QuickCountryLink(icon: "dollarsign.circle.fill", title: "Scholarships", color: .orange)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    NavigationLink {
                        CountryCostOfLivingView()
                    } label: {
                        QuickCountryLink(icon: "yensign.circle.fill", title: "Cost of Living", color: .purple)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    NavigationLink {
                        CountryJobsView()
                    } label: {
                        QuickCountryLink(icon: "briefcase.fill", title: "Jobs", color: .red)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
        .padding(Spacing.md)
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.xl))
        .cardShadow()
    }
    
    private func formatStudentCount(_ count: Int) -> String {
        if count >= 1000000 {
            return String(format: "%.1fM", Double(count) / 1000000)
        } else if count >= 1000 {
            return String(format: "%.0fK", Double(count) / 1000)
        }
        return "\(count)"
    }
    
    // MARK: - Quick Actions
    
    private var quickActionsSection: some View {
        HStack(spacing: Spacing.sm) {
            QuickActionButton(
                icon: "building.columns.fill",
                title: "Universities",
                color: .brand
            ) {
                appState.selectedTab = .studyHub
            }
            
            QuickActionButton(
                icon: "airplane.departure",
                title: "Journey",
                color: .secondary
            ) {
                appState.selectedTab = .journey
            }
            
            QuickActionButton(
                icon: "briefcase.fill",
                title: "Jobs",
                color: .tertiary
            ) {
                appState.selectedTab = .placement
            }
            
            QuickActionButton(
                icon: "dollarsign.circle.fill",
                title: "Money",
                color: .accent
            ) {
                appState.selectedTab = .remittance
            }
        }
    }
    
    // MARK: - Nepal Services Hub Section
    
    private var nepalServicesSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: Spacing.xs) {
                        Text("🇳🇵")
                        Text("For Nepali Students")
                            .font(.appTitle3)
                            .fontWeight(.bold)
                            .foregroundColor(.textPrimary)
                    }
                    
                    Text("Complete tools for studying abroad")
                        .font(.appCaption)
                        .foregroundColor(.textSecondary)
                }
                
                Spacer()
                
                NavigationLink {
                    NepalServicesView()
                } label: {
                    Text("View All")
                        .font(.appCaption)
                        .fontWeight(.semibold)
                        .foregroundColor(.brand)
                }
            }
            
            // Quick Access Cards
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Spacing.md) {
                    NavigationLink {
                        TestPrepView()
                    } label: {
                        NepalServiceQuickCard(
                            icon: "doc.text.fill",
                            title: "Test Prep",
                            subtitle: "IELTS, JLPT, TOPIK",
                            color: .red
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    NavigationLink {
                        VisaGuideView()
                    } label: {
                        NepalServiceQuickCard(
                            icon: "doc.badge.plus",
                            title: "Visa Guide",
                            subtitle: "Step-by-step help",
                            color: .blue
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    NavigationLink {
                        CostOfLivingView()
                    } label: {
                        NepalServiceQuickCard(
                            icon: "banknote.fill",
                            title: "Cost Calculator",
                            subtitle: "Living expenses",
                            color: .green
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    NavigationLink {
                        CurrencyConverterView()
                    } label: {
                        NepalServiceQuickCard(
                            icon: "dollarsign.arrow.circlepath",
                            title: "Currency",
                            subtitle: "NPR rates",
                            color: .orange
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    NavigationLink {
                        EmbassyDirectoryView()
                    } label: {
                        NepalServiceQuickCard(
                            icon: "building.columns.fill",
                            title: "Embassies",
                            subtitle: "Emergency contacts",
                            color: .purple
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
        .padding(Spacing.lg)
        .background(
            LinearGradient(
                colors: [Color(hex: "DC143C").opacity(0.08), Color(hex: "003893").opacity(0.05)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.large))
    }
    
    // MARK: - Services Section
    
    private var servicesSection: some View {
        VStack(alignment: .leading, spacing: Spacing.lg) {
            SectionHeader(title: "Our Services", subtitle: "Everything for your educational journey")
            
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: Spacing.md),
                GridItem(.flexible(), spacing: Spacing.md)
            ], spacing: Spacing.md) {
                ForEach(dataService.services) { service in
                    ServiceCard(service: service)
                        .onTapGesture {
                            HapticManager.shared.medium()
                            navigateToService(service)
                        }
                }
            }
        }
    }
    
    // MARK: - Featured Universities
    
    private var featuredUniversitiesSection: some View {
        VStack(alignment: .leading, spacing: Spacing.lg) {
            HStack {
                if let country = appState.selectedCountry {
                    SectionHeader(title: "Top Universities in \(country.name)", subtitle: nil)
                } else {
                    SectionHeader(title: "Top Universities", subtitle: nil)
                }
                Spacer()
                Button {
                    HapticManager.shared.tap()
                    appState.selectedTab = .studyHub
                } label: {
                    HStack(spacing: Spacing.xxs) {
                        Text("View All")
                        Image(systemName: "chevron.right")
                    }
                    .font(.appCaption)
                    .fontWeight(.semibold)
                    .foregroundColor(.brand)
                }
            }
            
            if filteredUniversities.isEmpty {
                EmptyStateCard(
                    icon: "building.columns",
                    title: "No Universities",
                    message: hasSelectedCountry ? "No universities found for this country" : "Universities will appear here"
                )
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: Spacing.md) {
                        ForEach(filteredUniversities.prefix(5)) { university in
                            NavigationLink {
                                UniversityDetailView(university: university)
                            } label: {
                                UniversityCard(university: university)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal, 2)
                    .padding(.vertical, 4)
                }
                .padding(.horizontal, -2)
            }
        }
    }
    
    // MARK: - Updates Section
    
    private var updatesSection: some View {
        VStack(alignment: .leading, spacing: Spacing.lg) {
            HStack {
                SectionHeader(title: "Latest Updates", subtitle: nil)
                Spacer()
                NavigationLink {
                    UpdatesListView()
                } label: {
                    HStack(spacing: Spacing.xxs) {
                        Text("See All")
                        Image(systemName: "chevron.right")
                    }
                    .font(.appCaption)
                    .fontWeight(.semibold)
                    .foregroundColor(.brand)
                }
            }
            
            if dataService.updates.isEmpty {
                EmptyStateCard(
                    icon: "newspaper",
                    title: "No Updates",
                    message: "Latest news will appear here"
                )
            } else {
                VStack(spacing: Spacing.sm) {
                    ForEach(dataService.updates.prefix(3)) { update in
                        UpdateCard(update: update)
                    }
                }
            }
        }
    }
    
    // MARK: - Scholarships Section
    
    private var scholarshipsSection: some View {
        VStack(alignment: .leading, spacing: Spacing.lg) {
            HStack {
                if let country = appState.selectedCountry {
                    SectionHeader(title: "Scholarships in \(country.name)", subtitle: nil)
                } else {
                    SectionHeader(title: "Scholarships", subtitle: nil)
                }
                Spacer()
                NavigationLink {
                    ScholarshipsView()
                } label: {
                    HStack(spacing: Spacing.xxs) {
                        Text("View All")
                        Image(systemName: "chevron.right")
                    }
                    .font(.appCaption)
                    .fontWeight(.semibold)
                    .foregroundColor(.brand)
                }
            }
            
            if filteredScholarships.isEmpty {
                EmptyStateCard(
                    icon: "dollarsign.circle",
                    title: "No Scholarships",
                    message: hasSelectedCountry ? "No scholarships found for this country" : "Scholarship opportunities will appear here"
                )
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: Spacing.md) {
                        ForEach(filteredScholarships.prefix(5)) { scholarship in
                            NavigationLink {
                                ScholarshipDetailView(scholarship: scholarship)
                            } label: {
                                ScholarshipCard(scholarship: scholarship)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal, 2)
                    .padding(.vertical, 4)
                }
                .padding(.horizontal, -2)
            }
        }
    }
    
    // MARK: - Guides Section
    
    private var guidesSection: some View {
        VStack(alignment: .leading, spacing: Spacing.lg) {
            HStack {
                SectionHeader(title: "Student Guides", subtitle: nil)
                Spacer()
                NavigationLink {
                    GuidesListView()
                } label: {
                    HStack(spacing: Spacing.xxs) {
                        Text("See All")
                        Image(systemName: "chevron.right")
                    }
                    .font(.appCaption)
                    .fontWeight(.semibold)
                    .foregroundColor(.brand)
                }
            }
            
            if dataService.guides.isEmpty {
                EmptyStateCard(
                    icon: "book.closed",
                    title: "No Guides Yet",
                    message: "Student guides will appear here"
                )
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: Spacing.md) {
                        ForEach(dataService.guides.prefix(5)) { guide in
                            NavigationLink {
                                GuideDetailView(guide: guide)
                            } label: {
                                GuideCard(guide: guide)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal, 2)
                    .padding(.vertical, 4)
                }
                .padding(.horizontal, -2)
            }
        }
    }
    
    // MARK: - Navigation Helper
    
    private func navigateToService(_ service: ServiceCategory) {
        switch service.id {
        case "study-hub":
            appState.selectedTab = .studyHub
        case "journey":
            appState.selectedTab = .journey
        case "placement":
            appState.selectedTab = .placement
        case "remittance":
            appState.selectedTab = .remittance
        default:
            break
        }
    }
}

// MARK: - Quick Action Button

struct QuickActionButton: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            HapticManager.shared.tap()
            action()
        }) {
            VStack(spacing: Spacing.xs) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.12))
                        .frame(width: 52, height: 52)
                    
                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(color)
                }
                
                Text(title)
                    .font(.appCaption2)
                    .fontWeight(.medium)
                    .foregroundColor(.textSecondary)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, Spacing.sm)
            .background(Color.backgroundSecondary)
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.large, style: .continuous))
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Nepal Service Quick Card

struct NepalServiceQuickCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 40, height: 40)
                
                Image(systemName: icon)
                    .font(.body)
                    .foregroundColor(color)
            }
            
            Text(title)
                .font(.appSubheadline)
                .fontWeight(.semibold)
                .foregroundColor(.textPrimary)
            
            Text(subtitle)
                .font(.appCaption2)
                .foregroundColor(.textSecondary)
                .lineLimit(1)
        }
        .padding(Spacing.md)
        .frame(width: 120)
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium))
        .cardShadow()
    }
}

// MARK: - Section Header

struct SectionHeader: View {
    let title: String
    var subtitle: String? = nil
    var icon: String? = nil
    
    init(title: String, subtitle: String? = nil) {
        self.title = title
        self.subtitle = subtitle
        self.icon = nil
    }
    
    init(title: String, icon: String) {
        self.title = title
        self.icon = icon
        self.subtitle = nil
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xxs) {
            HStack(spacing: Spacing.xs) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.appHeadline)
                        .foregroundColor(.brand)
                }
                
                Text(title)
                    .font(.appTitle3)
                    .fontWeight(.bold)
                    .foregroundColor(.textPrimary)
            }
            
            if let subtitle = subtitle {
                Text(subtitle)
                    .font(.appSubheadline)
                    .foregroundColor(.textSecondary)
            }
        }
    }
}

// MARK: - Empty State Card

struct EmptyStateCard: View {
    let icon: String
    let title: String
    let message: String
    
    var body: some View {
        VStack(spacing: Spacing.md) {
            Image(systemName: icon)
                .font(.system(size: 32))
                .foregroundColor(.brand.opacity(0.5))
            
            Text(title)
                .font(.appHeadline)
                .foregroundColor(.textSecondary)
            
            Text(message)
                .font(.appCaption)
                .foregroundColor(.textTertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(Spacing.xl)
        .background(Color.backgroundSecondary)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.large, style: .continuous))
    }
}

// MARK: - Service Card (Premium)

struct ServiceCard: View {
    let service: ServiceCategory
    @State private var isPressed = false
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            // Background Image
            AsyncImage(url: URL(string: service.image)) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                case .failure, .empty:
                    LinearGradient.brandGradient
                @unknown default:
                    Color.brand.opacity(0.2)
                }
            }
            .frame(height: 160)
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.xl, style: .continuous))
            
            // Overlay
            RoundedRectangle(cornerRadius: CornerRadius.xl, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Color.black.opacity(0.1), Color.black.opacity(0.7)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            
            // Content
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text(service.icon)
                    .font(.system(size: 28))
                    .shadow(color: .black.opacity(0.3), radius: 4)
                
                Text(service.title)
                    .font(.appHeadline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text(service.description)
                    .font(.appCaption)
                    .foregroundColor(.white.opacity(0.85))
                    .lineLimit(2)
            }
            .padding(Spacing.md)
        }
        .scaleEffect(isPressed ? 0.97 : 1.0)
        .animation(.spring(response: 0.3), value: isPressed)
        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
        .onLongPressGesture(minimumDuration: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }
}

// MARK: - Quick Country Link

struct QuickCountryLink: View {
    let icon: String
    let title: String
    let color: Color
    
    var body: some View {
        HStack(spacing: Spacing.sm) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 32, height: 32)
                
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundColor(color)
            }
            
            Text(title)
                .font(.appCaption)
                .fontWeight(.medium)
                .foregroundColor(.textPrimary)
        }
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, Spacing.sm)
        .background(Color.backgroundSecondary)
        .clipShape(Capsule())
    }
}

// MARK: - Preview

#Preview {
    HomeView()
        .environmentObject(AppState())
        .environmentObject(DataService.shared)
}
