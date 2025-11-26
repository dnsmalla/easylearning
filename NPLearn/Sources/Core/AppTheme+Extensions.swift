//
//  AppTheme+Extensions.swift
//  NPLearn
//
//  Theme extensions and utility methods
//

import SwiftUI

// MARK: - View Extensions

extension View {
  func primaryButtonStyle() -> some View {
    self
      .font(AppTheme.Typography.button)
      .foregroundColor(.white)
      .frame(height: AppTheme.Controls.buttonHeight)
      .frame(maxWidth: .infinity)
      .background(AppTheme.brandPrimary)
      .clipShape(RoundedRectangle(cornerRadius: AppTheme.Layout.cornerRadius))
  }
  
  func secondaryButtonStyle() -> some View {
    self
      .font(AppTheme.Typography.button)
      .foregroundColor(AppTheme.brandPrimary)
      .frame(height: AppTheme.Controls.buttonHeight)
      .frame(maxWidth: .infinity)
      .background(AppTheme.brandPrimary.opacity(0.1))
      .clipShape(RoundedRectangle(cornerRadius: AppTheme.Layout.cornerRadius))
  }
  
  func outlineButtonStyle() -> some View {
    self
      .font(AppTheme.Typography.button)
      .foregroundColor(AppTheme.brandPrimary)
      .frame(height: AppTheme.Controls.buttonHeight)
      .frame(maxWidth: .infinity)
      .background(AppTheme.background)
      .clipShape(RoundedRectangle(cornerRadius: AppTheme.Layout.cornerRadius))
      .overlay(
        RoundedRectangle(cornerRadius: AppTheme.Layout.cornerRadius)
          .stroke(AppTheme.brandPrimary, lineWidth: 2)
      )
  }
}

// MARK: - Loading Overlay

extension View {
  func loadingOverlay(_ isLoading: Bool) -> some View {
    overlay {
      if isLoading {
        ZStack {
          Color.black.opacity(0.3)
            .ignoresSafeArea()
          
          ProgressView()
            .scaleEffect(1.5)
            .tint(AppTheme.brandPrimary)
            .padding(32)
            .background(AppTheme.background)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Layout.cornerRadius))
        }
      }
    }
  }
}

// MARK: - Empty State View

struct EmptyStateView: View {
  let icon: String
  let title: String
  let message: String
  var actionTitle: String?
  var action: (() -> Void)?
  
  var body: some View {
    VStack(spacing: AppTheme.Layout.spacing) {
      Image(systemName: icon)
        .font(.system(size: 60))
        .foregroundColor(AppTheme.mutedText)
      
      Text(title)
        .font(AppTheme.Typography.title2)
        .foregroundColor(.primary)
      
      Text(message)
        .font(AppTheme.Typography.body)
        .foregroundColor(AppTheme.mutedText)
        .multilineTextAlignment(.center)
        .padding(.horizontal, 32)
      
      if let actionTitle = actionTitle, let action = action {
        Button(action: action) {
          Text(actionTitle)
        }
        .primaryButtonStyle()
        .padding(.horizontal, 48)
        .padding(.top, 8)
      }
    }
    .padding()
  }
}

// MARK: - Error View

struct ErrorView: View {
  let error: Error
  var retryAction: (() -> Void)?
  
  var body: some View {
    VStack(spacing: AppTheme.Layout.spacing) {
      Image(systemName: "exclamationmark.triangle.fill")
        .font(.system(size: 60))
        .foregroundColor(AppTheme.warning)
      
      Text("Oops!")
        .font(AppTheme.Typography.title2)
        .foregroundColor(.primary)
      
      Text(error.localizedDescription)
        .font(AppTheme.Typography.body)
        .foregroundColor(AppTheme.mutedText)
        .multilineTextAlignment(.center)
        .padding(.horizontal, 32)
      
      if let retryAction = retryAction {
        Button(action: retryAction) {
          Text("Try Again")
        }
        .primaryButtonStyle()
        .padding(.horizontal, 48)
        .padding(.top, 8)
      }
    }
    .padding()
  }
}

