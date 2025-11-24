//
//  DataSources.swift
//  JLearn
//
//  Data source implementations for loading learning content
//  Implements strategy pattern for different data sources
//

import Foundation

// MARK: - Bundled Data Source

/// Loads data from bundled JSON files
final class BundledDataSource: DataSourceProtocol {
    
    var priority: Int { return 100 } // Highest priority - always available
    var sourceName: String { return "Bundle" }
    
    private let parsingService: ParsingServiceProtocol
    
    init(parsingService: ParsingServiceProtocol = JSONParserService.shared) {
        self.parsingService = parsingService
    }
    
    func loadData(for level: LearningLevel) async throws -> LearningData {
        let filename = "japanese_learning_data_\(level.rawValue.lowercased())_jisho"
        
        guard let url = Bundle.main.url(forResource: filename, withExtension: "json") else {
            throw DataSourceError.fileNotFound(filename: filename)
        }
        
        let data = try Data(contentsOf: url)
        let parsed = try parsingService.parseAllData(data: data)
        
        AppLogger.info("📦 Loaded from bundle: \(parsed.flashcards.count) flashcards")
        
        return LearningData(
            flashcards: parsed.flashcards,
            grammar: parsed.grammar,
            kanji: parsed.kanji,
            practice: parsed.practice,
            games: parsed.games,
            level: level
        )
    }
    
    func hasData(for level: LearningLevel) async -> Bool {
        let filename = "japanese_learning_data_\(level.rawValue.lowercased())_jisho"
        return Bundle.main.url(forResource: filename, withExtension: "json") != nil
    }
}

// MARK: - Cached Data Source

/// Loads data from local cache
final class CachedDataSource: DataSourceProtocol {
    
    var priority: Int { return 80 } // Second priority
    var sourceName: String { return "Cache" }
    
    private let parsingService: ParsingServiceProtocol
    private let cacheDirectory: URL?
    private let cacheExpirationDays: Int
    
    init(
        parsingService: ParsingServiceProtocol = JSONParserService.shared,
        cacheExpirationDays: Int = Environment.config.cacheExpirationDays
    ) {
        self.parsingService = parsingService
        self.cacheExpirationDays = cacheExpirationDays
        self.cacheDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?
            .appendingPathComponent("RemoteDataCache", isDirectory: true)
        
        // Create cache directory if needed
        if let cacheDir = cacheDirectory {
            try? FileManager.default.createDirectory(at: cacheDir, withIntermediateDirectories: true)
        }
    }
    
    func loadData(for level: LearningLevel) async throws -> LearningData {
        guard let cacheDir = cacheDirectory else {
            throw DataSourceError.cacheUnavailable
        }
        
        let filename = "japanese_learning_data_\(level.rawValue.lowercased())_jisho.json"
        let dataURL = cacheDir.appendingPathComponent(filename)
        let infoURL = cacheDir.appendingPathComponent("\(filename).cache_info")
        
        // Check if cache exists
        guard FileManager.default.fileExists(atPath: dataURL.path) else {
            throw DataSourceError.fileNotFound(filename: filename)
        }
        
        // Check cache expiration
        if let cacheInfo = try? loadCacheInfo(from: infoURL) {
            if isCacheExpired(cacheInfo) {
                throw DataSourceError.cacheExpired
            }
        }
        
        // Load and parse data
        let data = try Data(contentsOf: dataURL)
        let parsed = try parsingService.parseAllData(data: data)
        
        AppLogger.info("📦 Loaded from cache: \(parsed.flashcards.count) flashcards")
        
        return LearningData(
            flashcards: parsed.flashcards,
            grammar: parsed.grammar,
            kanji: parsed.kanji,
            practice: parsed.practice,
            games: parsed.games,
            level: level
        )
    }
    
    func hasData(for level: LearningLevel) async -> Bool {
        guard let cacheDir = cacheDirectory else { return false }
        let filename = "japanese_learning_data_\(level.rawValue.lowercased())_jisho.json"
        let dataURL = cacheDir.appendingPathComponent(filename)
        return FileManager.default.fileExists(atPath: dataURL.path)
    }
    
    // MARK: - Cache Management
    
    func saveData(_ data: Data, for level: LearningLevel, version: String) throws {
        guard let cacheDir = cacheDirectory else {
            throw DataSourceError.cacheUnavailable
        }
        
        let filename = "japanese_learning_data_\(level.rawValue.lowercased())_jisho.json"
        let dataURL = cacheDir.appendingPathComponent(filename)
        let infoURL = cacheDir.appendingPathComponent("\(filename).cache_info")
        
        // Save data
        try data.write(to: dataURL)
        
        // Save cache info
        let cacheInfo = CacheInfo(version: version, downloadDate: Date(), level: level.rawValue)
        let infoData = try JSONEncoder().encode(cacheInfo)
        try infoData.write(to: infoURL)
        
        AppLogger.info("💾 Cached data for \(level.rawValue)")
    }
    
    func clearCache() throws {
        guard let cacheDir = cacheDirectory else { return }
        let files = try FileManager.default.contentsOfDirectory(at: cacheDir, includingPropertiesForKeys: nil)
        for file in files {
            try FileManager.default.removeItem(at: file)
        }
        AppLogger.info("🗑️ Cache cleared")
    }
    
    // MARK: - Private Methods
    
    private struct CacheInfo: Codable {
        let version: String
        let downloadDate: Date
        let level: String
    }
    
    private func loadCacheInfo(from url: URL) throws -> CacheInfo {
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode(CacheInfo.self, from: data)
    }
    
    private func isCacheExpired(_ cacheInfo: CacheInfo) -> Bool {
        let calendar = Calendar.current
        let daysSince = calendar.dateComponents([.day], from: cacheInfo.downloadDate, to: Date()).day ?? 0
        return daysSince >= cacheExpirationDays
    }
}

// MARK: - Remote Data Source

/// Downloads data from GitHub
final class RemoteDataSource: DataSourceProtocol {
    
    var priority: Int { return 50 } // Lowest priority
    var sourceName: String { return "Remote (GitHub)" }
    
    private let parsingService: ParsingServiceProtocol
    private let manifestURL: String
    private let baseURL: String
    
    init(
        parsingService: ParsingServiceProtocol = JSONParserService.shared,
        manifestURL: String = Environment.config.githubManifestURL,
        baseURL: String = Environment.config.githubDataBaseURL
    ) {
        self.parsingService = parsingService
        self.manifestURL = manifestURL
        self.baseURL = baseURL
    }
    
    func loadData(for level: LearningLevel) async throws -> LearningData {
        // Fetch manifest to get file info
        let manifest = try await fetchManifest()
        
        let filename = "japanese_learning_data_\(level.rawValue.lowercased())_jisho.json"
        guard let fileInfo = manifest.files[filename] else {
            throw DataSourceError.fileNotFound(filename: filename)
        }
        
        // Download file
        guard let url = URL(string: fileInfo.url) else {
            throw DataSourceError.invalidURL(urlString: fileInfo.url)
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw DataSourceError.downloadFailed
        }
        
        // Parse data
        let parsed = try parsingService.parseAllData(data: data)
        
        AppLogger.info("⬇️ Downloaded from GitHub: \(parsed.flashcards.count) flashcards")
        
        return LearningData(
            flashcards: parsed.flashcards,
            grammar: parsed.grammar,
            kanji: parsed.kanji,
            practice: parsed.practice,
            games: parsed.games,
            level: level
        )
    }
    
    func hasData(for level: LearningLevel) async -> Bool {
        // Check network connectivity
        return await NetworkMonitor.hasInternetConnection()
    }
    
    // MARK: - Private Methods
    
    private struct VersionManifest: Codable {
        let version: String
        let releaseDate: String
        let files: [String: FileInfo]
        
        struct FileInfo: Codable {
            let url: String
            let checksum: String
            let size: Int
        }
    }
    
    private func fetchManifest() async throws -> VersionManifest {
        guard let url = URL(string: manifestURL) else {
            throw DataSourceError.invalidURL(urlString: manifestURL)
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw DataSourceError.downloadFailed
        }
        
        return try JSONDecoder().decode(VersionManifest.self, from: data)
    }
}

// MARK: - Data Source Coordinator

/// Coordinates multiple data sources with fallback logic
final class DataSourceCoordinator {
    
    private let sources: [DataSourceProtocol]
    
    init(sources: [DataSourceProtocol]) {
        // Sort by priority (highest first)
        self.sources = sources.sorted { $0.priority > $1.priority }
    }
    
    /// Load data using fallback strategy
    func loadData(for level: LearningLevel) async throws -> LearningData {
        for source in sources {
            // Check if source has data
            guard await source.hasData(for: level) else {
                AppLogger.debug("⏭️ Skipping \(source.sourceName) - data not available")
                continue
            }
            
            do {
                let data = try await source.loadData(for: level)
                AppLogger.info("✅ Loaded data from \(source.sourceName)")
                return data
            } catch {
                AppLogger.warning("⚠️ Failed to load from \(source.sourceName): \(error)")
                // Continue to next source
                continue
            }
        }
        
        // No sources succeeded
        throw DataSourceError.allSourcesFailed
    }
}

// MARK: - Data Source Error

enum DataSourceError: LocalizedError {
    case fileNotFound(filename: String)
    case cacheUnavailable
    case cacheExpired
    case invalidURL(urlString: String)
    case downloadFailed
    case allSourcesFailed
    
    var errorDescription: String? {
        switch self {
        case .fileNotFound(let filename):
            return "File not found: \(filename)"
        case .cacheUnavailable:
            return "Cache is not available"
        case .cacheExpired:
            return "Cached data has expired"
        case .invalidURL(let urlString):
            return "Invalid URL: \(urlString)"
        case .downloadFailed:
            return "Download failed"
        case .allSourcesFailed:
            return "Failed to load data from all sources"
        }
    }
}


