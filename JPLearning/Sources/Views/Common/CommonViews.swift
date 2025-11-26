//
//  CommonViews.swift
//  JLearn
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
        Button(action: action) {
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
                // Use iOS 16-compatible onChange API (single newValue parameter)
                .onChange(of: text) { newValue in
                    if let maxLength = maxLength, newValue.count > maxLength {
                        text = String(newValue.prefix(maxLength))
                    }
                }
                
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
                        .font(.system(size: 12))
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
                        .font(.system(size: 12))
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

// MARK: - Professional Scale Button Style

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}

// MARK: - Professional Flow Layout

struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(
            in: proposal.replacingUnspecifiedDimensions().width,
            subviews: subviews,
            spacing: spacing
        )
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(
            in: bounds.width,
            subviews: subviews,
            spacing: spacing
        )
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.frames[index].minX,
                                     y: bounds.minY + result.frames[index].minY),
                         proposal: ProposedViewSize(result.frames[index].size))
        }
    }
    
    struct FlowResult {
        var size: CGSize
        var frames: [CGRect]
        
        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var frames: [CGRect] = []
            var currentX: CGFloat = 0
            var currentY: CGFloat = 0
            var lineHeight: CGFloat = 0
            
            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                
                if currentX + size.width > maxWidth && currentX > 0 {
                    currentX = 0
                    currentY += lineHeight + spacing
                    lineHeight = 0
                }
                
                frames.append(CGRect(x: currentX, y: currentY, width: size.width, height: size.height))
                lineHeight = max(lineHeight, size.height)
                currentX += size.width + spacing
            }
            
            self.frames = frames
            self.size = CGSize(width: maxWidth, height: currentY + lineHeight)
        }
    }
}

// MARK: - Professional Answer Button

struct ProfessionalAnswerButton: View {
    let text: String
    let isSelected: Bool
    let isCorrect: Bool
    let isWrong: Bool
    let action: () -> Void
    
    private var backgroundColor: Color {
        if isCorrect {
            return AppTheme.success.opacity(0.1)
        } else if isWrong {
            return AppTheme.danger.opacity(0.1)
        } else if isSelected {
            return AppTheme.brandPrimary.opacity(0.1)
        } else {
            return Color.white
        }
    }
    
    private var borderColor: Color {
        if isCorrect {
            return AppTheme.success
        } else if isWrong {
            return AppTheme.danger
        } else if isSelected {
            return AppTheme.brandPrimary
        } else {
            return AppTheme.separator
        }
    }
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(text)
                    .font(AppTheme.Typography.body)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
                
                Spacer()
                
                if isCorrect {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(AppTheme.success)
                } else if isWrong {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(AppTheme.danger)
                }
            }
            .padding()
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Layout.cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.Layout.cornerRadius)
                    .stroke(borderColor, lineWidth: 2)
            )
        }
    }
}

// MARK: - Professional Empty State View

struct ProfessionalEmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    let actionTitle: String?
    let action: (() -> Void)?
    
    init(
        icon: String,
        title: String,
        message: String,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.icon = icon
        self.title = title
        self.message = message
        self.actionTitle = actionTitle
        self.action = action
    }
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: icon)
                .font(.system(size: 64))
                .foregroundColor(.secondary)
            
            VStack(spacing: 8) {
                Text(title)
                    .font(AppTheme.Typography.title)
                    .foregroundColor(.primary)
                
                Text(message)
                    .font(AppTheme.Typography.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            if let actionTitle = actionTitle, let action = action {
                Button(action: action) {
                    Text(actionTitle)
                        .font(AppTheme.Typography.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(AppTheme.brandPrimary)
                        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Layout.cornerRadius))
                }
                .padding(.horizontal)
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

// MARK: - Professional Progress Header

struct ProfessionalProgressHeader: View {
    let currentIndex: Int
    let total: Int
    let score: Int?
    let scoreLabel: String
    let progressColor: Color
    
    init(
        currentIndex: Int,
        total: Int,
        score: Int? = nil,
        scoreLabel: String = "correct",
        progressColor: Color = AppTheme.brandPrimary
    ) {
        self.currentIndex = currentIndex
        self.total = total
        self.score = score
        self.scoreLabel = scoreLabel
        self.progressColor = progressColor
    }
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text("Question \(currentIndex + 1) of \(total)")
                    .font(AppTheme.Typography.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                if let score = score {
                    Text("\(score) \(scoreLabel)")
                        .font(AppTheme.Typography.caption)
                        .foregroundColor(progressColor)
                        .fontWeight(.semibold)
                }
            }
            .padding(.horizontal)
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(AppTheme.separator)
                        .frame(height: 4)
                    
                    Rectangle()
                        .fill(progressColor)
                        .frame(width: geometry.size.width * (Double(currentIndex) / Double(total)), height: 4)
                }
            }
            .frame(height: 4)
        }
        .padding(.top, 8)
    }
}

// MARK: - Professional Results View

struct ProfessionalResultsView: View {
    let score: Int
    let total: Int
    let title: String
    let icon: String
    let color: Color
    let restartAction: () -> Void
    let dismissAction: (() -> Void)?
    
    init(
        score: Int,
        total: Int,
        title: String = "Complete!",
        icon: String = "checkmark.circle.fill",
        color: Color = AppTheme.brandPrimary,
        restartAction: @escaping () -> Void,
        dismissAction: (() -> Void)? = nil
    ) {
        self.score = score
        self.total = total
        self.title = title
        self.icon = icon
        self.color = color
        self.restartAction = restartAction
        self.dismissAction = dismissAction
    }
    
    private var percentage: Int {
        guard total > 0 else { return 0 }
        return Int((Double(score) / Double(total)) * 100)
    }
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // Score Circle
            ZStack {
                Circle()
                    .stroke(AppTheme.separator, lineWidth: 10)
                    .frame(width: 160, height: 160)
                
                Circle()
                    .trim(from: 0, to: Double(score) / Double(total))
                    .stroke(color, lineWidth: 10)
                    .frame(width: 160, height: 160)
                    .rotationEffect(.degrees(-90))
                    .animation(.spring(response: 0.8, dampingFraction: 0.7), value: score)
                
                VStack(spacing: 6) {
                    Text("\(score)")
                        .font(.system(size: 56, weight: .bold))
                        .foregroundColor(color)
                    Text("out of \(total)")
                        .font(AppTheme.Typography.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // Title and Percentage
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 40))
                    .foregroundColor(color)
                
                Text(title)
                    .font(AppTheme.Typography.title)
                    .foregroundColor(.primary)
                
                Text("You scored \(percentage)%")
                    .font(AppTheme.Typography.body)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Action Buttons
            VStack(spacing: 12) {
                Button(action: restartAction) {
                    HStack {
                        Image(systemName: "arrow.clockwise")
                        Text("Try Again")
                    }
                    .font(AppTheme.Typography.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(color)
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.Layout.cornerRadius))
                }
                
                if let dismissAction = dismissAction {
                    Button(action: dismissAction) {
                        Text("Done")
                            .font(AppTheme.Typography.headline)
                            .foregroundColor(color)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(color.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Layout.cornerRadius))
                    }
                }
            }
            .padding()
        }
        .background(AppTheme.background)
    }
}

