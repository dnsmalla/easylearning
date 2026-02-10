//
//  AppState.swift
//  SpiceBite
//
//  Global app state management
//

import SwiftUI

// MARK: - App Tab

enum AppTab: String, CaseIterable, Identifiable {
    case home = "Home"
    case explore = "Explore"
    case compare = "Compare"
    case saved = "Saved"
    case profile = "Profile"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .home: return "house.fill"
        case .explore: return "magnifyingglass"
        case .compare: return "arrow.left.arrow.right"
        case .saved: return "heart.fill"
        case .profile: return "person.fill"
        }
    }
    
    var title: String { rawValue }
}

// MARK: - App State

@MainActor
final class AppState: ObservableObject {
    // MARK: - Navigation
    @Published var selectedTab: AppTab = .home
    
    // MARK: - Theme
    @AppStorage("isDarkMode") var isDarkMode = false
    @AppStorage("useSystemTheme") var useSystemTheme = true
    
    // MARK: - User Preferences
    @AppStorage("preferredCountry") var preferredCountry: String = ""
    @AppStorage("preferredCity") var preferredCity: String = ""
    @AppStorage("showPriceInNPR") var showPriceInNPR = false
    @AppStorage("showPriceInINR") var showPriceInINR = false
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding = false
    @AppStorage("preferredLanguage") var preferredLanguage: String = "en"
    
    var hasPreferredLocation: Bool {
        !preferredCountry.isEmpty || !preferredCity.isEmpty
    }
    
    // MARK: - Search & Filter
    @Published var searchQuery: String = ""
    @Published var activeFilter = RestaurantFilter()
    @Published var isFilterSheetPresented = false
    
    // MARK: - Comparison
    @Published var compareList: [Restaurant] = []
    @Published var maxCompareItems = 6
    
    // MARK: - Saved Items
    @Published var savedRestaurantIds: Set<String> = []
    
    // MARK: - Loading States
    @Published var isLoading = false
    @Published var toastMessage: String?
    @Published var showToast = false
    
    // MARK: - Exchange Rates (for price conversion)
    var jpyToNprRate: Double = 1.0  // Will be updated from API
    var jpyToInrRate: Double = 0.65 // Will be updated from API
    
    // MARK: - Methods
    
    func toggleSaved(for restaurant: Restaurant) {
        if savedRestaurantIds.contains(restaurant.id) {
            savedRestaurantIds.remove(restaurant.id)
            showToastMessage("Removed from favorites")
        } else {
            savedRestaurantIds.insert(restaurant.id)
            showToastMessage("Added to favorites")
        }
        saveSavedItems()
    }
    
    func isSaved(_ restaurant: Restaurant) -> Bool {
        savedRestaurantIds.contains(restaurant.id)
    }
    
    func clearAllSaved() {
        savedRestaurantIds.removeAll()
        saveSavedItems()
        showToastMessage("All saved restaurants cleared")
    }
    
    func addToCompare(_ restaurant: Restaurant) {
        guard compareList.count < maxCompareItems else {
            showToastMessage("Maximum \(maxCompareItems) items for comparison")
            return
        }
        
        guard !compareList.contains(where: { $0.id == restaurant.id }) else {
            showToastMessage("Already added to comparison")
            return
        }
        
        compareList.append(restaurant)
        showToastMessage("Added to comparison")
    }
    
    func removeFromCompare(_ restaurant: Restaurant) {
        compareList.removeAll { $0.id == restaurant.id }
    }
    
    func clearCompare() {
        compareList.removeAll()
    }
    
    func isInCompare(_ restaurant: Restaurant) -> Bool {
        compareList.contains { $0.id == restaurant.id }
    }
    
    // MARK: - Price Conversion
    
    func convertPrice(_ jpyPrice: Int) -> String {
        if showPriceInNPR {
            let nprPrice = Double(jpyPrice) * jpyToNprRate
            return "रू \(Int(nprPrice))"
        } else if showPriceInINR {
            let inrPrice = Double(jpyPrice) * jpyToInrRate
            return "₹\(Int(inrPrice))"
        } else {
            return "¥\(jpyPrice)"
        }
    }
    
    // MARK: - Toast
    
    func showToastMessage(_ message: String) {
        toastMessage = message
        showToast = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            self?.showToast = false
        }
    }
    
    // MARK: - Persistence
    
    private let savedItemsKey = "savedRestaurantIds"
    
    func loadSavedItems() {
        if let data = UserDefaults.standard.data(forKey: savedItemsKey),
           let ids = try? JSONDecoder().decode(Set<String>.self, from: data) {
            savedRestaurantIds = ids
        }
    }
    
    private func saveSavedItems() {
        if let data = try? JSONEncoder().encode(savedRestaurantIds) {
            UserDefaults.standard.set(data, forKey: savedItemsKey)
        }
    }
    
    init() {
        loadSavedItems()
    }
}
