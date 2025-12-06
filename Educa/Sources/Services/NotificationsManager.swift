//
//  NotificationsManager.swift
//  Educa
//
//  Manages in-app notifications and notification state
//

import Foundation
import SwiftUI

@MainActor
final class NotificationsManager: ObservableObject {
    static let shared = NotificationsManager()
    
    // MARK: - Published Properties
    
    @Published var notifications: [AppNotification] = []
    @Published var unreadCount: Int = 0
    @Published var showBadge: Bool = true
    
    // MARK: - Init
    
    private init() {
        loadDefaultNotifications()
        updateUnreadCount()
    }
    
    // MARK: - Methods
    
    func markAsRead(_ id: String) {
        if let index = notifications.firstIndex(where: { $0.id == id }) {
            notifications[index].isRead = true
            updateUnreadCount()
            HapticManager.shared.light()
        }
    }
    
    func markAllAsRead() {
        for index in notifications.indices {
            notifications[index].isRead = true
        }
        updateUnreadCount()
        HapticManager.shared.success()
    }
    
    func deleteNotification(_ id: String) {
        notifications.removeAll { $0.id == id }
        updateUnreadCount()
        HapticManager.shared.light()
    }
    
    func clearAllNotifications() {
        notifications.removeAll()
        updateUnreadCount()
    }
    
    private func updateUnreadCount() {
        unreadCount = notifications.filter { !$0.isRead }.count
        showBadge = unreadCount > 0
    }
    
    // MARK: - Default Data
    
    private func loadDefaultNotifications() {
        notifications = [
            AppNotification(
                id: "notif-1",
                title: "Welcome to Educa!",
                message: "Start exploring universities and scholarships to begin your journey.",
                type: .welcome,
                timestamp: Date().addingTimeInterval(-3600),
                isRead: false
            ),
            AppNotification(
                id: "notif-2",
                title: "New Scholarships Available",
                message: "Check out 3 new fully-funded scholarship opportunities.",
                type: .scholarship,
                timestamp: Date().addingTimeInterval(-86400),
                isRead: false
            ),
            AppNotification(
                id: "notif-3",
                title: "Application Deadline Reminder",
                message: "University of Melbourne deadline is in 7 days.",
                type: .deadline,
                timestamp: Date().addingTimeInterval(-172800),
                isRead: true
            ),
            AppNotification(
                id: "notif-4",
                title: "New Job Opportunities",
                message: "5 new internship positions matching your profile.",
                type: .job,
                timestamp: Date().addingTimeInterval(-259200),
                isRead: true
            )
        ]
    }
}

// MARK: - Notification Model

struct AppNotification: Identifiable {
    let id: String
    let title: String
    let message: String
    let type: NotificationType
    let timestamp: Date
    var isRead: Bool
    
    enum NotificationType {
        case welcome
        case scholarship
        case deadline
        case job
        case update
        case system
        
        var icon: String {
            switch self {
            case .welcome: return "hand.wave.fill"
            case .scholarship: return "dollarsign.circle.fill"
            case .deadline: return "clock.badge.exclamationmark.fill"
            case .job: return "briefcase.fill"
            case .update: return "bell.badge.fill"
            case .system: return "gear"
            }
        }
        
        var color: Color {
            switch self {
            case .welcome: return .brand
            case .scholarship: return .green
            case .deadline: return .red
            case .job: return .orange
            case .update: return .blue
            case .system: return .gray
            }
        }
    }
    
    var formattedTime: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: timestamp, relativeTo: Date())
    }
}

