//
//  TextTranslationService.swift
//  JLearn
//
//  Lightweight text translation service for Web Search.
//  Uses the free MyMemory API to translate short Japanese text
//  into the learner's preferred language.
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
    
    /// Language code used by the MyMemory API.
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
    
    private let baseURL = "https://api.mymemory.translated.net/get"
    
    private init() {}
    
    /// Translate Japanese text into the selected target language.
    /// - Parameters:
    ///   - text: Source text (assumed Japanese for this app).
    ///   - target: Target language.
    func translate(text: String, to target: TranslationLanguage) async throws -> String {
        guard !text.isEmpty else { return text }
        
        var components = URLComponents(string: baseURL)
        components?.queryItems = [
            URLQueryItem(name: "q", value: text),
            URLQueryItem(name: "langpair", value: "ja|\(target.code)")
        ]
        
        guard let url = components?.url else {
            throw AppError.network("Invalid translation URL")
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let response = try JSONDecoder().decode(MyMemoryResponse.self, from: data)
            return response.responseData.translatedText
        } catch {
            AppLogger.error("Translation failed for target \(target.displayName): \(error.localizedDescription)")
            throw AppError.network("Translation failed: \(error.localizedDescription)")
        }
    }
}

// MARK: - MyMemory Response

private struct MyMemoryResponse: Codable {
    struct ResponseData: Codable {
        let translatedText: String
    }
    
    let responseData: ResponseData
}



