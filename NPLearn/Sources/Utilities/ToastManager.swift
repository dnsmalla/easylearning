//
//  ToastManager.swift
//  NPLearn
//
//  Professional toast notification system
//  Non-intrusive user feedback for actions and errors
//

import SwiftUI
import Combine

// MARK: - Toast Manager

/// Manages toast notifications throughout the app
@MainActor
final class ToastManager: ObservableObject {
    
    // MARK: - Singleton
    
    static let shared = ToastManager()
    
    // MARK: - Properties
    
    @Published var currentToast: Toast?
    
    private var toastQueue: [Toast] = []
    private var isShowingToast = false
    
    // MARK: - Initialization
    
    private init() {}
    
    // MARK: - Public Methods
    
    /// Show a toast notification
    func show(_ toast: Toast) {
        toastQueue.append(toast)
        showNextToastIfNeeded()
    }
    
    /// Show a success toast
    func showSuccess(_ message: String, duration: TimeInterval = 3.0) {
        show(Toast(message: message, type: .success, duration: duration))
    }
    
    /// Show an error toast
    func showError(_ message: String, duration: TimeInterval = 4.0) {
        show(Toast(message: message, type: .error, duration: duration))
    }
    
    /// Show a warning toast
    func showWarning(_ message: String, duration: TimeInterval = 3.5) {
        show(Toast(message: message, type: .warning, duration: duration))
    }
    
    /// Show an info toast
    func showInfo(_ message: String, duration: TimeInterval = 3.0) {
        show(Toast(message: message, type: .info, duration: duration))
    }
    
    /// Dismiss current toast
    func dismiss() {
        withAnimation(.spring()) {
            currentToast = nil
        }
        isShowingToast = false
        showNextToastIfNeeded()
    }
    
    // MARK: - Private Methods
    
    private func showNextToastIfNeeded() {
        guard !isShowingToast, !toastQueue.isEmpty else { return }
        
        isShowingToast = true
        let toast = toastQueue.removeFirst()
        
        withAnimation(.spring()) {
            currentToast = toast
        }
        
        Haptics.notification(toast.type.hapticType)
        
        // Auto-dismiss after duration
        Task {
            try? await Task.sleep(nanoseconds: UInt64(toast.duration * 1_000_000_000))
            dismiss()
        }
    }
}

// MARK: - Toast Model

/// Toast notification model
struct Toast: Identifiable, Equatable {
    let id = UUID()
    let message: String
    let type: ToastType
    let duration: TimeInterval
    let action: ToastAction?
    
    init(
        message: String,
        type: ToastType = .info,
        duration: TimeInterval = 3.0,
        action: ToastAction? = nil
    ) {
        self.message = message
        self.type = type
        self.duration = duration
        self.action = action
    }
    
    static func == (lhs: Toast, rhs: Toast) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Toast Type

enum ToastType {
    case success
    case error
    case warning
    case info
    
    var icon: String {
        switch self {
        case .success: return "checkmark.circle.fill"
        case .error: return "xmark.circle.fill"
        case .warning: return "exclamationmark.triangle.fill"
        case .info: return "info.circle.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .success: return .green
        case .error: return .red
        case .warning: return .orange
        case .info: return .blue
        }
    }
    
    var hapticType: UINotificationFeedbackGenerator.FeedbackType {
        switch self {
        case .success: return .success
        case .error: return .error
        case .warning: return .warning
        case .info: return .success
        }
    }
}

// MARK: - Toast Action

struct ToastAction {
    let title: String
    let action: () -> Void
}

// MARK: - Toast View

struct ToastView: View {
    let toast: Toast
    let onDismiss: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: toast.type.icon)
                .font(.system(size: 20))
                .foregroundColor(toast.type.color)
            
            Text(toast.message)
                .font(AppTheme.Typography.body)
                .foregroundColor(.primary)
                .fixedSize(horizontal: false, vertical: true)
            
            Spacer()
            
            if let action = toast.action {
                Button(action: {
                    action.action()
                    onDismiss()
                }) {
                    Text(action.title)
                        .font(AppTheme.Typography.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(toast.type.color)
                }
            }
            
            Button(action: onDismiss) {
                Image(systemName: "xmark")
                    .font(.system(size: 14))
                    .foregroundColor(AppTheme.mutedText)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(AppTheme.background)
                .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
        )
        .padding(.horizontal)
        .transition(.move(edge: .top).combined(with: .opacity))
        .accessibilityElement(children: .combine)
        .accessibilityLabel(toast.message)
        .accessibilityAddTraits(.isButton)
    }
}

// MARK: - Toast Modifier

struct ToastModifier: ViewModifier {
    @ObservedObject var toastManager: ToastManager
    
    func body(content: Content) -> some View {
        ZStack {
            content
            
            VStack {
                if let toast = toastManager.currentToast {
                    ToastView(toast: toast) {
                        toastManager.dismiss()
                    }
                    .padding(.top, 8)
                    .animation(.spring(), value: toastManager.currentToast)
                }
                
                Spacer()
            }
        }
    }
}

extension View {
    /// Add toast notification support
    func toast() -> some View {
        self.modifier(ToastModifier(toastManager: .shared))
    }
}

