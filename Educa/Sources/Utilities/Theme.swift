//
//  Theme.swift
//  Educa
//
//  Premium app theme - Sophisticated colors, typography, and styling
//

import SwiftUI

// MARK: - Brand Colors (Premium Palette)

extension Color {
    // Primary brand - Deep ocean blue with emerald accents
    static let brand = Color(hex: "0A84FF")
    static let brandLight = Color(hex: "5AC8FA")
    static let brandDark = Color(hex: "0066CC")
    static let brandDeep = Color(hex: "003366")
    
    // Accent - Vibrant coral for CTAs
    static let accent = Color(hex: "FF6B6B")
    static let accentLight = Color(hex: "FF8E8E")
    static let accentDark = Color(hex: "E05555")
    
    // Secondary - Fresh mint for success/positives
    static let secondary = Color(hex: "34C759")
    static let secondaryLight = Color(hex: "5CD67A")
    static let secondaryDark = Color(hex: "248A3D")
    
    // Tertiary - Warm amber for highlights
    static let tertiary = Color(hex: "FF9F0A")
    static let tertiaryLight = Color(hex: "FFB340")
    static let tertiaryDark = Color(hex: "CC7F08")
    
    // Premium purple for special features
    static let premium = Color(hex: "BF5AF2")
    static let premiumLight = Color(hex: "D17FF7")
    static let premiumDark = Color(hex: "9945C2")
    
    // Background colors - Subtle warmth
    static let backgroundPrimary = Color(UIColor.systemBackground)
    static let backgroundSecondary = Color(UIColor.secondarySystemBackground)
    static let backgroundTertiary = Color(UIColor.tertiarySystemBackground)
    static let backgroundElevated = Color(UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark
            ? UIColor(red: 0.11, green: 0.11, blue: 0.12, alpha: 1)
            : UIColor.white
    })
    
    // Surface colors for cards
    static let surfaceLight = Color.white
    static let surfaceDark = Color(hex: "1C1C1E")
    static let surface = Color(UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark
            ? UIColor(red: 0.11, green: 0.11, blue: 0.12, alpha: 1)
            : UIColor.white
    })
    
    // Text colors
    static let textPrimary = Color(UIColor.label)
    static let textSecondary = Color(UIColor.secondaryLabel)
    static let textTertiary = Color(UIColor.tertiaryLabel)
    static let textInverse = Color.white
    
    // Status colors
    static let success = Color(hex: "34C759")
    static let warning = Color(hex: "FF9F0A")
    static let error = Color(hex: "FF3B30")
    static let info = Color(hex: "0A84FF")
    
    // Card colors
    static let cardBackground = Color(UIColor.secondarySystemBackground)
    static let cardBorder = Color(UIColor.separator).opacity(0.3)
    
    // Glass effect
    static let glassLight = Color.white.opacity(0.7)
    static let glassDark = Color.black.opacity(0.3)
    
    // Hex initializer
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
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

// MARK: - Typography (Premium Fonts)

extension Font {
    // Display - For hero sections
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
    
    // Monospace for numbers/data
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
    
    // Colored shadows
    static let brand = (color: Color.brand.opacity(0.3), radius: 12.0, x: 0.0, y: 6.0)
    static let accent = (color: Color.accent.opacity(0.3), radius: 12.0, x: 0.0, y: 6.0)
}

// MARK: - View Modifiers

extension View {
    // Premium card style
    func premiumCard() -> some View {
        self
            .background(Color.surface)
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.xl, style: .continuous))
            .shadow(color: AppShadow.medium.color, radius: AppShadow.medium.radius, x: AppShadow.medium.x, y: AppShadow.medium.y)
    }
    
    // Glass card style
    func glassCard() -> some View {
        self
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.xl, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: CornerRadius.xl, style: .continuous)
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
            )
    }
    
    // Standard card
    func cardStyle() -> some View {
        self
            .background(Color.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.large, style: .continuous))
            .shadow(color: AppShadow.small.color, radius: AppShadow.small.radius, x: AppShadow.small.x, y: AppShadow.small.y)
    }
    
    // Subtle card
    func subtleCard() -> some View {
        self
            .background(Color.backgroundSecondary)
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium, style: .continuous))
    }
    
    func cardShadow() -> some View {
        self.shadow(color: AppShadow.medium.color, radius: AppShadow.medium.radius, x: AppShadow.medium.x, y: AppShadow.medium.y)
    }
    
    func elevatedCard() -> some View {
        self
            .background(Color.backgroundElevated)
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.xl, style: .continuous))
            .shadow(color: AppShadow.large.color, radius: AppShadow.large.radius, x: AppShadow.large.x, y: AppShadow.large.y)
    }
    
    // Glow effect for important elements
    func glowEffect(color: Color = .brand) -> some View {
        self.shadow(color: color.opacity(0.4), radius: 8, x: 0, y: 0)
    }
    
    // Shimmer loading effect
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
                        colors: [
                            .clear,
                            .white.opacity(0.4),
                            .clear
                        ],
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

struct GhostButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.appSubheadline)
            .fontWeight(.medium)
            .foregroundColor(.brand)
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, Spacing.xs)
            .background(configuration.isPressed ? Color.brand.opacity(0.1) : Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.small, style: .continuous))
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

struct AccentButtonStyle: ButtonStyle {
    var isFullWidth: Bool = false
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.appHeadline)
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .frame(maxWidth: isFullWidth ? .infinity : nil)
            .padding(.horizontal, Spacing.xl)
            .padding(.vertical, Spacing.md)
            .background(
                LinearGradient(
                    colors: [Color.accent, Color.accentDark],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium, style: .continuous))
            .shadow(color: AppShadow.accent.color, radius: configuration.isPressed ? 4 : 8, x: 0, y: configuration.isPressed ? 2 : 4)
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

// MARK: - Gradient Presets

extension LinearGradient {
    // Brand gradients
    static let brandGradient = LinearGradient(
        colors: [Color.brand, Color.brandDark],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let brandSoftGradient = LinearGradient(
        colors: [Color.brand.opacity(0.8), Color.brandDark.opacity(0.6)],
        startPoint: .top,
        endPoint: .bottom
    )
    
    // Premium gradient
    static let premiumGradient = LinearGradient(
        colors: [Color.premium, Color.brand],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    // Accent gradient
    static let accentGradient = LinearGradient(
        colors: [Color.accent, Color.accentDark],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    // Success gradient
    static let successGradient = LinearGradient(
        colors: [Color.secondary, Color.secondaryDark],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    // Hero overlay gradients
    static let heroOverlay = LinearGradient(
        colors: [Color.black.opacity(0.0), Color.black.opacity(0.7)],
        startPoint: .top,
        endPoint: .bottom
    )
    
    static let heroOverlayReverse = LinearGradient(
        colors: [Color.black.opacity(0.5), Color.black.opacity(0.0)],
        startPoint: .top,
        endPoint: .bottom
    )
    
    static let heroOverlayFull = LinearGradient(
        colors: [Color.black.opacity(0.3), Color.black.opacity(0.6)],
        startPoint: .top,
        endPoint: .bottom
    )
    
    // Mesh-like subtle gradients
    static let subtleWarm = LinearGradient(
        colors: [Color(hex: "FFF5F5"), Color(hex: "FFF0E6")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let subtleCool = LinearGradient(
        colors: [Color(hex: "F0F9FF"), Color(hex: "E8F4FD")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    // Dark mode background gradient
    static let darkBackground = LinearGradient(
        colors: [Color(hex: "1A1A2E"), Color(hex: "16213E")],
        startPoint: .top,
        endPoint: .bottom
    )
}

// MARK: - Animation Presets

extension Animation {
    static let smoothSpring = Animation.spring(response: 0.4, dampingFraction: 0.8)
    static let quickSpring = Animation.spring(response: 0.3, dampingFraction: 0.7)
    static let bouncySpring = Animation.spring(response: 0.5, dampingFraction: 0.6)
    static let gentleEase = Animation.easeInOut(duration: 0.3)
    
    // Enhanced animations
    static let snappy = Animation.spring(response: 0.25, dampingFraction: 0.85)
    static let microBounce = Animation.spring(response: 0.2, dampingFraction: 0.6)
    static let slowReveal = Animation.easeOut(duration: 0.5)
    static let elasticPop = Animation.spring(response: 0.35, dampingFraction: 0.5, blendDuration: 0.1)
    
    // Staggered animation helper
    static func staggered(index: Int, baseDelay: Double = 0.05) -> Animation {
        .spring(response: 0.4, dampingFraction: 0.8).delay(Double(index) * baseDelay)
    }
}

// MARK: - View Transitions

extension AnyTransition {
    static let slideFromBottom = AnyTransition.asymmetric(
        insertion: .move(edge: .bottom).combined(with: .opacity),
        removal: .move(edge: .bottom).combined(with: .opacity)
    )
    
    static let slideFromTop = AnyTransition.asymmetric(
        insertion: .move(edge: .top).combined(with: .opacity),
        removal: .move(edge: .top).combined(with: .opacity)
    )
    
    static let scaleAndFade = AnyTransition.asymmetric(
        insertion: .scale(scale: 0.8).combined(with: .opacity),
        removal: .scale(scale: 0.8).combined(with: .opacity)
    )
    
    static let popIn = AnyTransition.asymmetric(
        insertion: .scale(scale: 0.5).combined(with: .opacity),
        removal: .scale(scale: 1.1).combined(with: .opacity)
    )
}

// MARK: - Custom Shapes

struct RoundedCornerShape: Shape {
    var corners: UIRectCorner
    var radius: CGFloat
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

// MARK: - Icon Badge

struct IconBadge: View {
    let systemName: String
    var color: Color = .brand
    var size: CGFloat = 44
    var iconScale: CGFloat = 0.5
    
    var body: some View {
        ZStack {
            Circle()
                .fill(color.opacity(0.15))
                .frame(width: size, height: size)
            
            Image(systemName: systemName)
                .font(.system(size: size * iconScale, weight: .semibold))
                .foregroundColor(color)
        }
    }
}

// MARK: - Tag/Chip View

struct TagView: View {
    let text: String
    var color: Color = .brand
    var style: TagStyle = .filled
    
    enum TagStyle {
        case filled, outlined, soft
    }
    
    var body: some View {
        Text(text)
            .font(.appCaption2)
            .fontWeight(.semibold)
            .foregroundColor(foregroundColor)
            .padding(.horizontal, Spacing.sm)
            .padding(.vertical, Spacing.xxs)
            .background(backgroundColor)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(borderColor, lineWidth: style == .outlined ? 1 : 0)
            )
    }
    
    private var foregroundColor: Color {
        switch style {
        case .filled: return .white
        case .outlined: return color
        case .soft: return color
        }
    }
    
    private var backgroundColor: Color {
        switch style {
        case .filled: return color
        case .outlined: return .clear
        case .soft: return color.opacity(0.12)
        }
    }
    
    private var borderColor: Color {
        switch style {
        case .outlined: return color
        default: return .clear
        }
    }
}

// MARK: - Interactive Button Styles

struct InteractiveScaleButtonStyle: ButtonStyle {
    var scale: CGFloat = 0.95
    var pressedOpacity: CGFloat = 0.8
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? scale : 1.0)
            .opacity(configuration.isPressed ? pressedOpacity : 1.0)
            .animation(.microBounce, value: configuration.isPressed)
    }
}

struct BounceButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
            .animation(.elasticPop, value: configuration.isPressed)
    }
}

struct TiltButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .rotation3DEffect(
                .degrees(configuration.isPressed ? -5 : 0),
                axis: (x: 1.0, y: 0.0, z: 0.0)
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.quickSpring, value: configuration.isPressed)
    }
}

// MARK: - Animated View Modifiers

extension View {
    // Press animation modifier
    func pressAnimation(scale: CGFloat = 0.95) -> some View {
        self.buttonStyle(InteractiveScaleButtonStyle(scale: scale))
    }
    
    // Bounce animation modifier
    func bounceOnTap() -> some View {
        self.buttonStyle(BounceButtonStyle())
    }
    
    // Pulsing animation for attention
    func pulsing(color: Color = .brand, active: Bool = true) -> some View {
        self.modifier(PulsingModifier(color: color, isActive: active))
    }
    
    // Floating animation
    func floating(active: Bool = true) -> some View {
        self.modifier(FloatingModifier(isActive: active))
    }
    
    // Shake animation for errors
    func shake(trigger: Bool) -> some View {
        self.modifier(ShakeModifier(trigger: trigger))
    }
    
    // Appear animation with stagger support
    func appearAnimation(index: Int = 0) -> some View {
        self.modifier(AppearAnimationModifier(index: index))
    }
    
    // Scale in animation
    func scaleInOnAppear(delay: Double = 0) -> some View {
        self.modifier(ScaleInModifier(delay: delay))
    }
    
    // Slide up animation
    func slideUpOnAppear(delay: Double = 0) -> some View {
        self.modifier(SlideUpModifier(delay: delay))
    }
}

// MARK: - Animation Modifiers

struct PulsingModifier: ViewModifier {
    let color: Color
    let isActive: Bool
    @State private var isPulsing = false
    
    func body(content: Content) -> some View {
        content
            .overlay(
                Circle()
                    .stroke(color, lineWidth: 2)
                    .scaleEffect(isPulsing ? 1.3 : 1.0)
                    .opacity(isPulsing ? 0 : 0.6)
            )
            .onAppear {
                if isActive {
                    withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: false)) {
                        isPulsing = true
                    }
                }
            }
    }
}

struct FloatingModifier: ViewModifier {
    let isActive: Bool
    @State private var offset: CGFloat = 0
    
    func body(content: Content) -> some View {
        content
            .offset(y: offset)
            .onAppear {
                if isActive {
                    withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                        offset = -8
                    }
                }
            }
    }
}

struct ShakeModifier: ViewModifier {
    let trigger: Bool
    @State private var shakeOffset: CGFloat = 0
    
    func body(content: Content) -> some View {
        content
            .offset(x: shakeOffset)
            .onChange(of: trigger) { _, newValue in
                if newValue {
                    withAnimation(.linear(duration: 0.05).repeatCount(5, autoreverses: true)) {
                        shakeOffset = 10
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        shakeOffset = 0
                    }
                }
            }
    }
}

struct AppearAnimationModifier: ViewModifier {
    let index: Int
    @State private var isVisible = false
    
    func body(content: Content) -> some View {
        content
            .opacity(isVisible ? 1 : 0)
            .offset(y: isVisible ? 0 : 20)
            .onAppear {
                withAnimation(.staggered(index: index)) {
                    isVisible = true
                }
            }
    }
}

struct ScaleInModifier: ViewModifier {
    let delay: Double
    @State private var scale: CGFloat = 0.8
    @State private var opacity: Double = 0
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(scale)
            .opacity(opacity)
            .onAppear {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.7).delay(delay)) {
                    scale = 1.0
                    opacity = 1.0
                }
            }
    }
}

struct SlideUpModifier: ViewModifier {
    let delay: Double
    @State private var offset: CGFloat = 30
    @State private var opacity: Double = 0
    
    func body(content: Content) -> some View {
        content
            .offset(y: offset)
            .opacity(opacity)
            .onAppear {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.8).delay(delay)) {
                    offset = 0
                    opacity = 1.0
                }
            }
    }
}

// MARK: - Animated Components

struct AnimatedCheckmark: View {
    let isChecked: Bool
    var size: CGFloat = 24
    var color: Color = .brand
    
    @State private var trim: CGFloat = 0
    
    var body: some View {
        ZStack {
            Circle()
                .fill(isChecked ? color : Color.clear)
                .frame(width: size, height: size)
                .overlay(
                    Circle()
                        .stroke(isChecked ? color : Color.textTertiary, lineWidth: 2)
                )
            
            if isChecked {
                Path { path in
                    path.move(to: CGPoint(x: size * 0.25, y: size * 0.5))
                    path.addLine(to: CGPoint(x: size * 0.4, y: size * 0.65))
                    path.addLine(to: CGPoint(x: size * 0.75, y: size * 0.35))
                }
                .trim(from: 0, to: trim)
                .stroke(Color.white, style: StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round))
                .offset(x: -size * 0.5, y: -size * 0.5)
            }
        }
        .frame(width: size, height: size)
        .onChange(of: isChecked) { _, newValue in
            if newValue {
                withAnimation(.easeOut(duration: 0.3)) {
                    trim = 1.0
                }
            } else {
                trim = 0
            }
        }
        .onAppear {
            if isChecked {
                trim = 1.0
            }
        }
    }
}

struct AnimatedProgressRing: View {
    let progress: Double
    var lineWidth: CGFloat = 6
    var size: CGFloat = 60
    var color: Color = .brand
    var showPercentage: Bool = true
    
    @State private var animatedProgress: Double = 0
    
    var body: some View {
        ZStack {
            // Background ring
            Circle()
                .stroke(color.opacity(0.2), lineWidth: lineWidth)
            
            // Progress ring
            Circle()
                .trim(from: 0, to: animatedProgress)
                .stroke(
                    AngularGradient(
                        colors: [color.opacity(0.5), color],
                        center: .center,
                        startAngle: .degrees(0),
                        endAngle: .degrees(360 * animatedProgress)
                    ),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
            
            // Percentage text
            if showPercentage {
                Text("\(Int(animatedProgress * 100))%")
                    .font(.appCaption)
                    .fontWeight(.bold)
                    .foregroundColor(.textPrimary)
            }
        }
        .frame(width: size, height: size)
        .onAppear {
            withAnimation(.easeOut(duration: 1.0)) {
                animatedProgress = min(progress, 1.0)
            }
        }
        .onChange(of: progress) { _, newValue in
            withAnimation(.easeOut(duration: 0.5)) {
                animatedProgress = min(newValue, 1.0)
            }
        }
    }
}

struct AnimatedCounter: View {
    let value: Int
    var prefix: String = ""
    var suffix: String = ""
    var font: Font = .appTitle2
    var color: Color = .textPrimary
    
    @State private var displayValue: Int = 0
    
    var body: some View {
        Text("\(prefix)\(displayValue)\(suffix)")
            .font(font)
            .fontWeight(.bold)
            .foregroundColor(color)
            .contentTransition(.numericText())
            .onAppear {
                animateValue()
            }
            .onChange(of: value) { _, _ in
                animateValue()
            }
    }
    
    private func animateValue() {
        let steps = 20
        let duration = 0.5
        let increment = max(1, (value - displayValue) / steps)
        
        for i in 0...steps {
            DispatchQueue.main.asyncAfter(deadline: .now() + (duration / Double(steps)) * Double(i)) {
                withAnimation(.easeOut(duration: 0.05)) {
                    if i == steps {
                        displayValue = value
                    } else {
                        displayValue = min(displayValue + increment, value)
                    }
                }
            }
        }
    }
}

struct ParallaxCard<Content: View>: View {
    let content: Content
    @State private var rotation: Double = 0
    @State private var offset: CGSize = .zero
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .rotation3DEffect(
                .degrees(rotation),
                axis: (x: offset.height / 20, y: offset.width / 20, z: 0)
            )
            .gesture(
                DragGesture()
                    .onChanged { value in
                        withAnimation(.interactiveSpring()) {
                            offset = value.translation
                            rotation = Double(offset.width + offset.height) / 30
                        }
                    }
                    .onEnded { _ in
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                            offset = .zero
                            rotation = 0
                        }
                    }
            )
    }
}
