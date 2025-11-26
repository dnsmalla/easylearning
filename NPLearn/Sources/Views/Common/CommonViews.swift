//
//  CommonViews.swift
//  NPLearn
//
//  Reusable professional UI components
//  Consistent design system components used throughout the app
//

import SwiftUI

// MARK: - Professional Card View

struct ProfessionalCard<Content: View>: View {
    let content: Content
    let padding: CGFloat
    let cornerRadius: CGFloat
    let shadowRadius: CGFloat
    
    init(
        padding: CGFloat = AppTheme.Layout.cardPadding,
        cornerRadius: CGFloat = AppTheme.Layout.cornerRadius,
        shadowRadius: CGFloat = 8,
        @ViewBuilder content: () -> Content
    ) {
        self.content = content()
        self.padding = padding
        self.cornerRadius = cornerRadius
        self.shadowRadius = shadowRadius
    }
    
    var body: some View {
        content
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(AppTheme.background)
            )
            .shadow(color: .black.opacity(0.08), radius: shadowRadius, x: 0, y: 4)
    }
}

// MARK: - Professional Button

struct ProfessionalButton: View {
    let title: String
    let icon: String?
    let style: ButtonStyleType
    let isLoading: Bool
    let isDisabled: Bool
    let action: () -> Void
    
    init(
        _ title: String,
        icon: String? = nil,
        style: ButtonStyleType = .primary,
        isLoading: Bool = false,
        isDisabled: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.style = style
        self.isLoading = isLoading
        self.isDisabled = isDisabled
        self.action = action
    }
    
    enum ButtonStyleType {
        case primary
        case secondary
        case destructive
        case outline
        case ghost
        
        var backgroundColor: Color {
            switch self {
            case .primary: return AppTheme.brandPrimary
            case .secondary: return AppTheme.brandSecondary
            case .destructive: return AppTheme.danger
            case .outline, .ghost: return .clear
            }
        }
        
        var foregroundColor: Color {
            switch self {
            case .primary, .secondary, .destructive: return .white
            case .outline: return AppTheme.brandPrimary
            case .ghost: return AppTheme.mutedText
            }
        }
        
        var borderColor: Color? {
            switch self {
            case .outline: return AppTheme.brandPrimary
            default: return nil
            }
        }
    }
    
    var body: some View {
        Button(action: {
            Haptics.light()
            action()
        }) {
            HStack(spacing: 8) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: style.foregroundColor))
                        .scaleEffect(0.8)
                } else {
                    if let icon = icon {
                        Image(systemName: icon)
                            .font(.system(size: 16, weight: .semibold))
                    }
                    
                    Text(title)
                        .font(AppTheme.Typography.button)
                }
            }
            .foregroundColor(style.foregroundColor)
            .frame(maxWidth: .infinity)
            .frame(height: AppTheme.Controls.buttonHeight)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(style.backgroundColor)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(style.borderColor ?? .clear, lineWidth: 2)
            )
        }
        .disabled(isDisabled || isLoading)
        .opacity(isDisabled ? 0.5 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isDisabled)
        .animation(.easeInOut(duration: 0.2), value: isLoading)
    }
}

// MARK: - Professional Text Field

struct ProfessionalTextField: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    let icon: String?
    let keyboardType: UIKeyboardType
    let isSecure: Bool
    let errorMessage: String?
    let maxLength: Int?
    
    @State private var isShowingPassword = false
    @FocusState private var isFocused: Bool
    
    init(
        _ title: String,
        text: Binding<String>,
        placeholder: String = "",
        icon: String? = nil,
        keyboardType: UIKeyboardType = .default,
        isSecure: Bool = false,
        errorMessage: String? = nil,
        maxLength: Int? = nil
    ) {
        self.title = title
        self._text = text
        self.placeholder = placeholder
        self.icon = icon
        self.keyboardType = keyboardType
        self.isSecure = isSecure
        self.errorMessage = errorMessage
        self.maxLength = maxLength
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Title
            Text(title)
                .font(AppTheme.Typography.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            // Input field
            HStack(spacing: 12) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 18))
                        .foregroundColor(isFocused ? AppTheme.brandPrimary : AppTheme.mutedText)
                }
                
                Group {
                    if isSecure && !isShowingPassword {
                        SecureField(placeholder, text: $text)
                    } else {
                        TextField(placeholder, text: $text)
                            .keyboardType(keyboardType)
                            .textInputAutocapitalization(keyboardType == .emailAddress ? .never : .sentences)
                    }
                }
                .font(AppTheme.Typography.body)
                .focused($isFocused)
                
                if isSecure {
                    Button {
                        isShowingPassword.toggle()
                        Haptics.selection()
                    } label: {
                        Image(systemName: isShowingPassword ? "eye.slash.fill" : "eye.fill")
                            .font(.system(size: 16))
                            .foregroundColor(AppTheme.mutedText)
                    }
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(AppTheme.secondaryBackground)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        errorMessage != nil ? AppTheme.danger :
                            isFocused ? AppTheme.brandPrimary : Color.clear,
                        lineWidth: 2
                    )
            )
            .animation(.easeInOut(duration: 0.2), value: isFocused)
            
            // Error message
            if let errorMessage = errorMessage {
                HStack(spacing: 4) {
                    Image(systemName: "exclamationmark.circle.fill")
                        .font(.system(size: 14)) // Changed from 12 for better visibility
                    Text(errorMessage)
                        .font(AppTheme.Typography.caption)
                }
                .foregroundColor(AppTheme.danger)
                .transition(.opacity)
            }
            
            // Character count
            if let maxLength = maxLength {
                Text("\(text.count)/\(maxLength)")
                    .font(AppTheme.Typography.caption2)
                    .foregroundColor(AppTheme.mutedText)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
        }
    }
}

// MARK: - Professional Chip

struct ProfessionalChip: View {
    let text: String
    let icon: String?
    let color: Color
    let isSelected: Bool
    let action: (() -> Void)?
    
    init(
        _ text: String,
        icon: String? = nil,
        color: Color = AppTheme.brandPrimary,
        isSelected: Bool = false,
        action: (() -> Void)? = nil
    ) {
        self.text = text
        self.icon = icon
        self.color = color
        self.isSelected = isSelected
        self.action = action
    }
    
    var body: some View {
        Button {
            action?()
            Haptics.selection()
        } label: {
            HStack(spacing: 6) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 14)) // Changed from 12 for better visibility
                }
                Text(text)
                    .font(AppTheme.Typography.caption)
                    .fontWeight(.semibold)
            }
            .foregroundColor(isSelected ? .white : color)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(isSelected ? color : color.opacity(0.15))
            )
        }
        .disabled(action == nil)
    }
}

// MARK: - Professional Progress Bar

struct ProfessionalProgressBar: View {
    let progress: Double
    let total: Double
    let color: Color
    let showLabel: Bool
    
    init(
        progress: Double,
        total: Double = 1.0,
        color: Color = AppTheme.brandPrimary,
        showLabel: Bool = true
    ) {
        self.progress = progress
        self.total = total
        self.color = color
        self.showLabel = showLabel
    }
    
    private var percentage: Double {
        min(max(progress / total, 0), 1)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if showLabel {
                HStack {
                    Text("\(Int(percentage * 100))%")
                        .font(AppTheme.Typography.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(color)
                    
                    Spacer()
                    
                    Text("\(Int(progress))/\(Int(total))")
                        .font(AppTheme.Typography.caption)
                        .foregroundColor(AppTheme.mutedText)
                }
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    RoundedRectangle(cornerRadius: 4)
                        .fill(color.opacity(0.2))
                    
                    // Progress
                    RoundedRectangle(cornerRadius: 4)
                        .fill(color)
                        .frame(width: geometry.size.width * percentage)
                        .animation(.spring(response: 0.5, dampingFraction: 0.7), value: percentage)
                }
            }
            .frame(height: 8)
        }
    }
}

// MARK: - Professional Badge

struct ProfessionalBadge: View {
    let text: String
    let color: Color
    let size: BadgeSize
    
    init(
        _ text: String,
        color: Color = AppTheme.brandPrimary,
        size: BadgeSize = .medium
    ) {
        self.text = text
        self.color = color
        self.size = size
    }
    
    enum BadgeSize {
        case small, medium, large
        
        var fontSize: Font {
            switch self {
            case .small: return AppTheme.Typography.caption2
            case .medium: return AppTheme.Typography.caption
            case .large: return AppTheme.Typography.subheadline
            }
        }
        
        var padding: (horizontal: CGFloat, vertical: CGFloat) {
            switch self {
            case .small: return (6, 3)
            case .medium: return (10, 5)
            case .large: return (14, 7)
            }
        }
    }
    
    var body: some View {
        Text(text)
            .font(size.fontSize)
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .padding(.horizontal, size.padding.horizontal)
            .padding(.vertical, size.padding.vertical)
            .background(
                Capsule()
                    .fill(color)
            )
    }
}

// MARK: - Professional Section Header

struct ProfessionalSectionHeader: View {
    let title: String
    let subtitle: String?
    let action: (() -> Void)?
    let actionTitle: String?
    
    init(
        _ title: String,
        subtitle: String? = nil,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.title = title
        self.subtitle = subtitle
        self.actionTitle = actionTitle
        self.action = action
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(AppTheme.Typography.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(AppTheme.Typography.caption)
                            .foregroundColor(AppTheme.mutedText)
                    }
                }
                
                Spacer()
                
                if let action = action, let actionTitle = actionTitle {
                    Button(action: action) {
                        Text(actionTitle)
                            .font(AppTheme.Typography.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(AppTheme.brandPrimary)
                    }
                }
            }
        }
    }
}

// MARK: - Professional Divider

struct ProfessionalDivider: View {
    let thickness: CGFloat
    let color: Color
    
    init(
        thickness: CGFloat = 1,
        color: Color = AppTheme.separator
    ) {
        self.thickness = thickness
        self.color = color
    }
    
    var body: some View {
        Rectangle()
            .fill(color)
            .frame(height: thickness)
    }
}

// MARK: - Shimmer Loading Effect

struct ShimmerView: View {
    @State private var phase: CGFloat = 0
    
    var body: some View {
        GeometryReader { geometry in
            LinearGradient(
                colors: [
                    Color.gray.opacity(0.3),
                    Color.gray.opacity(0.1),
                    Color.gray.opacity(0.3)
                ],
                startPoint: .leading,
                endPoint: .trailing
            )
            .frame(width: geometry.size.width * 2)
            .offset(x: phase * geometry.size.width * 2 - geometry.size.width * 2)
            .onAppear {
                withAnimation(
                    .linear(duration: 1.5)
                    .repeatForever(autoreverses: false)
                ) {
                    phase = 1
                }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

extension View {
    /// Add shimmer loading effect
    func shimmer() -> some View {
        self.overlay(ShimmerView())
    }
}

// MARK: - Stat Card

struct StatCard: View {
    let value: String
    let label: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)
            
            Text(value)
                .font(AppTheme.Typography.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text(label)
                .font(AppTheme.Typography.caption)
                .foregroundColor(AppTheme.mutedText)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(color.opacity(0.1))
        )
    }
}

