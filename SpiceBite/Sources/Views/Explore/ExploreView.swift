//
//  ExploreView.swift
//  SpiceBite
//
//  Explore restaurants with filters
//

import SwiftUI

struct ExploreView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var dataService: DataService
    @EnvironmentObject var locationService: LocationService
    @State private var searchText = ""
    @State private var showFilters = false
    
    var filteredRestaurants: [Restaurant] {
        dataService.filteredRestaurants(with: appState.activeFilter, searchQuery: searchText, userLocation: locationService.userLocation)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.backgroundPrimary.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Search Bar
                    searchBar
                        .padding(.horizontal, Spacing.md)
                        .padding(.vertical, Spacing.sm)
                    
                    // Active Filters
                    if appState.activeFilter.isActive {
                        activeFiltersBar
                    }
                    
                    // Results
                    if filteredRestaurants.isEmpty {
                        emptyState
                    } else {
                        ScrollView {
                            LazyVStack(spacing: Spacing.md) {
                                // Results count
                                HStack {
                                    Text("\(filteredRestaurants.count) restaurants found")
                                        .font(.appCaption)
                                        .foregroundColor(.textSecondary)
                                    Spacer()
                                    
                                    // Sort picker
                                    Menu {
                                        ForEach(SortOption.allCases) { option in
                                            Button {
                                                appState.activeFilter.sortBy = option
                                            } label: {
                                                Label(option.rawValue, systemImage: option.icon)
                                            }
                                        }
                                    } label: {
                                        HStack(spacing: 4) {
                                            Image(systemName: "arrow.up.arrow.down")
                                            Text(appState.activeFilter.sortBy.rawValue)
                                        }
                                        .font(.appCaption)
                                        .foregroundColor(.brand)
                                    }
                                }
                                .padding(.horizontal, Spacing.md)
                                
                                ForEach(filteredRestaurants) { restaurant in
                                    NavigationLink {
                                        RestaurantDetailView(restaurant: restaurant)
                                    } label: {
                                        RestaurantRowCard(restaurant: restaurant)
                                            .padding(.horizontal, Spacing.md)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .padding(.vertical, Spacing.md)
                        }
                        .safeAreaInset(edge: .bottom) {
                            Color.clear.frame(height: 90) // Space for tab bar
                        }
                    }
                }
            }
            .navigationTitle("Explore")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        HapticManager.shared.tap()
                        showFilters = true
                    } label: {
                        Image(systemName: appState.activeFilter.isActive ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle")
                            .font(.body)
                            .foregroundColor(.brand)
                    }
                }
            }
            .sheet(isPresented: $showFilters) {
                FilterView()
                    .environmentObject(appState)
                    .environmentObject(dataService)
            }
        }
    }
    
    // MARK: - Search Bar
    
    private var searchBar: some View {
        HStack(spacing: Spacing.sm) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.textTertiary)
            
            TextField("Search restaurants, cuisine, station...", text: $searchText)
                .font(.appBody)
            
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
    }
    
    // MARK: - Active Filters Bar
    
    private var activeFiltersBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Spacing.xs) {
                // Clear all button
                Button {
                    HapticManager.shared.tap()
                    appState.activeFilter.reset()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "xmark")
                        Text("Clear")
                    }
                    .font(.appCaption)
                    .foregroundColor(.accent)
                    .padding(.horizontal, Spacing.sm)
                    .padding(.vertical, Spacing.xs)
                    .background(Color.accent.opacity(0.1))
                    .clipShape(Capsule())
                }
                
                // Active filter chips
                ForEach(Array(appState.activeFilter.cuisineTypes), id: \.self) { cuisine in
                    FilterChip(text: cuisine.rawValue, icon: cuisine.icon) {
                        appState.activeFilter.cuisineTypes.remove(cuisine)
                    }
                }
                
                ForEach(Array(appState.activeFilter.priceRanges), id: \.self) { price in
                    FilterChip(text: price.rawValue) {
                        appState.activeFilter.priceRanges.remove(price)
                    }
                }
                
                ForEach(Array(appState.activeFilter.countries), id: \.self) { country in
                    FilterChip(text: country) {
                        appState.activeFilter.countries.remove(country)
                    }
                }
                
                ForEach(Array(appState.activeFilter.cities), id: \.self) { city in
                    FilterChip(text: city) {
                        appState.activeFilter.cities.remove(city)
                    }
                }
                
                if appState.activeFilter.isHalalOnly {
                    FilterChip(text: "Halal") {
                        appState.activeFilter.isHalalOnly = false
                    }
                }
                
                if appState.activeFilter.isVegetarianOnly {
                    FilterChip(text: "Vegetarian") {
                        appState.activeFilter.isVegetarianOnly = false
                    }
                }
            }
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, Spacing.xs)
        }
    }
    
    // MARK: - Empty State
    
    private var emptyState: some View {
        VStack(spacing: Spacing.lg) {
            Spacer()
            
            Image(systemName: "magnifyingglass")
                .font(.system(size: 48))
                .foregroundColor(.textTertiary)
            
            Text("No restaurants found")
                .font(.appTitle3)
                .foregroundColor(.textPrimary)
            
            Text("Try adjusting your search or filters")
                .font(.appSubheadline)
                .foregroundColor(.textSecondary)
            
            if appState.activeFilter.isActive {
                Button("Clear Filters") {
                    HapticManager.shared.tap()
                    appState.activeFilter.reset()
                }
                .buttonStyle(SecondaryButtonStyle())
            }
            
            Spacer()
        }
        .padding(Spacing.xl)
    }
}

// MARK: - Filter Chip

struct FilterChip: View {
    let text: String
    var icon: String? = nil
    let onRemove: () -> Void
    
    var body: some View {
        HStack(spacing: 4) {
            if let icon = icon {
                Text(icon)
                    .font(.caption)
            }
            Text(text)
                .font(.appCaption)
            
            Button {
                HapticManager.shared.tap()
                onRemove()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.caption)
            }
        }
        .foregroundColor(.brand)
        .padding(.horizontal, Spacing.sm)
        .padding(.vertical, Spacing.xs)
        .background(Color.brand.opacity(0.1))
        .clipShape(Capsule())
    }
}

// MARK: - Filter View

struct FilterView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var dataService: DataService
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Spacing.xl) {
                    // Cuisine Types
                    filterSection(title: "Cuisine Type", icon: "fork.knife") {
                        FlowLayout(spacing: Spacing.sm) {
                            ForEach(CuisineType.allCases) { cuisine in
                                FilterToggleButton(
                                    text: cuisine.rawValue,
                                    icon: cuisine.icon,
                                    isSelected: appState.activeFilter.cuisineTypes.contains(cuisine)
                                ) {
                                    if appState.activeFilter.cuisineTypes.contains(cuisine) {
                                        appState.activeFilter.cuisineTypes.remove(cuisine)
                                    } else {
                                        appState.activeFilter.cuisineTypes.insert(cuisine)
                                    }
                                }
                            }
                        }
                    }
                    
                    // Price Range
                    filterSection(title: "Price Range", icon: "yensign.circle") {
                        HStack(spacing: Spacing.sm) {
                            ForEach(PriceRange.allCases) { price in
                                FilterToggleButton(
                                    text: price.rawValue,
                                    isSelected: appState.activeFilter.priceRanges.contains(price)
                                ) {
                                    if appState.activeFilter.priceRanges.contains(price) {
                                        appState.activeFilter.priceRanges.remove(price)
                                    } else {
                                        appState.activeFilter.priceRanges.insert(price)
                                    }
                                }
                            }
                        }
                    }
                    
                    // Country
                    filterSection(title: "Country", icon: "globe") {
                        FlowLayout(spacing: Spacing.sm) {
                            ForEach(dataService.availableCountries(), id: \.self) { country in
                                FilterToggleButton(
                                    text: country,
                                    isSelected: appState.activeFilter.countries.contains(country)
                                ) {
                                    if appState.activeFilter.countries.contains(country) {
                                        appState.activeFilter.countries.remove(country)
                                    } else {
                                        appState.activeFilter.countries.insert(country)
                                    }
                                }
                            }
                        }
                    }
                    
                    // City
                    filterSection(title: "City", icon: "map") {
                        FlowLayout(spacing: Spacing.sm) {
                            ForEach(dataService.availableCities(), id: \.self) { city in
                                FilterToggleButton(
                                    text: city,
                                    isSelected: appState.activeFilter.cities.contains(city)
                                ) {
                                    if appState.activeFilter.cities.contains(city) {
                                        appState.activeFilter.cities.remove(city)
                                    } else {
                                        appState.activeFilter.cities.insert(city)
                                    }
                                }
                            }
                        }
                    }
                    
                    // Dietary Options
                    filterSection(title: "Dietary", icon: "leaf") {
                        VStack(spacing: Spacing.sm) {
                            FilterToggleRow(
                                title: "Halal Only",
                                icon: "checkmark.seal",
                                isOn: $appState.activeFilter.isHalalOnly
                            )
                            FilterToggleRow(
                                title: "Vegetarian Only",
                                icon: "leaf.fill",
                                isOn: $appState.activeFilter.isVegetarianOnly
                            )
                            FilterToggleRow(
                                title: "Has Vegan Options",
                                icon: "leaf.arrow.circlepath",
                                isOn: $appState.activeFilter.hasVeganOptions
                            )
                            FilterToggleRow(
                                title: "English Menu",
                                icon: "character.book.closed",
                                isOn: $appState.activeFilter.hasEnglishMenu
                            )
                        }
                    }
                    
                    // Minimum Rating
                    filterSection(title: "Minimum Rating", icon: "star") {
                        HStack(spacing: Spacing.md) {
                            ForEach([0.0, 3.0, 3.5, 4.0, 4.5], id: \.self) { rating in
                                Button {
                                    HapticManager.shared.tap()
                                    appState.activeFilter.minimumRating = rating
                                } label: {
                                    VStack(spacing: 4) {
                                        if rating == 0 {
                                            Text("Any")
                                                .font(.appCaption)
                                        } else {
                                            HStack(spacing: 2) {
                                                Image(systemName: "star.fill")
                                                    .font(.caption2)
                                                Text(String(format: "%.1f", rating))
                                                    .font(.appCaption)
                                            }
                                        }
                                    }
                                    .foregroundColor(appState.activeFilter.minimumRating == rating ? .white : .textPrimary)
                                    .padding(.horizontal, Spacing.md)
                                    .padding(.vertical, Spacing.sm)
                                    .background(appState.activeFilter.minimumRating == rating ? Color.brand : Color.cardBackground)
                                    .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium))
                                }
                            }
                        }
                    }
                }
                .padding(Spacing.lg)
            }
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Reset") {
                        HapticManager.shared.tap()
                        appState.activeFilter.reset()
                    }
                    .foregroundColor(.accent)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .foregroundColor(.brand)
                }
            }
        }
    }
    
    private func filterSection<Content: View>(
        title: String,
        icon: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            HStack(spacing: Spacing.xs) {
                Image(systemName: icon)
                    .foregroundColor(.brand)
                Text(title)
                    .font(.appHeadline)
                    .foregroundColor(.textPrimary)
            }
            
            content()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct FilterToggleButton: View {
    let text: String
    var icon: String? = nil
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            HapticManager.shared.tap()
            action()
        }) {
            HStack(spacing: 4) {
                if let icon = icon {
                    Text(icon)
                }
                Text(text)
                    .font(.appSubheadline)
            }
            .foregroundColor(isSelected ? .white : .textPrimary)
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, Spacing.sm)
            .background(isSelected ? Color.brand : Color.cardBackground)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(isSelected ? Color.brand : Color.cardBorder, lineWidth: 1)
            )
        }
    }
}

struct FilterToggleRow: View {
    let title: String
    let icon: String
    @Binding var isOn: Bool
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.brand)
            Text(title)
                .font(.appSubheadline)
                .foregroundColor(.textPrimary)
            Spacer()
            Toggle("", isOn: $isOn)
                .tint(.brand)
        }
        .padding(Spacing.md)
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium))
    }
}

// MARK: - Flow Layout

struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let sizes = subviews.map { $0.sizeThatFits(.unspecified) }
        return layout(sizes: sizes, containerWidth: proposal.width ?? 0).size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let sizes = subviews.map { $0.sizeThatFits(.unspecified) }
        let result = layout(sizes: sizes, containerWidth: bounds.width)
        
        for (index, frame) in result.frames.enumerated() {
            subviews[index].place(at: CGPoint(x: bounds.minX + frame.minX, y: bounds.minY + frame.minY), proposal: .unspecified)
        }
    }
    
    private func layout(sizes: [CGSize], containerWidth: CGFloat) -> (size: CGSize, frames: [CGRect]) {
        var frames: [CGRect] = []
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0
        
        for size in sizes {
            if x + size.width > containerWidth, x > 0 {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            
            frames.append(CGRect(origin: CGPoint(x: x, y: y), size: size))
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
        
        let width = containerWidth
        let height = y + rowHeight
        
        return (CGSize(width: width, height: height), frames)
    }
}

#Preview {
    ExploreView()
        .environmentObject(AppState())
        .environmentObject(DataService.shared)
        .environmentObject(LocationService.shared)
}
