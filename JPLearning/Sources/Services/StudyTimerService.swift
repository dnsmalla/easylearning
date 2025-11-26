//
//  StudyTimerService.swift
//  JLearn
//
//  Study session timer and statistics
//

import Foundation
import Combine
import SwiftUI

class StudyTimerService: ObservableObject {
    static let shared = StudyTimerService()
    
    @Published var isActive: Bool = false
    @Published var elapsedTime: TimeInterval = 0
    @Published var currentSessionTime: TimeInterval = 0
    
    private var timer: Timer?
    private var startTime: Date?
    private var sessionStartTime: Date?
    
    private let todayStudyKey = "today_study_time"
    private let lastStudyDateKey = "last_study_date_timer"
    
    private init() {
        resetIfNewDay()
    }
    
    // MARK: - Timer Control
    
    func startSession() {
        guard !isActive else { return }
        
        isActive = true
        sessionStartTime = Date()
        startTime = Date()
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            if let start = self.startTime {
                self.currentSessionTime = Date().timeIntervalSince(start)
                self.elapsedTime += 1
            }
        }
        
        // Update achievement service
        AchievementService.shared.updateStreak()
    }
    
    func pauseSession() {
        guard isActive else { return }
        
        isActive = false
        timer?.invalidate()
        timer = nil
        
        saveSessionTime()
    }
    
    func endSession() {
        guard isActive || currentSessionTime > 0 else { return }
        
        pauseSession()
        
        // Save to achievement service
        let minutes = Int(currentSessionTime / 60)
        if minutes > 0 {
            AchievementService.shared.addStudyTime(minutes: minutes)
        }
        
        // Reset session
        currentSessionTime = 0
        sessionStartTime = nil
    }
    
    // MARK: - Stats
    
    func getTodayStudyTime() -> TimeInterval {
        resetIfNewDay()
        return UserDefaults.standard.double(forKey: todayStudyKey)
    }
    
    func getTotalStudyTime() -> TimeInterval {
        return TimeInterval(AchievementService.shared.totalStudyMinutes * 60)
    }
    
    func getFormattedTime(_ time: TimeInterval) -> String {
        let hours = Int(time) / 3600
        let minutes = (Int(time) % 3600) / 60
        let seconds = Int(time) % 60
        
        if hours > 0 {
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
    
    // MARK: - Persistence
    
    private func saveSessionTime() {
        resetIfNewDay()
        
        let currentTotal = UserDefaults.standard.double(forKey: todayStudyKey)
        UserDefaults.standard.set(currentTotal + currentSessionTime, forKey: todayStudyKey)
        UserDefaults.standard.set(Date(), forKey: lastStudyDateKey)
    }
    
    private func resetIfNewDay() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        if let lastDate = UserDefaults.standard.object(forKey: lastStudyDateKey) as? Date {
            let lastDay = calendar.startOfDay(for: lastDate)
            
            if lastDay < today {
                // New day - reset today's counter
                UserDefaults.standard.set(0, forKey: todayStudyKey)
            }
        }
    }
    
    // MARK: - Background Handling
    
    func handleBackground() {
        if isActive {
            pauseSession()
        }
    }
    
    func handleForeground() {
        // Auto-resume could be added here if desired
    }
}
