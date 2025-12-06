//
//  TestPrepView.swift
//  Educa
//
//  Language Test Preparation module for Nepali students
//  Covers IELTS, TOEFL, PTE, JLPT, TOPIK, GRE, SAT
//

import SwiftUI

// MARK: - Test Prep Main View

struct TestPrepView: View {
    @EnvironmentObject var dataService: DataService
    @State private var selectedTestType: LanguageTestType?
    @State private var searchText = ""
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Spacing.xl) {
                    // Header
                    headerSection
                    
                    // Quick Stats
                    quickStatsSection
                    
                    // Test Categories
                    testCategoriesSection
                    
                    // Popular Tests Grid
                    popularTestsSection
                    
                    // Test Centers in Nepal
                    testCentersSection
                    
                    // Study Resources
                    studyResourcesSection
                }
                .padding(Spacing.md)
                .padding(.bottom, 100)
            }
            .background(Color.backgroundPrimary)
            .navigationTitle("Test Preparation")
            .searchable(text: $searchText, prompt: "Search tests...")
        }
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        VStack(spacing: Spacing.md) {
            HStack {
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text("Ace Your Tests 📝")
                        .font(.appTitle2)
                        .fontWeight(.bold)
                        .foregroundColor(.textPrimary)
                    
                    Text("Prepare for language & aptitude tests required for studying abroad")
                        .font(.appSubheadline)
                        .foregroundColor(.textSecondary)
                }
                Spacer()
            }
        }
        .padding(Spacing.lg)
        .background(
            LinearGradient(
                colors: [Color.brand.opacity(0.15), Color.brand.opacity(0.05)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.large))
    }
    
    // MARK: - Quick Stats
    
    private var quickStatsSection: some View {
        HStack(spacing: Spacing.md) {
            TestStatCard(value: "10+", label: "Test Types", icon: "doc.text.fill", color: .brand)
            TestStatCard(value: "50+", label: "Centers in Nepal", icon: "building.2", color: .green)
            TestStatCard(value: "1000+", label: "Resources", icon: "book.fill", color: .orange)
        }
    }
    
    // MARK: - Test Categories
    
    private var testCategoriesSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            SectionHeader(title: "Test Categories", icon: "folder.fill")
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: Spacing.md) {
                TestCategoryCard(
                    title: "English Tests",
                    tests: ["IELTS", "TOEFL", "PTE"],
                    icon: "textformat.abc",
                    color: Color(hex: "DC143C"),
                    destinations: "USA, UK, Australia, Canada"
                )
                
                TestCategoryCard(
                    title: "Asian Languages",
                    tests: ["JLPT", "TOPIK", "NAT"],
                    icon: "character.ja",
                    color: Color(hex: "BC002D"),
                    destinations: "Japan, South Korea"
                )
                
                TestCategoryCard(
                    title: "Graduate Tests",
                    tests: ["GRE", "GMAT"],
                    icon: "graduationcap.fill",
                    color: Color(hex: "00A651"),
                    destinations: "USA, Canada, UK"
                )
                
                TestCategoryCard(
                    title: "European",
                    tests: ["Goethe", "DELF"],
                    icon: "globe.europe.africa.fill",
                    color: Color(hex: "0055A4"),
                    destinations: "Germany, France"
                )
            }
        }
    }
    
    // MARK: - Popular Tests
    
    private var popularTestsSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            SectionHeader(title: "Popular Tests for Nepali Students", icon: "star.fill")
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Spacing.md) {
                    ForEach(LanguageTestType.allCases.prefix(6), id: \.self) { testType in
                        NavigationLink {
                            TestDetailView(testType: testType)
                        } label: {
                            PopularTestCard(testType: testType)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
        }
    }
    
    // MARK: - Test Centers
    
    private var testCentersSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            SectionHeader(title: "Test Centers in Nepal", icon: "mappin.circle.fill")
            
            VStack(spacing: Spacing.sm) {
                TestCenterRow(
                    name: "British Council Nepal",
                    tests: ["IELTS"],
                    address: "Lazimpat, Kathmandu",
                    phone: "+977-1-4410798"
                )
                
                TestCenterRow(
                    name: "Educational Testing Service",
                    tests: ["TOEFL", "GRE"],
                    address: "Multiple Centers",
                    phone: "1-800-TOEFL"
                )
                
                TestCenterRow(
                    name: "Pearson VUE",
                    tests: ["PTE Academic"],
                    address: "Kamaladi, Kathmandu",
                    phone: "+977-1-4444444"
                )
                
                TestCenterRow(
                    name: "Japan Foundation",
                    tests: ["JLPT", "NAT"],
                    address: "Baluwatar, Kathmandu",
                    phone: "+977-1-4426900"
                )
            }
        }
    }
    
    // MARK: - Study Resources
    
    private var studyResourcesSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            SectionHeader(title: "Free Study Resources", icon: "book.closed.fill")
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Spacing.md) {
                    ResourceCard(
                        title: "IELTS Liz",
                        type: "Website",
                        icon: "globe",
                        color: .red,
                        isFree: true
                    )
                    
                    ResourceCard(
                        title: "Magoosh",
                        type: "App",
                        icon: "iphone",
                        color: .green,
                        isFree: false
                    )
                    
                    ResourceCard(
                        title: "JLPT Sensei",
                        type: "Website",
                        icon: "globe",
                        color: .purple,
                        isFree: true
                    )
                    
                    ResourceCard(
                        title: "Talk To Me In Korean",
                        type: "Podcast",
                        icon: "headphones",
                        color: .blue,
                        isFree: true
                    )
                }
            }
        }
    }
}

// MARK: - Test Detail View

struct TestDetailView: View {
    let testType: LanguageTestType
    @State private var selectedSection = 0
    
    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.xl) {
                // Test Header
                testHeader
                
                // Quick Info
                quickInfoSection
                
                // Sections Picker
                Picker("Section", selection: $selectedSection) {
                    Text("Overview").tag(0)
                    Text("Sections").tag(1)
                    Text("Scores").tag(2)
                    Text("Tips").tag(3)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, Spacing.md)
                
                // Content based on selection
                switch selectedSection {
                case 0: overviewSection
                case 1: sectionsSection
                case 2: scoresSection
                default: tipsSection
                }
            }
            .padding(.bottom, 100)
        }
        .background(Color.backgroundPrimary)
        .navigationTitle(testType.rawValue)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var testHeader: some View {
        VStack(spacing: Spacing.md) {
            ZStack {
                Circle()
                    .fill(Color(hex: testType.color).opacity(0.15))
                    .frame(width: 80, height: 80)
                
                Image(systemName: testType.icon)
                    .font(.system(size: 36))
                    .foregroundColor(Color(hex: testType.color))
            }
            
            Text(testType.fullName)
                .font(.appHeadline)
                .fontWeight(.semibold)
                .foregroundColor(.textPrimary)
                .multilineTextAlignment(.center)
            
            Text("For: \(testType.targetCountries.joined(separator: ", "))")
                .font(.appCaption)
                .foregroundColor(.textSecondary)
        }
        .padding(Spacing.lg)
        .frame(maxWidth: .infinity)
        .background(Color.backgroundSecondary)
    }
    
    private var quickInfoSection: some View {
        HStack(spacing: Spacing.md) {
            InfoPill(icon: "clock", value: "2.5-4 hrs", label: "Duration")
            InfoPill(icon: "dollarsign.circle", value: getTestFee(), label: "Fee")
            InfoPill(icon: "calendar", value: "Monthly", label: "Availability")
        }
        .padding(.horizontal, Spacing.md)
    }
    
    private var overviewSection: some View {
        VStack(alignment: .leading, spacing: Spacing.lg) {
            // Description
            VStack(alignment: .leading, spacing: Spacing.sm) {
                Text("About \(testType.rawValue)")
                    .font(.appTitle3)
                    .foregroundColor(.textPrimary)
                
                Text(getTestDescription())
                    .font(.appBody)
                    .foregroundColor(.textSecondary)
            }
            .padding(Spacing.md)
            .background(Color.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.large))
            
            // Target Countries
            VStack(alignment: .leading, spacing: Spacing.sm) {
                Text("Accepted In")
                    .font(.appHeadline)
                    .foregroundColor(.textPrimary)
                
                FlowLayout(spacing: Spacing.sm) {
                    ForEach(testType.targetCountries, id: \.self) { country in
                        Text(country)
                            .font(.appCaption)
                            .fontWeight(.medium)
                            .padding(.horizontal, Spacing.sm)
                            .padding(.vertical, Spacing.xxs)
                            .background(Color.brand.opacity(0.1))
                            .foregroundColor(.brand)
                            .clipShape(Capsule())
                    }
                }
            }
            .padding(Spacing.md)
            .background(Color.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.large))
        }
        .padding(.horizontal, Spacing.md)
    }
    
    private var sectionsSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            ForEach(getTestSections(), id: \.self) { section in
                TestSectionCard(section: section)
            }
        }
        .padding(.horizontal, Spacing.md)
    }
    
    private var scoresSection: some View {
        VStack(alignment: .leading, spacing: Spacing.lg) {
            // Scoring System
            VStack(alignment: .leading, spacing: Spacing.sm) {
                Text("Scoring System")
                    .font(.appTitle3)
                    .foregroundColor(.textPrimary)
                
                Text(getScoringInfo())
                    .font(.appBody)
                    .foregroundColor(.textSecondary)
            }
            .padding(Spacing.md)
            .background(Color.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.large))
            
            // Minimum Scores
            VStack(alignment: .leading, spacing: Spacing.md) {
                Text("Required Scores by Country")
                    .font(.appTitle3)
                    .foregroundColor(.textPrimary)
                
                VStack(spacing: Spacing.sm) {
                    ScoreRequirementRow(country: "Australia", score: getRequiredScore("Australia"))
                    ScoreRequirementRow(country: "UK", score: getRequiredScore("UK"))
                    ScoreRequirementRow(country: "USA", score: getRequiredScore("USA"))
                    ScoreRequirementRow(country: "Canada", score: getRequiredScore("Canada"))
                }
            }
            .padding(Spacing.md)
            .background(Color.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.large))
        }
        .padding(.horizontal, Spacing.md)
    }
    
    private var tipsSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            ForEach(getPreparationTips().indices, id: \.self) { index in
                TipCard(number: index + 1, tip: getPreparationTips()[index])
            }
        }
        .padding(.horizontal, Spacing.md)
    }
    
    // Helper functions
    private func getTestFee() -> String {
        switch testType {
        case .ielts: return "NPR 29,500"
        case .toefl: return "NPR 25,000"
        case .pte: return "NPR 22,000"
        case .jlpt: return "NPR 2,500"
        case .topik: return "NPR 3,000"
        case .gre: return "NPR 27,000"
        case .sat: return "NPR 15,000"
        default: return "Varies"
        }
    }
    
    private func getTestDescription() -> String {
        switch testType {
        case .ielts:
            return "IELTS (International English Language Testing System) is the world's most popular English language test for higher education and global migration. It assesses all four language skills: listening, reading, writing, and speaking."
        case .toefl:
            return "TOEFL (Test of English as a Foreign Language) is accepted by more than 11,000 universities and institutions in over 150 countries. It measures your ability to use and understand English at the university level."
        case .jlpt:
            return "JLPT (Japanese Language Proficiency Test) is the most widely recognized Japanese language qualification in the world. It has 5 levels, from N5 (beginner) to N1 (advanced)."
        case .topik:
            return "TOPIK (Test of Proficiency in Korean) evaluates Korean language proficiency for non-native speakers. Required for studying or working in South Korea."
        default:
            return "A standardized test for measuring language proficiency and academic aptitude for international education."
        }
    }
    
    private func getTestSections() -> [String] {
        switch testType {
        case .ielts: return ["Listening (30 min)", "Reading (60 min)", "Writing (60 min)", "Speaking (11-14 min)"]
        case .toefl: return ["Reading (54-72 min)", "Listening (41-57 min)", "Speaking (17 min)", "Writing (50 min)"]
        case .jlpt: return ["Language Knowledge", "Reading", "Listening"]
        case .topik: return ["Listening", "Writing", "Reading"]
        default: return ["Section 1", "Section 2", "Section 3"]
        }
    }
    
    private func getScoringInfo() -> String {
        switch testType {
        case .ielts: return "Overall band score from 1-9 (in 0.5 increments). Average of all four sections."
        case .toefl: return "Score range: 0-120 total. Each section scored 0-30."
        case .jlpt: return "Pass/Fail based on level. N1 requires 100/180 points minimum."
        case .topik: return "Score range: 0-300. Level determined by total score."
        default: return "Varies by test type and section."
        }
    }
    
    private func getRequiredScore(_ country: String) -> String {
        switch testType {
        case .ielts:
            switch country {
            case "Australia": return "6.0-7.0"
            case "UK": return "6.0-7.5"
            case "USA": return "6.5-7.0"
            case "Canada": return "6.0-7.0"
            default: return "6.0+"
            }
        case .toefl:
            switch country {
            case "USA": return "80-100"
            case "UK": return "90-100"
            default: return "80+"
            }
        default: return "Varies"
        }
    }
    
    private func getPreparationTips() -> [String] {
        switch testType {
        case .ielts:
            return [
                "Practice with official Cambridge IELTS books - they contain real past papers",
                "Improve your vocabulary by reading academic articles daily",
                "Record yourself speaking and analyze your pronunciation",
                "Learn essay structures for Task 1 and Task 2 writing",
                "Take full-length mock tests under timed conditions",
                "Focus on your weakest section but maintain all skills"
            ]
        case .jlpt:
            return [
                "Use spaced repetition apps like Anki for kanji and vocabulary",
                "Watch Japanese dramas and anime with Japanese subtitles",
                "Practice with official JLPT workbooks",
                "Join Japanese language exchange communities",
                "Read NHK Easy News for reading practice",
                "Focus on grammar patterns specific to your level"
            ]
        default:
            return [
                "Create a study schedule and stick to it",
                "Take practice tests regularly",
                "Focus on your weak areas",
                "Get enough rest before the exam",
                "Familiarize yourself with the test format"
            ]
        }
    }
}

// MARK: - Supporting Components

struct TestStatCard: View {
    let value: String
    let label: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: Spacing.xs) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
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
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium))
        .cardShadow()
    }
}

struct TestCategoryCard: View {
    let title: String
    let tests: [String]
    let icon: String
    let color: Color
    let destinations: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                Spacer()
            }
            
            Text(title)
                .font(.appHeadline)
                .fontWeight(.semibold)
                .foregroundColor(.textPrimary)
            
            Text(tests.joined(separator: " • "))
                .font(.appCaption)
                .foregroundColor(.brand)
            
            Text(destinations)
                .font(.appCaption2)
                .foregroundColor(.textTertiary)
                .lineLimit(2)
        }
        .padding(Spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.large))
        .cardShadow()
    }
}

struct PopularTestCard: View {
    let testType: LanguageTestType
    
    var body: some View {
        VStack(spacing: Spacing.sm) {
            ZStack {
                Circle()
                    .fill(Color(hex: testType.color).opacity(0.15))
                    .frame(width: 60, height: 60)
                
                Image(systemName: testType.icon)
                    .font(.title2)
                    .foregroundColor(Color(hex: testType.color))
            }
            
            Text(testType.rawValue)
                .font(.appSubheadline)
                .fontWeight(.semibold)
                .foregroundColor(.textPrimary)
            
            Text(testType.targetCountries.prefix(2).joined(separator: ", "))
                .font(.appCaption2)
                .foregroundColor(.textSecondary)
                .lineLimit(1)
        }
        .frame(width: 100)
        .padding(Spacing.md)
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.large))
        .cardShadow()
    }
}

struct TestCenterRow: View {
    let name: String
    let tests: [String]
    let address: String
    let phone: String
    
    var body: some View {
        HStack(spacing: Spacing.md) {
            Image(systemName: "building.2.fill")
                .font(.title2)
                .foregroundColor(.brand)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .font(.appSubheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.textPrimary)
                
                Text(tests.joined(separator: ", "))
                    .font(.appCaption)
                    .foregroundColor(.brand)
                
                Text(address)
                    .font(.appCaption2)
                    .foregroundColor(.textTertiary)
            }
            
            Spacer()
            
            Button {
                if let url = URL(string: "tel:\(phone.replacingOccurrences(of: " ", with: ""))") {
                    UIApplication.shared.open(url)
                }
            } label: {
                Image(systemName: "phone.fill")
                    .foregroundColor(.brand)
            }
        }
        .padding(Spacing.md)
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium))
    }
}

struct ResourceCard: View {
    let title: String
    let type: String
    let icon: String
    let color: Color
    let isFree: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                
                Spacer()
                
                if isFree {
                    Text("FREE")
                        .font(.appCaption2)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.green.opacity(0.15))
                        .clipShape(Capsule())
                }
            }
            
            Text(title)
                .font(.appSubheadline)
                .fontWeight(.semibold)
                .foregroundColor(.textPrimary)
                .lineLimit(2)
            
            Text(type)
                .font(.appCaption2)
                .foregroundColor(.textSecondary)
        }
        .frame(width: 140)
        .padding(Spacing.md)
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium))
        .cardShadow()
    }
}

struct InfoPill: View {
    let icon: String
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: Spacing.xxs) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundColor(.brand)
                Text(value)
                    .font(.appSubheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.textPrimary)
            }
            
            Text(label)
                .font(.appCaption2)
                .foregroundColor(.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Spacing.sm)
        .background(Color.backgroundSecondary)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.small))
    }
}

struct TestSectionCard: View {
    let section: String
    
    var body: some View {
        HStack {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
            
            Text(section)
                .font(.appSubheadline)
                .foregroundColor(.textPrimary)
            
            Spacer()
        }
        .padding(Spacing.md)
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium))
    }
}

struct ScoreRequirementRow: View {
    let country: String
    let score: String
    
    var body: some View {
        HStack {
            Text(country)
                .font(.appSubheadline)
                .foregroundColor(.textPrimary)
            
            Spacer()
            
            Text(score)
                .font(.appSubheadline)
                .fontWeight(.semibold)
                .foregroundColor(.brand)
        }
        .padding(.vertical, Spacing.xs)
    }
}

struct TipCard: View {
    let number: Int
    let tip: String
    
    var body: some View {
        HStack(alignment: .top, spacing: Spacing.md) {
            Text("\(number)")
                .font(.appHeadline)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(width: 32, height: 32)
                .background(Color.brand)
                .clipShape(Circle())
            
            Text(tip)
                .font(.appBody)
                .foregroundColor(.textPrimary)
        }
        .padding(Spacing.md)
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium))
    }
}

// Note: FlowLayout is defined in DetailViews.swift

