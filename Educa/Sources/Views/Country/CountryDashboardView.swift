//
//  CountryDashboardView.swift
//  Educa
//
//  Main country-specific dashboard showing all relevant information
//

import SwiftUI

struct CountryDashboardView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var dataService: DataService
    @State private var animateContent = false
    @State private var showCountrySelector = false
    
    var country: DestinationCountry? {
        appState.selectedCountry
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.backgroundPrimary.ignoresSafeArea()
                
                if let country = country {
                    ScrollView {
                        VStack(spacing: Spacing.xl) {
                            // Country Hero
                            countryHero(country)
                            
                            // Quick Stats
                            quickStats
                            
                            // Main Sections
                            studySection
                            
                            visaSection
                            
                            jobsSection
                            
                            costOfLivingSection
                            
                            scholarshipsSection
                            
                            cultureSection
                        }
                        .padding(.horizontal, Spacing.md)
                        .padding(.bottom, 120)
                    }
                    .scrollIndicators(.hidden)
                    .refreshable {
                        if let country = appState.selectedCountry {
                            await dataService.loadCountryData(for: country)
                        }
                    }
                } else {
                    noCountrySelected
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if let country = country {
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
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    ProfileMenuButton()
                }
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
            withAnimation(.easeOut(duration: 0.5)) {
                animateContent = true
            }
            // Load country data if not already loaded
            if let country = appState.selectedCountry, dataService.currentCountry != country {
                Task {
                    await dataService.loadCountryData(for: country)
                }
            }
        }
    }
    
    // MARK: - Country Hero
    
    private func countryHero(_ country: DestinationCountry) -> some View {
        ZStack(alignment: .bottomLeading) {
            // Background Image
            AsyncImage(url: URL(string: country.heroImage)) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
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
            .frame(height: 220)
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.xxl, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: CornerRadius.xxl, style: .continuous)
                    .fill(LinearGradient.heroOverlay)
            }
            
            // Content
            VStack(alignment: .leading, spacing: Spacing.sm) {
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
                }
                
                // Quick info
                HStack(spacing: Spacing.md) {
                    InfoChip(icon: "clock", text: country.workHoursAllowed)
                    InfoChip(icon: "doc.text", text: country.primaryLanguageTest)
                    InfoChip(icon: "yensign.circle", text: country.currency)
                }
            }
            .padding(Spacing.lg)
        }
        .opacity(animateContent ? 1 : 0)
        .offset(y: animateContent ? 0 : 20)
    }
    
    // MARK: - Quick Stats
    
    private var quickStats: some View {
        HStack(spacing: Spacing.sm) {
            if let overview = dataService.countryOverview {
                StatBox(
                    icon: "building.columns",
                    value: "\(dataService.countryUniversities.count > 0 ? dataService.countryUniversities.count : overview.universitiesCount)",
                    label: "Universities"
                )
                
                StatBox(
                    icon: "person.3.fill",
                    value: formatNumber(overview.internationalStudents),
                    label: "Int'l Students"
                )
            }
            
            StatBox(
                icon: "dollarsign.circle",
                value: "\(dataService.countryScholarships.count)",
                label: "Scholarships"
            )
            
            StatBox(
                icon: "briefcase",
                value: "\(dataService.getJobsForCurrentCountry().count)",
                label: "Jobs"
            )
        }
        .opacity(animateContent ? 1 : 0)
        .offset(y: animateContent ? 0 : 20)
    }
    
    // MARK: - Study Section
    
    private var studySection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            HStack {
                SectionHeader(title: "📚 Study", subtitle: nil)
                Spacer()
                NavigationLink {
                    CountryUniversitiesView()
                } label: {
                    Text("See All")
                        .font(.appCaption)
                        .fontWeight(.semibold)
                        .foregroundColor(.brand)
                }
            }
            
            // Top Universities
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Spacing.md) {
                    ForEach(dataService.countryUniversities.prefix(5)) { university in
                        NavigationLink {
                            CountryUniversityDetailView(university: university)
                        } label: {
                            CountryUniversityCard(university: university)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal, 2)
            }
            
            // Language Test & Application
            HStack(spacing: Spacing.md) {
                NavigationLink {
                    CountryLanguageTestsView()
                } label: {
                    QuickLinkCard(
                        icon: "textformat.abc",
                        title: country?.primaryLanguageTest ?? "Language Test",
                        subtitle: "Test preparation",
                        color: .red
                    )
                }
                .buttonStyle(PlainButtonStyle())
                
                NavigationLink {
                    ApplicationGuideView()
                } label: {
                    QuickLinkCard(
                        icon: "doc.badge.plus",
                        title: "Apply",
                        subtitle: "Application guide",
                        color: .blue
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
    
    // MARK: - Visa Section
    
    private var visaSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            SectionHeader(title: "✈️ Visa & Journey", subtitle: nil)
            
            NavigationLink {
                CountryVisaGuideView()
            } label: {
                if let visaInfo = dataService.countryVisaInfo {
                    VisaOverviewCard(visaInfo: visaInfo, country: country!)
                } else {
                    VisaPlaceholderCard(country: country!)
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            // Quick Links
            HStack(spacing: Spacing.md) {
                NavigationLink {
                    CountryChecklistView()
                } label: {
                    QuickLinkCard(
                        icon: "checklist",
                        title: "Checklist",
                        subtitle: "Documents needed",
                        color: .green
                    )
                }
                .buttonStyle(PlainButtonStyle())
                
                NavigationLink {
                    CountryEmbassyView()
                } label: {
                    QuickLinkCard(
                        icon: "building.2",
                        title: "Embassy",
                        subtitle: "Contact info",
                        color: .purple
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
    
    // MARK: - Jobs Section
    
    private var jobsSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            HStack {
                SectionHeader(title: "💼 Jobs & Work", subtitle: nil)
                Spacer()
                NavigationLink {
                    CountryJobsView()
                } label: {
                    Text("See All")
                        .font(.appCaption)
                        .fontWeight(.semibold)
                        .foregroundColor(.brand)
                }
            }
            
            if let jobInfo = dataService.countryPartTimeJobs {
                // Part-time info card
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    HStack {
                        VStack(alignment: .leading, spacing: Spacing.xxs) {
                            Text("Part-time Work")
                                .font(.appHeadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.textPrimary)
                            
                            HStack(spacing: Spacing.sm) {
                                Label(jobInfo.workPermission, systemImage: "clock")
                                Label(jobInfo.averageHourlyWage, systemImage: "yensign.circle")
                            }
                            .font(.appCaption)
                            .foregroundColor(.textSecondary)
                        }
                        
                        Spacer()
                        
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
            
            // Common job types
            if let jobInfo = dataService.countryPartTimeJobs {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: Spacing.sm) {
                        ForEach(jobInfo.commonJobs.prefix(4)) { job in
                            JobTypeChip(job: job)
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Cost of Living Section
    
    private var costOfLivingSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            SectionHeader(title: "💰 Cost of Living", subtitle: nil)
            
            NavigationLink {
                CountryCostOfLivingView()
            } label: {
                if let costInfo = dataService.countryCostOfLiving {
                    CostOverviewCard(costInfo: costInfo, country: country!)
                } else {
                    PlaceholderCostCard()
                }
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
    
    // MARK: - Scholarships Section
    
    private var scholarshipsSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            HStack {
                SectionHeader(title: "🎓 Scholarships", subtitle: nil)
                Spacer()
                NavigationLink {
                    CountryScholarshipsView()
                } label: {
                    Text("See All")
                        .font(.appCaption)
                        .fontWeight(.semibold)
                        .foregroundColor(.brand)
                }
            }
            
            if dataService.countryScholarships.isEmpty {
                EmptyStateCard(
                    icon: "dollarsign.circle",
                    title: "Scholarships Coming Soon",
                    message: "We're adding scholarship data for this country"
                )
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: Spacing.md) {
                        ForEach(dataService.countryScholarships.prefix(3)) { scholarship in
                            NavigationLink {
                                CountryScholarshipDetailView(scholarship: scholarship)
                            } label: {
                                ScholarshipMiniCard(scholarship: scholarship)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal, 2)
                }
            }
        }
    }
    
    // MARK: - Culture Section
    
    private var cultureSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            SectionHeader(title: "🎌 Culture & Life", subtitle: nil)
            
            HStack(spacing: Spacing.md) {
                NavigationLink {
                    CountryCultureView()
                } label: {
                    QuickLinkCard(
                        icon: "heart.fill",
                        title: "Culture Tips",
                        subtitle: "Etiquette & customs",
                        color: .pink
                    )
                }
                .buttonStyle(PlainButtonStyle())
                
                NavigationLink {
                    CountryAccommodationView()
                } label: {
                    QuickLinkCard(
                        icon: "house.fill",
                        title: "Accommodation",
                        subtitle: "Housing options",
                        color: .orange
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            // Useful phrases (for Japan)
            if let cultureTips = dataService.countryCultureTips,
               let phrases = cultureTips.importantPhrases, !phrases.isEmpty {
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    Text("Useful Phrases")
                        .font(.appSubheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.textPrimary)
                    
                    ForEach(phrases.prefix(3)) { phrase in
                        HStack {
                            Text(phrase.japanese)
                                .font(.appBody)
                                .foregroundColor(.brand)
                            Spacer()
                            Text(phrase.meaning)
                                .font(.appCaption)
                                .foregroundColor(.textSecondary)
                        }
                        .padding(Spacing.sm)
                        .background(Color.backgroundSecondary)
                        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium))
                    }
                }
            }
        }
    }
    
    // MARK: - No Country Selected
    
    private var noCountrySelected: some View {
        VStack(spacing: Spacing.xl) {
            Image(systemName: "globe.americas.fill")
                .font(.system(size: 60))
                .foregroundColor(.brand.opacity(0.5))
            
            Text("Select Your Destination")
                .font(.appTitle2)
                .foregroundColor(.textPrimary)
            
            Text("Choose a country to see personalized\nuniversity, visa, and job information")
                .font(.appSubheadline)
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
            
            Button {
                showCountrySelector = true
            } label: {
                Label("Choose Country", systemImage: "globe")
            }
            .buttonStyle(PrimaryButtonStyle())
        }
        .padding(Spacing.xl)
    }
    
    // MARK: - Helpers
    
    private func formatNumber(_ number: Int) -> String {
        if number >= 1000000 {
            return String(format: "%.1fM", Double(number) / 1000000)
        } else if number >= 1000 {
            return String(format: "%.0fK", Double(number) / 1000)
        }
        return "\(number)"
    }
}

// MARK: - Supporting Views

struct InfoChip: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption2)
            Text(text)
                .font(.appCaption2)
        }
        .foregroundColor(.white.opacity(0.9))
        .padding(.horizontal, Spacing.sm)
        .padding(.vertical, Spacing.xxs)
        .background(.white.opacity(0.2))
        .clipShape(Capsule())
    }
}

struct QuickLinkCard: View {
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
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(Spacing.md)
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.large))
        .cardShadow()
    }
}

struct JobTypeChip: View {
    let job: CommonPartTimeJob
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xxs) {
            Text(job.title)
                .font(.appCaption)
                .fontWeight(.semibold)
                .foregroundColor(.textPrimary)
            
            Text(job.wageRange)
                .font(.appCaption2)
                .foregroundColor(.brand)
        }
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, Spacing.sm)
        .background(Color.backgroundSecondary)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium))
    }
}

struct VisaOverviewCard: View {
    let visaInfo: CountryVisaInfo
    let country: DestinationCountry
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            HStack {
                VStack(alignment: .leading, spacing: Spacing.xxs) {
                    Text(visaInfo.visaType)
                        .font(.appHeadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.textPrimary)
                    
                    Text("Processing: \(visaInfo.processingTime)")
                        .font(.appCaption)
                        .foregroundColor(.textSecondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: Spacing.xxs) {
                    Text(visaInfo.visaFee)
                        .font(.appHeadline)
                        .fontWeight(.bold)
                        .foregroundColor(.brand)
                    
                    Text("Visa Fee")
                        .font(.appCaption2)
                        .foregroundColor(.textTertiary)
                }
            }
            
            // Work permission
            HStack(spacing: Spacing.sm) {
                Image(systemName: "briefcase.fill")
                    .foregroundColor(.green)
                Text("Work: \(visaInfo.workPermission)")
                    .font(.appCaption)
                    .foregroundColor(.textSecondary)
            }
            
            HStack {
                Text("View full visa guide")
                    .font(.appCaption)
                    .foregroundColor(.brand)
                Image(systemName: "arrow.right")
                    .font(.caption)
                    .foregroundColor(.brand)
            }
        }
        .padding(Spacing.md)
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.large))
        .cardShadow()
    }
}

struct VisaPlaceholderCard: View {
    let country: DestinationCountry
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: Spacing.xxs) {
                Text(country.visaType)
                    .font(.appHeadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.textPrimary)
                
                Text("Tap for visa information")
                    .font(.appCaption)
                    .foregroundColor(.textSecondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.textTertiary)
        }
        .padding(Spacing.md)
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.large))
        .cardShadow()
    }
}

struct CostOverviewCard: View {
    let costInfo: CountryCostOfLiving
    let country: DestinationCountry
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            HStack {
                Text("Monthly Expenses")
                    .font(.appHeadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.textPrimary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.textTertiary)
            }
            
            // Show estimates for major city
            if let tokyo = costInfo.monthlyEstimate["tokyo"] {
                HStack {
                    Text("Tokyo:")
                        .font(.appCaption)
                        .foregroundColor(.textSecondary)
                    
                    Text("\(country.currencySymbol)\(tokyo.typical.formatted())/month")
                        .font(.appSubheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.brand)
                    
                    if let usd = tokyo.inUsd {
                        Text("(\(usd))")
                            .font(.appCaption)
                            .foregroundColor(.textTertiary)
                    }
                }
            }
            
            if let other = costInfo.monthlyEstimate["other_cities"] {
                HStack {
                    Text("Other cities:")
                        .font(.appCaption)
                        .foregroundColor(.textSecondary)
                    
                    Text("\(country.currencySymbol)\(other.typical.formatted())/month")
                        .font(.appSubheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.green)
                }
            }
        }
        .padding(Spacing.md)
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.large))
        .cardShadow()
    }
}

struct PlaceholderCostCard: View {
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: Spacing.xxs) {
                Text("Cost of Living")
                    .font(.appHeadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.textPrimary)
                
                Text("View monthly expense breakdown")
                    .font(.appCaption)
                    .foregroundColor(.textSecondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.textTertiary)
        }
        .padding(Spacing.md)
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.large))
        .cardShadow()
    }
}

struct ScholarshipMiniCard: View {
    let scholarship: CountryScholarship
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            // Fully funded badge
            if scholarship.isFullyFunded {
                Text("FULLY FUNDED")
                    .font(.appCaption2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.horizontal, Spacing.xs)
                    .padding(.vertical, 2)
                    .background(Color.green)
                    .clipShape(Capsule())
            }
            
            Text(scholarship.name)
                .font(.appSubheadline)
                .fontWeight(.semibold)
                .foregroundColor(.textPrimary)
                .lineLimit(2)
            
            Text(scholarship.provider)
                .font(.appCaption)
                .foregroundColor(.textSecondary)
            
            Spacer()
            
            Text(scholarship.amount)
                .font(.appCaption)
                .fontWeight(.semibold)
                .foregroundColor(.brand)
        }
        .frame(width: 180, height: 140, alignment: .leading)
        .padding(Spacing.md)
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.large))
        .cardShadow()
    }
}

struct CountryUniversityCard: View {
    let university: CountryUniversity
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            // Image
            AsyncImage(url: URL(string: university.image)) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                case .failure, .empty:
                    LinearGradient.brandGradient
                        .overlay {
                            Image(systemName: "building.columns")
                                .font(.title)
                                .foregroundColor(.white.opacity(0.5))
                        }
                @unknown default:
                    Color.gray.opacity(0.2)
                }
            }
            .frame(height: 100)
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium))
            
            // Info
            VStack(alignment: .leading, spacing: Spacing.xxs) {
                Text(university.title)
                    .font(.appCaption)
                    .fontWeight(.semibold)
                    .foregroundColor(.textPrimary)
                    .lineLimit(2)
                
                HStack(spacing: Spacing.xs) {
                    if let ranking = university.ranking {
                        Text("#\(ranking)")
                            .font(.appCaption2)
                            .fontWeight(.semibold)
                            .foregroundColor(.brand)
                    }
                    
                    HStack(spacing: 2) {
                        Image(systemName: "star.fill")
                            .font(.caption2)
                            .foregroundColor(.yellow)
                        Text(String(format: "%.1f", university.rating))
                            .font(.appCaption2)
                            .foregroundColor(.textSecondary)
                    }
                }
                
                Text(university.annualFee)
                    .font(.appCaption2)
                    .foregroundColor(.textSecondary)
            }
        }
        .frame(width: 160)
        .padding(Spacing.sm)
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.large))
        .cardShadow()
    }
}

// MARK: - Preview

#Preview {
    CountryDashboardView()
        .environmentObject(AppState())
        .environmentObject(DataService.shared)
}

