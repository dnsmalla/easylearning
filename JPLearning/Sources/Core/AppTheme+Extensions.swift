//
//  AppTheme+Extensions.swift
//  JLearn
//
//  Additional theme utilities and button styles
//

import SwiftUI

// MARK: - Button Styles

struct PrimaryButtonStyle: ViewModifier {
    var isDisabled: Bool = false
    
    func body(content: Content) -> some View {
        content
            .font(AppTheme.Typography.button)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: AppTheme.Controls.buttonHeight)
            .background(isDisabled ? AppTheme.mutedText : AppTheme.brandPrimary)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Layout.cornerRadius))
            .shadow(
                color: isDisabled ? .clear : AppTheme.brandPrimary.opacity(0.3),
                radius: 8,
                y: 4
            )
    }
}

struct SecondaryButtonStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(AppTheme.Typography.button)
            .foregroundColor(AppTheme.brandPrimary)
            .frame(maxWidth: .infinity)
            .frame(height: AppTheme.Controls.buttonHeight)
            .background(AppTheme.brandPrimary.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Layout.cornerRadius))
    }
}

struct OutlineButtonStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(AppTheme.Typography.button)
            .foregroundColor(AppTheme.brandPrimary)
            .frame(maxWidth: .infinity)
            .frame(height: AppTheme.Controls.buttonHeight)
            .background(Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Layout.cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.Layout.cornerRadius)
                    .stroke(AppTheme.brandPrimary, lineWidth: 2)
            )
    }
}

extension View {
    func primaryButtonStyle(isDisabled: Bool = false) -> some View {
        self.modifier(PrimaryButtonStyle(isDisabled: isDisabled))
    }
    
    func secondaryButtonStyle() -> some View {
        self.modifier(SecondaryButtonStyle())
    }
    
    func outlineButtonStyle() -> some View {
        self.modifier(OutlineButtonStyle())
    }
}

// MARK: - Typography Extensions
// (All typography is defined in AppTheme.swift)

// MARK: - Loading Indicator

struct LoadingOverlay: View {
    let message: String?
    
    init(message: String? = nil) {
        self.message = message
    }
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
                ProgressView()
                    .scaleEffect(1.5)
                    .tint(.white)
                
                if let message = message {
                    Text(message)
                        .font(AppTheme.Typography.subheadline)
                        .foregroundColor(.white)
                }
            }
            .padding(32)
            .background(Color.black.opacity(0.8))
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Layout.cornerRadius))
        }
    }
}

extension View {
    func loadingOverlay(isLoading: Bool, message: String? = nil) -> some View {
        ZStack {
            self
            
            if isLoading {
                LoadingOverlay(message: message)
            }
        }
    }
}

// MARK: - Toast Notification (legacy - kept for backward compatibility, not used in new toasts)

struct LegacyToastView: View {
    let message: String
    let type: ToastType
    
    enum ToastType {
        case success
        case error
        case info
        case warning
        
        var color: Color {
            switch self {
            case .success: return AppTheme.success
            case .error: return AppTheme.danger
            case .info: return AppTheme.info
            case .warning: return AppTheme.warning
            }
        }
        
        var icon: String {
            switch self {
            case .success: return "checkmark.circle.fill"
            case .error: return "xmark.circle.fill"
            case .info: return "info.circle.fill"
            case .warning: return "exclamationmark.triangle.fill"
            }
        }
    }
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: type.icon)
                .font(.system(size: 20))
                .foregroundColor(type.color)
            
            Text(message)
                .font(AppTheme.Typography.subheadline)
                .foregroundColor(.primary)
            
            Spacer()
        }
        .padding()
        .background(AppTheme.secondaryBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Layout.cornerRadius))
        .shadow(
            color: AppTheme.Shadows.elevation3.color,
            radius: AppTheme.Shadows.elevation3.radius,
            y: AppTheme.Shadows.elevation3.y
        )
        .padding(.horizontal)
    }
}

// MARK: - Empty State

struct EmptyStateView: View {
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
            Image(systemName: icon)
                .font(.system(size: 60))
                .foregroundColor(AppTheme.mutedText)
            
            VStack(spacing: 8) {
                Text(title)
                    .font(AppTheme.Typography.title2)
                    .foregroundColor(.primary)
                
                Text(message)
                    .font(AppTheme.Typography.body)
                    .foregroundColor(AppTheme.mutedText)
                    .multilineTextAlignment(.center)
            }
            
            if let actionTitle = actionTitle, let action = action {
                Button(action: action) {
                    Text(actionTitle)
                        .font(AppTheme.Typography.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 12)
                        .background(AppTheme.brandPrimary)
                        .clipShape(Capsule())
                }
            }
        }
        .padding()
    }
}

// MARK: - Divider with Text

struct DividerWithText: View {
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Rectangle()
                .fill(AppTheme.separator)
                .frame(height: 1)
            
            Text(text)
                .font(AppTheme.Typography.caption)
                .foregroundColor(AppTheme.mutedText)
            
            Rectangle()
                .fill(AppTheme.separator)
                .frame(height: 1)
        }
    }
}

