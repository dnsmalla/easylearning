//
//  SearchView.swift
//  SpiceBite
//
//  Global search view
//

import SwiftUI

struct SearchView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var dataService: DataService
    @Environment(\.dismiss) private var dismiss
    
    @State private var searchText = ""
    @State private var recentSearches: [String] = []
    @FocusState private var isSearchFocused: Bool
    
    var searchResults: [Restaurant] {
        guard !searchText.isEmpty else { return [] }
        return dataService.search(searchText).filter { $0.cuisineType.isNepaliOrIndian }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search Bar
                HStack(spacing: Spacing.sm) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.textTertiary)
                    
                    TextField("Search restaurants, cuisine, station...", text: $searchText)
                        .font(.appBody)
                        .focused($isSearchFocused)
                        .submitLabel(.search)
                        .onSubmit {
                            if !searchText.isEmpty {
                                addToRecentSearches(searchText)
                            }
                        }
                    
                    if !searchText.isEmpty {
                        Button {
                            searchText = ""
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.textTertiary)
                        }
                    }
                }
                .padding(Spacing.md)
                .background(Color.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: CornerRadius.large))
                .padding(Spacing.md)
                
                // Content
                if searchText.isEmpty {
                    suggestionsContent
                } else if searchResults.isEmpty {
                    noResultsContent
                } else {
                    resultsContent
                }
            }
            .background(Color.backgroundPrimary.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.brand)
                }
            }
            .onAppear {
                isSearchFocused = true
                loadRecentSearches()
            }
        }
    }
    
    // MARK: - Suggestions Content
    
    private var suggestionsContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.xl) {
                // Recent Searches
                if !recentSearches.isEmpty {
                    VStack(alignment: .leading, spacing: Spacing.md) {
                        HStack {
                            Text("Recent Searches")
                                .font(.appHeadline)
                                .foregroundColor(.textPrimary)
                            
                            Spacer()
                            
                            Button {
                                clearRecentSearches()
                            } label: {
                                Text("Clear")
                                    .font(.appCaption)
                                    .foregroundColor(.accent)
                            }
                        }
                        
                        FlowLayout(spacing: Spacing.sm) {
                            ForEach(recentSearches, id: \.self) { search in
                                Button {
                                    searchText = search
                                } label: {
                                    HStack(spacing: 4) {
                                        Image(systemName: "clock.arrow.circlepath")
                                            .font(.caption)
                                        Text(search)
                                            .font(.appCaption)
                                    }
                                    .foregroundColor(.textSecondary)
                                    .padding(.horizontal, Spacing.sm)
                                    .padding(.vertical, Spacing.xs)
                                    .background(Color.backgroundSecondary)
                                    .clipShape(Capsule())
                                }
                            }
                        }
                    }
                }
                
                // Quick Filters
                VStack(alignment: .leading, spacing: Spacing.md) {
                    Text("Browse by Cuisine")
                        .font(.appHeadline)
                        .foregroundColor(.textPrimary)
                    
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: Spacing.sm) {
                        ForEach(CuisineType.allCases) { cuisine in
                            Button {
                                searchText = cuisine.rawValue
                            } label: {
                                HStack(spacing: Spacing.sm) {
                                    Text(cuisine.icon)
                                    Text(cuisine.rawValue)
                                        .font(.appSubheadline)
                                    Spacer()
                                }
                                .foregroundColor(.textPrimary)
                                .padding(Spacing.md)
                                .background(Color(hex: cuisine.color).opacity(0.1))
                                .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium))
                            }
                        }
                    }
                }
                
                // Popular Searches
                VStack(alignment: .leading, spacing: Spacing.md) {
                    Text("Popular Searches")
                        .font(.appHeadline)
                        .foregroundColor(.textPrimary)
                    
                    FlowLayout(spacing: Spacing.sm) {
                        ForEach(["Butter Chicken", "Momo", "Biryani", "Naan", "Thali", "Curry", "Tandoori", "Dosa"], id: \.self) { term in
                            Button {
                                searchText = term
                            } label: {
                                Text(term)
                                    .font(.appCaption)
                                    .foregroundColor(.brand)
                                    .padding(.horizontal, Spacing.sm)
                                    .padding(.vertical, Spacing.xs)
                                    .background(Color.brand.opacity(0.1))
                                    .clipShape(Capsule())
                            }
                        }
                    }
                }
            }
            .padding(Spacing.md)
            .padding(.bottom, Spacing.xl)
        }
    }
    
    // MARK: - No Results Content
    
    private var noResultsContent: some View {
        VStack(spacing: Spacing.lg) {
            Spacer()
            
            Image(systemName: "magnifyingglass")
                .font(.system(size: 48))
                .foregroundColor(.textTertiary)
            
            Text("No results for \"\(searchText)\"")
                .font(.appTitle3)
                .foregroundColor(.textPrimary)
            
            Text("Try searching for a different restaurant name, cuisine type, or location")
                .font(.appSubheadline)
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, Spacing.xl)
            
            Spacer()
        }
    }
    
    // MARK: - Results Content
    
    private var resultsContent: some View {
        ScrollView {
            LazyVStack(spacing: Spacing.sm) {
                Text("\(searchResults.count) results")
                    .font(.appCaption)
                    .foregroundColor(.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, Spacing.md)
                
                ForEach(searchResults) { restaurant in
                    NavigationLink {
                        RestaurantDetailView(restaurant: restaurant)
                    } label: {
                        SearchResultCard(restaurant: restaurant, searchText: searchText)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.horizontal, Spacing.md)
                }
            }
            .padding(.vertical, Spacing.md)
            .padding(.bottom, Spacing.xl)
        }
    }
    
    // MARK: - Recent Searches Management
    
    private func loadRecentSearches() {
        if let saved = UserDefaults.standard.array(forKey: "recentSearches") as? [String] {
            recentSearches = saved
        }
    }
    
    private func addToRecentSearches(_ search: String) {
        var searches = recentSearches
        searches.removeAll { $0 == search }
        searches.insert(search, at: 0)
        searches = Array(searches.prefix(10))
        recentSearches = searches
        UserDefaults.standard.set(searches, forKey: "recentSearches")
    }
    
    private func clearRecentSearches() {
        recentSearches = []
        UserDefaults.standard.removeObject(forKey: "recentSearches")
    }
}

// MARK: - Search Result Card

struct SearchResultCard: View {
    let restaurant: Restaurant
    let searchText: String
    
    var body: some View {
        HStack(spacing: Spacing.md) {
            // Image
            AsyncImage(url: URL(string: restaurant.coverImage)) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                default:
                    Color(hex: restaurant.cuisineType.color).opacity(0.2)
                        .overlay {
                            Text(restaurant.cuisineType.icon)
                                .font(.title3)
                        }
                }
            }
            .frame(width: 70, height: 70)
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.small))
            
            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(restaurant.name)
                    .font(.appSubheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.textPrimary)
                    .lineLimit(1)
                
                HStack(spacing: Spacing.xs) {
                    CuisineBadge(cuisine: restaurant.cuisineType, showIcon: false, size: .small)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Text(String(format: "%.1f", restaurant.rating))
                            .font(.appCaption2)
                    }
                    .foregroundColor(.textSecondary)
                }
                
                HStack(spacing: 4) {
                    Image(systemName: "mappin.circle")
                        .font(.caption2)
                    Text(restaurant.displayLocation)
                    Text("•")
                    Text(restaurant.nearestStation)
                }
                .font(.appCaption)
                .foregroundColor(.textTertiary)
                .lineLimit(1)
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

#Preview {
    SearchView()
        .environmentObject(AppState())
        .environmentObject(DataService.shared)
        .environmentObject(LocationService.shared)
}
