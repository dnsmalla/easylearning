//
//  TranslatorService.swift
//  JLearn
//
//  Kanji to Furigana translation service using Jisho API
//

import Foundation

// MARK: - Translator Service

@MainActor
final class TranslatorService: ObservableObject {
    
    static let shared = TranslatorService()
    
    private let apiURL = "https://jisho.org/api/v1/search/words"
    private let cacheKeyPrefix = "translation_cache_"
    private var cache: [String: String] = [:]
    
    @Published var isTranslating = false
    
    nonisolated private init() {}
    
    func initialize() async {
        // Load cache from UserDefaults
        if let savedCache = UserDefaults.standard.dictionary(forKey: "translation_cache") as? [String: String] {
            await MainActor.run {
                self.cache = savedCache
            }
        }
    }
    
    // MARK: - Translation
    
    func translateToFurigana(_ text: String) async throws -> String {
        isTranslating = true
        defer { isTranslating = false }
        
        // Check cache first
        if let cached = getCachedTranslation(text) {
            return cached
        }
        
        // Check internet connection
        let hasInternet = await NetworkMonitor.hasInternetConnection()
        if !hasInternet {
            throw TranslationError.noInternet
        }
        
        // Split text into words
        let words = text.components(separatedBy: " ")
        var result = ""
        
        for word in words {
            let translation = try await translateWord(word)
            result += translation + " "
        }
        
        let finalResult = result.trimmingCharacters(in: .whitespaces)
        cacheTranslation(text, translation: finalResult)
        
        return finalResult
    }
    
    private func translateWord(_ word: String) async throws -> String {
        guard let encodedWord = word.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "\(apiURL)?keyword=\(encodedWord)") else {
            return word
        }
        
        let request = URLRequest(url: url, timeoutInterval: 10)
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw TranslationError.invalidResponse
            }
            
            guard httpResponse.statusCode == 200 else {
                throw TranslationError.serverError(httpResponse.statusCode)
            }
            
            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
            
            guard let dataArray = json?["data"] as? [[String: Any]],
                  !dataArray.isEmpty,
                  let japanese = dataArray[0]["japanese"] as? [[String: Any]],
                  !japanese.isEmpty else {
                return word
            }
            
            let firstEntry = japanese[0]
            
            if let kanjiWord = firstEntry["word"] as? String,
               let reading = firstEntry["reading"] as? String {
                // Return in ruby format for display
                return "<ruby>\(kanjiWord)<rt>\(reading)</rt></ruby>"
            } else if let reading = firstEntry["reading"] as? String {
                return reading
            }
            
            return word
        } catch let error as TranslationError {
            throw error
        } catch {
            throw TranslationError.connectionError(error.localizedDescription)
        }
    }
    
    // MARK: - Batch Translation
    
    func translateBatch(_ texts: [String]) async throws -> [String: String] {
        var results: [String: String] = [:]
        
        for text in texts {
            do {
                let translation = try await translateToFurigana(text)
                results[text] = translation
            } catch {
                results[text] = text // Return original on error
            }
        }
        
        return results
    }
    
    // MARK: - Cache Management
    
    private func getCachedTranslation(_ text: String) -> String? {
        return cache[text]
    }
    
    private func cacheTranslation(_ text: String, translation: String) {
        cache[text] = translation
        saveCache()
    }
    
    private func saveCache() {
        UserDefaults.standard.set(cache, forKey: "translation_cache")
    }
    
    func clearCache() {
        cache.removeAll()
        UserDefaults.standard.removeObject(forKey: "translation_cache")
    }
    
    // MARK: - Ruby Text Parser
    
    /// Parse ruby text format into attributed string components
    func parseRubyText(_ rubyText: String) -> [(word: String, reading: String?)] {
        var results: [(word: String, reading: String?)] = []
        let pattern = "<ruby>(.*?)<rt>(.*?)</rt></ruby>"
        
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
            return [(rubyText, nil)]
        }
        
        let nsString = rubyText as NSString
        let matches = regex.matches(in: rubyText, options: [], range: NSRange(location: 0, length: nsString.length))
        
        var lastEnd = 0
        
        for match in matches {
            // Add text before this match
            if match.range.location > lastEnd {
                let range = NSRange(location: lastEnd, length: match.range.location - lastEnd)
                let text = nsString.substring(with: range)
                if !text.isEmpty {
                    results.append((text, nil))
                }
            }
            
            // Add the ruby text
            if match.numberOfRanges >= 3 {
                let wordRange = match.range(at: 1)
                let readingRange = match.range(at: 2)
                
                let word = nsString.substring(with: wordRange)
                let reading = nsString.substring(with: readingRange)
                
                results.append((word, reading))
            }
            
            lastEnd = match.range.location + match.range.length
        }
        
        // Add remaining text
        if lastEnd < nsString.length {
            let range = NSRange(location: lastEnd, length: nsString.length - lastEnd)
            let text = nsString.substring(with: range)
            if !text.isEmpty {
                results.append((text, nil))
            }
        }
        
        return results.isEmpty ? [(rubyText, nil)] : results
    }
}

// MARK: - Offline Dictionary Service

@MainActor
final class OfflineDictionaryService: ObservableObject {
    
    static let shared = OfflineDictionaryService()
    
    private var dictionary: [String: DictionaryEntry] = [:]
    
    @Published var isLoaded = false
    
    nonisolated private init() {}
    
    struct DictionaryEntry: Codable {
        var word: String
        var reading: String
        var meaning: String
        var level: String?
    }
    
    func initialize() async {
        // Load dictionary from local JSON file
        guard let url = Bundle.main.url(forResource: "dictionary", withExtension: "json") else {
            print("Dictionary file not found")
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            let entries = try JSONDecoder().decode([DictionaryEntry].self, from: data)
            
            for entry in entries {
                dictionary[entry.word] = entry
            }
            
            isLoaded = true
            print("Loaded \(dictionary.count) dictionary entries")
        } catch {
            print("Failed to load dictionary: \(error)")
        }
    }
    
    func lookup(_ word: String) -> DictionaryEntry? {
        return dictionary[word]
    }
    
    func search(_ query: String) -> [DictionaryEntry] {
        let lowercaseQuery = query.lowercased()
        return dictionary.values.filter { entry in
            entry.word.lowercased().contains(lowercaseQuery) ||
            entry.reading.lowercased().contains(lowercaseQuery) ||
            entry.meaning.lowercased().contains(lowercaseQuery)
        }.sorted { $0.word < $1.word }
    }
}

