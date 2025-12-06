//
//  StudyHubView.swift
//  Educa
//
//  Premium Study Hub - Universities and Courses browser
//

import SwiftUI

struct StudyHubView: View {
    @EnvironmentObject var dataService: DataService
    @EnvironmentObject var appState: AppState
    @State private var searchText = ""
    @State private var selectedFilter: FilterOption = .all
    @State private var showFilters = false
    @State private var animateCards = false
    
    enum FilterOption: String, CaseIterable {
        case all = "All"
        case topRated = "Top Rated"
        case affordable = "Affordable"
        case popular = "Popular"
        
        var icon: String {
            switch self {
            case .all: return "square.grid.2x2"
            case .topRated: return "star.fill"
            case .affordable: return "dollarsign.circle"
            case .popular: return "flame.fill"
            }
        }
    }
    
    /// Check if a specific country is selected
    var hasCountrySelected: Bool {
        appState.selectedCountry != nil
    }
    
    /// Get all unique countries from universities
    var availableCountries: [String] {
        Array(Set(dataService.universities.map { $0.country })).sorted()
    }
    
    /// Get country info (flag, etc.) for display
    func getCountryInfo(_ countryName: String) -> (flag: String, code: String) {
        switch countryName.lowercased() {
        case "japan": return ("🇯🇵", "jpn")
        case "australia": return ("🇦🇺", "aus")
        case "canada": return ("🇨🇦", "can")
        case "germany": return ("🇩🇪", "deu")
        case "united kingdom": return ("🇬🇧", "gbr")
        case "singapore": return ("🇸🇬", "sgp")
        case "united states", "usa": return ("🇺🇸", "usa")
        case "new zealand": return ("🇳🇿", "nzl")
        case "south korea": return ("🇰🇷", "kor")
        default: return ("🌍", "")
        }
    }
    
    /// Get top 2 universities for a specific country
    func topUniversitiesFor(country: String) -> [University] {
        dataService.universities
            .filter { $0.country == country }
            .sorted { $0.rating > $1.rating }
            .prefix(2)
            .map { $0 }
    }
    
    /// Universities filtered by selected destination country
    var countryFilteredUniversities: [University] {
        // If user has selected a destination country, filter by it
        if let selectedCountry = appState.selectedCountry {
            return dataService.universities.filter { university in
                university.country.lowercased() == selectedCountry.name.lowercased()
            }
        }
        // If no country selected, return empty (we'll use grouped view instead)
        return []
    }
    
    var filteredUniversities: [University] {
        // Start with country-filtered universities
        var result = countryFilteredUniversities
        
        // Apply search filter
        if !searchText.isEmpty {
            let lowercased = searchText.lowercased()
            // When searching, search all universities regardless of country
            result = dataService.universities.filter {
                $0.title.lowercased().contains(lowercased) ||
                $0.location.lowercased().contains(lowercased) ||
                $0.country.lowercased().contains(lowercased) ||
                $0.programs.contains { $0.lowercased().contains(lowercased) }
            }
        }
        
        // Apply sorting/filter
        switch selectedFilter {
        case .topRated:
            result = result.filter { $0.rating >= 4.0 }.sorted { $0.rating > $1.rating }
        case .affordable:
            result = result.sorted { 
                extractFee($0.annualFee) < extractFee($1.annualFee)
            }
        case .popular:
            result = result.sorted { ($0.studentCount ?? 0) > ($1.studentCount ?? 0) }
        case .all:
            break
        }
        
        return result
    }
    
    private func extractFee(_ feeString: String) -> Double {
        let digits = feeString.filter { $0.isNumber || $0 == "." }
        return Double(digits) ?? 0
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.backgroundPrimary.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Stats Header
                    statsHeader
                    
                    // Filter Pills (only show when country is selected or searching)
                    if hasCountrySelected || !searchText.isEmpty {
                        filterSection
                    }
                    
                    // Content
                    if dataService.isLoading {
                        loadingView
                    } else if !searchText.isEmpty {
                        // Show search results
                        if filteredUniversities.isEmpty {
                            emptyView
                        } else {
                            universitiesList
                        }
                    } else if hasCountrySelected {
                        // Show filtered universities for selected country
                        if filteredUniversities.isEmpty {
                            emptyView
                        } else {
                            universitiesList
                        }
                    } else {
                        // Show grouped view: Top 2 universities per country
                        countriesGroupedList
                    }
                }
            }
            .navigationTitle("Study Hub")
            .navigationBarTitleDisplayMode(.large)
            .searchable(text: $searchText, prompt: "Search universities, courses...")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: Spacing.sm) {
                        NavigationLink {
                            UniversityComparisonView()
                        } label: {
                            HStack(spacing: Spacing.xxs) {
                                Image(systemName: "rectangle.on.rectangle.angled")
                                Text("Compare")
                            }
                            .font(.appCaption)
                            .fontWeight(.semibold)
                            .foregroundColor(.brand)
                            .padding(.horizontal, Spacing.sm)
                            .padding(.vertical, Spacing.xxs)
                            .background(Color.brand.opacity(0.1))
                            .clipShape(Capsule())
                        }
                        
                        ProfileMenuButton()
                    }
                }
            }
            .refreshable {
                await dataService.loadUniversities()
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.5).delay(0.2)) {
                animateCards = true
            }
        }
    }
    
    // MARK: - Stats Header
    
    private var statsHeader: some View {
        VStack(spacing: Spacing.sm) {
            // Show selected country badge if any
            if let selectedCountry = appState.selectedCountry {
                HStack(spacing: Spacing.xs) {
                    Text(selectedCountry.flag)
                        .font(.title3)
                    Text("Showing universities in \(selectedCountry.name)")
                        .font(.appCaption)
                        .foregroundColor(.textSecondary)
                    Spacer()
                    Button {
                        // Optional: Navigate to country selection
                    } label: {
                        Text("Change")
                            .font(.appCaption)
                            .foregroundColor(.brand)
                    }
                }
                .padding(.horizontal, Spacing.md)
                .padding(.vertical, Spacing.xs)
                .background(Color.brand.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium))
                .padding(.horizontal, Spacing.md)
            } else {
                // Prompt to select country
                HStack(spacing: Spacing.xs) {
                    Image(systemName: "info.circle.fill")
                        .foregroundColor(.brand)
                    Text("Select a destination to see all universities")
                        .font(.appCaption)
                        .foregroundColor(.textSecondary)
                    Spacer()
                }
                .padding(.horizontal, Spacing.md)
                .padding(.vertical, Spacing.xs)
                .background(Color.backgroundSecondary)
                .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium))
                .padding(.horizontal, Spacing.md)
            }
            
            HStack(spacing: Spacing.md) {
                QuickStatView(
                    value: hasCountrySelected ? "\(countryFilteredUniversities.count)" : "\(dataService.universities.count)",
                    label: "Universities",
                    icon: "building.columns",
                    color: .brand
                )
                
                QuickStatView(
                    value: "\(dataService.courses.count)",
                    label: "Courses",
                    icon: "book.fill",
                    color: .secondary
                )
                
                QuickStatView(
                    value: hasCountrySelected ? "1" : "\(availableCountries.count)",
                    label: hasCountrySelected ? "Country" : "Countries",
                    icon: hasCountrySelected ? "mappin.circle.fill" : "globe",
                    color: .tertiary
                )
            }
            .padding(.horizontal, Spacing.md)
        }
        .padding(.vertical, Spacing.sm)
    }
    
    // MARK: - Filter Section
    
    private var filterSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Spacing.sm) {
                ForEach(FilterOption.allCases, id: \.self) { option in
                    FilterPill(
                        title: option.rawValue,
                        icon: option.icon,
                        isSelected: selectedFilter == option
                    ) {
                        HapticManager.shared.selection()
                        withAnimation(.spring(response: 0.3)) {
                            selectedFilter = option
                        }
                    }
                }
            }
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, Spacing.sm)
        }
        .background(Color.backgroundSecondary.opacity(0.5))
    }
    
    // MARK: - Universities List (for selected country)
    
    private var universitiesList: some View {
        ScrollView {
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: Spacing.md),
                GridItem(.flexible(), spacing: Spacing.md)
            ], spacing: Spacing.md) {
                ForEach(Array(filteredUniversities.enumerated()), id: \.element.id) { index, university in
                    NavigationLink {
                        UniversityDetailView(university: university)
                    } label: {
                        UniversityGridCard(university: university)
                            .opacity(animateCards ? 1 : 0)
                            .offset(y: animateCards ? 0 : 20)
                            .animation(
                                .spring(response: 0.4, dampingFraction: 0.8)
                                .delay(Double(index) * 0.05),
                                value: animateCards
                            )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(Spacing.md)
            .padding(.bottom, 100)
        }
    }
    
    // MARK: - Countries Grouped List (when no country selected)
    
    private var countriesGroupedList: some View {
        ScrollView {
            LazyVStack(spacing: Spacing.lg) {
                ForEach(Array(availableCountries.enumerated()), id: \.element) { countryIndex, country in
                    let countryInfo = getCountryInfo(country)
                    let universities = topUniversitiesFor(country: country)
                    let totalCount = dataService.universities.filter { $0.country == country }.count
                    
                    VStack(alignment: .leading, spacing: Spacing.sm) {
                        // Country Header
                        HStack {
                            Text(countryInfo.flag)
                                .font(.title2)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(country)
                                    .font(.appHeadline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.textPrimary)
                                
                                Text("\(totalCount) universities available")
                                    .font(.appCaption2)
                                    .foregroundColor(.textSecondary)
                            }
                            
                            Spacer()
                            
                            NavigationLink {
                                AllUniversitiesForCountryView(country: country, countryInfo: countryInfo)
                                    .environmentObject(dataService)
                            } label: {
                                HStack(spacing: 4) {
                                    Text("View All")
                                        .font(.appCaption)
                                        .fontWeight(.semibold)
                                    Image(systemName: "chevron.right")
                                        .font(.caption2)
                                }
                                .foregroundColor(.brand)
                            }
                        }
                        .padding(.horizontal, Spacing.md)
                        
                        // Top 2 Universities Grid
                        LazyVGrid(columns: [
                            GridItem(.flexible(), spacing: Spacing.md),
                            GridItem(.flexible(), spacing: Spacing.md)
                        ], spacing: Spacing.md) {
                            ForEach(Array(universities.enumerated()), id: \.element.id) { index, university in
                                NavigationLink {
                                    UniversityDetailView(university: university)
                                } label: {
                                    UniversityGridCard(university: university)
                                        .opacity(animateCards ? 1 : 0)
                                        .offset(y: animateCards ? 0 : 20)
                                        .animation(
                                            .spring(response: 0.4, dampingFraction: 0.8)
                                            .delay(Double(countryIndex) * 0.1 + Double(index) * 0.05),
                                            value: animateCards
                                        )
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal, Spacing.md)
                    }
                    .padding(.vertical, Spacing.sm)
                    .background(Color.backgroundSecondary.opacity(0.3))
                    .clipShape(RoundedRectangle(cornerRadius: CornerRadius.large))
                    .padding(.horizontal, Spacing.md)
                }
            }
            .padding(.vertical, Spacing.md)
            .padding(.bottom, 100)
        }
    }
    
    // MARK: - Loading View
    
    private var loadingView: some View {
        VStack(spacing: Spacing.lg) {
            Spacer()
            
            ZStack {
                Circle()
                    .stroke(Color.brand.opacity(0.2), lineWidth: 4)
                    .frame(width: 60, height: 60)
                
                Circle()
                    .trim(from: 0, to: 0.7)
                    .stroke(Color.brand, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                    .frame(width: 60, height: 60)
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 1).repeatForever(autoreverses: false), value: UUID())
            }
            
            Text("Loading universities...")
                .font(.appSubheadline)
                .foregroundColor(.textSecondary)
            
            Spacer()
        }
    }
    
    // MARK: - Empty View
    
    private var emptyView: some View {
        EmptyStateView(
            icon: "building.columns",
            title: "No Universities Found",
            message: {
                if let country = appState.selectedCountry {
                    if !searchText.isEmpty {
                        return "No universities match '\(searchText)' in \(country.name)"
                    } else {
                        return "No universities available for \(country.name) yet. Check back soon!"
                    }
                } else {
                    return searchText.isEmpty 
                        ? "Universities will appear here once loaded" 
                        : "Try adjusting your search or filters"
                }
            }()
        )
    }
}

// MARK: - Quick Stat View

struct QuickStatView: View {
    let value: String
    let label: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: Spacing.xxs) {
            HStack(spacing: Spacing.xxs) {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundColor(color)
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
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium, style: .continuous))
    }
}

// MARK: - Filter Pill

struct FilterPill: View {
    let title: String
    var icon: String? = nil
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: Spacing.xxs) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.caption)
                }
                Text(title)
                    .font(.appCaption)
                    .fontWeight(isSelected ? .semibold : .medium)
            }
            .foregroundColor(isSelected ? .white : .textPrimary)
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, Spacing.xs)
            .background(
                isSelected 
                    ? AnyShapeStyle(LinearGradient.brandGradient)
                    : AnyShapeStyle(Color.backgroundTertiary)
            )
            .clipShape(Capsule())
            .shadow(
                color: isSelected ? Color.brand.opacity(0.3) : Color.clear,
                radius: 8,
                x: 0,
                y: 4
            )
        }
    }
}

// MARK: - University Grid Card (Premium)

struct UniversityGridCard: View {
    let university: University
    @ObservedObject private var userData = UserDataManager.shared
    @State private var isPressed = false
    
    var isSaved: Bool {
        userData.savedUniversities.contains(university.id)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Image
            ZStack(alignment: .topTrailing) {
                AsyncImage(url: URL(string: university.image)) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    case .failure, .empty:
                        LinearGradient(
                            colors: [Color.brand.opacity(0.2), Color.brand.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        .overlay {
                            Image(systemName: "building.columns")
                                .font(.system(size: 28))
                                .foregroundColor(.brand.opacity(0.5))
                        }
                    @unknown default:
                        Color.gray.opacity(0.1)
                    }
                }
                .frame(height: 110)
                .clipShape(RoundedRectangle(cornerRadius: CornerRadius.large, style: .continuous))
                
                // Rating Badge
                HStack(spacing: 3) {
                    Image(systemName: "star.fill")
                        .font(.caption2)
                        .foregroundColor(.yellow)
                    Text(String(format: "%.1f", university.rating))
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(.textPrimary)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(.ultraThinMaterial)
                .clipShape(Capsule())
                .padding(8)
                
                // Save Button
                Button {
                    HapticManager.shared.tap()
                    userData.toggleUniversitySaved(university.id)
                } label: {
                    Image(systemName: isSaved ? "heart.fill" : "heart")
                        .font(.caption)
                        .foregroundColor(isSaved ? .accent : .white)
                        .padding(6)
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                }
                .padding(8)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
            }
            
            // Info
            VStack(alignment: .leading, spacing: Spacing.xxs) {
                Text(university.title)
                    .font(.appCaption)
                    .fontWeight(.bold)
                    .foregroundColor(.textPrimary)
                    .lineLimit(2)
                    .frame(height: 36, alignment: .topLeading)
                
                HStack(spacing: 3) {
                    Image(systemName: "mappin.circle.fill")
                        .font(.caption2)
                        .foregroundColor(.brand)
                    Text(university.country)
                        .font(.appCaption2)
                        .foregroundColor(.textSecondary)
                        .lineLimit(1)
                }
                
                HStack {
                    Text(university.annualFee)
                        .font(.appCaption2)
                        .fontWeight(.bold)
                        .foregroundColor(.brand)
                    
                    Spacer()
                    
                    if let ranking = university.ranking {
                        Text("#\(ranking)")
                            .font(.appCaption2)
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(Spacing.sm)
        }
        .background(Color.surface)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.xl, style: .continuous))
        .shadow(color: .black.opacity(0.06), radius: 10, x: 0, y: 5)
        .scaleEffect(isPressed ? 0.97 : 1.0)
        .animation(.spring(response: 0.3), value: isPressed)
        .onLongPressGesture(minimumDuration: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }
}

// MARK: - All Universities For Country View (shows all universities for a country from Study Hub)

struct AllUniversitiesForCountryView: View {
    let country: String
    let countryInfo: (flag: String, code: String)
    @EnvironmentObject var dataService: DataService
    @State private var searchText = ""
    @State private var animateCards = false
    
    var universities: [University] {
        var result = dataService.universities.filter { $0.country == country }
        
        if !searchText.isEmpty {
            let lowercased = searchText.lowercased()
            result = result.filter {
                $0.title.lowercased().contains(lowercased) ||
                $0.location.lowercased().contains(lowercased) ||
                $0.programs.contains { $0.lowercased().contains(lowercased) }
            }
        }
        
        return result.sorted { $0.rating > $1.rating }
    }
    
    var body: some View {
        ZStack {
            Color.backgroundPrimary.ignoresSafeArea()
            
            ScrollView {
                // Country Info Header
                VStack(spacing: Spacing.sm) {
                    Text(countryInfo.flag)
                        .font(.system(size: 60))
                    
                    Text(country)
                        .font(.appTitle2)
                        .fontWeight(.bold)
                        .foregroundColor(.textPrimary)
                    
                    Text("\(universities.count) universities")
                        .font(.appSubheadline)
                        .foregroundColor(.textSecondary)
                }
                .padding(.vertical, Spacing.lg)
                
                // Universities Grid
                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: Spacing.md),
                    GridItem(.flexible(), spacing: Spacing.md)
                ], spacing: Spacing.md) {
                    ForEach(Array(universities.enumerated()), id: \.element.id) { index, university in
                        NavigationLink {
                            UniversityDetailView(university: university)
                        } label: {
                            UniversityGridCard(university: university)
                                .opacity(animateCards ? 1 : 0)
                                .offset(y: animateCards ? 0 : 20)
                                .animation(
                                    .spring(response: 0.4, dampingFraction: 0.8)
                                    .delay(Double(index) * 0.05),
                                    value: animateCards
                                )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(Spacing.md)
                .padding(.bottom, 100)
            }
        }
        .navigationTitle("Universities in \(country)")
        .navigationBarTitleDisplayMode(.inline)
        .searchable(text: $searchText, prompt: "Search universities...")
        .onAppear {
            withAnimation(.easeOut(duration: 0.5).delay(0.2)) {
                animateCards = true
            }
        }
    }
}

// MARK: - Preview

#Preview {
    StudyHubView()
        .environmentObject(DataService.shared)
        .environmentObject(AppState())
}
