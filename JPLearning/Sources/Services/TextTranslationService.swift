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
    private var lastRequestTime: Date?
    private let minimumRequestInterval: TimeInterval = 1.0 // 1 second between requests
    
    private init() {}
    
    /// Translate Japanese text into the selected target language.
    /// - Parameters:
    ///   - text: Source text (assumed Japanese for this app).
    ///   - target: Target language.
    func translate(text: String, to target: TranslationLanguage) async throws -> String {
        guard !text.isEmpty else { return text }
        
        // Rate limiting: ensure minimum time between requests
        if let lastTime = lastRequestTime {
            let timeSinceLastRequest = Date().timeIntervalSince(lastTime)
            if timeSinceLastRequest < minimumRequestInterval {
                let waitTime = minimumRequestInterval - timeSinceLastRequest
                AppLogger.info("Rate limiting: waiting \(waitTime) seconds before next request")
                try? await Task.sleep(nanoseconds: UInt64(waitTime * 1_000_000_000))
            }
        }
        
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
        
        var responseData: Data?
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            responseData = data // Store for error logging
            lastRequestTime = Date() // Update last request time
            
            // Log response for debugging
            if let httpResponse = response as? HTTPURLResponse {
                AppLogger.info("Translation response status: \(httpResponse.statusCode)")
                
            // Handle rate limiting
            if httpResponse.statusCode == 429 {
                AppLogger.error("Translation API rate limit exceeded (429)")
                throw AppError.network(
                    "Translation service limit reached. Please wait a moment and try again."
                )
            }
                
                // Handle other HTTP errors
                if httpResponse.statusCode >= 400 {
                    AppLogger.error("Translation API error: HTTP \(httpResponse.statusCode)")
                    throw AppError.network("Translation service unavailable (HTTP \(httpResponse.statusCode))")
                }
            }
            
            let decoder = JSONDecoder()
            let apiResponse = try decoder.decode(MyMemoryResponse.self, from: data)
            
            AppLogger.info("Translation successful: \(apiResponse.responseData.translatedText)")
            return apiResponse.responseData.translatedText
        } catch let error as AppError {
            // Re-throw AppError as-is
            throw error
        } catch let error as DecodingError {
            AppLogger.error("Translation decoding failed: \(error)")
            // Log raw response for debugging
            if let data = responseData, let responseString = String(data: data, encoding: .utf8) {
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



