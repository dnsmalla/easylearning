//
//  DataManagementService.swift
//  JLearn
//
//  Export, import, and manage user data
//

import Foundation
import Combine
import SwiftUI

@MainActor
class DataManagementService: ObservableObject {
    static let shared = DataManagementService()
    
    @Published var isExporting: Bool = false
    @Published var isImporting: Bool = false
    @Published var lastExportDate: Date?
    @Published var exportMessage: String = ""
    
    private let fileManager = FileManager.default
    private let exportFileName = "jlearn_backup.json"
    
    private init() {
        loadLastExportDate()
    }
    
    // MARK: - Export
    
    func exportUserData() -> URL? {
        isExporting = true
        defer { isExporting = false }
        
        let exportData = ExportData(
            version: "1.0",
            exportDate: Date(),
            userData: collectUserData()
        )
        
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            encoder.outputFormatting = .prettyPrinted
            
            let jsonData = try encoder.encode(exportData)
            
            // Save to temporary directory
            let tempDirectory = fileManager.temporaryDirectory
            let fileURL = tempDirectory.appendingPathComponent(exportFileName)
            
            try jsonData.write(to: fileURL)
            
            lastExportDate = Date()
            saveLastExportDate()
            exportMessage = "Export successful!"
            
            return fileURL
        } catch {
            exportMessage = "Export failed: \(error.localizedDescription)"
            AppLogger.error("Failed to export data: \(error)")
            return nil
        }
    }
    
    // MARK: - Import
    
    func importUserData(from url: URL) -> Bool {
        isImporting = true
        defer { isImporting = false }
        
        do {
            let jsonData = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            
            let importData = try decoder.decode(ExportData.self, from: jsonData)
            
            // Validate version compatibility
            guard importData.version == "1.0" else {
                exportMessage = "Incompatible backup version"
                return false
            }
            
            // Restore user data
            restoreUserData(importData.userData)
            
            exportMessage = "Import successful!"
            return true
        } catch {
            exportMessage = "Import failed: \(error.localizedDescription)"
            AppLogger.error("Failed to import data: \(error)")
            return false
        }
    }
    
    // MARK: - Cache Management
    
    func getCacheSize() -> String {
        guard let cacheURL = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first else {
            return "0 MB"
        }
        
        do {
            let contents = try fileManager.contentsOfDirectory(at: cacheURL, includingPropertiesForKeys: [.fileSizeKey])
            let totalSize = contents.reduce(0) { size, url in
                let fileSize = (try? url.resourceValues(forKeys: [.fileSizeKey]))?.fileSize ?? 0
                return size + fileSize
            }
            
            let sizeInMB = Double(totalSize) / 1_000_000
            return String(format: "%.2f MB", sizeInMB)
        } catch {
            return "Unknown"
        }
    }
    
    func clearCache() {
        guard let cacheURL = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first else {
            return
        }
        
        do {
            let contents = try fileManager.contentsOfDirectory(at: cacheURL, includingPropertiesForKeys: nil)
            for fileURL in contents {
                try fileManager.removeItem(at: fileURL)
            }
            exportMessage = "Cache cleared successfully"
        } catch {
            exportMessage = "Failed to clear cache: \(error.localizedDescription)"
            AppLogger.error("Failed to clear cache: \(error)")
        }
    }
    
    // MARK: - Data Collection
    
    private func collectUserData() -> UserBackupData {
        return UserBackupData(
            savedFlashcards: UserDefaults.standard.array(forKey: "saved_flashcards") as? [String] ?? [],
            completedLessons: UserDefaults.standard.array(forKey: "completed_lessons") as? [String] ?? [],
            currentStreak: AchievementService.shared.currentStreak,
            longestStreak: AchievementService.shared.longestStreak,
            totalStudyMinutes: AchievementService.shared.totalStudyMinutes,
            unlockedAchievements: Array(AchievementService.shared.unlockedAchievements),
            lastStudyDate: AchievementService.shared.lastStudyDate,
            userPreferences: [
                "theme": UserDefaults.standard.string(forKey: "app_theme") ?? "system",
                "notifications": UserDefaults.standard.bool(forKey: "notifications_enabled")
            ]
        )
    }
    
    private func restoreUserData(_ data: UserBackupData) {
        // Restore saved items
        UserDefaults.standard.set(data.savedFlashcards, forKey: "saved_flashcards")
        UserDefaults.standard.set(data.completedLessons, forKey: "completed_lessons")
        
        // Restore achievements
        AchievementService.shared.currentStreak = data.currentStreak
        AchievementService.shared.longestStreak = data.longestStreak
        AchievementService.shared.totalStudyMinutes = data.totalStudyMinutes
        AchievementService.shared.unlockedAchievements = Set(data.unlockedAchievements)
        AchievementService.shared.lastStudyDate = data.lastStudyDate
        
        // Restore preferences
        if let theme = data.userPreferences["theme"] as? String {
            UserDefaults.standard.set(theme, forKey: "app_theme")
        }
        if let notifications = data.userPreferences["notifications"] as? Bool {
            UserDefaults.standard.set(notifications, forKey: "notifications_enabled")
        }
    }
    
    // MARK: - Persistence
    
    private func loadLastExportDate() {
        if let date = UserDefaults.standard.object(forKey: "last_export_date") as? Date {
            lastExportDate = date
        }
    }
    
    private func saveLastExportDate() {
        UserDefaults.standard.set(lastExportDate, forKey: "last_export_date")
    }
}

// MARK: - Export Data Models

struct ExportData: Codable {
    let version: String
    let exportDate: Date
    let userData: UserBackupData
}

struct UserBackupData: Codable {
    let savedFlashcards: [String]
    let completedLessons: [String]
    let currentStreak: Int
    let longestStreak: Int
    let totalStudyMinutes: Int
    let unlockedAchievements: [String]
    let lastStudyDate: Date?
    let userPreferences: [String: Any]
    
    enum CodingKeys: String, CodingKey {
        case savedFlashcards, completedLessons, currentStreak, longestStreak
        case totalStudyMinutes, unlockedAchievements, lastStudyDate, userPreferences
    }
    
    init(savedFlashcards: [String], completedLessons: [String], currentStreak: Int, longestStreak: Int,
         totalStudyMinutes: Int, unlockedAchievements: [String], lastStudyDate: Date?, userPreferences: [String: Any]) {
        self.savedFlashcards = savedFlashcards
        self.completedLessons = completedLessons
        self.currentStreak = currentStreak
        self.longestStreak = longestStreak
        self.totalStudyMinutes = totalStudyMinutes
        self.unlockedAchievements = unlockedAchievements
        self.lastStudyDate = lastStudyDate
        self.userPreferences = userPreferences
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        savedFlashcards = try container.decode([String].self, forKey: .savedFlashcards)
        completedLessons = try container.decode([String].self, forKey: .completedLessons)
        currentStreak = try container.decode(Int.self, forKey: .currentStreak)
        longestStreak = try container.decode(Int.self, forKey: .longestStreak)
        totalStudyMinutes = try container.decode(Int.self, forKey: .totalStudyMinutes)
        unlockedAchievements = try container.decode([String].self, forKey: .unlockedAchievements)
        lastStudyDate = try container.decodeIfPresent(Date.self, forKey: .lastStudyDate)
        
        // Decode userPreferences as a simple dictionary
        if let prefsData = try? container.decode([String: String].self, forKey: .userPreferences) {
            userPreferences = prefsData
        } else {
            userPreferences = [:]
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(savedFlashcards, forKey: .savedFlashcards)
        try container.encode(completedLessons, forKey: .completedLessons)
        try container.encode(currentStreak, forKey: .currentStreak)
        try container.encode(longestStreak, forKey: .longestStreak)
        try container.encode(totalStudyMinutes, forKey: .totalStudyMinutes)
        try container.encode(unlockedAchievements, forKey: .unlockedAchievements)
        try container.encodeIfPresent(lastStudyDate, forKey: .lastStudyDate)
        
        // Encode only string values from userPreferences
        let stringPrefs = userPreferences.compactMapValues { $0 as? String }
        try container.encode(stringPrefs, forKey: .userPreferences)
    }
}
