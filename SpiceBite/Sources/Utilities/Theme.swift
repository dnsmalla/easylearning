//
//  Theme.swift
//  SpiceBite
//
//  Premium theme inspired by Indian & Nepali aesthetics
//  Rich warm colors with spice-inspired accents
//

import SwiftUI

// MARK: - Brand Colors (Warm Spice Palette)

extension Color {
    // Primary - Deep Curry Gold
    static let brand = Color(hex: "DC6437")  // Warm tandoori orange
    static let brandLight = Color(hex: "F08552")
    static let brandDark = Color(hex: "B84C28")
    static let brandDeep = Color(hex: "8B3A1D")
    
    // Secondary - Rich Saffron
    static let secondary = Color(hex: "E8A838")  // Golden saffron
    static let secondaryLight = Color(hex: "F5C050")
    static let secondaryDark = Color(hex: "C48C28")
    
    // Accent - Deep Maroon (Nepal inspired)
    static let accent = Color(hex: "DC143C")  // Crimson
    static let accentLight = Color(hex: "FF4D6A")
    static let accentDark = Color(hex: "A30F2D")
    
    // Tertiary - Forest Green (for vegetarian/fresh)
    static let tertiary = Color(hex: "2E7D32")
    static let tertiaryLight = Color(hex: "4CAF50")
    static let tertiaryDark = Color(hex: "1B5E20")
    
    // Indian Flag Inspired
    static let saffron = Color(hex: "FF9933")
    static let indiaGreen = Color(hex: "138808")
    static let indiaBlue = Color(hex: "000080")
    
    // Nepal Flag Inspired
    static let nepalRed = Color(hex: "DC143C")
    static let nepalBlue = Color(hex: "003893")
    
    // Background colors
    static let backgroundPrimary = Color(UIColor.systemBackground)
    static let backgroundSecondary = Color(UIColor.secondarySystemBackground)
    static let backgroundTertiary = Color(UIColor.tertiarySystemBackground)
    
    // Surface colors
    static let surface = Color(UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark
            ? UIColor(red: 0.11, green: 0.11, blue: 0.12, alpha: 1)
            : UIColor.white
    })
    static let surfaceElevated = Color(UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark
            ? UIColor(red: 0.15, green: 0.15, blue: 0.16, alpha: 1)
            : UIColor.white
    })
    
    // Text colors
    static let textPrimary = Color(UIColor.label)
    static let textSecondary = Color(UIColor.secondaryLabel)
    static let textTertiary = Color(UIColor.tertiaryLabel)
    static let textInverse = Color.white
    
    // Status colors
    static let success = Color(hex: "4CAF50")
    static let warning = Color(hex: "FF9800")
    static let error = Color(hex: "F44336")
    static let info = Color(hex: "2196F3")
    
    // Card colors
    static let cardBackground = Color(UIColor.secondarySystemBackground)
    static let cardBorder = Color(UIColor.separator).opacity(0.3)
    
    // Spice level colors
    static let mild = Color(hex: "8BC34A")
    static let medium = Color(hex: "FF9800")
    static let hot = Color(hex: "FF5722")
    static let veryHot = Color(hex: "D32F2F")
    static let extreme = Color(hex: "B71C1C")
    
    // Hex initializer
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Spacing System

struct Spacing {
    static let xxxs: CGFloat = 2
    static let xxs: CGFloat = 4
    static let xs: CGFloat = 8
    static let sm: CGFloat = 12
    static let md: CGFloat = 16
    static let lg: CGFloat = 20
    static let xl: CGFloat = 24
    static let xxl: CGFloat = 32
    static let xxxl: CGFloat = 48
    static let huge: CGFloat = 64
}

// MARK: - Corner Radius

struct CornerRadius {
    static let xs: CGFloat = 4
    static let small: CGFloat = 8
    static let medium: CGFloat = 12
    static let large: CGFloat = 16
    static let xl: CGFloat = 20
    static let extraLarge: CGFloat = 24
    static let xxl: CGFloat = 32
    static let full: CGFloat = 999
}

// MARK: - Typography

extension Font {
    // Display
    static let appDisplay = Font.system(size: 40, weight: .bold, design: .rounded)
    static let appLargeTitle = Font.system(size: 34, weight: .bold, design: .rounded)
    
    // Titles
    static let appTitle = Font.system(size: 28, weight: .bold, design: .rounded)
    static let appTitle2 = Font.system(size: 22, weight: .bold, design: .rounded)
    static let appTitle3 = Font.system(size: 20, weight: .semibold, design: .rounded)
    
    // Body text
    static let appHeadline = Font.system(size: 17, weight: .semibold, design: .default)
    static let appSubheadline = Font.system(size: 15, weight: .medium, design: .default)
    static let appBody = Font.system(size: 17, weight: .regular, design: .default)
    static let appCallout = Font.system(size: 16, weight: .regular, design: .default)
    
    // Small text
    static let appCaption = Font.system(size: 13, weight: .medium, design: .default)
    static let appCaption2 = Font.system(size: 11, weight: .medium, design: .default)
    static let appFootnote = Font.system(size: 13, weight: .regular, design: .default)
    
    // Monospace
    static let appMono = Font.system(size: 15, weight: .medium, design: .monospaced)
    static let appMonoLarge = Font.system(size: 24, weight: .bold, design: .monospaced)
}

// MARK: - Shadow Presets

struct AppShadow {
    static let subtle = (color: Color.black.opacity(0.04), radius: 2.0, x: 0.0, y: 1.0)
    static let small = (color: Color.black.opacity(0.08), radius: 4.0, x: 0.0, y: 2.0)
    static let medium = (color: Color.black.opacity(0.12), radius: 8.0, x: 0.0, y: 4.0)
    static let large = (color: Color.black.opacity(0.16), radius: 16.0, x: 0.0, y: 8.0)
    static let elevated = (color: Color.black.opacity(0.2), radius: 20.0, x: 0.0, y: 10.0)
    
    static let brand = (color: Color.brand.opacity(0.3), radius: 12.0, x: 0.0, y: 6.0)
    static let accent = (color: Color.accent.opacity(0.3), radius: 12.0, x: 0.0, y: 6.0)
}

// MARK: - View Modifiers

extension View {
    func premiumCard() -> some View {
        self
            .background(Color.surface)
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.xl, style: .continuous))
            .shadow(color: AppShadow.medium.color, radius: AppShadow.medium.radius, x: AppShadow.medium.x, y: AppShadow.medium.y)
    }
    
    func cardStyle() -> some View {
        self
            .background(Color.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.large, style: .continuous))
            .shadow(color: AppShadow.small.color, radius: AppShadow.small.radius, x: AppShadow.small.x, y: AppShadow.small.y)
    }
    
    func subtleCard() -> some View {
        self
            .background(Color.backgroundSecondary)
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium, style: .continuous))
    }
    
    func cardShadow() -> some View {
        self.shadow(color: AppShadow.medium.color, radius: AppShadow.medium.radius, x: AppShadow.medium.x, y: AppShadow.medium.y)
    }
    
    func shimmer() -> some View {
        self.modifier(ShimmerModifier())
    }
}

// MARK: - Shimmer Modifier

struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = 0
    
    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geometry in
                    LinearGradient(
                        colors: [.clear, .white.opacity(0.4), .clear],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: geometry.size.width * 2)
                    .offset(x: -geometry.size.width + (geometry.size.width * 2 * phase))
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.small))
            .onAppear {
                withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                    phase = 1
                }
            }
    }
}

// MARK: - Button Styles

struct PrimaryButtonStyle: ButtonStyle {
    var isFullWidth: Bool = false
    var size: ButtonSize = .regular
    
    enum ButtonSize {
        case small, regular, large
        
        var verticalPadding: CGFloat {
            switch self {
            case .small: return Spacing.xs
            case .regular: return Spacing.md
            case .large: return Spacing.lg
            }
        }
        
        var horizontalPadding: CGFloat {
            switch self {
            case .small: return Spacing.md
            case .regular: return Spacing.xl
            case .large: return Spacing.xxl
            }
        }
        
        var font: Font {
            switch self {
            case .small: return .appCaption
            case .regular: return .appHeadline
            case .large: return .appTitle3
            }
        }
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(size.font)
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .frame(maxWidth: isFullWidth ? .infinity : nil)
            .padding(.horizontal, size.horizontalPadding)
            .padding(.vertical, size.verticalPadding)
            .background(
                LinearGradient(
                    colors: [Color.brand, Color.brandDark],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium, style: .continuous))
            .shadow(color: AppShadow.brand.color, radius: configuration.isPressed ? 4 : AppShadow.brand.radius, x: 0, y: configuration.isPressed ? 2 : 4)
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    var isFullWidth: Bool = false
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.appHeadline)
            .fontWeight(.semibold)
            .foregroundColor(.brand)
            .frame(maxWidth: isFullWidth ? .infinity : nil)
            .padding(.horizontal, Spacing.xl)
            .padding(.vertical, Spacing.md)
            .background(Color.brand.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: CornerRadius.medium, style: .continuous)
                    .stroke(Color.brand.opacity(0.3), lineWidth: 1.5)
            )
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

// MARK: - Gradient Presets

extension LinearGradient {
    static let brandGradient = LinearGradient(
        colors: [Color.brand, Color.brandDark],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let warmGradient = LinearGradient(
        colors: [Color.saffron, Color.brand],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let nepalGradient = LinearGradient(
        colors: [Color.nepalRed, Color.nepalBlue.opacity(0.8)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let indianGradient = LinearGradient(
        colors: [Color.saffron, Color.indiaGreen],
        startPoint: .top,
        endPoint: .bottom
    )
    
    static let heroOverlay = LinearGradient(
        colors: [Color.black.opacity(0.0), Color.black.opacity(0.7)],
        startPoint: .top,
        endPoint: .bottom
    )
    
    static let spicyGradient = LinearGradient(
        colors: [Color.hot, Color.veryHot],
        startPoint: .leading,
        endPoint: .trailing
    )
}

// MARK: - Animation Presets

extension Animation {
    static let smoothSpring = Animation.spring(response: 0.4, dampingFraction: 0.8)
    static let quickSpring = Animation.spring(response: 0.3, dampingFraction: 0.7)
    static let bouncySpring = Animation.spring(response: 0.5, dampingFraction: 0.6)
    static let gentleEase = Animation.easeInOut(duration: 0.3)
    
    static func staggered(index: Int, baseDelay: Double = 0.05) -> Animation {
        .spring(response: 0.4, dampingFraction: 0.8).delay(Double(index) * baseDelay)
    }
}

// MARK: - Spice Level View

struct SpiceLevelView: View {
    let level: Int // 1-5
    var size: CGFloat = 16
    
    var body: some View {
        HStack(spacing: 2) {
            ForEach(1...5, id: \.self) { i in
                Image(systemName: i <= level ? "flame.fill" : "flame")
                    .font(.system(size: size))
                    .foregroundColor(colorForLevel(i, active: i <= level))
            }
        }
    }
    
    private func colorForLevel(_ index: Int, active: Bool) -> Color {
        guard active else { return .gray.opacity(0.3) }
        switch index {
        case 1: return .mild
        case 2: return .medium
        case 3: return .hot
        case 4: return .veryHot
        case 5: return .extreme
        default: return .gray
        }
    }
}

// MARK: - Rating Stars View

struct RatingStarsView: View {
    let rating: Double
    var maxRating: Int = 5
    var size: CGFloat = 16
    var color: Color = .secondary
    
    var body: some View {
        HStack(spacing: 2) {
            ForEach(1...maxRating, id: \.self) { index in
                Image(systemName: starType(for: index))
                    .font(.system(size: size, weight: .medium))
                    .foregroundColor(index <= Int(rating.rounded()) ? color : .gray.opacity(0.3))
            }
        }
    }
    
    private func starType(for index: Int) -> String {
        let difference = rating - Double(index - 1)
        if difference >= 1 {
            return "star.fill"
        } else if difference >= 0.5 {
            return "star.leadinghalf.filled"
        } else {
            return "star"
        }
    }
}

// MARK: - Price Tag View

struct PriceTagView: View {
    let priceRange: PriceRange
    var showDescription: Bool = false
    
    var body: some View {
        HStack(spacing: Spacing.xs) {
            Text(priceRange.rawValue)
                .font(.appSubheadline)
                .fontWeight(.bold)
                .foregroundColor(.brand)
            
            if showDescription {
                Text(priceRange.description)
                    .font(.appCaption)
                    .foregroundColor(.textSecondary)
            }
        }
        .padding(.horizontal, Spacing.sm)
        .padding(.vertical, Spacing.xxs)
        .background(Color.brand.opacity(0.1))
        .clipShape(Capsule())
    }
}

// MARK: - Cuisine Badge View

struct CuisineBadge: View {
    let cuisine: CuisineType
    var showIcon: Bool = true
    var size: BadgeSize = .regular
    
    enum BadgeSize {
        case small, regular, large
        
        var font: Font {
            switch self {
            case .small: return .appCaption2
            case .regular: return .appCaption
            case .large: return .appSubheadline
            }
        }
        
        var padding: CGFloat {
            switch self {
            case .small: return Spacing.xxs
            case .regular: return Spacing.xs
            case .large: return Spacing.sm
            }
        }
    }
    
    var body: some View {
        HStack(spacing: Spacing.xxs) {
            if showIcon {
                Text(cuisine.icon)
            }
            Text(cuisine.rawValue)
                .font(size.font)
                .fontWeight(.semibold)
        }
        .foregroundColor(Color(hex: cuisine.color))
        .padding(.horizontal, size.padding + 4)
        .padding(.vertical, size.padding)
        .background(Color(hex: cuisine.color).opacity(0.15))
        .clipShape(Capsule())
    }
}

// MARK: - Formatting Utilities

struct Formatting {
    static func formatNumber(_ number: Int) -> String {
        if number >= 1_000_000 {
            return String(format: "%.1fM", Double(number) / 1_000_000)
        } else if number >= 1_000 {
            return String(format: "%.0fK", Double(number) / 1_000)
        }
        return "\(number)"
    }
    
    static func formatPrice(_ amount: Int, currency: String = "¥") -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        let formatted = formatter.string(from: NSNumber(value: amount)) ?? "\(amount)"
        return "\(currency)\(formatted)"
    }
    
    static func formatRating(_ rating: Double) -> String {
        String(format: "%.1f", rating)
    }
    
    static func formatWalkingTime(_ minutes: Int) -> String {
        if minutes < 1 {
            return "< 1 min walk"
        } else if minutes == 1 {
            return "1 min walk"
        } else {
            return "\(minutes) min walk"
        }
    }

    static func formatDistanceKm(_ distanceKm: Double) -> String {
        if distanceKm < 1 {
            let meters = Int(distanceKm * 1000)
            return "\(meters)m away"
        } else {
            return String(format: "%.1f km away", distanceKm)
        }
    }
}
