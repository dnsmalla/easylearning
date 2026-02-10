//
//  HapticManager.swift
//  SpiceBite
//
//  Haptic feedback manager for tactile interactions
//

import UIKit

@MainActor
final class HapticManager {
    static let shared = HapticManager()
    
    private let lightGenerator = UIImpactFeedbackGenerator(style: .light)
    private let mediumGenerator = UIImpactFeedbackGenerator(style: .medium)
    private let heavyGenerator = UIImpactFeedbackGenerator(style: .heavy)
    private let notificationGenerator = UINotificationFeedbackGenerator()
    private let selectionGenerator = UISelectionFeedbackGenerator()
    
    private init() {
        // Prepare generators
        lightGenerator.prepare()
        mediumGenerator.prepare()
        heavyGenerator.prepare()
        notificationGenerator.prepare()
        selectionGenerator.prepare()
    }
    
    // MARK: - Impact Feedback
    
    func light() {
        lightGenerator.impactOccurred()
    }
    
    func medium() {
        mediumGenerator.impactOccurred()
    }
    
    func heavy() {
        heavyGenerator.impactOccurred()
    }
    
    // MARK: - Notification Feedback
    
    func success() {
        notificationGenerator.notificationOccurred(.success)
    }
    
    func warning() {
        notificationGenerator.notificationOccurred(.warning)
    }
    
    func error() {
        notificationGenerator.notificationOccurred(.error)
    }
    
    // MARK: - Selection Feedback
    
    func selection() {
        selectionGenerator.selectionChanged()
    }
    
    // MARK: - Convenience
    
    func tap() {
        light()
    }
    
    func toggle() {
        medium()
    }
    
    func button() {
        medium()
    }
}

