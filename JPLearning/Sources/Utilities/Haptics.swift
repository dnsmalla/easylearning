//
//  Haptics.swift
//  NPLearn
//
//  Haptic feedback utilities
//

import UIKit

enum Haptics {
    
    static func impact(style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
    
    static func notification(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(type)
    }
    
    static func selection() {
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }
    
    static func success() {
        notification(.success)
    }
    
    static func warning() {
        notification(.warning)
    }
    
    static func error() {
        notification(.error)
    }
    
    static func light() {
        impact(style: .light)
    }
    
    static func medium() {
        impact(style: .medium)
    }
    
    static func heavy() {
        impact(style: .heavy)
    }
}

