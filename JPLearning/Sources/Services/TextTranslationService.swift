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
    case english = "en"
    case spanish = "es"
    case chineseSimplified = "zh"
    case korean = "ko"
    case french = "fr"
    case german = "de"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .english: return "English"
        case .spanish: return "Spanish"
        case .chineseSimplified: return "Chinese (Simplified)"
        case .korean: return "Korean"
        case .french: return "French"
        case .german: return "German"
        }
    }
    
    /// Language code used by the MyMemory API.
    var code: String {
        return rawValue
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
            AppLogger.error("Translation failed: Invalid URL")
            throw AppError.network("Invalid translation URL")
        }
        
        AppLogger.info("Translation request: \(url.absoluteString)")
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            // Log response for debugging
            if let httpResponse = response as? HTTPURLResponse {
                AppLogger.info("Translation response status: \(httpResponse.statusCode)")
            }
            
            let decoder = JSONDecoder()
            let apiResponse = try decoder.decode(MyMemoryResponse.self, from: data)
            
            AppLogger.info("Translation successful: \(apiResponse.responseData.translatedText)")
            return apiResponse.responseData.translatedText
        } catch let error as DecodingError {
            AppLogger.error("Translation decoding failed: \(error)")
            // Log raw response for debugging
            if let responseString = String(data: try! await URLSession.shared.data(from: url).0, encoding: .utf8) {
                AppLogger.error("Raw response: \(responseString)")
            }
            throw AppError.network("Translation response decode failed: \(error.localizedDescription)")
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



