//
//  AppError.swift
//  NPLearn
//
//  Centralized error handling
//

import Foundation

// MARK: - App Error

enum AppError: LocalizedError {
    case network(String)
    case authentication(String)
    case validation(String)
    case notFound(String)
    case notAuthenticated
    case timeout
    case unknown(String)
    case firebaseError(String)
    case translationError(TranslationError)
    case rateLimitExceeded(String)
    
    var errorDescription: String? {
        switch self {
        case .network(let message):
            return "Network Error: \(message)"
        case .authentication(let message):
            return "Authentication Error: \(message)"
        case .validation(let message):
            return "Validation Error: \(message)"
        case .notFound(let message):
            return "Not Found: \(message)"
        case .notAuthenticated:
            return "Not Authenticated"
        case .timeout:
            return "Request Timeout"
        case .unknown(let message):
            return "Error: \(message)"
        case .firebaseError(let message):
            return "Firebase Error: \(message)"
        case .translationError(let error):
            return error.localizedDescription
        case .rateLimitExceeded(let message):
            return "Rate Limit Exceeded: \(message)"
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .network:
            return "Please check your internet connection and try again."
        case .authentication:
            return "Please try signing in again."
        case .validation:
            return "Please check your input and try again."
        case .notFound:
            return "The requested item could not be found."
        case .notAuthenticated:
            return "Please sign in to continue."
        case .timeout:
            return "The request took too long. Please try again or check your connection."
        case .unknown:
            return "An unexpected error occurred. Please try again."
        case .firebaseError:
            return "There was a problem connecting to the server. Please try again."
        case .translationError(.noInternet):
            return "Please check your internet connection or try offline mode."
        case .translationError(.timeout):
            return "The request took too long. Please try again."
        case .rateLimitExceeded:
            return "Too many requests. Please wait a moment before trying again."
        default:
            return "Please try again later."
        }
    }
}

// MARK: - Error Handler

@MainActor
final class ErrorHandler: ObservableObject {
    
    static let shared = ErrorHandler()
    
    @Published var currentError: AppError?
    @Published var showError: Bool = false
    
    private init() {}
    
    func handle(_ error: Error) {
        if let appError = error as? AppError {
            currentError = appError
        } else if let translationError = error as? TranslationError {
            currentError = .translationError(translationError)
        } else {
            currentError = .unknown(error.localizedDescription)
        }
        showError = true
    }
    
    func handle(_ error: AppError) {
        currentError = error
        showError = true
    }
    
    func clearError() {
        currentError = nil
        showError = false
    }
}

// MARK: - Result Extension

extension Result where Failure == Error {
    
    var value: Success? {
        switch self {
        case .success(let value):
            return value
        case .failure:
            return nil
        }
    }
    
    var error: Error? {
        switch self {
        case .success:
            return nil
        case .failure(let error):
            return error
        }
    }
}

