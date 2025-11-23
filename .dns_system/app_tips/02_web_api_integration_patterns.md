# Web API Integration Patterns for iOS Apps

**Author:** DNS System  
**Date:** November 14, 2025  
**Version:** 1.0  
**Source:** VocAd App Implementation

---

## 📋 Overview

Complete guide for integrating multiple web APIs into iOS apps using modern Swift concurrency (async/await), including error handling, rate limiting, caching, and offline support.

### What This Covers
1. ✅ Modern Async/Await API Calls
2. ✅ Multi-Source Data Aggregation
3. ✅ Response Parsing & Mapping
4. ✅ Error Handling & Retry Logic
5. ✅ Rate Limiting & Throttling
6. ✅ Offline Caching Strategy
7. ✅ Progress Tracking for Long Operations

---

## 🏗️ Architecture Pattern

```
┌─────────────────────────────────────────────────────────┐
│              Multi-API Integration Layer                 │
├─────────────────────────────────────────────────────────┤
│                                                          │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐ │
│  │   API #1     │  │   API #2     │  │   API #3     │ │
│  │ (Dictionary) │  │  (Datamuse)  │  │(Translation) │ │
│  └──────────────┘  └──────────────┘  └──────────────┘ │
│         │                 │                  │          │
│         └─────────────────┴──────────────────┘          │
│                           │                             │
│                   ┌───────▼────────┐                    │
│                   │  API Manager   │                    │
│                   │  • Aggregation │                    │
│                   │  • Deduplication│                   │
│                   │  • Mapping     │                    │
│                   └───────┬────────┘                    │
│                           │                             │
│                   ┌───────▼────────┐                    │
│                   │ Cache Manager  │                    │
│                   │  • Memory      │                    │
│                   │  • Disk        │                    │
│                   │  • UserDefaults│                    │
│                   └───────┬────────┘                    │
│                           │                             │
│                   ┌───────▼────────┐                    │
│                   │  Data Manager  │                    │
│                   │  (Your App)    │                    │
│                   └────────────────┘                    │
└─────────────────────────────────────────────────────────┘
```

---

## 🎯 PART 1: API Service Manager

### Step 1: Create Base API Manager

```swift
// APIManager.swift
import Foundation

class APIManager {
    static let shared = APIManager()
    
    // Configuration
    private let session: URLSession
    private let timeout: TimeInterval = 30.0
    
    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = timeout
        config.timeoutIntervalForResource = timeout * 2
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        self.session = URLSession(configuration: config)
    }
    
    // MARK: - Generic API Call
    
    func fetch<T: Decodable>(
        url: URL,
        method: HTTPMethod = .get,
        headers: [String: String]? = nil,
        body: Data? = nil,
        responseType: T.Type
    ) async throws -> T {
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.httpBody = body
        
        // Add headers
        if let headers = headers {
            for (key, value) in headers {
                request.setValue(value, forHTTPHeaderField: key)
            }
        }
        
        // Default headers
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        // Make request
        let (data, response) = try await session.data(for: request)
        
        // Validate response
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        // Check status code
        guard (200...299).contains(httpResponse.statusCode) else {
            throw APIError.httpError(statusCode: httpResponse.statusCode)
        }
        
        // Decode response
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        do {
            let decoded = try decoder.decode(T.self, from: data)
            return decoded
        } catch {
            print("❌ Decoding error: \(error)")
            throw APIError.decodingError(error)
        }
    }
    
    // MARK: - Raw Data Fetch
    
    func fetchData(url: URL) async throws -> Data {
        let (data, response) = try await session.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw APIError.invalidResponse
        }
        
        return data
    }
}

// MARK: - Supporting Types

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
    case patch = "PATCH"
}

enum APIError: LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int)
    case decodingError(Error)
    case networkError(Error)
    case timeout
    case rateLimitExceeded
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid server response"
        case .httpError(let code):
            return "HTTP error: \(code)"
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .timeout:
            return "Request timed out"
        case .rateLimitExceeded:
            return "Rate limit exceeded. Please try again later."
        }
    }
}
```

---

### Step 2: Create Service-Specific Wrappers

```swift
// DictionaryAPIService.swift
import Foundation

struct DictionaryAPIService {
    private let apiManager = APIManager.shared
    private let baseURL = "https://api.dictionaryapi.dev/api/v2/entries/en"
    
    // MARK: - Fetch Word Definition
    
    func fetchDefinition(for word: String) async throws -> [DictionaryEntry] {
        let cleanWord = word.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let encodedWord = cleanWord.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "\(baseURL)/\(encodedWord)") else {
            throw APIError.invalidURL
        }
        
        print("🔍 Fetching definition for: \(word)")
        
        do {
            let entries = try await apiManager.fetch(
                url: url,
                responseType: [DictionaryEntry].self
            )
            print("✅ Found \(entries.count) definition(s)")
            return entries
        } catch {
            print("❌ Dictionary API error: \(error.localizedDescription)")
            throw error
        }
    }
}

// MARK: - Response Models

struct DictionaryEntry: Codable {
    let word: String
    let phonetics: [Phonetic]
    let meanings: [Meaning]
    let sourceUrls: [String]?
    
    struct Phonetic: Codable {
        let text: String?
        let audio: String?
    }
    
    struct Meaning: Codable {
        let partOfSpeech: String
        let definitions: [Definition]
        let synonyms: [String]?
        let antonyms: [String]?
    }
    
    struct Definition: Codable {
        let definition: String
        let example: String?
        let synonyms: [String]?
        let antonyms: [String]?
    }
}
```

```swift
// DatamuseAPIService.swift
import Foundation

struct DatamuseAPIService {
    private let apiManager = APIManager.shared
    private let baseURL = "https://api.datamuse.com/words"
    
    // MARK: - Find Related Words
    
    func findRelatedWords(
        to word: String,
        maxResults: Int = 50
    ) async throws -> [DatamuseWord] {
        
        guard let encodedWord = word.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "\(baseURL)?rel_trg=\(encodedWord)&max=\(maxResults)") else {
            throw APIError.invalidURL
        }
        
        print("🔗 Finding words related to: \(word)")
        
        let words = try await apiManager.fetch(
            url: url,
            responseType: [DatamuseWord].self
        )
        
        print("✅ Found \(words.count) related word(s)")
        return words
    }
    
    // MARK: - Find Rhyming Words
    
    func findRhymes(for word: String) async throws -> [DatamuseWord] {
        guard let encodedWord = word.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "\(baseURL)?rel_rhy=\(encodedWord)") else {
            throw APIError.invalidURL
        }
        
        return try await apiManager.fetch(
            url: url,
            responseType: [DatamuseWord].self
        )
    }
    
    // MARK: - Find Synonyms
    
    func findSynonyms(for word: String) async throws -> [DatamuseWord] {
        guard let encodedWord = word.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "\(baseURL)?rel_syn=\(encodedWord)") else {
            throw APIError.invalidURL
        }
        
        return try await apiManager.fetch(
            url: url,
            responseType: [DatamuseWord].self
        )
    }
}

// MARK: - Response Model

struct DatamuseWord: Codable {
    let word: String
    let score: Int
    let tags: [String]?
}
```

```swift
// TranslationAPIService.swift
import Foundation

struct TranslationAPIService {
    private let apiManager = APIManager.shared
    private let baseURL = "https://api.mymemory.translated.net/get"
    
    // MARK: - Translate Text
    
    func translate(
        text: String,
        from sourceLang: String = "en",
        to targetLang: String
    ) async throws -> String {
        
        guard let encodedText = text.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "\(baseURL)?q=\(encodedText)&langpair=\(sourceLang)|\(targetLang)") else {
            throw APIError.invalidURL
        }
        
        print("🌍 Translating: \(text) (\(sourceLang) → \(targetLang))")
        
        let response = try await apiManager.fetch(
            url: url,
            responseType: TranslationResponse.self
        )
        
        guard let translation = response.responseData.translatedText else {
            throw APIError.invalidResponse
        }
        
        print("✅ Translated: \(translation)")
        return translation
    }
}

// MARK: - Response Model

struct TranslationResponse: Codable {
    let responseData: ResponseData
    let responseStatus: Int
    
    struct ResponseData: Codable {
        let translatedText: String?
        let match: Double?
    }
}
```

---

## 🎯 PART 2: Multi-Source Aggregation

### Step 1: Create Aggregation Service

```swift
// MultiSourceDataAggregator.swift
import Foundation

class MultiSourceDataAggregator: ObservableObject {
    
    @Published var isLoading = false
    @Published var progress: Double = 0.0
    @Published var errorMessage: String?
    
    private let dictionaryAPI = DictionaryAPIService()
    private let datamuseAPI = DatamuseAPIService()
    private let translationAPI = TranslationAPIService()
    
    // MARK: - Aggregate Data from Multiple Sources
    
    func fetchCompleteData(
        for word: String,
        targetLanguage: String = "ja"
    ) async -> AggregatedWordData? {
        
        await MainActor.run {
            isLoading = true
            progress = 0.0
            errorMessage = nil
        }
        
        var data = AggregatedWordData(word: word)
        
        do {
            // 1. Fetch definition (30% progress)
            await updateProgress(0.1, "Fetching definition...")
            
            if let definition = try? await dictionaryAPI.fetchDefinition(for: word).first {
                data.definitions = definition.meanings.flatMap { $0.definitions.map { $0.definition } }
                data.examples = definition.meanings.flatMap { meaning in
                    meaning.definitions.compactMap { $0.example }
                }
                data.phonetics = definition.phonetics.compactMap { $0.text }
                data.audioURL = definition.phonetics.first?.audio
            }
            await updateProgress(0.3, "Definition fetched")
            
            // 2. Fetch related words (60% progress)
            await updateProgress(0.4, "Finding related words...")
            
            if let relatedWords = try? await datamuseAPI.findRelatedWords(to: word, maxResults: 10) {
                data.relatedWords = relatedWords.map { $0.word }
            }
            await updateProgress(0.6, "Related words found")
            
            // 3. Fetch translation (90% progress)
            await updateProgress(0.7, "Translating...")
            
            if let translation = try? await translationAPI.translate(
                text: word,
                from: "en",
                to: targetLanguage
            ) {
                data.translation = translation
            }
            await updateProgress(0.9, "Translation complete")
            
            // 4. Complete
            await updateProgress(1.0, "Complete!")
            
            await MainActor.run {
                isLoading = false
            }
            
            return data
            
        } catch {
            await MainActor.run {
                self.errorMessage = "Failed to fetch data: \(error.localizedDescription)"
                self.isLoading = false
            }
            return nil
        }
    }
    
    // MARK: - Batch Processing
    
    func fetchMultipleWords(
        _ words: [String],
        targetLanguage: String = "ja",
        progressCallback: @escaping (Double) -> Void
    ) async -> [AggregatedWordData] {
        
        var results: [AggregatedWordData] = []
        let totalWords = words.count
        
        for (index, word) in words.enumerated() {
            if let data = await fetchCompleteData(for: word, targetLanguage: targetLanguage) {
                results.append(data)
            }
            
            // Update overall progress
            let progress = Double(index + 1) / Double(totalWords)
            await MainActor.run {
                progressCallback(progress)
            }
            
            // Rate limiting: wait between requests
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        }
        
        return results
    }
    
    // MARK: - Helper
    
    private func updateProgress(_ value: Double, _ message: String) async {
        await MainActor.run {
            self.progress = value
            print("📊 Progress: \(Int(value * 100))% - \(message)")
        }
    }
}

// MARK: - Aggregated Data Model

struct AggregatedWordData {
    let word: String
    var definitions: [String] = []
    var examples: [String] = []
    var phonetics: [String] = []
    var audioURL: String?
    var relatedWords: [String] = []
    var translation: String?
    var synonyms: [String] = []
    var antonyms: [String] = []
    
    var isComplete: Bool {
        !definitions.isEmpty && translation != nil
    }
}
```

---

## 🎯 PART 3: Caching Strategy

### Step 1: Create Cache Manager

```swift
// APICacheManager.swift
import Foundation

class APICacheManager {
    static let shared = APICacheManager()
    
    private let memoryCache = NSCache<NSString, CachedData>()
    private let fileManager = FileManager.default
    private var cacheDirectory: URL?
    
    private init() {
        setupCacheDirectory()
        configureMemoryCache()
    }
    
    // MARK: - Setup
    
    private func setupCacheDirectory() {
        guard let cachesURL = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first else {
            return
        }
        
        cacheDirectory = cachesURL.appendingPathComponent("APICache", isDirectory: true)
        
        if let dir = cacheDirectory, !fileManager.fileExists(atPath: dir.path) {
            try? fileManager.createDirectory(at: dir, withIntermediateDirectories: true)
        }
    }
    
    private func configureMemoryCache() {
        memoryCache.countLimit = 100  // Max 100 items
        memoryCache.totalCostLimit = 50 * 1024 * 1024  // 50 MB
    }
    
    // MARK: - Cache Operations
    
    func cache<T: Codable>(
        _ data: T,
        forKey key: String,
        expiresIn seconds: TimeInterval = 3600  // 1 hour default
    ) {
        let cacheData = CachedData(
            data: data,
            expirationDate: Date().addingTimeInterval(seconds)
        )
        
        // Store in memory
        memoryCache.setObject(cacheData, forKey: key as NSString)
        
        // Store on disk
        saveToDisk(cacheData, forKey: key)
    }
    
    func retrieve<T: Codable>(forKey key: String, type: T.Type) -> T? {
        // Try memory first
        if let cached = memoryCache.object(forKey: key as NSString) {
            if cached.isValid {
                return cached.data as? T
            } else {
                // Expired, remove
                memoryCache.removeObject(forKey: key as NSString)
            }
        }
        
        // Try disk
        if let cached = loadFromDisk(forKey: key, type: type) {
            if cached.isValid {
                // Restore to memory
                memoryCache.setObject(cached, forKey: key as NSString)
                return cached.data as? T
            } else {
                // Expired, remove
                removeFromDisk(forKey: key)
            }
        }
        
        return nil
    }
    
    func clearCache() {
        memoryCache.removeAllObjects()
        
        guard let dir = cacheDirectory else { return }
        try? fileManager.removeItem(at: dir)
        setupCacheDirectory()
        
        print("🗑️ Cache cleared")
    }
    
    // MARK: - Disk Operations
    
    private func saveToDisk<T: Codable>(_ cachedData: CachedData, forKey key: String) {
        guard let dir = cacheDirectory else { return }
        
        let fileURL = dir.appendingPathComponent(key.md5)
        
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(cachedData)
            try data.write(to: fileURL)
        } catch {
            print("❌ Failed to save cache to disk: \(error)")
        }
    }
    
    private func loadFromDisk<T: Codable>(forKey key: String, type: T.Type) -> CachedData? {
        guard let dir = cacheDirectory else { return nil }
        
        let fileURL = dir.appendingPathComponent(key.md5)
        
        guard fileManager.fileExists(atPath: fileURL.path) else {
            return nil
        }
        
        do {
            let data = try Data(contentsOf: fileURL)
            let decoder = JSONDecoder()
            let cached = try decoder.decode(CachedData.self, from: data)
            return cached
        } catch {
            print("❌ Failed to load cache from disk: \(error)")
            return nil
        }
    }
    
    private func removeFromDisk(forKey key: String) {
        guard let dir = cacheDirectory else { return }
        
        let fileURL = dir.appendingPathComponent(key.md5)
        try? fileManager.removeItem(at: fileURL)
    }
}

// MARK: - Cached Data Model

class CachedData: NSObject, Codable {
    let data: Codable
    let expirationDate: Date
    
    init<T: Codable>(data: T, expirationDate: Date) {
        self.data = data
        self.expirationDate = expirationDate
    }
    
    var isValid: Bool {
        return Date() < expirationDate
    }
    
    // Codable conformance
    private enum CodingKeys: String, CodingKey {
        case data, expirationDate
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        // Note: You'll need to handle Codable type erasure here
        // This is a simplified version
        fatalError("Implement proper Codable decoding")
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(expirationDate, forKey: .expirationDate)
        // Note: You'll need to handle Codable type erasure here
    }
}

// MARK: - String MD5 Extension

extension String {
    var md5: String {
        // Simple hash for filenames
        return String(abs(self.hashValue))
    }
}
```

---

### Step 2: Use Cache in API Service

```swift
// Enhanced DictionaryAPIService with Caching
extension DictionaryAPIService {
    
    func fetchDefinition(for word: String, useCache: Bool = true) async throws -> [DictionaryEntry] {
        let cacheKey = "dictionary_\(word.lowercased())"
        
        // Try cache first
        if useCache, let cached = APICacheManager.shared.retrieve(
            forKey: cacheKey,
            type: [DictionaryEntry].self
        ) {
            print("✅ Using cached definition for: \(word)")
            return cached
        }
        
        // Fetch from API
        let entries = try await fetchDefinitionFromAPI(for: word)
        
        // Cache the result (1 week expiration)
        APICacheManager.shared.cache(entries, forKey: cacheKey, expiresIn: 604800)
        
        return entries
    }
    
    private func fetchDefinitionFromAPI(for word: String) async throws -> [DictionaryEntry] {
        // ... existing implementation ...
        return []
    }
}
```

---

## 🎯 PART 4: SwiftUI Integration

### Step 1: Create API Service View

```swift
// WebDataFetchView.swift
import SwiftUI

struct WebDataFetchView: View {
    @StateObject private var aggregator = MultiSourceDataAggregator()
    @State private var searchWord = ""
    @State private var fetchedData: AggregatedWordData?
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Search")) {
                    TextField("Enter word", text: $searchWord)
                    
                    Button(action: fetchData) {
                        if aggregator.isLoading {
                            HStack {
                                ProgressView()
                                Text("Loading...")
                            }
                        } else {
                            Text("Fetch Data")
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .disabled(searchWord.isEmpty || aggregator.isLoading)
                }
                
                if aggregator.isLoading {
                    Section {
                        ProgressView(value: aggregator.progress)
                            .progressViewStyle(.linear)
                        Text("Progress: \(Int(aggregator.progress * 100))%")
                            .font(.caption)
                    }
                }
                
                if let data = fetchedData {
                    Section(header: Text("Results")) {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Word: \(data.word)")
                                .font(.headline)
                            
                            if let translation = data.translation {
                                Text("Translation: \(translation)")
                                    .font(.subheadline)
                            }
                            
                            if !data.definitions.isEmpty {
                                Text("Definitions:")
                                    .font(.subheadline)
                                    .fontWeight(.bold)
                                ForEach(data.definitions, id: \.self) { def in
                                    Text("• \(def)")
                                        .font(.caption)
                                }
                            }
                            
                            if !data.relatedWords.isEmpty {
                                Text("Related: \(data.relatedWords.joined(separator: ", "))")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                
                if let error = aggregator.errorMessage {
                    Section {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
            }
            .navigationTitle("Web Data Fetch")
        }
    }
    
    private func fetchData() {
        Task {
            fetchedData = await aggregator.fetchCompleteData(
                for: searchWord,
                targetLanguage: "ja"
            )
        }
    }
}
```

---

## 🔑 Best Practices

### 1. **Error Handling**
```swift
// ✅ DO: Handle specific errors gracefully
do {
    let data = try await apiManager.fetch(url: url, responseType: MyType.self)
} catch APIError.rateLimitExceeded {
    // Show user-friendly message
    showAlert("Rate limit reached. Try again in a minute.")
} catch {
    // Generic error
    showAlert("Something went wrong. Please try again.")
}
```

### 2. **Rate Limiting**
```swift
// ✅ DO: Add delays between batch requests
for word in words {
    let data = await fetchData(for: word)
    results.append(data)
    try? await Task.sleep(nanoseconds: 500_000_000)  // 0.5s delay
}
```

### 3. **Caching Strategy**
```swift
// ✅ DO: Cache stable data with appropriate expiration
// - Definitions: 1 week (rarely change)
// - Translations: 1 day (may update)
// - Trending: 1 hour (frequently updated)

cache(definition, forKey: key, expiresIn: 604800)  // 1 week
cache(translation, forKey: key, expiresIn: 86400)  // 1 day
cache(trending, forKey: key, expiresIn: 3600)      // 1 hour
```

### 4. **Progress Tracking**
```swift
// ✅ DO: Update progress for better UX
await MainActor.run {
    self.progress = 0.5
    self.statusMessage = "Processing..."
}
```

---

## 📚 Quick Reference: Common APIs

| API | Base URL | Rate Limit | Cost | Use Case |
|-----|----------|------------|------|----------|
| Dictionary API | `api.dictionaryapi.dev` | Fair use | Free | Word definitions |
| Datamuse | `api.datamuse.com` | 100K/day | Free | Related words |
| MyMemory | `api.mymemory.translated.net` | 1K words/day | Free tier | Translation |
| OpenAI | `api.openai.com` | Token-based | Paid | AI generation |
| Google Translate | `translation.googleapis.com` | Usage-based | Paid | Translation |

---

## ✅ Implementation Checklist

- [ ] Create `APIManager` base class
- [ ] Implement service-specific wrappers
- [ ] Add error handling for all endpoints
- [ ] Implement multi-source aggregation
- [ ] Add progress tracking
- [ ] Create caching layer (memory + disk)
- [ ] Add rate limiting for batch operations
- [ ] Handle offline scenarios
- [ ] Add retry logic for failed requests
- [ ] Test with real API endpoints
- [ ] Monitor API usage/costs
- [ ] Add analytics for API performance

---

**Questions?** Refer to VocAd source code for complete working implementation.

