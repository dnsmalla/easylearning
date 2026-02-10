//
//  CompareView.swift
//  SpiceBite
//
//  Side-by-side restaurant comparison
//

import SwiftUI

struct CompareView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var dataService: DataService
    @State private var showAddSheet = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.backgroundPrimary.ignoresSafeArea()
                
                if appState.compareList.isEmpty {
                    emptyState
                } else if appState.compareList.count == 1 {
                    singleItemState
                } else {
                    comparisonContent
                }
            }
            .navigationTitle("Compare")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                if !appState.compareList.isEmpty {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            HapticManager.shared.tap()
                            showAddSheet = true
                        } label: {
                            Image(systemName: "plus.circle")
                                .foregroundColor(.brand)
                        }
                        .disabled(appState.compareList.count >= appState.maxCompareItems)
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            HapticManager.shared.tap()
                            appState.clearCompare()
                        } label: {
                            Text("Clear")
                                .foregroundColor(.accent)
                        }
                    }
                }
            }
            .sheet(isPresented: $showAddSheet) {
                AddToCompareSheet()
                    .environmentObject(appState)
                    .environmentObject(dataService)
            }
        }
    }
    
    // MARK: - Empty State
    
    private var emptyState: some View {
        VStack(spacing: Spacing.xl) {
            Image(systemName: "arrow.left.arrow.right.circle")
                .font(.system(size: 64))
                .foregroundColor(.brand.opacity(0.5))
            
            Text("Compare Restaurants")
                .font(.appTitle2)
                .foregroundColor(.textPrimary)
            
            Text("Add restaurants to compare prices, ratings, features, and more side by side")
                .font(.appSubheadline)
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, Spacing.xl)
            
            Button("Add Restaurants") {
                HapticManager.shared.medium()
                showAddSheet = true
            }
            .buttonStyle(PrimaryButtonStyle())
        }
        .padding(Spacing.xl)
    }
    
    // MARK: - Single Item State
    
    private var singleItemState: some View {
        VStack(spacing: Spacing.xl) {
            // Show the added restaurant
            if let restaurant = appState.compareList.first {
                CompareRestaurantCard(restaurant: restaurant, showRemove: true) {
                    appState.removeFromCompare(restaurant)
                }
            }
            
            // Prompt to add more
            VStack(spacing: Spacing.md) {
                Image(systemName: "plus.circle.dashed")
                    .font(.system(size: 48))
                    .foregroundColor(.textTertiary)
                
                Text("Add another restaurant to compare")
                    .font(.appSubheadline)
                    .foregroundColor(.textSecondary)
                
                Button("Add Restaurant") {
                    HapticManager.shared.tap()
                    showAddSheet = true
                }
                .buttonStyle(SecondaryButtonStyle())
            }
            .padding(Spacing.xl)
        }
        .padding(Spacing.md)
    }
    
    // MARK: - Comparison Content
    
    private var comparisonContent: some View {
        ScrollView {
            VStack(spacing: Spacing.lg) {
                // Restaurant Headers
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: Spacing.md) {
                        ForEach(appState.compareList) { restaurant in
                            CompareRestaurantCard(restaurant: restaurant, showRemove: true) {
                                appState.removeFromCompare(restaurant)
                            }
                            .frame(width: 160)
                        }
                    }
                    .padding(.horizontal, Spacing.md)
                }
                
                Divider()
                
                // Comparison Categories
                VStack(spacing: Spacing.md) {
                    ComparisonRow(title: "Rating", icon: "star.fill") { restaurant in
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(String(format: "%.1f", restaurant.rating))
                                .font(.appHeadline)
                                .fontWeight(.bold)
                        }
                        .foregroundColor(.textPrimary)
                    }
                    
                    ComparisonRow(title: "Reviews", icon: "bubble.left.and.bubble.right") { restaurant in
                        Text("\(restaurant.reviewCount)")
                            .font(.appHeadline)
                            .foregroundColor(.textPrimary)
                    }
                    
                    ComparisonRow(title: "Price Range", icon: "yensign.circle") { restaurant in
                        VStack(spacing: 4) {
                            Text(restaurant.priceRange.rawValue)
                                .font(.appHeadline)
                                .fontWeight(.bold)
                                .foregroundColor(.brand)
                            Text(restaurant.priceRange.description)
                                .font(.appCaption2)
                                .foregroundColor(.textSecondary)
                        }
                    }
                    
                    ComparisonRow(title: "Lunch Avg", icon: "sun.max") { restaurant in
                        Text(Formatting.formatPrice(restaurant.priceRangeDetails?.averageLunch ?? 0))
                            .font(.appHeadline)
                            .foregroundColor(.textPrimary)
                    }
                    
                    ComparisonRow(title: "Dinner Avg", icon: "moon") { restaurant in
                        Text(Formatting.formatPrice(restaurant.priceRangeDetails?.averageDinner ?? 0))
                            .font(.appHeadline)
                            .foregroundColor(.textPrimary)
                    }
                    
                    ComparisonRow(title: "Cuisine", icon: "fork.knife") { restaurant in
                        CuisineBadge(cuisine: restaurant.cuisineType, size: .small)
                    }
                    
                    ComparisonRow(title: "Location", icon: "mappin") { restaurant in
                        VStack(spacing: 2) {
                            Text(restaurant.displayLocation)
                                .font(.appSubheadline)
                                .foregroundColor(.textPrimary)
                            Text(restaurant.nearestStation)
                                .font(.appCaption2)
                                .foregroundColor(.textSecondary)
                        }
                    }
                    
                    ComparisonRow(title: "Walk Time", icon: "figure.walk") { restaurant in
                        Text(Formatting.formatWalkingTime(restaurant.walkingMinutes))
                            .font(.appSubheadline)
                            .foregroundColor(.textPrimary)
                    }
                    
                    ComparisonRow(title: "Halal", icon: "checkmark.seal") { restaurant in
                        Image(systemName: restaurant.isHalal ? "checkmark.circle.fill" : "xmark.circle")
                            .font(.title3)
                            .foregroundColor(restaurant.isHalal ? .success : .textTertiary)
                    }
                    
                    ComparisonRow(title: "Vegetarian", icon: "leaf") { restaurant in
                        Image(systemName: restaurant.isVegetarian ? "checkmark.circle.fill" : "xmark.circle")
                            .font(.title3)
                            .foregroundColor(restaurant.isVegetarian ? .success : .textTertiary)
                    }
                    
                    ComparisonRow(title: "English Menu", icon: "character.book.closed") { restaurant in
                        Image(systemName: restaurant.hasEnglishMenu ? "checkmark.circle.fill" : "xmark.circle")
                            .font(.title3)
                            .foregroundColor(restaurant.hasEnglishMenu ? .success : .textTertiary)
                    }
                    
                    ComparisonRow(title: "Nepali Staff", icon: "person.bubble") { restaurant in
                        Image(systemName: restaurant.hasNepaliSpeakingStaff ? "checkmark.circle.fill" : "xmark.circle")
                            .font(.title3)
                            .foregroundColor(restaurant.hasNepaliSpeakingStaff ? .success : .textTertiary)
                    }
                    
                    ComparisonRow(title: "Credit Card", icon: "creditcard") { restaurant in
                        Image(systemName: restaurant.acceptsCreditCard ? "checkmark.circle.fill" : "xmark.circle")
                            .font(.title3)
                            .foregroundColor(restaurant.acceptsCreditCard ? .success : .textTertiary)
                    }
                }
                .padding(.horizontal, Spacing.md)
            }
            .padding(.vertical, Spacing.lg)
        }
        .safeAreaInset(edge: .bottom) {
            Color.clear.frame(height: 90) // Space for tab bar
        }
    }
}

// MARK: - Compare Restaurant Card

struct CompareRestaurantCard: View {
    let restaurant: Restaurant
    var showRemove: Bool = false
    var onRemove: (() -> Void)?
    
    var body: some View {
        VStack(spacing: Spacing.sm) {
            // Image
            ZStack(alignment: .topTrailing) {
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
                                    .font(.title)
                            }
                    }
                }
                .frame(height: 100)
                .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium))
                
                if showRemove {
                    Button {
                        HapticManager.shared.tap()
                        onRemove?()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title3)
                            .foregroundColor(.white)
                            .background(Circle().fill(Color.black.opacity(0.5)))
                    }
                    .padding(8)
                }
            }
            
            // Name
            Text(restaurant.name)
                .font(.appSubheadline)
                .fontWeight(.semibold)
                .foregroundColor(.textPrimary)
                .lineLimit(2)
                .multilineTextAlignment(.center)
            
            // Rating
            HStack(spacing: 4) {
                Image(systemName: "star.fill")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Text(String(format: "%.1f", restaurant.rating))
                    .font(.appCaption)
                    .foregroundColor(.textSecondary)
            }
        }
        .padding(Spacing.sm)
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.large))
    }
}

// MARK: - Comparison Row

struct ComparisonRow<Content: View>: View {
    let title: String
    let icon: String
    let content: (Restaurant) -> Content
    
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        VStack(spacing: Spacing.sm) {
            // Header
            HStack(spacing: Spacing.xs) {
                Image(systemName: icon)
                    .foregroundColor(.brand)
                Text(title)
                    .font(.appSubheadline)
                    .foregroundColor(.textSecondary)
                Spacer()
            }
            
            // Values
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Spacing.md) {
                    ForEach(appState.compareList) { restaurant in
                        content(restaurant)
                            .frame(width: 160)
                            .frame(minHeight: 40)
                    }
                }
            }
        }
        .padding(Spacing.md)
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium))
    }
}

// MARK: - Add to Compare Sheet

struct AddToCompareSheet: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var dataService: DataService
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    
    var availableRestaurants: [Restaurant] {
        let existing = Set(appState.compareList.map { $0.id })
        var result = dataService.restaurants.filter { !existing.contains($0.id) }
        
        if !searchText.isEmpty {
            let query = searchText.lowercased()
            result = result.filter {
                $0.name.lowercased().contains(query) ||
                $0.cuisineType.rawValue.lowercased().contains(query)
            }
        }
        
        return result
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search
                HStack(spacing: Spacing.sm) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.textTertiary)
                    TextField("Search restaurants...", text: $searchText)
                        .font(.appBody)
                }
                .padding(Spacing.md)
                .background(Color.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: CornerRadius.large))
                .padding(Spacing.md)
                
                // List
                ScrollView {
                    LazyVStack(spacing: Spacing.sm) {
                        ForEach(availableRestaurants) { restaurant in
                            Button {
                                HapticManager.shared.medium()
                                appState.addToCompare(restaurant)
                                if appState.compareList.count >= appState.maxCompareItems {
                                    dismiss()
                                }
                            } label: {
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
                                        }
                                    }
                                    .frame(width: 60, height: 60)
                                    .clipShape(RoundedRectangle(cornerRadius: CornerRadius.small))
                                    
                                    // Info
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(restaurant.name)
                                            .font(.appSubheadline)
                                            .fontWeight(.semibold)
                                            .foregroundColor(.textPrimary)
                                        
                                        HStack(spacing: Spacing.xs) {
                                            CuisineBadge(cuisine: restaurant.cuisineType, showIcon: false, size: .small)
                                            Text("•")
                                                .foregroundColor(.textTertiary)
                                            Text(restaurant.displayLocation)
                                                .font(.appCaption)
                                                .foregroundColor(.textSecondary)
                                        }
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "plus.circle")
                                        .font(.title3)
                                        .foregroundColor(.brand)
                                }
                                .padding(Spacing.md)
                                .background(Color.cardBackground)
                                .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium))
                            }
                        }
                    }
                    .padding(.horizontal, Spacing.md)
                }
                .safeAreaInset(edge: .bottom) {
                    Color.clear.frame(height: 20)
                }
            }
            .navigationTitle("Add to Compare")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.brand)
                }
            }
        }
    }
}

#Preview {
    CompareView()
        .environmentObject(AppState())
        .environmentObject(DataService.shared)
}
