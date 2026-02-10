//
//  SpiceBiteTests.swift
//  SpiceBiteTests
//
//  Unit tests for SpiceBite app
//

import XCTest
@testable import SpiceBite

final class SpiceBiteTests: XCTestCase {
    
    // MARK: - Model Tests
    
    func testCuisineTypeRawValues() {
        XCTAssertEqual(CuisineType.indian.rawValue, "Indian")
        XCTAssertEqual(CuisineType.nepali.rawValue, "Nepali")
        XCTAssertEqual(CuisineType.northIndian.rawValue, "North Indian")
        XCTAssertEqual(CuisineType.southIndian.rawValue, "South Indian")
        XCTAssertEqual(CuisineType.himalayan.rawValue, "Himalayan")
        XCTAssertEqual(CuisineType.indoNepali.rawValue, "Indo-Nepali")
    }
    
    func testPriceRangeValues() {
        XCTAssertEqual(PriceRange.budget.rawValue, "¥")
        XCTAssertEqual(PriceRange.moderate.rawValue, "¥¥")
        XCTAssertEqual(PriceRange.upscale.rawValue, "¥¥¥")
        XCTAssertEqual(PriceRange.premium.rawValue, "¥¥¥¥")
    }
    
    func testPriceRangeAverages() {
        XCTAssertEqual(PriceRange.budget.averagePrice, 800)
        XCTAssertEqual(PriceRange.moderate.averagePrice, 1500)
        XCTAssertEqual(PriceRange.upscale.averagePrice, 3000)
        XCTAssertEqual(PriceRange.premium.averagePrice, 5000)
    }
    
    func testJapanRegionJapaneseNames() {
        XCTAssertEqual(JapanRegion.tokyo.japaneseName, "東京")
        XCTAssertEqual(JapanRegion.osaka.japaneseName, "大阪")
        XCTAssertEqual(JapanRegion.kyoto.japaneseName, "京都")
    }
    
    // MARK: - Filter Tests
    
    func testRestaurantFilterReset() {
        var filter = RestaurantFilter()
        filter.cuisineTypes = [.indian, .nepali]
        filter.isHalalOnly = true
        filter.minimumRating = 4.0
        
        XCTAssertTrue(filter.isActive)
        
        filter.reset()
        
        XCTAssertFalse(filter.isActive)
        XCTAssertTrue(filter.cuisineTypes.isEmpty)
        XCTAssertFalse(filter.isHalalOnly)
        XCTAssertEqual(filter.minimumRating, 0.0)
    }
    
    func testFilterIsActive() {
        var filter = RestaurantFilter()
        XCTAssertFalse(filter.isActive)
        
        filter.isHalalOnly = true
        XCTAssertTrue(filter.isActive)
        
        filter.isHalalOnly = false
        XCTAssertFalse(filter.isActive)
        
        filter.regions.insert(.tokyo)
        XCTAssertTrue(filter.isActive)
    }
    
    // MARK: - JSON Decoding Tests
    
    func testRestaurantDecoding() throws {
        let json = """
        {
            "id": "test-001",
            "name": "Test Restaurant",
            "japanese_name": "テストレストラン",
            "cuisineType": "Indian",
            "priceRange": "¥¥",
            "region": "Tokyo",
            "address": "Test Address",
            "phone": "+81-3-1234-5678",
            "website": "https://example.com",
            "google_maps_url": "https://maps.google.com",
            "rating": 4.5,
            "review_count": 100,
            "description": "Test description",
            "images": [],
            "cover_image": "https://example.com/image.jpg",
            "operating_hours": {
                "monday": {"open": "11:00", "close": "22:00", "is_closed": false},
                "tuesday": {"open": "11:00", "close": "22:00", "is_closed": false},
                "wednesday": {"open": "11:00", "close": "22:00", "is_closed": false},
                "thursday": {"open": "11:00", "close": "22:00", "is_closed": false},
                "friday": {"open": "11:00", "close": "23:00", "is_closed": false},
                "saturday": {"open": "11:00", "close": "23:00", "is_closed": false},
                "sunday": {"open": "11:00", "close": "21:00", "is_closed": false}
            },
            "features": ["Dine-in", "Takeout"],
            "specialties": ["Butter Chicken", "Naan"],
            "menu_highlights": [],
            "price_range_details": {
                "lunch_min": 800,
                "lunch_max": 1500,
                "dinner_min": 1500,
                "dinner_max": 3000,
                "average_lunch": 1000,
                "average_dinner": 2000
            },
            "is_halal": false,
            "is_vegetarian": false,
            "has_vegan_options": true,
            "has_english_menu": true,
            "has_nepali_speaking_staff": false,
            "has_hindi_speaking_staff": true,
            "accepts_credit_card": true,
            "nearest_station": "Tokyo Station",
            "walking_minutes": 5,
            "last_updated": "2024-12-01"
        }
        """.data(using: .utf8)!
        
        let restaurant = try JSONDecoder().decode(Restaurant.self, from: json)
        
        XCTAssertEqual(restaurant.id, "test-001")
        XCTAssertEqual(restaurant.name, "Test Restaurant")
        XCTAssertEqual(restaurant.cuisineType, .indian)
        XCTAssertEqual(restaurant.priceRange, .moderate)
        XCTAssertEqual(restaurant.region, .tokyo)
        XCTAssertEqual(restaurant.rating, 4.5)
    }
    
    // MARK: - Sort Option Tests
    
    func testSortOptionIcons() {
        XCTAssertEqual(SortOption.rating.icon, "star.fill")
        XCTAssertEqual(SortOption.nearest.icon, "location.fill")
        XCTAssertEqual(SortOption.priceLowToHigh.icon, "arrow.up.circle")
    }
}

