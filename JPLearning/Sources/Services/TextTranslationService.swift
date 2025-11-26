//
//  TextTranslationService.swift
//  JLearn
//
//  Text translation service using free alternative API.
//  Apple's Translation framework requires UI interaction, so we use
//  a reliable free API for programmatic translation.
//

import Foundation

/// Supported target languages for text translation in the Web Search view.
enum TranslationLanguage: String, CaseIterable, Identifiable {
    case english
    case spanish
    case chineseSimplified
    case korean
    case french
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .english: return "English"
        case .spanish: return "Spanish"
        case .chineseSimplified: return "Chinese (Simplified)"
        case .korean: return "Korean"
        case .french: return "French"
        }
    }
    
    /// Language code for LibreTranslate API
    var code: String {
        switch self {
        case .english: return "en"
        case .spanish: return "es"
        case .chineseSimplified: return "zh"
        case .korean: return "ko"
        case .french: return "fr"
        }
    }
}

// MARK: - Text Translation Service

@MainActor
final class TextTranslationService: ObservableObject {
    
    static let shared = TextTranslationService()
    
    @Published var isAvailable = true
    
    // Using MyMemory API (free, reliable, no API key required)
    private let baseURL = "https://api.mymemory.translated.net/get"
    
    private init() {}
    
    /// Translate Japanese text into the selected target language using MyMemory API (free service).
    /// This is a free, reliable translation API with good availability.
    /// - Parameters:
    ///   - text: Source text (assumed Japanese for this app).
    ///   - target: Target language.
    func translate(text: String, to target: TranslationLanguage) async throws -> String {
        guard !text.isEmpty else { return text }
        
        // Build URL with query parameters
        var components = URLComponents(string: baseURL)
        components?.queryItems = [
            URLQueryItem(name: "q", value: text),
            URLQueryItem(name: "langpair", value: "ja|\(target.code)")
        ]
        
        guard let url = components?.url else {
            AppLogger.error("Invalid translation URL")
            throw AppError.network("Invalid translation URL")
        }
        
        do {
            AppLogger.info("Translating text to \(target.displayName)...")
            
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                AppLogger.error("Invalid HTTP response")
                throw AppError.network("Invalid response from translation service")
            }
            
            AppLogger.info("Received response with status code: \(httpResponse.statusCode)")
            
            guard (200...299).contains(httpResponse.statusCode) else {
                AppLogger.error("HTTP error: \(httpResponse.statusCode)")
                throw AppError.network("Translation service returned error (code: \(httpResponse.statusCode))")
            }
            
            // Parse JSON response
            guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let responseData = json["responseData"] as? [String: Any],
                  let translatedText = responseData["translatedText"] as? String else {
                AppLogger.error("Failed to parse translation response")
                throw AppError.network("Could not parse translation response")
            }
            
            AppLogger.info("Translation completed successfully")
            return translatedText
            
        } catch let error as AppError {
            // Re-throw AppError as-is
            throw error
        } catch {
            // Wrap other errors
            AppLogger.error("Translation network error: \(error.localizedDescription)")
            
            if let urlError = error as? URLError {
                switch urlError.code {
                case .notConnectedToInternet, .networkConnectionLost:
                    throw AppError.translationError(.noInternet)
                case .timedOut:
                    throw AppError.translationError(.timeout)
                default:
                    throw AppError.translationError(.networkError("Network error: \(urlError.localizedDescription)"))
                }
            }
            
            throw AppError.translationError(.networkError(error.localizedDescription))
        }
    }
}



