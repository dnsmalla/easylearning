//
//  DataService.swift
//  SpiceBite
//
//  Central data service for loading and managing restaurant data
//  Supports both local bundle and GitHub-based JSON data
//

import Foundation
import CoreLocation

// MARK: - Manifest Model

struct DataManifest: Codable {
    let version: String
    let appName: String
    let lastUpdated: String
    let minAppVersion: String
    let baseUrl: String
    let files: [String: ManifestFile]
    
    enum CodingKeys: String, CodingKey {
        case version, files
        case appName = "app_name"
        case lastUpdated = "last_updated"
        case minAppVersion = "min_app_version"
        case baseUrl = "base_url"
    }
}

struct ManifestFile: Codable {
    let filename: String
    let path: String
    let version: String
    let description: String?
    let itemCount: Int?
    
    enum CodingKeys: String, CodingKey {
        case filename, path, version, description
        case itemCount = "item_count"
    }
}

// MARK: - Data Service

@MainActor
final class DataService: ObservableObject {
    static let shared = DataService()
    
    // MARK: - GitHub Configuration
    
    /// Change this to your GitHub raw content URL
    private let githubBaseURL = "https://raw.githubusercontent.com/dnsmalla/spicebite-data/main"
    
    // MARK: - Published Properties
    
    @Published var restaurants: [Restaurant] = []
    @Published var featuredRestaurants: [Restaurant] = []
    @Published var reviews: [String: [Review]] = [:]
    
    @Published var isLoading = false
    @Published var isSyncing = false
    @Published var error: String?
    @Published var lastSyncDate: Date?
    @Published var dataVersion: String = "1.0.0"
    
    // MARK: - Statistics
    
    @Published var statistics = AppStatistics()
    
    // MARK: - Cache
    
    private let cacheDir: URL = {
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("SpiceBiteData")
    }()
    
    private let versionKey = "SpiceBiteDataVersion"
    private let lastSyncKey = "SpiceBiteLastSync"
    
    private init() {
        try? FileManager.default.createDirectory(at: cacheDir, withIntermediateDirectories: true)
        loadCachedVersion()
    }
    
    // MARK: - Load All Data
    
    func loadAllData() async {
        isLoading = true
        error = nil
        
        // First load from cache/bundle for instant display
        await loadFromLocalSources()
        calculateStatistics()
        
        // Then check for updates from GitHub in background
        await syncFromGitHub()
        
        isLoading = false
    }
    
    // MARK: - Load From Local Sources
    
    private func loadFromLocalSources() async {
        var allRestaurants: [Restaurant] = []
        
        let regionalFiles = ["restaurants_global"]
        
        for fileName in regionalFiles {
            // Try cache first, then bundle
            if let data = loadFromCache(fileName) ?? loadFromBundle(fileName) {
                if let regional = try? JSONDecoder().decode(RegionalRestaurantsResponse.self, from: data) {
                    allRestaurants.append(contentsOf: regional.restaurants)
                    print("📦 Loaded \(regional.restaurants.count) restaurants from \(fileName)")
                } else if let response = try? JSONDecoder().decode(RestaurantsResponse.self, from: data) {
                    allRestaurants.append(contentsOf: response.restaurants)
                    print("📦 Loaded \(response.restaurants.count) restaurants from \(fileName)")
                }
            }
        }
        
        if allRestaurants.isEmpty {
            loadSampleData()
        } else {
            var seen = Set<String>()
            restaurants = allRestaurants.filter { seen.insert($0.id).inserted }
            featuredRestaurants = restaurants.filter { $0.rating >= 4.3 }.prefix(15).map { $0 }
            print("✅ Total restaurants loaded: \(restaurants.count)")
        }
    }
    
    // MARK: - GitHub Sync
    
    func syncFromGitHub() async {
        isSyncing = true
        
        do {
            // Fetch manifest
            guard let manifestURL = URL(string: "\(githubBaseURL)/manifest.json") else {
                throw DataError.invalidURL
            }
            
            let (manifestData, _) = try await URLSession.shared.data(from: manifestURL)
            let manifest = try JSONDecoder().decode(DataManifest.self, from: manifestData)
            
            print("🌐 Remote version: \(manifest.version), Local version: \(dataVersion)")
            
            // Check if update needed
            if manifest.version > dataVersion {
                print("📥 Downloading updated data...")
                await downloadAllFiles(from: manifest)
                
                // Update local version
                dataVersion = manifest.version
                UserDefaults.standard.set(dataVersion, forKey: versionKey)
                
                // Reload data
                await loadFromLocalSources()
                calculateStatistics()
                
                print("✅ Data updated to version \(manifest.version)")
            } else {
                print("✅ Data is up to date")
            }
            
            lastSyncDate = Date()
            UserDefaults.standard.set(lastSyncDate, forKey: lastSyncKey)
            
        } catch {
            print("⚠️ GitHub sync failed: \(error.localizedDescription)")
            // Don't set error - we still have cached/bundled data
        }
        
        isSyncing = false
    }
    
    private func downloadAllFiles(from manifest: DataManifest) async {
        for (key, file) in manifest.files {
            do {
                guard let url = URL(string: "\(githubBaseURL)/\(file.path)") else { continue }
                
                let (data, _) = try await URLSession.shared.data(from: url)
                
                // Validate JSON
                _ = try JSONSerialization.jsonObject(with: data)
                
                // Save to cache
                let cacheURL = cacheDir.appendingPathComponent(file.filename)
                try data.write(to: cacheURL)
                
                print("📥 Downloaded: \(file.filename) (\(file.itemCount ?? 0) items)")
                
            } catch {
                print("❌ Failed to download \(key): \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Force Refresh
    
    func forceRefresh() async {
        // Clear cache
        try? FileManager.default.removeItem(at: cacheDir)
        try? FileManager.default.createDirectory(at: cacheDir, withIntermediateDirectories: true)
        
        // Reset version
        dataVersion = "0.0.0"
        UserDefaults.standard.removeObject(forKey: versionKey)
        
        // Reload
        await loadAllData()
    }
    
    // MARK: - Cache Management
    
    private func loadFromCache(_ fileName: String) -> Data? {
        let cacheURL = cacheDir.appendingPathComponent("\(fileName).json")
        return try? Data(contentsOf: cacheURL)
    }
    
    private func loadFromBundle(_ fileName: String) -> Data? {
        guard let bundleURL = Bundle.main.url(forResource: fileName, withExtension: "json") else {
            return nil
        }
        return try? Data(contentsOf: bundleURL)
    }
    
    private func loadCachedVersion() {
        dataVersion = UserDefaults.standard.string(forKey: versionKey) ?? "1.0.0"
        lastSyncDate = UserDefaults.standard.object(forKey: lastSyncKey) as? Date
    }
    
    // MARK: - Statistics
    
    private func calculateStatistics() {
        statistics.totalRestaurants = restaurants.count
        statistics.indianRestaurants = restaurants.filter { 
            $0.cuisineType == .indian || $0.cuisineType == .northIndian || $0.cuisineType == .southIndian 
        }.count
        statistics.nepaliRestaurants = restaurants.filter { 
            $0.cuisineType == .nepali || $0.cuisineType == .himalayan 
        }.count
        statistics.totalReviews = restaurants.reduce(0) { $0 + $1.reviewCount }
        statistics.averageRating = restaurants.isEmpty ? 0 : restaurants.reduce(0) { $0 + $1.rating } / Double(restaurants.count)
        
        statistics.countryCounts = Dictionary(
            grouping: restaurants.compactMap { $0.country?.trimmingCharacters(in: .whitespacesAndNewlines) },
            by: { $0 }
        ).mapValues { $0.count }
        statistics.cityCounts = Dictionary(
            grouping: restaurants.compactMap { $0.city?.trimmingCharacters(in: .whitespacesAndNewlines) },
            by: { $0 }
        ).mapValues { $0.count }
    }
    
    // MARK: - Filtering & Sorting
    
    func filteredRestaurants(with filter: RestaurantFilter, searchQuery: String = "", userLocation: CLLocation? = nil) -> [Restaurant] {
        var result = restaurants
        
        if !searchQuery.isEmpty {
            let query = searchQuery.lowercased()
            result = result.filter {
                $0.name.lowercased().contains(query) ||
                $0.japaneseName?.lowercased().contains(query) == true ||
                $0.address.lowercased().contains(query) ||
                $0.city?.lowercased().contains(query) == true ||
                $0.country?.lowercased().contains(query) == true ||
                $0.specialties.contains { $0.lowercased().contains(query) } ||
                $0.cuisineType.rawValue.lowercased().contains(query)
            }
        }
        
        if !filter.cuisineTypes.isEmpty {
            result = result.filter { filter.cuisineTypes.contains($0.cuisineType) }
        }
        
        if !filter.priceRanges.isEmpty {
            result = result.filter { filter.priceRanges.contains($0.priceRange) }
        }
        
        if !filter.countries.isEmpty {
            result = result.filter { restaurant in
                guard let country = restaurant.country else { return false }
                return filter.countries.contains(country)
            }
        }
        
        if !filter.cities.isEmpty {
            result = result.filter { restaurant in
                guard let city = restaurant.city else { return false }
                return filter.cities.contains(city)
            }
        }
        
        if !filter.features.isEmpty {
            result = result.filter { restaurant in
                filter.features.allSatisfy { restaurant.features.contains($0) }
            }
        }
        
        if filter.isHalalOnly { result = result.filter { $0.isHalal } }
        if filter.isVegetarianOnly { result = result.filter { $0.isVegetarian } }
        if filter.hasVeganOptions { result = result.filter { $0.hasVeganOptions } }
        if filter.hasEnglishMenu { result = result.filter { $0.hasEnglishMenu } }
        if filter.minimumRating > 0 { result = result.filter { $0.rating >= filter.minimumRating } }
        
        return sortRestaurants(result, by: filter.sortBy, userLocation: userLocation)
    }
    
    private func sortRestaurants(_ restaurants: [Restaurant], by option: SortOption, userLocation: CLLocation?) -> [Restaurant] {
        switch option {
        case .rating:
            return restaurants.sorted { $0.rating > $1.rating }
        case .reviewCount:
            return restaurants.sorted { $0.reviewCount > $1.reviewCount }
        case .priceLowToHigh:
            return restaurants.sorted { $0.priceRange.averagePrice < $1.priceRange.averagePrice }
        case .priceHighToLow:
            return restaurants.sorted { $0.priceRange.averagePrice > $1.priceRange.averagePrice }
        case .nearest:
            guard let userLocation else {
                return restaurants.sorted { $0.walkingMinutes < $1.walkingMinutes }
            }
            return restaurants.sorted {
                ($0.distanceKm(from: userLocation) ?? Double.greatestFiniteMagnitude) <
                ($1.distanceKm(from: userLocation) ?? Double.greatestFiniteMagnitude)
            }
        case .newest:
            return restaurants.sorted { ($0.lastUpdated ?? "") > ($1.lastUpdated ?? "") }
        }
    }
    
    // MARK: - Query Methods
    
    func getRestaurant(by id: String) -> Restaurant? {
        restaurants.first { $0.id == id }
    }
    
    func getRestaurants(in region: JapanRegion) -> [Restaurant] {
        restaurants.filter { $0.region == region.rawValue }
    }
    
    func getRestaurants(cuisine: CuisineType) -> [Restaurant] {
        restaurants.filter { $0.cuisineType == cuisine }
    }
    
    func getSimilarRestaurants(to restaurant: Restaurant, limit: Int = 5) -> [Restaurant] {
        restaurants
            .filter { $0.id != restaurant.id }
            .filter { $0.cuisineType == restaurant.cuisineType || $0.region == restaurant.region }
            .sorted { $0.rating > $1.rating }
            .prefix(limit)
            .map { $0 }
    }
    
    func search(_ query: String) -> [Restaurant] {
        guard !query.isEmpty else { return restaurants }
        let lowercased = query.lowercased()
        return restaurants.filter {
            $0.name.lowercased().contains(lowercased) ||
            $0.japaneseName?.lowercased().contains(lowercased) == true ||
            $0.address.lowercased().contains(lowercased) ||
            $0.city?.lowercased().contains(lowercased) == true ||
            $0.country?.lowercased().contains(lowercased) == true ||
            $0.nearestStation.lowercased().contains(lowercased) ||
            $0.specialties.contains { $0.lowercased().contains(lowercased) }
        }
    }

    func availableCountries() -> [String] {
        let countries = restaurants.compactMap { $0.country?.trimmingCharacters(in: .whitespacesAndNewlines) }
        return Array(Set(countries)).sorted()
    }

    func availableCities(for country: String? = nil) -> [String] {
        let filtered = restaurants.filter { restaurant in
            guard let country else { return true }
            return restaurant.country == country
        }
        let cities = filtered.compactMap { $0.city?.trimmingCharacters(in: .whitespacesAndNewlines) }
        return Array(Set(cities)).sorted()
    }

    func nearbyNepaliIndianRestaurants(userLocation: CLLocation?, limit: Int = 8) -> [Restaurant] {
        let filtered = restaurants.filter { $0.cuisineType.isNepaliOrIndian }
        guard let userLocation else {
            return filtered.sorted { $0.reviewCount > $1.reviewCount }.prefix(limit).map { $0 }
        }
        return filtered.sorted {
            ($0.distanceKm(from: userLocation) ?? Double.greatestFiniteMagnitude) <
            ($1.distanceKm(from: userLocation) ?? Double.greatestFiniteMagnitude)
        }
        .prefix(limit)
        .map { $0 }
    }
    
    func refresh() async {
        await loadAllData()
    }
    
    // MARK: - Sample Data (Fallback)
    
    private func loadSampleData() {
        restaurants = [
            createSampleRestaurant(id: "rest-001", name: "Curry House Shinjuku", japaneseName: "カレーハウス新宿", cuisineType: .indian, priceRange: .moderate, region: "Tokyo", rating: 4.5, reviewCount: 328, latitude: 35.6900, longitude: 139.7000, city: "Tokyo", country: "Japan"),
            createSampleRestaurant(id: "rest-002", name: "Himalayan Kitchen", japaneseName: "ヒマラヤンキッチン", cuisineType: .nepali, priceRange: .moderate, region: "Tokyo", rating: 4.7, reviewCount: 256, latitude: 35.6895, longitude: 139.6917, city: "Tokyo", country: "Japan"),
            createSampleRestaurant(id: "rest-003", name: "Namaste Tokyo", japaneseName: "ナマステ東京", cuisineType: .indoNepali, priceRange: .budget, region: "Tokyo", rating: 4.3, reviewCount: 189, latitude: 35.6938, longitude: 139.7034, city: "Tokyo", country: "Japan"),
            createSampleRestaurant(id: "rest-004", name: "Spice Magic Osaka", japaneseName: "スパイスマジック大阪", cuisineType: .southIndian, priceRange: .moderate, region: "Osaka", rating: 4.6, reviewCount: 412, latitude: 34.6937, longitude: 135.5023, city: "Osaka", country: "Japan"),
            createSampleRestaurant(id: "rest-005", name: "Everest Dining", japaneseName: "エベレストダイニング", cuisineType: .himalayan, priceRange: .upscale, region: "Tokyo", rating: 4.8, reviewCount: 567, latitude: 35.6812, longitude: 139.7671, city: "Tokyo", country: "Japan"),
            createSampleRestaurant(id: "rest-006", name: "Taj Mahal Restaurant", japaneseName: "タージマハルレストラン", cuisineType: .northIndian, priceRange: .upscale, region: "Yokohama", rating: 4.4, reviewCount: 234, latitude: 35.4437, longitude: 139.6380, city: "Yokohama", country: "Japan")
        ]
        featuredRestaurants = restaurants.filter { $0.rating >= 4.5 }
    }
    
    private func createSampleRestaurant(id: String, name: String, japaneseName: String, cuisineType: CuisineType, priceRange: PriceRange, region: String?, rating: Double, reviewCount: Int, latitude: Double?, longitude: Double?, city: String?, country: String?) -> Restaurant {
        Restaurant(
            id: id, name: name, japaneseName: japaneseName, cuisineType: cuisineType, priceRange: priceRange, region: region,
            country: country, city: city, latitude: latitude, longitude: longitude,
            address: "〒160-0022 Tokyo, \(region ?? "Tokyo") 1-2-3", addressJapanese: nil,
            phone: "+81-3-1234-5678", website: "https://example.com", googleMapsUrl: "https://maps.google.com",
            rating: rating, reviewCount: reviewCount,
            description: "Authentic \(cuisineType.rawValue) cuisine in the heart of \(region ?? "the city").",
            descriptionJapanese: nil, images: [], coverImage: "https://images.unsplash.com/photo-1585937421612-70a008356fbe",
            operatingHours: nil, features: ["Dine-in", "Takeout", "Reservation", "Free WiFi"],
            specialties: ["Butter Chicken", "Biryani", "Naan"], menuHighlights: nil,
            priceRangeDetails: PriceRangeDetails(lunchMin: 800, lunchMax: 1500, dinnerMin: 1500, dinnerMax: 3000, averageLunch: 1000, averageDinner: 2000),
            isHalal: false, isVegetarian: false, hasVeganOptions: true, hasEnglishMenu: true,
            hasNepaliSpeakingStaff: cuisineType == .nepali || cuisineType == .himalayan, hasHindiSpeakingStaff: true,
            acceptsCreditCard: true, nearestStation: "\(region.rawValue) Station", walkingMinutes: Int.random(in: 2...10), lastUpdated: "2024-12-01"
        )
    }
}

// MARK: - Errors

enum DataError: Error {
    case invalidURL
    case networkError
    case decodingError
    case cacheError
}
