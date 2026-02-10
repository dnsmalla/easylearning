//
//  RestaurantListView.swift
//  SpiceBite
//
//  List view for restaurants with optional filters
//

import SwiftUI

struct RestaurantListView: View {
    let title: String
    var cuisineFilter: CuisineType? = nil
    var countryFilter: String? = nil
    var cityFilter: String? = nil
    
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var dataService: DataService
    @EnvironmentObject var locationService: LocationService
    
    var filteredRestaurants: [Restaurant] {
        var result = dataService.restaurants
        
        if let cuisine = cuisineFilter {
            result = result.filter { $0.cuisineType == cuisine }
        }
        
        if let country = countryFilter {
            result = result.filter { $0.country == country }
        }
        
        if let city = cityFilter {
            result = result.filter { $0.city == city }
        }
        
        // Apply app state filters
        result = dataService.filteredRestaurants(with: appState.activeFilter, searchQuery: "", userLocation: locationService.userLocation)
            .filter { restaurant in
                if let cuisine = cuisineFilter {
                    return restaurant.cuisineType == cuisine
                }
                if let country = countryFilter {
                    return restaurant.country == country
                }
                if let city = cityFilter {
                    return restaurant.city == city
                }
                return true
            }
        
        return result
    }
    
    var body: some View {
        ZStack {
            Color.backgroundPrimary.ignoresSafeArea()
            
            if filteredRestaurants.isEmpty {
                VStack(spacing: Spacing.lg) {
                    Image(systemName: "fork.knife.circle")
                        .font(.system(size: 48))
                        .foregroundColor(.textTertiary)
                    
                    Text("No restaurants found")
                        .font(.appTitle3)
                        .foregroundColor(.textSecondary)
                    
                    if let cuisine = cuisineFilter {
                        Text("in \(cuisine.rawValue) category")
                            .font(.appSubheadline)
                            .foregroundColor(.textTertiary)
                    }
                }
            } else {
                ScrollView {
                    LazyVStack(spacing: Spacing.md) {
                        // Header info
                        HStack {
                            if let cuisine = cuisineFilter {
                                HStack(spacing: Spacing.xs) {
                                    Text(cuisine.icon)
                                    Text("\(filteredRestaurants.count) \(cuisine.rawValue) restaurants")
                                }
                            } else if let country = countryFilter {
                                HStack(spacing: Spacing.xs) {
                                    Image(systemName: "globe")
                                    Text("\(filteredRestaurants.count) restaurants in \(country)")
                                }
                            } else if let city = cityFilter {
                                HStack(spacing: Spacing.xs) {
                                    Image(systemName: "map")
                                    Text("\(filteredRestaurants.count) restaurants in \(city)")
                                }
                            } else {
                                Text("\(filteredRestaurants.count) restaurants")
                            }
                            Spacer()
                        }
                        .font(.appCaption)
                        .foregroundColor(.textSecondary)
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
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.large)
    }
}

#Preview {
    NavigationStack {
        RestaurantListView(title: "All Restaurants")
    }
    .environmentObject(AppState())
    .environmentObject(DataService.shared)
    .environmentObject(LocationService.shared)
}
