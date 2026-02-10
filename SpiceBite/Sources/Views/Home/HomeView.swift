//
//  HomeView.swift
//  SpiceBite
//
//  Premium home screen with restaurant discovery
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var dataService: DataService
    @EnvironmentObject var locationService: LocationService
    @State private var animateContent = false
    @State private var showSearch = false
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                Color.backgroundPrimary.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: Spacing.xxl) {
                        // Hero Section
                        heroSection
                            .opacity(animateContent ? 1 : 0)
                            .offset(y: animateContent ? 0 : 20)
                        
                        // Quick Stats
                        quickStatsSection
                            .opacity(animateContent ? 1 : 0)
                            .offset(y: animateContent ? 0 : 20)
                        
                        // Cuisine Types
                        cuisineTypesSection
                            .opacity(animateContent ? 1 : 0)
                            .offset(y: animateContent ? 0 : 20)
                        
                        // Featured Restaurants
                        featuredRestaurantsSection
                        
                        // Browse by Country
                        regionsSection

                        // Quick Location Filters
                        quickLocationFiltersSection
                        
                        // Nearby Nepali & Indian
                        popularSection
                        
                        // Today's Recommendations
                        recommendationsSection
                    }
                    .padding(.horizontal, Spacing.md)
                    .padding(.top, Spacing.md)
                }
                .scrollIndicators(.hidden)
                .refreshable {
                    await dataService.refresh()
                }
                .safeAreaInset(edge: .bottom) {
                    Color.clear.frame(height: 90) // Space for tab bar
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    HStack(spacing: Spacing.xs) {
                        Text("🍛")
                            .font(.title2)
                        Text("SpiceBite")
                            .font(.appTitle2)
                            .foregroundColor(.textPrimary)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        HapticManager.shared.tap()
                        showSearch = true
                    } label: {
                        Image(systemName: "magnifyingglass")
                            .font(.body.weight(.medium))
                            .foregroundColor(.brand)
                    }
                }
            }
            .sheet(isPresented: $showSearch) {
                SearchView()
                    .environmentObject(appState)
                    .environmentObject(dataService)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.6).delay(0.1)) {
                animateContent = true
            }
        }
    }
    
    // MARK: - Hero Section
    
    private var heroSection: some View {
        ZStack(alignment: .bottomLeading) {
            // Background
            LinearGradient(
                colors: [Color.brand, Color.brandDark],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .overlay {
                // Pattern overlay
                Image(systemName: "fork.knife.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 200)
                    .foregroundColor(.white.opacity(0.1))
                    .offset(x: 100, y: -20)
            }
            .frame(height: 200)
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.xxl, style: .continuous))
            
            // Content
            VStack(alignment: .leading, spacing: Spacing.md) {
                HStack(spacing: Spacing.xs) {
                    Text("🇳🇵")
                    Text("🇮🇳")
                    Text("Worldwide")
                        .font(.appCaption)
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .padding(.horizontal, Spacing.sm)
                .padding(.vertical, Spacing.xxs)
                .background(.white.opacity(0.2))
                .clipShape(Capsule())
                
                Text("Find Your\nTaste of Home")
                    .font(.appTitle)
                    .foregroundColor(.white)
                
                Text("Discover \(dataService.restaurants.count)+ authentic Indian & Nepali restaurants")
                    .font(.appSubheadline)
                    .foregroundColor(.white.opacity(0.9))
            }
            .padding(Spacing.xl)
        }
        .shadow(color: Color.brand.opacity(0.3), radius: 20, x: 0, y: 10)
    }
    
    // MARK: - Quick Stats
    
    private var quickStatsSection: some View {
        HStack(spacing: Spacing.sm) {
            StatCard(
                icon: "fork.knife",
                value: "\(dataService.statistics.totalRestaurants)",
                label: "Restaurants",
                color: .brand
            )
            
            StatCard(
                icon: "star.fill",
                value: String(format: "%.1f", dataService.statistics.averageRating),
                label: "Avg Rating",
                color: .secondary
            )
            
            StatCard(
                icon: "bubble.left.and.bubble.right.fill",
                value: Formatting.formatNumber(dataService.statistics.totalReviews),
                label: "Reviews",
                color: .accent
            )
        }
    }
    
    // MARK: - Cuisine Types
    
    private var cuisineTypesSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            SectionHeader(title: "Cuisine Types", icon: "list.bullet")
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Spacing.md) {
                    ForEach(CuisineType.allCases) { cuisine in
                        NavigationLink {
                            RestaurantListView(title: cuisine.rawValue, cuisineFilter: cuisine)
                        } label: {
                            CuisineCard(cuisine: cuisine, count: countForCuisine(cuisine))
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
    
    private func countForCuisine(_ cuisine: CuisineType) -> Int {
        dataService.restaurants.filter { $0.cuisineType == cuisine }.count
    }
    
    // MARK: - Featured Restaurants
    
    private var featuredRestaurantsSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            HStack {
                SectionHeader(title: "Featured", icon: "star.circle.fill")
                Spacer()
                NavigationLink {
                    RestaurantListView(title: "Featured Restaurants")
                } label: {
                    Text("See All")
                        .font(.appCaption)
                        .fontWeight(.semibold)
                        .foregroundColor(.brand)
                }
            }
            
            if dataService.featuredRestaurants.isEmpty {
                EmptyStateCard(
                    icon: "star",
                    title: "No Featured Restaurants",
                    message: "Featured restaurants will appear here"
                )
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: Spacing.md) {
                        ForEach(dataService.featuredRestaurants) { restaurant in
                            NavigationLink {
                                RestaurantDetailView(restaurant: restaurant)
                            } label: {
                                FeaturedRestaurantCard(restaurant: restaurant)
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
    
    // MARK: - Countries Section
    
    private var regionsSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            SectionHeader(title: "Browse by Country", icon: "globe")
            
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: Spacing.sm),
                GridItem(.flexible(), spacing: Spacing.sm)
            ], spacing: Spacing.sm) {
                ForEach(dataService.availableCountries().prefix(6), id: \.self) { country in
                    NavigationLink {
                        RestaurantListView(title: country, countryFilter: country)
                    } label: {
                        CountryCard(country: country, count: dataService.statistics.countryCounts[country] ?? 0)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
    }
    
    // MARK: - Popular Section
    
    private var popularSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            HStack {
                SectionHeader(title: locationService.userLocation == nil ? "Popular Nepali & Indian" : "Nearby Nepali & Indian", icon: "location.fill")
                Spacer()
                NavigationLink {
                    RestaurantListView(title: "Nepali & Indian Restaurants")
                } label: {
                    Text("View All")
                        .font(.appCaption)
                        .fontWeight(.semibold)
                        .foregroundColor(.brand)
                }
            }
            
            VStack(spacing: Spacing.sm) {
                ForEach(dataService.nearbyNepaliIndianRestaurants(userLocation: locationService.userLocation, limit: 5)) { restaurant in
                    NavigationLink {
                        RestaurantDetailView(restaurant: restaurant)
                    } label: {
                        RestaurantRowCard(restaurant: restaurant)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
    }
    
    // MARK: - Recommendations
    
    private var recommendationsSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            SectionHeader(title: "For You", icon: "heart.fill")
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Spacing.md) {
                    ForEach(dataService.restaurants.shuffled().prefix(8)) { restaurant in
                        NavigationLink {
                            RestaurantDetailView(restaurant: restaurant)
                        } label: {
                            CompactRestaurantCard(restaurant: restaurant)
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

    // MARK: - Quick Location Filters

    private var quickLocationFiltersSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            SectionHeader(title: "Quick Filters", icon: "line.3.horizontal.decrease.circle")

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Spacing.sm) {
                    ForEach(dataService.availableCountries().prefix(8), id: \.self) { country in
                        Button {
                            HapticManager.shared.tap()
                            appState.activeFilter.countries = [country]
                            appState.activeFilter.cities = []
                            appState.selectedTab = .explore
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "globe")
                                    .font(.caption)
                                Text(country)
                                    .font(.appCaption)
                            }
                            .foregroundColor(.textPrimary)
                            .padding(.horizontal, Spacing.sm)
                            .padding(.vertical, Spacing.xs)
                            .background(Color.cardBackground)
                            .clipShape(Capsule())
                            .overlay(
                                Capsule()
                                    .stroke(Color.cardBorder, lineWidth: 1)
                            )
                        }
                    }

                    ForEach(dataService.availableCities().prefix(8), id: \.self) { city in
                        Button {
                            HapticManager.shared.tap()
                            appState.activeFilter.cities = [city]
                            appState.activeFilter.countries = []
                            appState.selectedTab = .explore
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "map")
                                    .font(.caption)
                                Text(city)
                                    .font(.appCaption)
                            }
                            .foregroundColor(.textPrimary)
                            .padding(.horizontal, Spacing.sm)
                            .padding(.vertical, Spacing.xs)
                            .background(Color.cardBackground)
                            .clipShape(Capsule())
                            .overlay(
                                Capsule()
                                    .stroke(Color.cardBorder, lineWidth: 1)
                            )
                        }
                    }
                }
                .padding(.horizontal, 2)
            }
        }
    }
}

// MARK: - Supporting Views

struct SectionHeader: View {
    let title: String
    var icon: String? = nil
    
    var body: some View {
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
    }
}

struct StatCard: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: Spacing.xs) {
            Image(systemName: icon)
                .font(.title3)
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
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.large))
        .cardShadow()
    }
}

struct CuisineCard: View {
    let cuisine: CuisineType
    let count: Int
    
    var body: some View {
        VStack(spacing: Spacing.sm) {
            Text(cuisine.icon)
                .font(.system(size: 32))
            
            Text(cuisine.rawValue)
                .font(.appSubheadline)
                .fontWeight(.semibold)
                .foregroundColor(.textPrimary)
            
            Text("\(count) places")
                .font(.appCaption2)
                .foregroundColor(.textSecondary)
        }
        .frame(width: 100, height: 110)
        .background(Color(hex: cuisine.color).opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.large))
        .overlay(
            RoundedRectangle(cornerRadius: CornerRadius.large)
                .stroke(Color(hex: cuisine.color).opacity(0.3), lineWidth: 1)
        )
    }
}

struct CountryCard: View {
    let country: String
    let count: Int
    
    var body: some View {
        HStack(spacing: Spacing.sm) {
            Image(systemName: "globe")
                .font(.title3)
                .foregroundColor(.brand)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(country)
                    .font(.appSubheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.textPrimary)
                
                Text("\(count) restaurants")
                    .font(.appCaption2)
                    .foregroundColor(.textSecondary)
            }
            
            Spacer()
        }
        .padding(Spacing.md)
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium))
    }
}

struct FeaturedRestaurantCard: View {
    let restaurant: Restaurant
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Image
            ZStack(alignment: .topTrailing) {
                AsyncImage(url: URL(string: restaurant.coverImage)) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    default:
                        LinearGradient(
                            colors: [Color(hex: restaurant.cuisineType.color).opacity(0.3), Color(hex: restaurant.cuisineType.color).opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        .overlay {
                            Text(restaurant.cuisineType.icon)
                                .font(.system(size: 40))
                        }
                    }
                }
                .frame(width: 240, height: 140)
                .clipShape(RoundedRectangle(cornerRadius: CornerRadius.large, style: .continuous))
                
                // Rating Badge
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text(String(format: "%.1f", restaurant.rating))
                        .font(.caption)
                        .fontWeight(.bold)
                }
                .foregroundColor(.textPrimary)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(.ultraThinMaterial)
                .clipShape(Capsule())
                .padding(10)
            }
            
            // Info
            VStack(alignment: .leading, spacing: Spacing.xs) {
                HStack {
                    Text(restaurant.name)
                        .font(.appSubheadline)
                        .fontWeight(.bold)
                        .foregroundColor(.textPrimary)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    PriceTagView(priceRange: restaurant.priceRange)
                }
                
                HStack(spacing: Spacing.xs) {
                    CuisineBadge(cuisine: restaurant.cuisineType, size: .small)
                    
                    Spacer()
                    
                    HStack(spacing: 4) {
                        Image(systemName: "mappin.circle.fill")
                            .font(.caption2)
                        Text(restaurant.displayLocation)
                            .font(.appCaption2)
                    }
                    .foregroundColor(.textSecondary)
                }
                
                HStack(spacing: 4) {
                    Image(systemName: "train.side.front.car")
                        .font(.caption2)
                    Text(restaurant.nearestStation)
                        .font(.appCaption2)
                    Text("•")
                    Text(Formatting.formatWalkingTime(restaurant.walkingMinutes))
                        .font(.appCaption2)
                }
                .foregroundColor(.textTertiary)
            }
            .padding(Spacing.md)
        }
        .frame(width: 240)
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.xl, style: .continuous))
        .shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: 5)
    }
}

struct RestaurantRowCard: View {
    let restaurant: Restaurant
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var locationService: LocationService
    
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
            .frame(width: 80, height: 80)
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium))
            
            // Info
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text(restaurant.name)
                    .font(.appSubheadline)
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
                    CuisineBadge(cuisine: restaurant.cuisineType, showIcon: false, size: .small)
                    Text("•")
                        .foregroundColor(.textTertiary)
                    if let location = locationService.userLocation,
                       let distanceKm = restaurant.distanceKm(from: location) {
                        Text(Formatting.formatDistanceKm(distanceKm))
                            .font(.appCaption)
                            .foregroundColor(.textSecondary)
                    } else if let city = restaurant.city {
                        Text(city)
                            .font(.appCaption)
                            .foregroundColor(.textSecondary)
                    } else {
                    Text(restaurant.displayLocation)
                            .font(.appCaption)
                            .foregroundColor(.textSecondary)
                    }
                }
            }
            
            Spacer()
            
            // Actions
            VStack(alignment: .trailing, spacing: Spacing.sm) {
                PriceTagView(priceRange: restaurant.priceRange)
                
                Button {
                    HapticManager.shared.toggle()
                    appState.toggleSaved(for: restaurant)
                } label: {
                    Image(systemName: appState.isSaved(restaurant) ? "heart.fill" : "heart")
                        .font(.body)
                        .foregroundColor(appState.isSaved(restaurant) ? .accent : .textTertiary)
                }
            }
        }
        .padding(Spacing.md)
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.large))
        .cardShadow()
    }
}

struct CompactRestaurantCard: View {
    let restaurant: Restaurant
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
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
                                .font(.title)
                        }
                }
            }
            .frame(width: 150, height: 100)
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium))
            
            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(restaurant.name)
                    .font(.appCaption)
                    .fontWeight(.semibold)
                    .foregroundColor(.textPrimary)
                    .lineLimit(1)
                
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text(String(format: "%.1f", restaurant.rating))
                        .font(.appCaption2)
                        .foregroundColor(.textSecondary)
                    
                    Text(restaurant.priceRange.rawValue)
                        .font(.appCaption2)
                        .foregroundColor(.brand)
                }
            }
        }
        .frame(width: 150)
        .padding(Spacing.sm)
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.large))
    }
}

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
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(Spacing.xl)
        .background(Color.backgroundSecondary)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.large))
    }
}

#Preview {
    HomeView()
        .environmentObject(AppState())
        .environmentObject(DataService.shared)
        .environmentObject(LocationService.shared)
}
