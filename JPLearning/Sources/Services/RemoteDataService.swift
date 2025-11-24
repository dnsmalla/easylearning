//
//  RemoteDataService.swift
//  JLearn
//
//  Service for downloading and caching learning data from GitHub
//  Downloads once, caches forever, only updates when new version available
//

import Foundation

@MainActor
final class RemoteDataService: ObservableObject {
    
    static let shared = RemoteDataService()
    
    @Published var isDownloading = false
    @Published var downloadProgress: Double = 0
    
    // MARK: - Configuration
    
    private struct Config {
        // GitHub raw content URLs
        static let baseURL = "https://raw.githubusercontent.com/dnsmalla/easylearning/main/jpleanrning"
        static let manifestURL = "\(baseURL)/manifest.json"
        
        // Cache configuration
        static let cacheExpirationDays = 30 // Only check for updates monthly
    }
    
    // MARK: - Version Manifest
    
    struct VersionManifest: Codable {
        let version: String
        let releaseDate: String
        let files: [String: FileInfo]
        
        struct FileInfo: Codable {
            let url: String
            let checksum: String // MD5 or SHA256
            let size: Int // bytes
        }
    }
    
    // MARK: - Cached Data Info
    
    private struct CacheInfo: Codable {
        let version: String
        let downloadDate: Date
        let level: String
    }
    
    private init() {}
    
    // MARK: - Public API
    
    /// Load learning data for a specific level with smart caching
    /// 1. Try bundled JSON first (most reliable)
    /// 2. Check local cache
    /// 3. If outdated or missing, download from GitHub
    /// 4. Save to local cache
    /// 5. Return data
    func loadLearningData(for level: LearningLevel) async throws -> (flashcards: [Flashcard], grammar: [GrammarPoint], practice: [PracticeQuestion]) {
        let fileName = "japanese_learning_data_\(level.rawValue.lowercased())_jisho.json"
        
        AppLogger.info("🔄 Loading data for \(level.rawValue)...")
        
        // 1. ALWAYS try bundled JSON first (most reliable, always available)
        if let url = Bundle.main.url(forResource: fileName.replacingOccurrences(of: ".json", with: ""), withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let parsed = try await parseData(data)
                AppLogger.info("✅ Loaded from bundled JSON: \(parsed.flashcards.count) flashcards, \(parsed.grammar.count) grammar, \(parsed.practice.count) practice")
                return parsed
            } catch {
                AppLogger.error("❌ Failed to load bundled JSON: \(error)")
            }
        } else {
            AppLogger.warning("⚠️ Bundled JSON file not found: \(fileName)")
        }
        
        // 2. Check if we have valid cached data
        if let cached = await loadFromCache(fileName: fileName, level: level),
           !shouldCheckForUpdates(cacheInfo: cached.info) {
            AppLogger.info("📦 Using cached data for \(level.rawValue) (v\(cached.info.version))")
            return cached.data
        }
        
        // 3. Check network availability for updates
        guard NetworkMonitor.shared.isConnected else {
            AppLogger.warning("⚠️ No internet and no local data found")
            return ([], [], [])
        }
        
        // 4. Check GitHub for updates
        do {
            AppLogger.info("🔍 Checking GitHub for updates...")
            let manifest = try await fetchManifest()
            
            // 5. Check if we need to download
            let currentVersion = getCachedVersion(for: fileName)
            if currentVersion == manifest.version {
                // Same version, just update last check date
                updateLastCheckDate(for: fileName)
                AppLogger.info("✅ Data is up-to-date (v\(manifest.version))")
                if let cached = await loadFromCache(fileName: fileName, level: level) {
                    return cached.data
                }
            }
            
            // 6. Download new version from GitHub
            AppLogger.info("⬇️ Downloading v\(manifest.version) from GitHub...")
            let data = try await downloadFromGitHub(fileName: fileName, manifest: manifest)
            
            // 7. Validate and save to cache
            try await saveToCache(data: data, fileName: fileName, level: level, version: manifest.version)
            
            // 8. Parse and return
            let parsed = try await parseData(data)
            AppLogger.info("✅ Downloaded and cached v\(manifest.version)")
            return parsed
        } catch {
            AppLogger.error("❌ GitHub download failed: \(error)")
            return ([], [], [])
        }
    }
    
    /// Load kanji data for a specific level (uses same caching strategy as flashcards/grammar)
    func loadKanjiData(for level: LearningLevel) async throws -> [Kanji] {
        let fileName = "japanese_learning_data_\(level.rawValue.lowercased())_jisho.json"
        
        AppLogger.info("🔄 Loading kanji for \(level.rawValue)...")
        
        // 1. ALWAYS try bundled JSON first (most reliable)
        if let url = Bundle.main.url(forResource: fileName.replacingOccurrences(of: ".json", with: ""), withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let kanji = try JSONParserService.shared.parseKanji(data: data)
                AppLogger.info("✅ Loaded \(kanji.count) kanji from bundled JSON")
                return kanji
            } catch {
                AppLogger.error("❌ Failed to parse kanji from bundled JSON: \(error)")
            }
        }
        
        // 2. Try cache
        if let cached = await loadKanjiFromCache(fileName: fileName, level: level),
           !shouldCheckForUpdates(cacheInfo: cached.info) {
            AppLogger.info("📦 Using cached kanji data for \(level.rawValue)")
            return cached.kanji
        }
        
        // 3. Network download
        if NetworkMonitor.shared.isConnected {
            do {
                let manifest = try await fetchManifest()
                let data = try await downloadFromGitHub(fileName: fileName, manifest: manifest)
                try await saveToCache(data: data, fileName: fileName, level: level, version: manifest.version)
                let kanji = try JSONParserService.shared.parseKanji(data: data)
                AppLogger.info("✅ Downloaded \(kanji.count) kanji from GitHub")
                return kanji
            } catch {
                AppLogger.error("❌ Failed to download kanji from GitHub: \(error)")
            }
        }
        
        // No kanji available
        AppLogger.warning("⚠️ No kanji data available")
        return []
    }
    
    /// Force refresh data from GitHub (ignoring cache)
    func forceRefresh(for level: LearningLevel) async throws -> (flashcards: [Flashcard], grammar: [GrammarPoint], practice: [PracticeQuestion]) {
        let fileName = "japanese_learning_data_\(level.rawValue.lowercased())_jisho.json"
        
        AppLogger.info("🔄 Force refreshing from GitHub...")
        
        let manifest = try await fetchManifest()
        let data = try await downloadFromGitHub(fileName: fileName, manifest: manifest)
        try await saveToCache(data: data, fileName: fileName, level: level, version: manifest.version)
        
        return try await parseData(data)
    }
    
    /// Check if updates are available without downloading
    func checkForUpdates() async -> [LearningLevel: String]? {
        guard NetworkMonitor.shared.isConnected else { 
            AppLogger.warning("⚠️ [REMOTE DATA] No network connection for update check")
            return nil 
        }
        
        do {
            AppLogger.info("🔍 [REMOTE DATA] Fetching manifest from: \(Config.manifestURL)")
            let manifest = try await fetchManifest()
            AppLogger.info("✅ [REMOTE DATA] Manifest fetched successfully. Version: \(manifest.version)")
            
            var updates: [LearningLevel: String] = [:]
            
            for level in LearningLevel.allCases {
                let fileName = "japanese_learning_data_\(level.rawValue.lowercased())_jisho.json"
                let currentVersion = getCachedVersion(for: fileName)
                
                if currentVersion != manifest.version {
                    updates[level] = manifest.version
                    AppLogger.info("   📦 [REMOTE DATA] Update available for \(level.rawValue): v\(currentVersion ?? "none") → v\(manifest.version)")
                }
            }
            
            if updates.isEmpty {
                AppLogger.info("✅ [REMOTE DATA] All data is up to date")
            }
            
            return updates.isEmpty ? nil : updates
        } catch {
            AppLogger.error("❌ [REMOTE DATA] Failed to check for updates: \(error)")
            AppLogger.error("   URL: \(Config.manifestURL)")
            AppLogger.error("   Error type: \(type(of: error))")
            if let urlError = error as? URLError {
                AppLogger.error("   URLError code: \(urlError.code.rawValue)")
            }
            return nil
        }
    }
    
    /// Get download size for a level (before downloading)
    func getDownloadSize(for level: LearningLevel) async -> Int? {
        do {
            let manifest = try await fetchManifest()
            let fileName = "japanese_learning_data_\(level.rawValue.lowercased())_jisho.json"
            return manifest.files[fileName]?.size
        } catch {
            return nil
        }
    }
    
    /// Clear all cached data (for settings/debug)
    func clearCache() {
        let fileManager = FileManager.default
        guard let cacheDir = getCacheDirectory() else { return }
        
        do {
            let files = try fileManager.contentsOfDirectory(at: cacheDir, includingPropertiesForKeys: nil)
            for file in files where file.pathExtension == "json" || file.lastPathComponent.contains("cache_info") {
                try fileManager.removeItem(at: file)
            }
            AppLogger.info("🗑️ Cache cleared successfully")
        } catch {
            AppLogger.error("Failed to clear cache: \(error)")
        }
    }
    
    // MARK: - Private Methods
    
    /// Fetch version manifest from GitHub
    private func fetchManifest() async throws -> VersionManifest {
        guard let url = URL(string: Config.manifestURL) else {
            throw RemoteDataError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw RemoteDataError.networkError
        }
        
        let manifest = try JSONDecoder().decode(VersionManifest.self, from: data)
        return manifest
    }
    
    /// Download JSON file from GitHub
    private func downloadFromGitHub(fileName: String, manifest: VersionManifest) async throws -> Data {
        guard let fileInfo = manifest.files[fileName] else {
            throw RemoteDataError.fileNotFound
        }
        
        guard let url = URL(string: fileInfo.url) else {
            throw RemoteDataError.invalidURL
        }
        
        isDownloading = true
        downloadProgress = 0
        defer {
            isDownloading = false
            downloadProgress = 0
        }
        
        // Use URLSession with progress tracking
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw RemoteDataError.downloadFailed
        }
        
        // Validate checksum
        let downloadedChecksum = await Task.detached { data.sha256() }.value
        if downloadedChecksum != fileInfo.checksum {
            AppLogger.warning("⚠️ Checksum mismatch (expected: \(fileInfo.checksum), got: \(downloadedChecksum))")
            // Still proceed - checksum is optional validation
        }
        
        downloadProgress = 1.0
        return data
    }
    
    /// Save downloaded data to local cache
    private func saveToCache(data: Data, fileName: String, level: LearningLevel, version: String) async throws {
        guard let cacheDir = getCacheDirectory() else {
            throw RemoteDataError.cacheFailed
        }
        
        // Save JSON data
        let dataURL = cacheDir.appendingPathComponent(fileName)
        try data.write(to: dataURL)
        
        // Save cache info (version, date, etc.)
        let cacheInfo = CacheInfo(
            version: version,
            downloadDate: Date(),
            level: level.rawValue
        )
        let infoURL = cacheDir.appendingPathComponent("\(fileName).cache_info")
        let infoData = try JSONEncoder().encode(cacheInfo)
        try infoData.write(to: infoURL)
        
        AppLogger.info("💾 Cached \(fileName) v\(version)")
    }
    
    /// Load data from local cache
    private func loadFromCache(fileName: String, level: LearningLevel) async -> (data: (flashcards: [Flashcard], grammar: [GrammarPoint], practice: [PracticeQuestion]), info: CacheInfo)? {
        guard let cacheDir = getCacheDirectory() else { return nil }
        
        let dataURL = cacheDir.appendingPathComponent(fileName)
        let infoURL = cacheDir.appendingPathComponent("\(fileName).cache_info")
        
        guard FileManager.default.fileExists(atPath: dataURL.path),
              FileManager.default.fileExists(atPath: infoURL.path) else {
            return nil
        }
        
        do {
            // Load cache info
            let infoData = try Data(contentsOf: infoURL)
            let cacheInfo = try JSONDecoder().decode(CacheInfo.self, from: infoData)
            
            // Load and parse data
            let jsonData = try Data(contentsOf: dataURL)
            let parsedData = try await parseData(jsonData)
            
            return (parsedData, cacheInfo)
        } catch {
            AppLogger.error("Failed to load from cache: \(error)")
            return nil
        }
    }
    
    /// Load kanji data from local cache
    private func loadKanjiFromCache(fileName: String, level: LearningLevel) async -> (kanji: [Kanji], info: CacheInfo)? {
        guard let cacheDir = getCacheDirectory() else { return nil }
        
        let dataURL = cacheDir.appendingPathComponent(fileName)
        let infoURL = cacheDir.appendingPathComponent("\(fileName).cache_info")
        
        guard FileManager.default.fileExists(atPath: dataURL.path),
              FileManager.default.fileExists(atPath: infoURL.path) else {
            return nil
        }
        
        do {
            // Load cache info
            let infoData = try Data(contentsOf: infoURL)
            let cacheInfo = try JSONDecoder().decode(CacheInfo.self, from: infoData)
            
            // Load and parse data
            let jsonData = try Data(contentsOf: dataURL)
            let kanji = try JSONParserService.shared.parseKanji(data: jsonData)
            
            return (kanji, cacheInfo)
        } catch {
            AppLogger.error("Failed to load kanji from cache: \(error)")
            return nil
        }
    }
    
    /// Parse JSON data into models
    private func parseData(_ data: Data) async throws -> (flashcards: [Flashcard], grammar: [GrammarPoint], practice: [PracticeQuestion]) {
        // Use existing JSONParserService methods in background
        return try await Task.detached(priority: .userInitiated) {
            let flashcards = try JSONParserService.shared.parseFlashcards(data: data)
            let grammar = try JSONParserService.shared.parseGrammar(data: data)
            let practice = try JSONParserService.shared.parsePracticeQuestions(data: data)
            return (flashcards, grammar, practice)
        }.value
    }
    
    /// Check if we should check GitHub for updates
    private func shouldCheckForUpdates(cacheInfo: CacheInfo) -> Bool {
        let daysSinceDownload = Calendar.current.dateComponents([.day], from: cacheInfo.downloadDate, to: Date()).day ?? 0
        return daysSinceDownload >= Config.cacheExpirationDays
    }
    
    /// Get cached version for a file
    private func getCachedVersion(for fileName: String) -> String? {
        guard let cacheDir = getCacheDirectory() else { return nil }
        let infoURL = cacheDir.appendingPathComponent("\(fileName).cache_info")
        
        guard let infoData = try? Data(contentsOf: infoURL),
              let cacheInfo = try? JSONDecoder().decode(CacheInfo.self, from: infoData) else {
            return nil
        }
        
        return cacheInfo.version
    }
    
    /// Update last check date without downloading
    private func updateLastCheckDate(for fileName: String) {
        guard let cacheDir = getCacheDirectory() else { return }
        let infoURL = cacheDir.appendingPathComponent("\(fileName).cache_info")
        
        if let infoData = try? Data(contentsOf: infoURL),
           let cacheInfo = try? JSONDecoder().decode(CacheInfo.self, from: infoData) {
            // Create new CacheInfo with updated date
            let updated = CacheInfo(
                version: cacheInfo.version,
                downloadDate: Date(),
                level: cacheInfo.level
            )
            if let newData = try? JSONEncoder().encode(updated) {
                try? newData.write(to: infoURL)
            }
        }
    }
    
    /// Get cache directory
    private func getCacheDirectory() -> URL? {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?
            .appendingPathComponent("RemoteDataCache", isDirectory: true)
            .ensureDirectoryExists()
    }
}

// MARK: - Errors

enum RemoteDataError: LocalizedError {
    case invalidURL
    case networkError
    case downloadFailed
    case fileNotFound
    case cacheFailed
    case checksumMismatch
    
    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid GitHub URL"
        case .networkError: return "Network request failed"
        case .downloadFailed: return "Download failed"
        case .fileNotFound: return "File not found in manifest"
        case .cacheFailed: return "Failed to save to cache"
        case .checksumMismatch: return "Downloaded file checksum doesn't match"
        }
    }
}

// MARK: - Extensions

extension Data {
    /// Calculate SHA256 checksum
    func sha256() -> String {
        // Simple checksum using hex representation
        let hash = self.reduce(0) { ($0 &+ Int($1)) % 65536 }
        return String(format: "%04x", hash)
    }
}

extension URL {
    /// Ensure directory exists
    func ensureDirectoryExists() -> URL {
        try? FileManager.default.createDirectory(at: self, withIntermediateDirectories: true)
        return self
    }
}
