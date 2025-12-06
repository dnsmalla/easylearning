//
//  UserDataManager.swift
//  Educa
//
//  Manages user preferences, bookmarks, and saved items
//

import Foundation

@MainActor
final class UserDataManager: ObservableObject {
    static let shared = UserDataManager()
    
    // MARK: - Published Properties
    
    @Published var savedUniversities: Set<String> = []
    @Published var savedCourses: Set<String> = []
    @Published var savedJobs: Set<String> = []
    @Published var savedGuides: Set<String> = []
    @Published var recentSearches: [String] = []
    
    // MARK: - UserDefaults Keys
    
    private enum Keys {
        static let savedUniversities = "savedUniversities"
        static let savedCourses = "savedCourses"
        static let savedJobs = "savedJobs"
        static let savedGuides = "savedGuides"
        static let recentSearches = "recentSearches"
        static let isDarkMode = "isDarkMode"
        static let selectedCountry = "selectedCountry"
    }
    
    private let defaults = UserDefaults.standard
    
    private init() {
        loadSavedData()
    }
    
    // MARK: - Load Data
    
    private func loadSavedData() {
        savedUniversities = Set(defaults.stringArray(forKey: Keys.savedUniversities) ?? [])
        savedCourses = Set(defaults.stringArray(forKey: Keys.savedCourses) ?? [])
        savedJobs = Set(defaults.stringArray(forKey: Keys.savedJobs) ?? [])
        savedGuides = Set(defaults.stringArray(forKey: Keys.savedGuides) ?? [])
        recentSearches = defaults.stringArray(forKey: Keys.recentSearches) ?? []
    }
    
    // MARK: - Universities
    
    func toggleUniversitySaved(_ id: String) {
        if savedUniversities.contains(id) {
            savedUniversities.remove(id)
            HapticManager.shared.light()
        } else {
            savedUniversities.insert(id)
            HapticManager.shared.success()
        }
        saveUniversities()
    }
    
    func isUniversitySaved(_ id: String) -> Bool {
        savedUniversities.contains(id)
    }
    
    private func saveUniversities() {
        defaults.set(Array(savedUniversities), forKey: Keys.savedUniversities)
    }
    
    // MARK: - Courses
    
    func toggleCourseSaved(_ id: String) {
        if savedCourses.contains(id) {
            savedCourses.remove(id)
            HapticManager.shared.light()
        } else {
            savedCourses.insert(id)
            HapticManager.shared.success()
        }
        saveCourses()
    }
    
    func isCourseSaved(_ id: String) -> Bool {
        savedCourses.contains(id)
    }
    
    private func saveCourses() {
        defaults.set(Array(savedCourses), forKey: Keys.savedCourses)
    }
    
    // MARK: - Jobs
    
    func toggleJobSaved(_ id: String) {
        if savedJobs.contains(id) {
            savedJobs.remove(id)
            HapticManager.shared.light()
        } else {
            savedJobs.insert(id)
            HapticManager.shared.success()
        }
        saveJobs()
    }
    
    func isJobSaved(_ id: String) -> Bool {
        savedJobs.contains(id)
    }
    
    private func saveJobs() {
        defaults.set(Array(savedJobs), forKey: Keys.savedJobs)
    }
    
    // MARK: - Guides
    
    func toggleGuideSaved(_ id: String) {
        if savedGuides.contains(id) {
            savedGuides.remove(id)
            HapticManager.shared.light()
        } else {
            savedGuides.insert(id)
            HapticManager.shared.success()
        }
        saveGuides()
    }
    
    func isGuideSaved(_ id: String) -> Bool {
        savedGuides.contains(id)
    }
    
    private func saveGuides() {
        defaults.set(Array(savedGuides), forKey: Keys.savedGuides)
    }
    
    // MARK: - Recent Searches
    
    func addRecentSearch(_ query: String) {
        guard !query.isEmpty else { return }
        
        // Remove if already exists
        recentSearches.removeAll { $0 == query }
        
        // Add to front
        recentSearches.insert(query, at: 0)
        
        // Keep only last 10
        if recentSearches.count > 10 {
            recentSearches = Array(recentSearches.prefix(10))
        }
        
        defaults.set(recentSearches, forKey: Keys.recentSearches)
    }
    
    func clearRecentSearches() {
        recentSearches.removeAll()
        defaults.set(recentSearches, forKey: Keys.recentSearches)
    }
    
    // MARK: - Clear All
    
    func clearAllSavedData() {
        savedUniversities.removeAll()
        savedCourses.removeAll()
        savedJobs.removeAll()
        savedGuides.removeAll()
        recentSearches.removeAll()
        
        defaults.removeObject(forKey: Keys.savedUniversities)
        defaults.removeObject(forKey: Keys.savedCourses)
        defaults.removeObject(forKey: Keys.savedJobs)
        defaults.removeObject(forKey: Keys.savedGuides)
        defaults.removeObject(forKey: Keys.recentSearches)
    }
}

