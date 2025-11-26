//
//  AppTheme.swift
//  NPLearn
//
//  Application-wide design system and theme definitions for Nepali learning
//

import SwiftUI

// MARK: - App Theme

enum AppTheme {
  
  // MARK: - Brand Colors (Professional Nepal Theme)
  
  static let brandPrimary = Color(red: 0.00, green: 0.48, blue: 1.00) // Modern Blue
  static let brandSecondary = Color(red: 0.20, green: 0.60, blue: 0.86) // Sky Blue
  static let brandAccent = Color(red: 0.35, green: 0.34, blue: 0.84) // Indigo
  static let brandPurple = Color(red: 0.61, green: 0.35, blue: 0.71) // Elegant Purple
  static let brandGold = Color(red: 0.85, green: 0.65, blue: 0.13) // Traditional Gold
  
  static let background = Color(uiColor: .systemBackground)
  static let secondaryBackground = Color(uiColor: .secondarySystemBackground)
  static let tertiaryBackground = Color(uiColor: .tertiarySystemBackground)
  static let groupedBackground = Color(uiColor: .systemGroupedBackground)
  static let separator = Color.black.opacity(0.06)
  static let mutedText = Color.secondary
  
  // Category Colors (Professional Palette)
  static let vocabularyColor = Color(red: 0.20, green: 0.78, blue: 0.35) // Emerald Green
  static let grammarColor = Color(red: 0.95, green: 0.52, blue: 0.13) // Sunset Orange
  static let listeningColor = Color(red: 0.55, green: 0.27, blue: 0.75) // Royal Purple
  static let speakingColor = Color(red: 0.86, green: 0.08, blue: 0.24) // Crimson Red
  static let writingColor = Color(red: 0.00, green: 0.69, blue: 0.88) // Ocean Teal
  static let readingColor = Color(red: 0.00, green: 0.48, blue: 0.78) // Deep Sky Blue
  
  // Status Colors
  static let success = Color(red: 0.20, green: 0.78, blue: 0.35)
  static let warning = Color(red: 0.95, green: 0.52, blue: 0.13)
  static let danger = Color(red: 0.92, green: 0.26, blue: 0.21)
  static let info = Color(red: 0.00, green: 0.48, blue: 0.78)
  
  // Gradients (Professional)
  static var heroGradient: LinearGradient {
    LinearGradient(
      colors: [
        brandPrimary,
        Color(red: 0.20, green: 0.60, blue: 0.86) // Sky Blue
      ],
      startPoint: .topLeading,
      endPoint: .bottomTrailing
    )
  }
  
  static var cardGradient: LinearGradient {
    LinearGradient(
      colors: [Color.white, Color(white: 0.98)],
      startPoint: .top,
      endPoint: .bottom
    )
  }
  
  static var successGradient: LinearGradient {
    LinearGradient(
      colors: [success, success.opacity(0.7)],
      startPoint: .leading,
      endPoint: .trailing
    )
  }
  
  static var goldGradient: LinearGradient {
    LinearGradient(
      colors: [
        Color(red: 1.00, green: 0.84, blue: 0.00),
        Color(red: 0.85, green: 0.65, blue: 0.13)
      ],
      startPoint: .topLeading,
      endPoint: .bottomTrailing
    )
  }
  
  static var surface: some ShapeStyle { secondaryBackground }
  static var surfaceElevated: some ShapeStyle { tertiaryBackground }
  static var border: Color { separator }
  
  // MARK: - Typography (Apple Readable Guidelines)
  
  enum Typography {
    static let largeTitle = Font.system(.largeTitle, design: .rounded).weight(.bold)
    static let title = Font.system(.title, design: .rounded).weight(.bold)
    static let title2 = Font.system(.title2, design: .rounded).weight(.semibold)
    static let title3 = Font.system(.title3, design: .rounded).weight(.semibold)
    static let headline = Font.system(.headline, design: .rounded).weight(.semibold)
    static let subheadline = Font.system(.subheadline, design: .rounded)
    static let body = Font.system(.body, design: .rounded)
    static let bodyBold = Font.system(.body, design: .rounded).weight(.semibold)
    static let callout = Font.system(.callout, design: .rounded)
    static let footnote = Font.system(.footnote, design: .rounded)
    // Changed: Increased minimum font sizes for Apple readability guidelines
    static let caption = Font.system(.footnote, design: .rounded) // Was .caption (12pt), now .footnote (13pt)
    static let caption2 = Font.system(.footnote, design: .rounded).weight(.medium) // Was .caption2 (11pt), now .footnote (13pt)
    static let button = Font.system(.headline, design: .rounded).weight(.semibold)
    
    // Nepali-specific fonts (optimized for Devanagari legibility)
    static let nepaliDisplay = Font.system(.largeTitle, design: .default).weight(.semibold)
    static let nepaliTitle = Font.system(.title, design: .default).weight(.medium)
    static let nepaliBody = Font.system(.title3, design: .default).weight(.medium)
    // Changed: Increased romanization from caption2 (11pt) to callout (16pt) for better readability
    static let romanization = Font.system(.callout, design: .default).weight(.medium)
  }
  
  // MARK: - Layout
  
  enum Layout {
    static let horizontalPadding: CGFloat = 24
    static let verticalPadding: CGFloat = 16
    static let maxContentWidth: CGFloat = 720
    static let cornerRadius: CGFloat = 16
    static let smallCornerRadius: CGFloat = 8
    static let largeCornerRadius: CGFloat = 20
    static let spacing: CGFloat = 16
    static let smallSpacing: CGFloat = 8
    static let mediumSpacing: CGFloat = 12
    static let largeSpacing: CGFloat = 24
    static let cardPadding: CGFloat = 16
  }
  
  // MARK: - Controls
  
  enum Controls {
    static let buttonHeight: CGFloat = 48
    static let compactButtonHeight: CGFloat = 44
    static let smallButtonHeight: CGFloat = 36
    static let avatarSize: CGFloat = 40
    static let smallAvatarSize: CGFloat = 32
    static let largeAvatarSize: CGFloat = 60
    static let iconSize: CGFloat = 24
    static let smallIconSize: CGFloat = 20
    static let largeIconSize: CGFloat = 32
  }
  
  // MARK: - Shadows
  
  enum Shadows {
    static let cardOpacity: Double = 0.10
    static let cardRadius: CGFloat = 8
    static let cardYOffset: CGFloat = 4
    static let elevation1: (color: Color, radius: CGFloat, y: CGFloat) = (.black.opacity(0.05), 2, 1)
    static let elevation2: (color: Color, radius: CGFloat, y: CGFloat) = (.black.opacity(0.08), 4, 2)
    static let elevation3: (color: Color, radius: CGFloat, y: CGFloat) = (.black.opacity(0.12), 8, 4)
  }
  
  // MARK: - Animations
  
  enum Animations {
    static let standard: Animation = .easeInOut(duration: 0.3)
    static let quick: Animation = .easeInOut(duration: 0.2)
    static let spring: Animation = .spring(response: 0.3, dampingFraction: 0.7)
    static let bouncy: Animation = .spring(response: 0.4, dampingFraction: 0.6)
  }
}

// MARK: - Color Extensions

extension Color {
  static func forCategory(_ category: String) -> Color {
    switch category.lowercased() {
    case "vocabulary":
      return AppTheme.vocabularyColor
    case "grammar":
      return AppTheme.grammarColor
    case "listening":
      return AppTheme.listeningColor
    case "speaking":
      return AppTheme.speakingColor
    case "writing":
      return AppTheme.writingColor
    case "reading":
      return AppTheme.readingColor
    default:
      return AppTheme.brandPrimary
    }
  }
}

// MARK: - View Extensions for Theme

extension View {
  func cardStyle() -> some View {
    self
      .padding(AppTheme.Layout.cardPadding)
      .background(AppTheme.background)
      .clipShape(RoundedRectangle(cornerRadius: AppTheme.Layout.cornerRadius))
      .shadow(
        color: AppTheme.Shadows.elevation2.color,
        radius: AppTheme.Shadows.elevation2.radius,
        y: AppTheme.Shadows.elevation2.y
      )
  }
  
  func elevatedCardStyle() -> some View {
    self
      .padding(AppTheme.Layout.cardPadding)
      .background(AppTheme.background)
      .clipShape(RoundedRectangle(cornerRadius: AppTheme.Layout.cornerRadius))
      .shadow(
        color: AppTheme.Shadows.elevation3.color,
        radius: AppTheme.Shadows.elevation3.radius,
        y: AppTheme.Shadows.elevation3.y
      )
  }
  
  func chipStyle(backgroundColor: Color = AppTheme.secondaryBackground) -> some View {
    self
      .padding(.horizontal, 12)
      .padding(.vertical, 6)
      .background(backgroundColor)
      .clipShape(Capsule())
  }
  
  func studyCardStyle(color: Color) -> some View {
    self
      .padding(AppTheme.Layout.cardPadding)
      .background(color.opacity(0.1))
      .clipShape(RoundedRectangle(cornerRadius: AppTheme.Layout.cornerRadius))
      .overlay(
        RoundedRectangle(cornerRadius: AppTheme.Layout.cornerRadius)
          .stroke(color.opacity(0.2), lineWidth: 1)
      )
  }
}

