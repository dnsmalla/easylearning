//
//  AppTheme.swift
//  JLearn
//
//  Application-wide design system and theme definitions
//

import SwiftUI

// MARK: - App Theme

enum AppTheme {
  
  // MARK: - Brand Colors
  
  static let brandPrimary = Color(red: 0.29, green: 0.56, blue: 0.89) // Blue
  static let brandSecondary = Color(red: 0.40, green: 0.80, blue: 0.40) // Green
  static let brandAccent = Color(red: 1.00, green: 0.64, blue: 0.00) // Orange
  static let brandPurple = Color(red: 0.61, green: 0.35, blue: 0.71) // Purple
  
  static let background = Color(uiColor: .systemBackground)
  static let secondaryBackground = Color(uiColor: .secondarySystemBackground)
  static let tertiaryBackground = Color(uiColor: .tertiarySystemBackground)
  static let groupedBackground = Color(uiColor: .systemGroupedBackground)
  static let separator = Color.black.opacity(0.06)
  static let mutedText = Color.secondary
  
  // Category Colors
  static let kanjiColor = Color(red: 0.29, green: 0.56, blue: 0.89) // Blue
  static let vocabularyColor = Color(red: 0.40, green: 0.80, blue: 0.40) // Green
  static let grammarColor = Color(red: 1.00, green: 0.64, blue: 0.00) // Orange
  static let listeningColor = Color(red: 0.61, green: 0.35, blue: 0.71) // Purple
  static let speakingColor = Color(red: 0.90, green: 0.30, blue: 0.30) // Red
  static let writingColor = Color(red: 0.20, green: 0.70, blue: 0.70) // Teal
  
  // Status Colors
  static let success = Color.green
  static let warning = Color.orange
  static let danger = Color.red
  static let info = Color.blue
  
  // Gradients
  static var heroGradient: LinearGradient {
    LinearGradient(
      colors: [brandPrimary.opacity(0.85), brandSecondary.opacity(0.85)],
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
  
  static var surface: some ShapeStyle { secondaryBackground }
  static var surfaceElevated: some ShapeStyle { tertiaryBackground }
  static var border: Color { separator }
  
  // MARK: - Typography
  
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
    static let caption = Font.system(.caption, design: .rounded)
    static let caption2 = Font.system(.caption2, design: .rounded)
    static let button = Font.system(.headline, design: .rounded)
    
    // Japanese-specific fonts
    static let japaneseDisplay = Font.system(.largeTitle, design: .default)
    static let japaneseTitle = Font.system(.title, design: .default)
    static let japaneseBody = Font.system(.title3, design: .default)
    static let furigana = Font.system(.caption2, design: .default)
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
  init?(hex: String) {
    var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
    hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
    
    var rgb: UInt64 = 0
    
    guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }
    
    let red = Double((rgb & 0xFF0000) >> 16) / 255.0
    let green = Double((rgb & 0x00FF00) >> 8) / 255.0
    let blue = Double(rgb & 0x0000FF) / 255.0
    
    self.init(red: red, green: green, blue: blue)
  }
  
  func toHex() -> String {
    guard let components = UIColor(self).cgColor.components, components.count >= 3 else {
      return "#000000"
    }
    
    let r = Int(components[0] * 255.0)
    let g = Int(components[1] * 255.0)
    let b = Int(components[2] * 255.0)
    
    return String(format: "#%02X%02X%02X", r, g, b)
  }
  
  static func forCategory(_ category: String) -> Color {
    switch category.lowercased() {
    case "kanji":
      return AppTheme.kanjiColor
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

