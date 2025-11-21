//
//  InputValidator.swift
//  NPLearn
//
//  Input validation utilities
//

import Foundation

struct InputValidator {
    
    // MARK: - Email Validation
    
    static func isValidEmail(_ email: String) -> Bool {
        let emailRegex = #"^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$"#
        let emailPredicate = NSPredicate(format: "SELF MATCHES[c] %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    // MARK: - Password Validation
    
    static func isValidPassword(_ password: String) -> (isValid: Bool, message: String) {
        guard password.count >= 6 else {
            return (false, "Password must be at least 6 characters")
        }
        
        return (true, "Valid password")
    }
    
    // MARK: - Display Name Validation
    
    static func isValidDisplayName(_ name: String) -> (isValid: Bool, message: String) {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedName.isEmpty else {
            return (false, "Display name cannot be empty")
        }
        
        guard trimmedName.count >= 2 else {
            return (false, "Display name must be at least 2 characters")
        }
        
        guard trimmedName.count <= 50 else {
            return (false, "Display name must be less than 50 characters")
        }
        
        return (true, "Valid display name")
    }
    
    // MARK: - String Validation
    
    static func isNotEmpty(_ string: String) -> Bool {
        return !string.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    static func hasMinLength(_ string: String, minLength: Int) -> Bool {
        return string.count >= minLength
    }
    
    static func hasMaxLength(_ string: String, maxLength: Int) -> Bool {
        return string.count <= maxLength
    }
    
    // MARK: - Japanese Text Validation
    
    static func containsJapaneseScript(_ text: String) -> Bool {
        // Hiragana: U+3040-U+309F, Katakana: U+30A0-U+30FF, Kanji: U+4E00-U+9FFF
        let japaneseRegex = #"[\u3040-\u309F\u30A0-\u30FF\u4E00-\u9FFF]+"#
        let japaneseTest = NSPredicate(format: "SELF MATCHES %@", japaneseRegex)
        return japaneseTest.evaluate(with: text)
    }
}

