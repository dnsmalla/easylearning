//
//  RestaurantDetailView.swift
//  SpiceBite
//
//  Detailed restaurant view
//

import SwiftUI

struct RestaurantDetailView: View {
    let restaurant: Restaurant
    
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var locationService: LocationService
    @EnvironmentObject var dataService: DataService
    @State private var selectedTab = 0
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Hero Image
                heroSection
                
                // Content
                VStack(spacing: Spacing.xl) {
                    // Quick Info
                    quickInfoSection
                    
                    // Action Buttons
                    actionButtons
                    
                    // Tabs
                    tabSection
                    
                    // Tab Content
                    tabContent
                    
                    // Similar Restaurants
                    similarRestaurantsSection
                }
                .padding(.horizontal, Spacing.md)
            }
        }
        .scrollContentBackground(.hidden)
        .safeAreaInset(edge: .bottom) {
            Color.clear.frame(height: 20)
        }
        .ignoresSafeArea(edges: .top)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack(spacing: Spacing.sm) {
                    Button {
                        HapticManager.shared.toggle()
                        appState.toggleSaved(for: restaurant)
                    } label: {
                        Image(systemName: appState.isSaved(restaurant) ? "heart.fill" : "heart")
                            .foregroundColor(appState.isSaved(restaurant) ? .accent : .textPrimary)
                    }
                    
                    Button {
                        HapticManager.shared.tap()
                        appState.addToCompare(restaurant)
                    } label: {
                        Image(systemName: "arrow.left.arrow.right")
                            .foregroundColor(.brand)
                    }
                    .disabled(appState.isInCompare(restaurant))
                    
                    ShareLink(item: restaurant.website ?? "https://spicebite.app") {
                        Image(systemName: "square.and.arrow.up")
                    }
                }
            }
        }
    }
    
    // MARK: - Hero Section
    
    private var heroSection: some View {
        ZStack(alignment: .bottomLeading) {
            // Image
            AsyncImage(url: URL(string: restaurant.coverImage)) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                default:
                    LinearGradient(
                        colors: [Color(hex: restaurant.cuisineType.color), Color(hex: restaurant.cuisineType.color).opacity(0.5)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .overlay {
                        Text(restaurant.cuisineType.icon)
                            .font(.system(size: 60))
                    }
                }
            }
            .frame(height: 280)
            .clipped()
            
            // Gradient overlay
            LinearGradient.heroOverlay
            
            // Content
            VStack(alignment: .leading, spacing: Spacing.sm) {
                CuisineBadge(cuisine: restaurant.cuisineType)
                
                Text(restaurant.name)
                    .font(.appTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                if let japaneseName = restaurant.japaneseName {
                    Text(japaneseName)
                        .font(.appSubheadline)
                        .foregroundColor(.white.opacity(0.9))
                }
                
                HStack(spacing: Spacing.md) {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .foregroundColor(.secondary)
                        Text(String(format: "%.1f", restaurant.rating))
                            .fontWeight(.bold)
                        Text("(\(restaurant.reviewCount))")
                            .foregroundColor(.white.opacity(0.8))
                    }
                    
                    Text(restaurant.priceRange.rawValue)
                        .fontWeight(.bold)
                    
                    if restaurant.operatingHours?.isOpenNow == true {
                        HStack(spacing: 4) {
                            Circle()
                                .fill(Color.success)
                                .frame(width: 8, height: 8)
                            Text("Open")
                        }
                        .foregroundColor(.success)
                    }
                }
                .font(.appSubheadline)
                .foregroundColor(.white)
            }
            .padding(Spacing.lg)
        }
    }
    
    // MARK: - Quick Info
    
    private var quickInfoSection: some View {
        VStack(spacing: Spacing.md) {
            // Location
            HStack(spacing: Spacing.md) {
                Image(systemName: "mappin.circle.fill")
                    .font(.title3)
                    .foregroundColor(.brand)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(restaurant.address)
                        .font(.appSubheadline)
                        .foregroundColor(.textPrimary)
                    
                    HStack(spacing: Spacing.xs) {
                        if let location = locationService.userLocation,
                           let distanceKm = restaurant.distanceKm(from: location) {
                            Text(Formatting.formatDistanceKm(distanceKm))
                        } else {
                            Text(restaurant.nearestStation)
                            Text("•")
                            Text(Formatting.formatWalkingTime(restaurant.walkingMinutes))
                        }
                    }
                    .font(.appCaption)
                    .foregroundColor(.textSecondary)
                }
                
                Spacer()
                
                if let url = restaurant.googleMapsUrl {
                    Link(destination: URL(string: url)!) {
                        Image(systemName: "arrow.up.right.square")
                            .font(.title3)
                            .foregroundColor(.brand)
                    }
                }
            }
            
            Divider()
            
            // Phone
            if let phone = restaurant.phone {
                HStack(spacing: Spacing.md) {
                    Image(systemName: "phone.circle.fill")
                        .font(.title3)
                        .foregroundColor(.brand)
                    
                    Text(phone)
                        .font(.appSubheadline)
                        .foregroundColor(.textPrimary)
                    
                    Spacer()
                    
                    Link(destination: URL(string: "tel:\(phone)")!) {
                        Text("Call")
                            .font(.appCaption)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding(.horizontal, Spacing.md)
                            .padding(.vertical, Spacing.xs)
                            .background(Color.brand)
                            .clipShape(Capsule())
                    }
                }
            }
            
            Divider()
            
            // Price Details
            HStack(spacing: Spacing.xl) {
                VStack(spacing: 4) {
                    Text("Lunch")
                        .font(.appCaption)
                        .foregroundColor(.textSecondary)
                    Text(Formatting.formatPrice(restaurant.priceRangeDetails?.averageLunch ?? 0))
                        .font(.appHeadline)
                        .fontWeight(.bold)
                        .foregroundColor(.textPrimary)
                }
                
                Rectangle()
                    .fill(Color.cardBorder)
                    .frame(width: 1, height: 40)
                
                VStack(spacing: 4) {
                    Text("Dinner")
                        .font(.appCaption)
                        .foregroundColor(.textSecondary)
                    Text(Formatting.formatPrice(restaurant.priceRangeDetails?.averageDinner ?? 0))
                        .font(.appHeadline)
                        .fontWeight(.bold)
                        .foregroundColor(.textPrimary)
                }
                
                Spacer()
                
                VStack(spacing: 4) {
                    Text("Price Range")
                        .font(.appCaption)
                        .foregroundColor(.textSecondary)
                    Text(restaurant.priceRange.description)
                        .font(.appCaption)
                        .foregroundColor(.textPrimary)
                }
            }
        }
        .padding(Spacing.lg)
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.xl))
        .cardShadow()
    }
    
    // MARK: - Action Buttons
    
    private var actionButtons: some View {
        HStack(spacing: Spacing.md) {
            if let website = restaurant.website, let url = URL(string: website) {
                Link(destination: url) {
                    HStack {
                        Image(systemName: "globe")
                        Text("Website")
                    }
                    .font(.appSubheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.brand)
                    .frame(maxWidth: .infinity)
                    .padding(Spacing.md)
                    .background(Color.brand.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium))
                }
            }
            
            if let maps = restaurant.googleMapsUrl, let url = URL(string: maps) {
                Link(destination: url) {
                    HStack {
                        Image(systemName: "map")
                        Text("Directions")
                    }
                    .font(.appSubheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(Spacing.md)
                    .background(Color.brand)
                    .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium))
                }
            }
        }
    }
    
    // MARK: - Tabs
    
    private var tabSection: some View {
        HStack(spacing: 0) {
            ForEach(["Info", "Menu", "Features"], id: \.self) { tab in
                let index = ["Info", "Menu", "Features"].firstIndex(of: tab) ?? 0
                Button {
                    HapticManager.shared.tap()
                    withAnimation(.smoothSpring) {
                        selectedTab = index
                    }
                } label: {
                    VStack(spacing: Spacing.xs) {
                        Text(tab)
                            .font(.appSubheadline)
                            .fontWeight(selectedTab == index ? .semibold : .regular)
                            .foregroundColor(selectedTab == index ? .brand : .textSecondary)
                        
                        Rectangle()
                            .fill(selectedTab == index ? Color.brand : Color.clear)
                            .frame(height: 3)
                            .clipShape(Capsule())
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.top, Spacing.md)
    }
    
    // MARK: - Tab Content
    
    @ViewBuilder
    private var tabContent: some View {
        switch selectedTab {
        case 0:
            infoContent
        case 1:
            menuContent
        case 2:
            featuresContent
        default:
            EmptyView()
        }
    }
    
    private var infoContent: some View {
        VStack(alignment: .leading, spacing: Spacing.lg) {
            // Description
            VStack(alignment: .leading, spacing: Spacing.sm) {
                Text("About")
                    .font(.appHeadline)
                    .foregroundColor(.textPrimary)
                
                Text(restaurant.description)
                    .font(.appBody)
                    .foregroundColor(.textSecondary)
            }
            
            // Specialties
            if !restaurant.specialties.isEmpty {
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    Text("Specialties")
                        .font(.appHeadline)
                        .foregroundColor(.textPrimary)
                    
                    FlowLayout(spacing: Spacing.sm) {
                        ForEach(restaurant.specialties, id: \.self) { specialty in
                            Text(specialty)
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
            
            // Dietary Info
            VStack(alignment: .leading, spacing: Spacing.sm) {
                Text("Dietary Information")
                    .font(.appHeadline)
                    .foregroundColor(.textPrimary)
                
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: Spacing.sm) {
                    DietaryBadge(title: "Halal", isAvailable: restaurant.isHalal, icon: "checkmark.seal")
                    DietaryBadge(title: "Vegetarian", isAvailable: restaurant.isVegetarian, icon: "leaf")
                    DietaryBadge(title: "Vegan Options", isAvailable: restaurant.hasVeganOptions, icon: "leaf.arrow.circlepath")
                    DietaryBadge(title: "English Menu", isAvailable: restaurant.hasEnglishMenu, icon: "character.book.closed")
                }
            }
            
            // Language Support
            VStack(alignment: .leading, spacing: Spacing.sm) {
                Text("Language Support")
                    .font(.appHeadline)
                    .foregroundColor(.textPrimary)
                
                HStack(spacing: Spacing.md) {
                    if restaurant.hasNepaliSpeakingStaff {
                        LanguageBadge(language: "🇳🇵 Nepali")
                    }
                    if restaurant.hasHindiSpeakingStaff {
                        LanguageBadge(language: "🇮🇳 Hindi")
                    }
                    if restaurant.hasEnglishMenu {
                        LanguageBadge(language: "🇬🇧 English")
                    }
                }
            }
        }
        .padding(Spacing.lg)
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.xl))
    }
    
    private var menuContent: some View {
        VStack(alignment: .leading, spacing: Spacing.lg) {
            Text("Menu Highlights")
                .font(.appHeadline)
                .foregroundColor(.textPrimary)
            
            if let menuHighlights = restaurant.menuHighlights, !menuHighlights.isEmpty {
                ForEach(menuHighlights) { item in
                    MenuItemCard(item: item)
                }
            } else {
                Text("Menu information coming soon")
                    .font(.appSubheadline)
                    .foregroundColor(.textSecondary)
            }
        }
        .padding(Spacing.lg)
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.xl))
    }
    
    private var featuresContent: some View {
        VStack(alignment: .leading, spacing: Spacing.lg) {
            Text("Features & Amenities")
                .font(.appHeadline)
                .foregroundColor(.textPrimary)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: Spacing.sm) {
                ForEach(restaurant.features, id: \.self) { feature in
                    FeatureBadge(feature: feature)
                }
            }
            
            if restaurant.acceptsCreditCard {
                HStack(spacing: Spacing.sm) {
                    Image(systemName: "creditcard")
                        .foregroundColor(.brand)
                    Text("Credit cards accepted")
                        .font(.appSubheadline)
                        .foregroundColor(.textPrimary)
                }
                .padding(.top, Spacing.sm)
            }
        }
        .padding(Spacing.lg)
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.xl))
    }
    
    // MARK: - Similar Restaurants
    
    private var similarRestaurantsSection: some View {
        let similar = dataService.getSimilarRestaurants(to: restaurant)
        
        return Group {
            if !similar.isEmpty {
                VStack(alignment: .leading, spacing: Spacing.md) {
                    Text("Similar Restaurants")
                        .font(.appHeadline)
                        .foregroundColor(.textPrimary)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: Spacing.md) {
                            ForEach(similar) { restaurant in
                                NavigationLink {
                                    RestaurantDetailView(restaurant: restaurant)
                                } label: {
                                    CompactRestaurantCard(restaurant: restaurant)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                }
                .padding(.top, Spacing.lg)
            }
        }
    }
}

// MARK: - Supporting Views

struct DietaryBadge: View {
    let title: String
    let isAvailable: Bool
    let icon: String
    
    var body: some View {
        HStack(spacing: Spacing.sm) {
            Image(systemName: icon)
                .foregroundColor(isAvailable ? .success : .textTertiary)
            
            Text(title)
                .font(.appCaption)
                .foregroundColor(isAvailable ? .textPrimary : .textTertiary)
            
            Spacer()
            
            Image(systemName: isAvailable ? "checkmark.circle.fill" : "xmark.circle")
                .foregroundColor(isAvailable ? .success : .textTertiary)
        }
        .padding(Spacing.sm)
        .background(isAvailable ? Color.success.opacity(0.1) : Color.backgroundSecondary)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.small))
    }
}

struct LanguageBadge: View {
    let language: String
    
    var body: some View {
        Text(language)
            .font(.appCaption)
            .foregroundColor(.textPrimary)
            .padding(.horizontal, Spacing.sm)
            .padding(.vertical, Spacing.xs)
            .background(Color.backgroundSecondary)
            .clipShape(Capsule())
    }
}

struct MenuItemCard: View {
    let item: MenuItem
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        HStack(spacing: Spacing.md) {
            // Image
            if let imageUrl = item.image {
                AsyncImage(url: URL(string: imageUrl)) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    default:
                        Color(hex: "DC6437").opacity(0.2)
                            .overlay {
                                Text(item.category.icon)
                            }
                    }
                }
                .frame(width: 70, height: 70)
                .clipShape(RoundedRectangle(cornerRadius: CornerRadius.small))
            }
            
            // Info
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(item.name)
                        .font(.appSubheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.textPrimary)
                    
                    if item.isPopular {
                        Text("🔥")
                    }
                }
                
                if let description = item.description {
                    Text(description)
                        .font(.appCaption)
                        .foregroundColor(.textSecondary)
                        .lineLimit(2)
                }
                
                HStack(spacing: Spacing.sm) {
                    if item.isVegetarian {
                        Image(systemName: "leaf.fill")
                            .font(.caption2)
                            .foregroundColor(.success)
                    }
                    
                    if item.isSpicy, let level = item.spiceLevel {
                        SpiceLevelView(level: level, size: 10)
                    }
                }
            }
            
            Spacer()
            
            // Price
            Text(appState.convertPrice(item.price))
                .font(.appHeadline)
                .fontWeight(.bold)
                .foregroundColor(.brand)
        }
        .padding(Spacing.sm)
        .background(Color.backgroundSecondary)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium))
    }
}

struct FeatureBadge: View {
    let feature: String
    
    private var icon: String {
        switch feature {
        case "Delivery": return "bicycle"
        case "Takeout": return "bag"
        case "Dine-in": return "fork.knife"
        case "Reservation": return "calendar"
        case "Private Room": return "door.left.hand.closed"
        case "Parking": return "car"
        case "Free WiFi": return "wifi"
        case "Child Friendly": return "figure.child"
        case "Non-Smoking": return "nosign"
        case "Buffet": return "tray.full"
        case "Lunch Set": return "sun.max"
        case "All-You-Can-Eat": return "fork.knife.circle"
        case "All-You-Can-Drink": return "wineglass"
        case "Late Night": return "moon.stars"
        case "Counter Seating": return "person.line.dotted.person"
        case "No Table Charge": return "checkmark.circle"
        default: return "star"
        }
    }
    
    var body: some View {
        HStack(spacing: Spacing.sm) {
            Image(systemName: icon)
                .font(.body)
                .foregroundColor(.brand)
            
            Text(feature)
                .font(.appCaption)
                .foregroundColor(.textPrimary)
            
            Spacer()
        }
        .padding(Spacing.sm)
        .background(Color.backgroundSecondary)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.small))
    }
}

#Preview {
    NavigationStack {
        RestaurantDetailView(restaurant: Restaurant(
            id: "test",
            name: "Test Restaurant",
            japaneseName: "テストレストラン",
            cuisineType: .indian,
            priceRange: .moderate,
            region: "Tokyo",
            country: "Japan",
            city: "Tokyo",
            latitude: 35.6895,
            longitude: 139.6917,
            address: "Tokyo, Japan",
            addressJapanese: nil,
            phone: "+81-3-1234-5678",
            website: "https://example.com",
            googleMapsUrl: nil,
            rating: 4.5,
            reviewCount: 123,
            description: "A great Indian restaurant",
            descriptionJapanese: nil,
            images: [],
            coverImage: "",
            operatingHours: OperatingHours(monday: nil, tuesday: nil, wednesday: nil, thursday: nil, friday: nil, saturday: nil, sunday: nil, holidays: nil, notes: nil),
            features: ["Dine-in", "Takeout"],
            specialties: ["Butter Chicken"],
            menuHighlights: [],
            priceRangeDetails: PriceRangeDetails(lunchMin: 800, lunchMax: 1500, dinnerMin: 1500, dinnerMax: 3000, averageLunch: 1000, averageDinner: 2000),
            isHalal: true,
            isVegetarian: false,
            hasVeganOptions: true,
            hasEnglishMenu: true,
            hasNepaliSpeakingStaff: true,
            hasHindiSpeakingStaff: true,
            acceptsCreditCard: true,
            nearestStation: "Shinjuku Station",
            walkingMinutes: 5,
            lastUpdated: "2024-12-01"
        ))
    }
    .environmentObject(AppState())
    .environmentObject(DataService.shared)
    .environmentObject(LocationService.shared)
}
