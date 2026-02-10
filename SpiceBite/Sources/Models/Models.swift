//
//  Models.swift
//  SpiceBite
//
//  Data models for Indian & Nepali Restaurant Comparison App
//

import Foundation
import CoreLocation

// MARK: - Cuisine Type

enum CuisineType: String, Codable, CaseIterable, Identifiable {
    case indian = "Indian"
    case nepali = "Nepali"
    case indoNepali = "Indo-Nepali"
    case northIndian = "North Indian"
    case southIndian = "South Indian"
    case himalayan = "Himalayan"
    
    var id: String { rawValue }

    var isNepaliOrIndian: Bool {
        switch self {
        case .indian, .nepali, .indoNepali, .northIndian, .southIndian, .himalayan:
            return true
        }
    }
    
    var icon: String {
        switch self {
        case .indian: return "🇮🇳"
        case .nepali: return "🇳🇵"
        case .indoNepali: return "🍛"
        case .northIndian: return "🫓"
        case .southIndian: return "🥘"
        case .himalayan: return "🏔️"
        }
    }
    
    var color: String {
        switch self {
        case .indian: return "FF9933"     // Saffron
        case .nepali: return "DC143C"     // Crimson
        case .indoNepali: return "8B4513"  // Saddle brown
        case .northIndian: return "D4AF37" // Gold
        case .southIndian: return "228B22" // Forest green
        case .himalayan: return "4169E1"   // Royal blue
        }
    }
}

// MARK: - Price Range

enum PriceRange: String, Codable, CaseIterable, Identifiable {
    case budget = "¥"
    case moderate = "¥¥"
    case upscale = "¥¥¥"
    case premium = "¥¥¥¥"
    
    var id: String { rawValue }
    
    var description: String {
        switch self {
        case .budget: return "Under ¥1,000"
        case .moderate: return "¥1,000 - ¥2,000"
        case .upscale: return "¥2,000 - ¥4,000"
        case .premium: return "Over ¥4,000"
        }
    }
    
    var averagePrice: Int {
        switch self {
        case .budget: return 800
        case .moderate: return 1500
        case .upscale: return 3000
        case .premium: return 5000
        }
    }
}

// MARK: - Japan Region

// Legacy Japan regions (kept for backward compatibility)
enum JapanRegion: String, Codable, CaseIterable, Identifiable {
    case tokyo = "Tokyo"
    case osaka = "Osaka"
    case kyoto = "Kyoto"
    case nagoya = "Nagoya"
    case fukuoka = "Fukuoka"
    case sapporo = "Sapporo"
    case yokohama = "Yokohama"
    case kobe = "Kobe"
    case hiroshima = "Hiroshima"
    case sendai = "Sendai"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .tokyo: return "🗼"
        case .osaka: return "🏯"
        case .kyoto: return "⛩️"
        case .nagoya: return "🐉"
        case .fukuoka: return "🍜"
        case .sapporo: return "❄️"
        case .yokohama: return "🎡"
        case .kobe: return "🥩"
        case .hiroshima: return "🕊️"
        case .sendai: return "🌸"
        }
    }
}

// MARK: - Restaurant

struct Restaurant: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let japaneseName: String?
    let cuisineType: CuisineType
    let priceRange: PriceRange
    let region: String?
    let country: String?
    let city: String?
    let latitude: Double?
    let longitude: Double?
    let address: String
    let addressJapanese: String?
    let phone: String?
    let website: String?
    let googleMapsUrl: String?
    let rating: Double
    let reviewCount: Int
    let description: String
    let descriptionJapanese: String?
    let images: [String]
    let coverImage: String
    let operatingHours: OperatingHours?
    let features: [String] // Changed to String array for flexible parsing
    let specialties: [String]
    let menuHighlights: [MenuItem]?
    let priceRangeDetails: PriceRangeDetails?
    let isHalal: Bool
    let isVegetarian: Bool
    let hasVeganOptions: Bool
    let hasEnglishMenu: Bool
    let hasNepaliSpeakingStaff: Bool
    let hasHindiSpeakingStaff: Bool
    let acceptsCreditCard: Bool
    let nearestStation: String
    let walkingMinutes: Int
    let lastUpdated: String?
    
    enum CodingKeys: String, CodingKey {
        case id, name, cuisineType, priceRange, region, address, phone, website
        case rating, description, images, features, specialties, country, city, latitude, longitude
        case japaneseName = "japanese_name"
        case addressJapanese = "address_japanese"
        case googleMapsUrl = "google_maps_url"
        case reviewCount = "review_count"
        case descriptionJapanese = "description_japanese"
        case coverImage = "cover_image"
        case operatingHours = "operating_hours"
        case menuHighlights = "menu_highlights"
        case priceRangeDetails = "price_range_details"
        case isHalal = "is_halal"
        case isVegetarian = "is_vegetarian"
        case hasVeganOptions = "has_vegan_options"
        case hasEnglishMenu = "has_english_menu"
        case hasNepaliSpeakingStaff = "has_nepali_speaking_staff"
        case hasHindiSpeakingStaff = "has_hindi_speaking_staff"
        case acceptsCreditCard = "accepts_credit_card"
        case nearestStation = "nearest_station"
        case walkingMinutes = "walking_minutes"
        case lastUpdated = "last_updated"
    }
    
    // Custom decoder to handle missing fields with defaults
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        japaneseName = try container.decodeIfPresent(String.self, forKey: .japaneseName)
        cuisineType = try container.decode(CuisineType.self, forKey: .cuisineType)
        priceRange = try container.decode(PriceRange.self, forKey: .priceRange)
        region = try container.decodeIfPresent(String.self, forKey: .region)
        country = try container.decodeIfPresent(String.self, forKey: .country)
        city = try container.decodeIfPresent(String.self, forKey: .city)
        latitude = try container.decodeIfPresent(Double.self, forKey: .latitude)
        longitude = try container.decodeIfPresent(Double.self, forKey: .longitude)
        address = try container.decode(String.self, forKey: .address)
        addressJapanese = try container.decodeIfPresent(String.self, forKey: .addressJapanese)
        phone = try container.decodeIfPresent(String.self, forKey: .phone)
        website = try container.decodeIfPresent(String.self, forKey: .website)
        googleMapsUrl = try container.decodeIfPresent(String.self, forKey: .googleMapsUrl)
        rating = try container.decode(Double.self, forKey: .rating)
        reviewCount = try container.decodeIfPresent(Int.self, forKey: .reviewCount) ?? 0
        description = try container.decode(String.self, forKey: .description)
        descriptionJapanese = try container.decodeIfPresent(String.self, forKey: .descriptionJapanese)
        images = try container.decodeIfPresent([String].self, forKey: .images) ?? []
        coverImage = try container.decode(String.self, forKey: .coverImage)
        operatingHours = try container.decodeIfPresent(OperatingHours.self, forKey: .operatingHours)
        features = try container.decodeIfPresent([String].self, forKey: .features) ?? []
        specialties = try container.decodeIfPresent([String].self, forKey: .specialties) ?? []
        menuHighlights = try container.decodeIfPresent([MenuItem].self, forKey: .menuHighlights)
        priceRangeDetails = try container.decodeIfPresent(PriceRangeDetails.self, forKey: .priceRangeDetails)
        isHalal = try container.decodeIfPresent(Bool.self, forKey: .isHalal) ?? false
        isVegetarian = try container.decodeIfPresent(Bool.self, forKey: .isVegetarian) ?? false
        hasVeganOptions = try container.decodeIfPresent(Bool.self, forKey: .hasVeganOptions) ?? false
        hasEnglishMenu = try container.decodeIfPresent(Bool.self, forKey: .hasEnglishMenu) ?? false
        hasNepaliSpeakingStaff = try container.decodeIfPresent(Bool.self, forKey: .hasNepaliSpeakingStaff) ?? false
        hasHindiSpeakingStaff = try container.decodeIfPresent(Bool.self, forKey: .hasHindiSpeakingStaff) ?? false
        acceptsCreditCard = try container.decodeIfPresent(Bool.self, forKey: .acceptsCreditCard) ?? true
        nearestStation = try container.decodeIfPresent(String.self, forKey: .nearestStation) ?? ""
        walkingMinutes = try container.decodeIfPresent(Int.self, forKey: .walkingMinutes) ?? 5
        lastUpdated = try container.decodeIfPresent(String.self, forKey: .lastUpdated)
    }
    
    // Standard initializer for programmatic creation
    init(
        id: String, name: String, japaneseName: String?, cuisineType: CuisineType,
        priceRange: PriceRange, region: String?, country: String?, city: String?,
        latitude: Double?, longitude: Double?, address: String, addressJapanese: String?,
        phone: String?, website: String?, googleMapsUrl: String?, rating: Double, reviewCount: Int,
        description: String, descriptionJapanese: String?, images: [String], coverImage: String,
        operatingHours: OperatingHours?, features: [String], specialties: [String],
        menuHighlights: [MenuItem]?, priceRangeDetails: PriceRangeDetails?, isHalal: Bool,
        isVegetarian: Bool, hasVeganOptions: Bool, hasEnglishMenu: Bool,
        hasNepaliSpeakingStaff: Bool, hasHindiSpeakingStaff: Bool, acceptsCreditCard: Bool,
        nearestStation: String, walkingMinutes: Int, lastUpdated: String?
    ) {
        self.id = id
        self.name = name
        self.japaneseName = japaneseName
        self.cuisineType = cuisineType
        self.priceRange = priceRange
        self.region = region
        self.country = country
        self.city = city
        self.latitude = latitude
        self.longitude = longitude
        self.address = address
        self.addressJapanese = addressJapanese
        self.phone = phone
        self.website = website
        self.googleMapsUrl = googleMapsUrl
        self.rating = rating
        self.reviewCount = reviewCount
        self.description = description
        self.descriptionJapanese = descriptionJapanese
        self.images = images
        self.coverImage = coverImage
        self.operatingHours = operatingHours
        self.features = features
        self.specialties = specialties
        self.menuHighlights = menuHighlights
        self.priceRangeDetails = priceRangeDetails
        self.isHalal = isHalal
        self.isVegetarian = isVegetarian
        self.hasVeganOptions = hasVeganOptions
        self.hasEnglishMenu = hasEnglishMenu
        self.hasNepaliSpeakingStaff = hasNepaliSpeakingStaff
        self.hasHindiSpeakingStaff = hasHindiSpeakingStaff
        self.acceptsCreditCard = acceptsCreditCard
        self.nearestStation = nearestStation
        self.walkingMinutes = walkingMinutes
        self.lastUpdated = lastUpdated
    }
    
    // Helper to check for specific features
    func hasFeature(_ feature: String) -> Bool {
        features.contains { $0.lowercased() == feature.lowercased() }
    }

    var hasCoordinates: Bool {
        latitude != nil && longitude != nil
    }

    var displayLocation: String {
        city ?? region ?? country ?? "Unknown"
    }

    func distanceKm(from location: CLLocation) -> Double? {
        guard let latitude, let longitude else { return nil }
        let restaurantLocation = CLLocation(latitude: latitude, longitude: longitude)
        return location.distance(from: restaurantLocation) / 1000.0
    }
}

// MARK: - Operating Hours

struct OperatingHours: Codable, Hashable {
    let monday: DayHours?
    let tuesday: DayHours?
    let wednesday: DayHours?
    let thursday: DayHours?
    let friday: DayHours?
    let saturday: DayHours?
    let sunday: DayHours?
    let holidays: String?
    let notes: String?
    
    var isOpenNow: Bool {
        let calendar = Calendar.current
        let now = Date()
        let weekday = calendar.component(.weekday, from: now)
        
        let todayHours: DayHours? = {
            switch weekday {
            case 1: return sunday
            case 2: return monday
            case 3: return tuesday
            case 4: return wednesday
            case 5: return thursday
            case 6: return friday
            case 7: return saturday
            default: return nil
            }
        }()
        
        guard let hours = todayHours, !hours.isClosed else { return false }
        // Simplified check - would need proper time parsing in production
        return true
    }
}

struct DayHours: Codable, Hashable {
    let open: String?
    let close: String?
    let lunchOpen: String?
    let lunchClose: String?
    let isClosed: Bool
    
    enum CodingKeys: String, CodingKey {
        case open, close
        case lunchOpen = "lunch_open"
        case lunchClose = "lunch_close"
        case isClosed = "is_closed"
    }
}

// MARK: - Restaurant Feature

enum RestaurantFeature: String, Codable, CaseIterable {
    case delivery = "Delivery"
    case takeout = "Takeout"
    case dineIn = "Dine-in"
    case reservation = "Reservation"
    case privateRoom = "Private Room"
    case parking = "Parking"
    case wifi = "Free WiFi"
    case childFriendly = "Child Friendly"
    case petFriendly = "Pet Friendly"
    case smokingArea = "Smoking Area"
    case nonSmoking = "Non-Smoking"
    case buffet = "Buffet"
    case lunchSet = "Lunch Set"
    case allYouCanEat = "All-You-Can-Eat"
    case allYouCanDrink = "All-You-Can-Drink"
    case lateNight = "Late Night"
    case earlyMorning = "Early Morning"
    case tableChargeIncluded = "No Table Charge"
    case counterSeating = "Counter Seating"
    
    var icon: String {
        switch self {
        case .delivery: return "bicycle"
        case .takeout: return "bag"
        case .dineIn: return "fork.knife"
        case .reservation: return "calendar"
        case .privateRoom: return "door.left.hand.closed"
        case .parking: return "car"
        case .wifi: return "wifi"
        case .childFriendly: return "figure.child"
        case .petFriendly: return "pawprint"
        case .smokingArea: return "smoke"
        case .nonSmoking: return "nosign"
        case .buffet: return "tray.full"
        case .lunchSet: return "sun.max"
        case .allYouCanEat: return "fork.knife.circle"
        case .allYouCanDrink: return "wineglass"
        case .lateNight: return "moon.stars"
        case .earlyMorning: return "sunrise"
        case .tableChargeIncluded: return "checkmark.circle"
        case .counterSeating: return "person.line.dotted.person"
        }
    }
}

// MARK: - Menu Item

struct MenuItem: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let japaneseName: String?
    let description: String?
    let price: Int
    let category: MenuCategory
    let image: String?
    let isPopular: Bool
    let isSpicy: Bool
    let spiceLevel: Int? // 1-5
    let isVegetarian: Bool
    let isVegan: Bool
    let allergens: [String]?
    
    enum CodingKeys: String, CodingKey {
        case id, name, description, price, category, image, allergens
        case japaneseName = "japanese_name"
        case isPopular = "is_popular"
        case isSpicy = "is_spicy"
        case spiceLevel = "spice_level"
        case isVegetarian = "is_vegetarian"
        case isVegan = "is_vegan"
    }
}

enum MenuCategory: String, Codable, CaseIterable {
    case appetizer = "Appetizer"
    case curry = "Curry"
    case tandoor = "Tandoor"
    case biryani = "Biryani"
    case naan = "Naan & Bread"
    case rice = "Rice"
    case momo = "Momo"
    case thali = "Thali Set"
    case dal = "Dal"
    case dessert = "Dessert"
    case drink = "Drink"
    case lunchSet = "Lunch Set"
    case special = "Special"
    
    var icon: String {
        switch self {
        case .appetizer: return "🥗"
        case .curry: return "🍛"
        case .tandoor: return "🍗"
        case .biryani: return "🍚"
        case .naan: return "🫓"
        case .rice: return "🍙"
        case .momo: return "🥟"
        case .thali: return "🍽️"
        case .dal: return "🫕"
        case .dessert: return "🍨"
        case .drink: return "🥤"
        case .lunchSet: return "☀️"
        case .special: return "⭐"
        }
    }
}

// MARK: - Price Range Details

struct PriceRangeDetails: Codable, Hashable {
    let lunchMin: Int
    let lunchMax: Int
    let dinnerMin: Int
    let dinnerMax: Int
    let averageLunch: Int
    let averageDinner: Int
    
    enum CodingKeys: String, CodingKey {
        case lunchMin = "lunch_min"
        case lunchMax = "lunch_max"
        case dinnerMin = "dinner_min"
        case dinnerMax = "dinner_max"
        case averageLunch = "average_lunch"
        case averageDinner = "average_dinner"
    }
}

// MARK: - Review

struct Review: Identifiable, Codable, Hashable {
    let id: String
    let restaurantId: String
    let userId: String
    let userName: String
    let userAvatar: String?
    let rating: Int // 1-5
    let title: String
    let content: String
    let visitDate: String
    let createdAt: String
    let likes: Int
    let images: [String]?
    let tags: [String]?
    let isVerified: Bool
    let language: String
    
    enum CodingKeys: String, CodingKey {
        case id, rating, title, content, likes, images, tags, language
        case restaurantId = "restaurant_id"
        case userId = "user_id"
        case userName = "user_name"
        case userAvatar = "user_avatar"
        case visitDate = "visit_date"
        case createdAt = "created_at"
        case isVerified = "is_verified"
    }
}

// MARK: - Comparison Item

struct ComparisonItem: Identifiable {
    let id: String
    let restaurant: Restaurant
    var isSelected: Bool = false
    
    init(restaurant: Restaurant) {
        self.id = restaurant.id
        self.restaurant = restaurant
    }
}

// MARK: - Response Wrappers

struct RestaurantsResponse: Codable {
    let version: String
    let lastUpdated: String
    let totalCount: Int
    let restaurants: [Restaurant]
    
    enum CodingKeys: String, CodingKey {
        case version, restaurants
        case lastUpdated = "last_updated"
        case totalCount = "total_count"
    }
}

// Regional response for split JSON files
struct RegionalRestaurantsResponse: Codable {
    let region: String
    let lastUpdated: String
    let restaurants: [Restaurant]
    
    enum CodingKeys: String, CodingKey {
        case region, restaurants
        case lastUpdated = "last_updated"
    }
}

struct ReviewsResponse: Codable {
    let version: String
    let restaurantId: String
    let reviews: [Review]
    
    enum CodingKeys: String, CodingKey {
        case version, reviews
        case restaurantId = "restaurant_id"
    }
}

// MARK: - Filter Options

struct RestaurantFilter {
    var cuisineTypes: Set<CuisineType> = []
    var priceRanges: Set<PriceRange> = []
    var countries: Set<String> = []
    var cities: Set<String> = []
    var features: Set<String> = [] // Using strings to match restaurant.features
    var isHalalOnly: Bool = false
    var isVegetarianOnly: Bool = false
    var hasVeganOptions: Bool = false
    var hasEnglishMenu: Bool = false
    var isOpenNow: Bool = false
    var minimumRating: Double = 0.0
    var sortBy: SortOption = .rating
    
    var isActive: Bool {
        !cuisineTypes.isEmpty ||
        !priceRanges.isEmpty ||
        !countries.isEmpty ||
        !cities.isEmpty ||
        !features.isEmpty ||
        isHalalOnly ||
        isVegetarianOnly ||
        hasVeganOptions ||
        hasEnglishMenu ||
        isOpenNow ||
        minimumRating > 0
    }
    
    mutating func reset() {
        cuisineTypes = []
        priceRanges = []
        countries = []
        cities = []
        features = []
        isHalalOnly = false
        isVegetarianOnly = false
        hasVeganOptions = false
        hasEnglishMenu = false
        isOpenNow = false
        minimumRating = 0.0
        sortBy = .rating
    }
}

enum SortOption: String, CaseIterable, Identifiable {
    case rating = "Rating"
    case reviewCount = "Most Reviews"
    case priceLowToHigh = "Price: Low to High"
    case priceHighToLow = "Price: High to Low"
    case nearest = "Nearest"
    case newest = "Recently Added"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .rating: return "star.fill"
        case .reviewCount: return "bubble.left.and.bubble.right.fill"
        case .priceLowToHigh: return "arrow.up.circle"
        case .priceHighToLow: return "arrow.down.circle"
        case .nearest: return "location.fill"
        case .newest: return "clock.fill"
        }
    }
}

// MARK: - Saved Restaurant

struct SavedRestaurant: Identifiable, Codable {
    let id: String
    let restaurantId: String
    let savedAt: String
    let notes: String?
    
    enum CodingKeys: String, CodingKey {
        case id, notes
        case restaurantId = "restaurant_id"
        case savedAt = "saved_at"
    }
}

// MARK: - Statistics

struct AppStatistics {
    var totalRestaurants: Int = 0
    var indianRestaurants: Int = 0
    var nepaliRestaurants: Int = 0
    var totalReviews: Int = 0
    var averageRating: Double = 0.0
    var countryCounts: [String: Int] = [:]
    var cityCounts: [String: Int] = [:]
}
