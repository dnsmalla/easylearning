//
//  CountryDetailViews.swift
//  Educa
//
//  Detailed views for country-specific content
//

import SwiftUI

// MARK: - Country Universities View

struct CountryUniversitiesView: View {
    @EnvironmentObject var dataService: DataService
    @EnvironmentObject var appState: AppState
    @State private var searchText = ""
    @State private var selectedFilter: UniversityFilter = .all
    
    enum UniversityFilter: String, CaseIterable {
        case all = "All"
        case national = "National"
        case privateUni = "Private"
        case englishPrograms = "English"
        
        var displayName: String { rawValue }
    }
    
    var filteredUniversities: [CountryUniversity] {
        var result = dataService.countryUniversities
        
        if !searchText.isEmpty {
            result = result.filter {
                $0.title.lowercased().contains(searchText.lowercased()) ||
                $0.location.lowercased().contains(searchText.lowercased())
            }
        }
        
        switch selectedFilter {
        case .national:
            result = result.filter { $0.type.lowercased().contains("national") }
        case .privateUni:
            result = result.filter { $0.type.lowercased().contains("private") }
        case .englishPrograms:
            result = result.filter { $0.englishPrograms == true }
        case .all:
            break
        }
        
        return result.sorted { $0.rating > $1.rating }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Stats
            HStack(spacing: Spacing.md) {
                StatBox(icon: "building.columns", value: "\(dataService.countryUniversities.count)", label: "Universities")
                if let overview = dataService.countryOverview {
                    StatBox(icon: "person.3", value: formatNumber(overview.internationalStudents), label: "Int'l Students")
                }
                StatBox(icon: "star.fill", value: String(format: "%.1f", averageRating), label: "Avg Rating")
            }
            .padding(Spacing.md)
            
            // Filters
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Spacing.sm) {
                    ForEach(UniversityFilter.allCases, id: \.self) { filter in
                        FilterPill(
                            title: filter.displayName,
                            isSelected: selectedFilter == filter
                        ) {
                            selectedFilter = filter
                        }
                    }
                }
                .padding(.horizontal, Spacing.md)
            }
            .padding(.bottom, Spacing.sm)
            
            // Search
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.textTertiary)
                TextField("Search universities...", text: $searchText)
            }
            .padding(Spacing.sm)
            .background(Color.backgroundSecondary)
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium))
            .padding(.horizontal, Spacing.md)
            .padding(.bottom, Spacing.sm)
            
            // Universities List
            if filteredUniversities.isEmpty {
                Spacer()
                EmptyStateView(
                    icon: "building.columns",
                    title: "No Universities Found",
                    message: "Try adjusting your search"
                )
                Spacer()
            } else {
                ScrollView {
                    LazyVStack(spacing: Spacing.md) {
                        ForEach(filteredUniversities) { university in
                            NavigationLink {
                                CountryUniversityDetailView(university: university)
                            } label: {
                                UniversityListCard(university: university)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(Spacing.md)
                    .padding(.bottom, 100)
                }
            }
        }
        .background(Color.backgroundPrimary)
        .navigationTitle("Universities")
    }
    
    private var averageRating: Double {
        guard !dataService.countryUniversities.isEmpty else { return 0 }
        return dataService.countryUniversities.reduce(0) { $0 + $1.rating } / Double(dataService.countryUniversities.count)
    }
    
    private func formatNumber(_ number: Int) -> String {
        if number >= 1000 {
            return String(format: "%.0fK", Double(number) / 1000)
        }
        return "\(number)"
    }
}

struct UniversityListCard: View {
    let university: CountryUniversity
    
    var body: some View {
        HStack(spacing: Spacing.md) {
            // Image
            AsyncImage(url: URL(string: university.image)) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                default:
                    LinearGradient.brandGradient
                        .overlay {
                            Image(systemName: "building.columns")
                                .foregroundColor(.white.opacity(0.5))
                        }
                }
            }
            .frame(width: 80, height: 80)
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium))
            
            // Info
            VStack(alignment: .leading, spacing: Spacing.xxs) {
                HStack {
                    Text(university.title)
                        .font(.appSubheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.textPrimary)
                        .lineLimit(2)
                    
                    if university.englishPrograms == true {
                        Text("EN")
                            .font(.appCaption2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.green)
                            .clipShape(Capsule())
                    }
                }
                
                Text(university.location)
                    .font(.appCaption)
                    .foregroundColor(.textSecondary)
                
                HStack(spacing: Spacing.md) {
                    if let ranking = university.ranking {
                        HStack(spacing: 2) {
                            Image(systemName: "trophy.fill")
                                .font(.caption2)
                                .foregroundColor(.yellow)
                            Text("#\(ranking)")
                                .font(.appCaption)
                                .fontWeight(.semibold)
                                .foregroundColor(.textPrimary)
                        }
                    }
                    
                    HStack(spacing: 2) {
                        Image(systemName: "star.fill")
                            .font(.caption2)
                            .foregroundColor(.yellow)
                        Text(String(format: "%.1f", university.rating))
                            .font(.appCaption)
                            .foregroundColor(.textSecondary)
                    }
                }
                
                Text(university.annualFee)
                    .font(.appCaption)
                    .fontWeight(.semibold)
                    .foregroundColor(.brand)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.textTertiary)
        }
        .padding(Spacing.md)
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.large))
        .cardShadow()
    }
}

// MARK: - Country University Detail View

struct CountryUniversityDetailView: View {
    let university: CountryUniversity
    @ObservedObject private var userData = UserDataManager.shared
    
    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.lg) {
                // Hero Image
                ZStack(alignment: .bottomLeading) {
                    AsyncImage(url: URL(string: university.image)) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        default:
                            LinearGradient.brandGradient
                        }
                    }
                    .frame(height: 220)
                    .clipShape(RoundedRectangle(cornerRadius: CornerRadius.xxl))
                    .overlay {
                        RoundedRectangle(cornerRadius: CornerRadius.xxl)
                            .fill(LinearGradient.heroOverlay)
                    }
                    
                    // Badge
                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        if let ranking = university.ranking {
                            HStack(spacing: Spacing.xs) {
                                Image(systemName: "trophy.fill")
                                    .foregroundColor(.yellow)
                                Text("World Rank #\(ranking)")
                                    .font(.appCaption)
                                    .fontWeight(.bold)
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, Spacing.sm)
                            .padding(.vertical, Spacing.xxs)
                            .background(.black.opacity(0.4))
                            .clipShape(Capsule())
                        }
                    }
                    .padding(Spacing.md)
                }
                
                // Title & Basic Info
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    Text(university.title)
                        .font(.appTitle2)
                        .fontWeight(.bold)
                        .foregroundColor(.textPrimary)
                    
                    if let japaneseName = university.japaneseName {
                        Text(japaneseName)
                            .font(.appSubheadline)
                            .foregroundColor(.textSecondary)
                    }
                    
                    HStack(spacing: Spacing.lg) {
                        Label(university.location, systemImage: "mappin.circle.fill")
                        Label(university.type, systemImage: "building.2.fill")
                    }
                    .font(.appCaption)
                    .foregroundColor(.textSecondary)
                    
                    // Rating & Students
                    HStack(spacing: Spacing.lg) {
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                            Text(String(format: "%.1f", university.rating))
                                .fontWeight(.semibold)
                        }
                        
                        if let students = university.studentCount {
                            HStack(spacing: 4) {
                                Image(systemName: "person.3.fill")
                                    .foregroundColor(.brand)
                                Text("\(students.formatted()) students")
                            }
                        }
                        
                        if let intl = university.internationalStudents {
                            HStack(spacing: 4) {
                                Image(systemName: "globe")
                                    .foregroundColor(.green)
                                Text("\(intl.formatted()) int'l")
                            }
                        }
                    }
                    .font(.appCaption)
                    .foregroundColor(.textSecondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                // Tuition
                HStack {
                    VStack(alignment: .leading, spacing: Spacing.xxs) {
                        Text("Annual Tuition")
                            .font(.appCaption)
                            .foregroundColor(.textSecondary)
                        Text(university.annualFee)
                            .font(.appTitle3)
                            .fontWeight(.bold)
                            .foregroundColor(.brand)
                        if let usd = university.annualFeeUsd {
                            Text("≈ \(usd)")
                                .font(.appCaption)
                                .foregroundColor(.textTertiary)
                        }
                    }
                    
                    Spacer()
                    
                    // Features
                    HStack(spacing: Spacing.sm) {
                        if university.englishPrograms == true {
                            FeatureBadge(icon: "globe", text: "English")
                        }
                        if university.scholarshipAvailable == true {
                            FeatureBadge(icon: "dollarsign.circle", text: "Scholarships")
                        }
                        if university.dormitoryAvailable == true {
                            FeatureBadge(icon: "house", text: "Dorm")
                        }
                    }
                }
                .padding(Spacing.md)
                .background(Color.backgroundSecondary)
                .clipShape(RoundedRectangle(cornerRadius: CornerRadius.large))
                
                // Description
                InfoSection(title: "About") {
                    Text(university.description)
                        .font(.appBody)
                        .foregroundColor(.textSecondary)
                }
                
                // Programs
                InfoSection(title: "Programs") {
                    FlowLayout(spacing: Spacing.xs) {
                        ForEach(university.programs, id: \.self) { program in
                            Text(program)
                                .font(.appCaption)
                                .padding(.horizontal, Spacing.sm)
                                .padding(.vertical, Spacing.xxs)
                                .background(Color.brand.opacity(0.1))
                                .foregroundColor(.brand)
                                .clipShape(Capsule())
                        }
                    }
                }
                
                // Entry Requirements
                if let requirements = university.entryRequirements {
                    InfoSection(title: "Entry Requirements") {
                        if let undergrad = requirements.undergraduate {
                            VStack(alignment: .leading, spacing: Spacing.xxs) {
                                Text("Undergraduate")
                                    .font(.appCaption)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.textPrimary)
                                Text(undergrad)
                                    .font(.appBody)
                                    .foregroundColor(.textSecondary)
                            }
                        }
                        
                        if let grad = requirements.graduate {
                            VStack(alignment: .leading, spacing: Spacing.xxs) {
                                Text("Graduate")
                                    .font(.appCaption)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.textPrimary)
                                Text(grad)
                                    .font(.appBody)
                                    .foregroundColor(.textSecondary)
                            }
                            .padding(.top, Spacing.sm)
                        }
                    }
                }
                
                // Application Deadlines
                if let deadlines = university.applicationDeadlines {
                    InfoSection(title: "Application Deadlines") {
                        VStack(spacing: Spacing.sm) {
                            if let april = deadlines.aprilIntake {
                                DeadlineRow(intake: "April Intake", deadline: april)
                            }
                            if let october = deadlines.octoberIntake {
                                DeadlineRow(intake: "October Intake", deadline: october)
                            }
                            if let september = deadlines.septemberIntake {
                                DeadlineRow(intake: "September Intake", deadline: september)
                            }
                        }
                    }
                }
                
                // Actions
                VStack(spacing: Spacing.sm) {
                    if let website = university.website {
                        Link(destination: URL(string: website)!) {
                            Label("Visit Official Website", systemImage: "globe")
                        }
                        .buttonStyle(PrimaryButtonStyle(isFullWidth: true))
                    }
                    
                    Button {
                        userData.toggleUniversitySaved(university.id)
                    } label: {
                        Label(
                            userData.isUniversitySaved(university.id) ? "Saved" : "Save University",
                            systemImage: userData.isUniversitySaved(university.id) ? "heart.fill" : "heart"
                        )
                    }
                    .buttonStyle(SecondaryButtonStyle(isFullWidth: true))
                }
            }
            .padding(Spacing.md)
            .padding(.bottom, Spacing.xxl)
        }
        .background(Color.backgroundPrimary)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct FeatureBadge: View {
    let icon: String
    let text: String
    
    var body: some View {
        VStack(spacing: 2) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(.brand)
            Text(text)
                .font(.appCaption2)
                .foregroundColor(.textSecondary)
        }
        .padding(.horizontal, Spacing.sm)
        .padding(.vertical, Spacing.xs)
        .background(Color.brand.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.small))
    }
}

struct DeadlineRow: View {
    let intake: String
    let deadline: String
    
    var body: some View {
        HStack {
            Text(intake)
                .font(.appBody)
                .foregroundColor(.textPrimary)
            Spacer()
            Text(deadline)
                .font(.appSubheadline)
                .fontWeight(.semibold)
                .foregroundColor(.brand)
        }
        .padding(Spacing.sm)
        .background(Color.backgroundSecondary)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium))
    }
}

// MARK: - Country Visa Guide View

struct CountryVisaGuideView: View {
    @EnvironmentObject var dataService: DataService
    @EnvironmentObject var appState: AppState
    
    var visaInfo: CountryVisaInfo? {
        dataService.countryVisaInfo
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.lg) {
                // Visa Overview Card
                if let visa = visaInfo {
                    VStack(alignment: .leading, spacing: Spacing.md) {
                        HStack {
                            VStack(alignment: .leading, spacing: Spacing.xxs) {
                                Text(visa.visaType)
                                    .font(.appTitle3)
                                    .fontWeight(.bold)
                                    .foregroundColor(.textPrimary)
                                
                                Text("for \(appState.selectedCountry?.name ?? "this country")")
                                    .font(.appCaption)
                                    .foregroundColor(.textSecondary)
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing, spacing: Spacing.xxs) {
                                Text(visa.visaFee)
                                    .font(.appTitle3)
                                    .fontWeight(.bold)
                                    .foregroundColor(.brand)
                                Text("Visa Fee")
                                    .font(.appCaption)
                                    .foregroundColor(.textTertiary)
                            }
                        }
                        
                        Divider()
                        
                        // Key Info
                        HStack(spacing: Spacing.xl) {
                            VisaInfoItem(icon: "clock.fill", title: "Processing", value: visa.processingTime)
                            VisaInfoItem(icon: "calendar", title: "Validity", value: visa.validity)
                            VisaInfoItem(icon: "briefcase.fill", title: "Work", value: visa.workPermission)
                        }
                    }
                    .padding(Spacing.lg)
                    .background(Color.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: CornerRadius.xl))
                    .cardShadow()
                    
                    // Application Process
                    if !visa.applicationProcess.isEmpty {
                        VStack(alignment: .leading, spacing: Spacing.md) {
                            Text("Application Process")
                                .font(.appTitle3)
                                .fontWeight(.bold)
                                .foregroundColor(.textPrimary)
                            
                            ForEach(visa.applicationProcess) { step in
                                CountryVisaStepCard(step: step)
                            }
                        }
                    }
                    
                    // Required Documents
                    if let docs = visa.requiredDocuments {
                        VStack(alignment: .leading, spacing: Spacing.md) {
                            Text("Required Documents")
                                .font(.appTitle3)
                                .fontWeight(.bold)
                                .foregroundColor(.textPrimary)
                            
                            if let coeDocs = docs.forCoe, !coeDocs.isEmpty {
                                DocumentSection(title: "For COE Application", documents: coeDocs)
                            }
                            
                            if let visaDocs = docs.forVisa, !visaDocs.isEmpty {
                                DocumentSection(title: "For Visa Application", documents: visaDocs)
                            }
                        }
                    }
                    
                    // Tips
                    if !visa.tips.isEmpty {
                        InfoSection(title: "💡 Tips") {
                            ForEach(visa.tips, id: \.self) { tip in
                                HStack(alignment: .top, spacing: Spacing.sm) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                    Text(tip)
                                        .font(.appBody)
                                        .foregroundColor(.textSecondary)
                                }
                            }
                        }
                    }
                    
                    // Common Rejection Reasons
                    if let rejections = visa.commonRejectionReasons, !rejections.isEmpty {
                        InfoSection(title: "⚠️ Common Rejection Reasons") {
                            ForEach(rejections, id: \.self) { reason in
                                HStack(alignment: .top, spacing: Spacing.sm) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.red)
                                    Text(reason)
                                        .font(.appBody)
                                        .foregroundColor(.textSecondary)
                                }
                            }
                        }
                    }
                    
                    // Embassy Info
                    if let embassy = visa.embassyNepal {
                        InfoSection(title: "🏛️ Embassy Information") {
                            VStack(alignment: .leading, spacing: Spacing.sm) {
                                InfoRow(label: "Name", value: embassy.name)
                                InfoRow(label: "Address", value: embassy.address)
                                InfoRow(label: "Phone", value: embassy.phone)
                                if let email = embassy.email {
                                    InfoRow(label: "Email", value: email)
                                }
                                InfoRow(label: "Hours", value: embassy.workingHours)
                                
                                if let url = URL(string: embassy.website) {
                                    Link(destination: url) {
                                        Label("Visit Website", systemImage: "globe")
                                    }
                                    .buttonStyle(SecondaryButtonStyle(isFullWidth: true))
                                }
                            }
                        }
                    }
                } else {
                    EmptyStateView(
                        icon: "doc.text",
                        title: "Visa Information",
                        message: "Visa details for this country are being prepared"
                    )
                }
            }
            .padding(Spacing.md)
            .padding(.bottom, Spacing.xxl)
        }
        .background(Color.backgroundPrimary)
        .navigationTitle("Visa Guide")
    }
}

struct VisaInfoItem: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: Spacing.xxs) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.brand)
            Text(title)
                .font(.appCaption2)
                .foregroundColor(.textTertiary)
            Text(value)
                .font(.appCaption)
                .fontWeight(.semibold)
                .foregroundColor(.textPrimary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }
}

struct CountryVisaStepCard: View {
    let step: VisaStep
    
    var body: some View {
        HStack(alignment: .top, spacing: Spacing.md) {
            // Step Number
            ZStack {
                Circle()
                    .fill(Color.brand)
                    .frame(width: 32, height: 32)
                
                Text("\(step.step)")
                    .font(.appSubheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text(step.title)
                    .font(.appSubheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.textPrimary)
                
                Text(step.description)
                    .font(.appCaption)
                    .foregroundColor(.textSecondary)
                
                if let duration = step.duration {
                    HStack(spacing: Spacing.xxs) {
                        Image(systemName: "clock")
                            .font(.caption2)
                        Text(duration)
                            .font(.appCaption2)
                    }
                    .foregroundColor(.brand)
                }
            }
        }
        .padding(Spacing.md)
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.large))
    }
}

struct DocumentSection: View {
    let title: String
    let documents: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text(title)
                .font(.appSubheadline)
                .fontWeight(.semibold)
                .foregroundColor(.textPrimary)
            
            ForEach(documents, id: \.self) { doc in
                HStack(spacing: Spacing.sm) {
                    Image(systemName: "doc.text")
                        .font(.caption)
                        .foregroundColor(.brand)
                    Text(doc)
                        .font(.appBody)
                        .foregroundColor(.textSecondary)
                }
            }
        }
        .padding(Spacing.md)
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.large))
    }
}

// MARK: - Placeholder Views (to be implemented)

struct CountryLanguageTestsView: View {
    @EnvironmentObject var dataService: DataService
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: Spacing.md) {
                ForEach(dataService.countryLanguageTests) { test in
                    LanguageTestCard(test: test)
                }
            }
            .padding(Spacing.md)
        }
        .background(Color.backgroundPrimary)
        .navigationTitle("Language Tests")
    }
}

struct LanguageTestCard: View {
    let test: CountryLanguageTest
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            HStack {
                VStack(alignment: .leading, spacing: Spacing.xxs) {
                    Text(test.type)
                        .font(.appTitle3)
                        .fontWeight(.bold)
                        .foregroundColor(.textPrimary)
                    Text(test.fullName)
                        .font(.appCaption)
                        .foregroundColor(.textSecondary)
                }
                Spacer()
                Text(test.testFee)
                    .font(.appSubheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.brand)
            }
            
            Text(test.description)
                .font(.appBody)
                .foregroundColor(.textSecondary)
            
            // Test dates
            HStack(spacing: Spacing.xs) {
                Image(systemName: "calendar")
                    .foregroundColor(.brand)
                Text(test.testDates.joined(separator: ", "))
                    .font(.appCaption)
                    .foregroundColor(.textSecondary)
            }
            
            // Levels
            if let levels = test.levels {
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text("Levels")
                        .font(.appCaption)
                        .fontWeight(.semibold)
                        .foregroundColor(.textPrimary)
                    
                    ForEach(levels, id: \.level) { level in
                        HStack {
                            Text(level.level)
                                .font(.appSubheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.brand)
                                .frame(width: 40)
                            Text(level.description)
                                .font(.appCaption)
                                .foregroundColor(.textSecondary)
                        }
                    }
                }
            }
        }
        .padding(Spacing.md)
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.large))
        .cardShadow()
    }
}

struct ApplicationGuideView: View {
    var body: some View {
        Text("Application Guide - Coming Soon")
            .navigationTitle("Application Guide")
    }
}

struct CountryChecklistView: View {
    var body: some View {
        Text("Pre-departure Checklist - Coming Soon")
            .navigationTitle("Checklist")
    }
}

struct CountryEmbassyView: View {
    var body: some View {
        Text("Embassy Information - Coming Soon")
            .navigationTitle("Embassy")
    }
}

struct CountryJobsView: View {
    @EnvironmentObject var dataService: DataService
    
    var body: some View {
        ScrollView {
            if let jobInfo = dataService.countryPartTimeJobs {
                VStack(spacing: Spacing.lg) {
                    // Work info
                    VStack(alignment: .leading, spacing: Spacing.md) {
                        Text("Part-time Work Rules")
                            .font(.appTitle3)
                            .fontWeight(.bold)
                        
                        InfoRow(label: "Work Hours", value: jobInfo.workPermission)
                        InfoRow(label: "Average Wage", value: jobInfo.averageHourlyWage)
                        if let min = jobInfo.minimumWageTokyo {
                            InfoRow(label: "Min. Wage (Tokyo)", value: min)
                        }
                        InfoRow(label: "Work Permit", value: jobInfo.permitRequired ? "Required" : "Not Required")
                    }
                    .padding(Spacing.md)
                    .background(Color.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: CornerRadius.large))
                    
                    // Common Jobs
                    VStack(alignment: .leading, spacing: Spacing.md) {
                        Text("Common Part-time Jobs")
                            .font(.appTitle3)
                            .fontWeight(.bold)
                        
                        ForEach(jobInfo.commonJobs) { job in
                            JobDetailCard(job: job)
                        }
                    }
                    
                    // Tips
                    InfoSection(title: "💡 Tips") {
                        ForEach(jobInfo.tips, id: \.self) { tip in
                            HStack(alignment: .top, spacing: Spacing.sm) {
                                Image(systemName: "lightbulb.fill")
                                    .foregroundColor(.yellow)
                                Text(tip)
                                    .font(.appBody)
                                    .foregroundColor(.textSecondary)
                            }
                        }
                    }
                }
                .padding(Spacing.md)
            } else {
                EmptyStateView(
                    icon: "briefcase",
                    title: "Job Information",
                    message: "Loading job information..."
                )
            }
        }
        .background(Color.backgroundPrimary)
        .navigationTitle("Jobs & Work")
    }
}

struct JobDetailCard: View {
    let job: CommonPartTimeJob
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            HStack {
                Text(job.title)
                    .font(.appSubheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.textPrimary)
                Spacer()
                Text(job.wageRange)
                    .font(.appCaption)
                    .fontWeight(.semibold)
                    .foregroundColor(.brand)
            }
            
            if let japanese = job.japaneseRequired {
                HStack(spacing: Spacing.xxs) {
                    Image(systemName: "character.ja")
                    Text("Japanese: \(japanese)")
                }
                .font(.appCaption)
                .foregroundColor(.textSecondary)
            }
            
            Text(job.description)
                .font(.appCaption)
                .foregroundColor(.textSecondary)
            
            HStack(spacing: Spacing.md) {
                if let pros = job.pros {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Pros")
                            .font(.appCaption2)
                            .fontWeight(.semibold)
                            .foregroundColor(.green)
                        ForEach(pros.prefix(2), id: \.self) { pro in
                            Text("• \(pro)")
                                .font(.appCaption2)
                                .foregroundColor(.textSecondary)
                        }
                    }
                }
                
                if let cons = job.cons {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Cons")
                            .font(.appCaption2)
                            .fontWeight(.semibold)
                            .foregroundColor(.orange)
                        ForEach(cons.prefix(2), id: \.self) { con in
                            Text("• \(con)")
                                .font(.appCaption2)
                                .foregroundColor(.textSecondary)
                        }
                    }
                }
            }
        }
        .padding(Spacing.md)
        .background(Color.backgroundSecondary)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium))
    }
}

struct CountryCostOfLivingView: View {
    @EnvironmentObject var dataService: DataService
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        ScrollView {
            if let costInfo = dataService.countryCostOfLiving {
                VStack(spacing: Spacing.lg) {
                    // Monthly estimates by city
                    ForEach(Array(costInfo.monthlyEstimate.keys.sorted()), id: \.self) { city in
                        if let estimate = costInfo.monthlyEstimate[city] {
                            CityEstimateCard(
                                city: city.capitalized.replacingOccurrences(of: "_", with: " "),
                                estimate: estimate,
                                currency: appState.selectedCountry?.currencySymbol ?? "¥"
                            )
                        }
                    }
                    
                    // Money saving tips
                    if !costInfo.moneySavingTips.isEmpty {
                        InfoSection(title: "💰 Money Saving Tips") {
                            ForEach(costInfo.moneySavingTips, id: \.self) { tip in
                                HStack(alignment: .top, spacing: Spacing.sm) {
                                    Image(systemName: "lightbulb.fill")
                                        .foregroundColor(.yellow)
                                    Text(tip)
                                        .font(.appBody)
                                        .foregroundColor(.textSecondary)
                                }
                            }
                        }
                    }
                }
                .padding(Spacing.md)
            } else {
                EmptyStateView(
                    icon: "yensign.circle",
                    title: "Cost Information",
                    message: "Loading cost data..."
                )
            }
        }
        .background(Color.backgroundPrimary)
        .navigationTitle("Cost of Living")
    }
}

struct CityEstimateCard: View {
    let city: String
    let estimate: CostEstimate
    let currency: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text(city)
                .font(.appTitle3)
                .fontWeight(.bold)
                .foregroundColor(.textPrimary)
            
            HStack(spacing: Spacing.xl) {
                VStack(spacing: Spacing.xxs) {
                    Text("Min")
                        .font(.appCaption2)
                        .foregroundColor(.textTertiary)
                    Text("\(currency)\(estimate.min.formatted())")
                        .font(.appSubheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.green)
                }
                
                VStack(spacing: Spacing.xxs) {
                    Text("Typical")
                        .font(.appCaption2)
                        .foregroundColor(.textTertiary)
                    Text("\(currency)\(estimate.typical.formatted())")
                        .font(.appHeadline)
                        .fontWeight(.bold)
                        .foregroundColor(.brand)
                }
                
                VStack(spacing: Spacing.xxs) {
                    Text("Max")
                        .font(.appCaption2)
                        .foregroundColor(.textTertiary)
                    Text("\(currency)\(estimate.max.formatted())")
                        .font(.appSubheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.orange)
                }
            }
            
            if let usd = estimate.inUsd {
                Text("≈ \(usd) per month")
                    .font(.appCaption)
                    .foregroundColor(.textSecondary)
            }
        }
        .padding(Spacing.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.large))
        .cardShadow()
    }
}

struct CountryScholarshipsView: View {
    @EnvironmentObject var dataService: DataService
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: Spacing.md) {
                ForEach(dataService.countryScholarships) { scholarship in
                    NavigationLink {
                        CountryScholarshipDetailView(scholarship: scholarship)
                    } label: {
                        CountryScholarshipListCard(scholarship: scholarship)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(Spacing.md)
        }
        .background(Color.backgroundPrimary)
        .navigationTitle("Scholarships")
    }
}

struct CountryScholarshipListCard: View {
    let scholarship: CountryScholarship
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            HStack {
                VStack(alignment: .leading, spacing: Spacing.xxs) {
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
                    
                    Text(scholarship.provider)
                        .font(.appCaption)
                        .foregroundColor(.textSecondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.textTertiary)
            }
            
            Text(scholarship.amount)
                .font(.appSubheadline)
                .fontWeight(.semibold)
                .foregroundColor(.brand)
            
            HStack(spacing: Spacing.sm) {
                Label(scholarship.deadline, systemImage: "calendar")
                    .font(.appCaption)
                    .foregroundColor(.textSecondary)
            }
        }
        .padding(Spacing.md)
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.large))
        .cardShadow()
    }
}

struct CountryScholarshipDetailView: View {
    let scholarship: CountryScholarship
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.lg) {
                // Header
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    if scholarship.isFullyFunded {
                        Text("FULLY FUNDED")
                            .font(.appCaption)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.horizontal, Spacing.sm)
                            .padding(.vertical, Spacing.xxs)
                            .background(Color.green)
                            .clipShape(Capsule())
                    }
                    
                    Text(scholarship.name)
                        .font(.appTitle2)
                        .fontWeight(.bold)
                        .foregroundColor(.textPrimary)
                    
                    Text("by \(scholarship.provider)")
                        .font(.appSubheadline)
                        .foregroundColor(.textSecondary)
                    
                    Text(scholarship.amount)
                        .font(.appTitle3)
                        .fontWeight(.bold)
                        .foregroundColor(.brand)
                    
                    if let desc = scholarship.amountDescription {
                        Text(desc)
                            .font(.appCaption)
                            .foregroundColor(.textTertiary)
                    }
                }
                .padding(Spacing.md)
                .background(Color.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: CornerRadius.large))
                
                // Deadline
                HStack {
                    Image(systemName: "calendar.badge.clock")
                        .foregroundColor(.orange)
                    Text("Deadline: \(scholarship.deadline)")
                        .fontWeight(.semibold)
                }
                .font(.appSubheadline)
                .foregroundColor(.textPrimary)
                .padding(Spacing.md)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.orange.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium))
                
                // Description
                InfoSection(title: "About") {
                    Text(scholarship.description)
                        .font(.appBody)
                        .foregroundColor(.textSecondary)
                }
                
                // Eligibility
                InfoSection(title: "Eligibility") {
                    ForEach(scholarship.eligibility, id: \.self) { item in
                        HStack(alignment: .top, spacing: Spacing.sm) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text(item)
                                .font(.appBody)
                                .foregroundColor(.textSecondary)
                        }
                    }
                }
                
                // Coverage
                InfoSection(title: "What's Covered") {
                    ForEach(scholarship.coverageDetails, id: \.self) { item in
                        HStack(alignment: .top, spacing: Spacing.sm) {
                            Image(systemName: "gift.fill")
                                .foregroundColor(.brand)
                            Text(item)
                                .font(.appBody)
                                .foregroundColor(.textSecondary)
                        }
                    }
                }
                
                // Application Process
                if let process = scholarship.applicationProcess {
                    InfoSection(title: "Application Process") {
                        ForEach(Array(process.enumerated()), id: \.offset) { index, step in
                            HStack(alignment: .top, spacing: Spacing.sm) {
                                Text("\(index + 1)")
                                    .font(.appCaption)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .frame(width: 20, height: 20)
                                    .background(Color.brand)
                                    .clipShape(Circle())
                                Text(step)
                                    .font(.appBody)
                                    .foregroundColor(.textSecondary)
                            }
                        }
                    }
                }
                
                // Required Documents
                if let docs = scholarship.requiredDocuments {
                    InfoSection(title: "Required Documents") {
                        ForEach(docs, id: \.self) { doc in
                            HStack(alignment: .top, spacing: Spacing.sm) {
                                Image(systemName: "doc.text")
                                    .foregroundColor(.brand)
                                Text(doc)
                                    .font(.appBody)
                                    .foregroundColor(.textSecondary)
                            }
                        }
                    }
                }
                
                // Success Tips
                if let tips = scholarship.successTips {
                    InfoSection(title: "💡 Success Tips") {
                        ForEach(tips, id: \.self) { tip in
                            HStack(alignment: .top, spacing: Spacing.sm) {
                                Image(systemName: "lightbulb.fill")
                                    .foregroundColor(.yellow)
                                Text(tip)
                                    .font(.appBody)
                                    .foregroundColor(.textSecondary)
                            }
                        }
                    }
                }
                
                // Apply Button
                if let website = scholarship.website {
                    Link(destination: URL(string: website)!) {
                        Label("Apply Now", systemImage: "arrow.right.circle.fill")
                    }
                    .buttonStyle(PrimaryButtonStyle(isFullWidth: true))
                }
            }
            .padding(Spacing.md)
            .padding(.bottom, Spacing.xxl)
        }
        .background(Color.backgroundPrimary)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct CountryCultureView: View {
    @EnvironmentObject var dataService: DataService
    
    var body: some View {
        ScrollView {
            if let culture = dataService.countryCultureTips {
                VStack(spacing: Spacing.lg) {
                    // Etiquette
                    InfoSection(title: "🎌 Etiquette & Customs") {
                        ForEach(culture.etiquette, id: \.self) { item in
                            HStack(alignment: .top, spacing: Spacing.sm) {
                                Image(systemName: "hand.thumbsup.fill")
                                    .foregroundColor(.green)
                                Text(item)
                                    .font(.appBody)
                                    .foregroundColor(.textSecondary)
                            }
                        }
                    }
                    
                    // Useful Apps
                    InfoSection(title: "📱 Useful Apps") {
                        ForEach(culture.usefulApps) { app in
                            HStack {
                                Text(app.name)
                                    .font(.appSubheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.textPrimary)
                                Spacer()
                                Text(app.use)
                                    .font(.appCaption)
                                    .foregroundColor(.textSecondary)
                            }
                            .padding(Spacing.sm)
                            .background(Color.backgroundSecondary)
                            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium))
                        }
                    }
                    
                    // Important Phrases
                    if let phrases = culture.importantPhrases {
                        InfoSection(title: "🗣️ Useful Phrases") {
                            ForEach(phrases) { phrase in
                                HStack {
                                    Text(phrase.japanese)
                                        .font(.appSubheadline)
                                        .fontWeight(.semibold)
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
                .padding(Spacing.md)
            }
        }
        .background(Color.backgroundPrimary)
        .navigationTitle("Culture & Life")
    }
}

struct CountryAccommodationView: View {
    @EnvironmentObject var dataService: DataService
    
    var body: some View {
        ScrollView {
            if let accommodation = dataService.countryAccommodation {
                VStack(spacing: Spacing.lg) {
                    // Types
                    ForEach(accommodation.types) { type in
                        AccommodationTypeCard(type: type)
                    }
                    
                    // Search Websites
                    InfoSection(title: "🔍 Where to Search") {
                        ForEach(accommodation.searchWebsites) { site in
                            Link(destination: URL(string: site.url)!) {
                                HStack {
                                    Text(site.name)
                                        .font(.appSubheadline)
                                        .foregroundColor(.brand)
                                    Spacer()
                                    Image(systemName: "arrow.up.right.square")
                                        .foregroundColor(.brand)
                                }
                                .padding(Spacing.sm)
                                .background(Color.backgroundSecondary)
                                .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium))
                            }
                        }
                    }
                    
                    // Tips
                    InfoSection(title: "💡 Tips") {
                        ForEach(accommodation.tips, id: \.self) { tip in
                            HStack(alignment: .top, spacing: Spacing.sm) {
                                Image(systemName: "lightbulb.fill")
                                    .foregroundColor(.yellow)
                                Text(tip)
                                    .font(.appBody)
                                    .foregroundColor(.textSecondary)
                            }
                        }
                    }
                }
                .padding(Spacing.md)
            }
        }
        .background(Color.backgroundPrimary)
        .navigationTitle("Accommodation")
    }
}

struct AccommodationTypeCard: View {
    let type: AccommodationType
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            HStack {
                VStack(alignment: .leading, spacing: Spacing.xxs) {
                    Text(type.type)
                        .font(.appHeadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.textPrimary)
                    
                    if let japanese = type.japanese {
                        Text(japanese)
                            .font(.appCaption)
                            .foregroundColor(.textSecondary)
                    }
                }
                
                Spacer()
                
                Text(type.costRange)
                    .font(.appSubheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.brand)
            }
            
            // Pros
            HStack(alignment: .top, spacing: Spacing.lg) {
                VStack(alignment: .leading, spacing: Spacing.xxs) {
                    Text("Pros")
                        .font(.appCaption2)
                        .fontWeight(.semibold)
                        .foregroundColor(.green)
                    ForEach(type.pros.prefix(3), id: \.self) { pro in
                        Text("• \(pro)")
                            .font(.appCaption)
                            .foregroundColor(.textSecondary)
                    }
                }
                
                VStack(alignment: .leading, spacing: Spacing.xxs) {
                    Text("Cons")
                        .font(.appCaption2)
                        .fontWeight(.semibold)
                        .foregroundColor(.orange)
                    ForEach(type.cons.prefix(3), id: \.self) { con in
                        Text("• \(con)")
                            .font(.appCaption)
                            .foregroundColor(.textSecondary)
                    }
                }
            }
            
            if let recommended = type.recommendedFor {
                HStack(spacing: Spacing.xxs) {
                    Image(systemName: "person.fill")
                        .font(.caption2)
                    Text("Best for: \(recommended)")
                        .font(.appCaption)
                }
                .foregroundColor(.brand)
            }
        }
        .padding(Spacing.md)
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.large))
        .cardShadow()
    }
}

