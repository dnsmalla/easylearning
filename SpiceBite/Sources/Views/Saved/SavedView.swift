//
//  SavedView.swift
//  SpiceBite
//
//  User's saved/favorite restaurants
//

import SwiftUI

struct SavedView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var dataService: DataService
    
    var savedRestaurants: [Restaurant] {
        dataService.restaurants.filter { appState.savedRestaurantIds.contains($0.id) }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.backgroundPrimary.ignoresSafeArea()
                
                if savedRestaurants.isEmpty {
                    emptyState
                } else {
                    ScrollView {
                        LazyVStack(spacing: Spacing.md) {
                            ForEach(savedRestaurants) { restaurant in
                                NavigationLink {
                                    RestaurantDetailView(restaurant: restaurant)
                                } label: {
                                    SavedRestaurantCard(restaurant: restaurant)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(Spacing.md)
                    }
                    .safeAreaInset(edge: .bottom) {
                        Color.clear.frame(height: 90) // Space for tab bar
                    }
                }
            }
            .navigationTitle("Saved")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: Spacing.xl) {
            Image(systemName: "heart.circle")
                .font(.system(size: 64))
                .foregroundColor(.accent.opacity(0.5))
            
            Text("No Saved Restaurants")
                .font(.appTitle2)
                .foregroundColor(.textPrimary)
            
            Text("Tap the heart icon on any restaurant to save it here for quick access")
                .font(.appSubheadline)
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, Spacing.xl)
            
            NavigationLink {
                ExploreView()
            } label: {
                Text("Explore Restaurants")
            }
            .buttonStyle(PrimaryButtonStyle())
        }
        .padding(Spacing.xl)
    }
}

struct SavedRestaurantCard: View {
    let restaurant: Restaurant
    @EnvironmentObject var appState: AppState
    
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
                                .font(.title2)
                        }
                }
            }
            .frame(width: 100, height: 100)
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium))
            
            // Info
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text(restaurant.name)
                    .font(.appHeadline)
                    .fontWeight(.bold)
                    .foregroundColor(.textPrimary)
                    .lineLimit(1)
                
                HStack(spacing: Spacing.xs) {
                    RatingStarsView(rating: restaurant.rating, size: 12)
                    Text("(\(restaurant.reviewCount))")
                        .font(.appCaption2)
                        .foregroundColor(.textSecondary)
                }
                
                HStack(spacing: Spacing.xs) {
                    CuisineBadge(cuisine: restaurant.cuisineType, size: .small)
                    PriceTagView(priceRange: restaurant.priceRange)
                }
                
                HStack(spacing: 4) {
                    Image(systemName: "mappin.circle.fill")
                        .font(.caption2)
                    Text(restaurant.displayLocation)
                        .font(.appCaption)
                    Text("•")
                    Text(restaurant.nearestStation)
                        .font(.appCaption)
                }
                .foregroundColor(.textSecondary)
            }
            
            Spacer()
            
            // Actions
            VStack(spacing: Spacing.md) {
                Button {
                    HapticManager.shared.toggle()
                    appState.toggleSaved(for: restaurant)
                } label: {
                    Image(systemName: "heart.fill")
                        .font(.title3)
                        .foregroundColor(.accent)
                }
                
                Button {
                    HapticManager.shared.tap()
                    if !appState.isInCompare(restaurant) {
                        appState.addToCompare(restaurant)
                    }
                } label: {
                    Image(systemName: appState.isInCompare(restaurant) ? "arrow.left.arrow.right.circle.fill" : "arrow.left.arrow.right.circle")
                        .font(.title3)
                        .foregroundColor(.brand)
                }
            }
        }
        .padding(Spacing.md)
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.large))
        .cardShadow()
    }
}

#Preview {
    SavedView()
        .environmentObject(AppState())
        .environmentObject(DataService.shared)
}
