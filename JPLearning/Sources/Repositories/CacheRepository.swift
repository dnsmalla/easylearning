//
//  CacheRepository.swift
//  JLearn
//
//  Advanced caching system with TTL, size limits, and eviction policies
//  Implements LRU (Least Recently Used) cache eviction
//

import Foundation

// MARK: - Cache Repository

/// Advanced cache repository with TTL and size management
final class CacheRepository: CacheRepositoryProtocol {
    
    // MARK: - Singleton
    
    static let shared = CacheRepository()
    
    // MARK: - Properties
    
    private let fileManager: FileManager
    private let cacheDirectory: URL
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder
    private let cacheMetadata: CacheMetadata
    
    /// Maximum cache size in bytes (50 MB default)
    private let maxCacheSize: Int64 = 50 * 1024 * 1024
    
    /// Default TTL (Time To Live) in seconds (7 days)
    private let defaultTTL: TimeInterval = 7 * 24 * 60 * 60
    
    // MARK: - Initialization
    
    private init() {
        self.fileManager = .default
        
        // Get cache directory
        let cacheDir = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        self.cacheDirectory = cacheDir.appendingPathComponent("JLearnCache", isDirectory: true)
        
        // Create cache directory if needed
        try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
        
        // Configure JSON coders
        self.encoder = JSONEncoder()
        self.encoder.dateEncodingStrategy = .iso8601
        
        self.decoder = JSONDecoder()
        self.decoder.dateDecodingStrategy = .iso8601
        
        // Load metadata
        self.cacheMetadata = CacheMetadata.load() ?? CacheMetadata()
        
        // Perform cleanup on init
        Task {
            await cleanupExpiredCache()
            await enforceCacheSizeLimit()
        }
        
        AppLogger.info("CacheRepository initialized")
    }
    
    // MARK: - Public Methods
    
    func save<T: Codable>(_ data: T, forKey key: String) throws {
        let cacheKey = sanitizeKey(key)
        let fileURL = cacheDirectory.appendingPathComponent(cacheKey)
        
        do {
            let encodedData = try encoder.encode(data)
            try encodedData.write(to: fileURL)
            
            // Update metadata
            let entry = CacheEntry(
                key: cacheKey,
                createdAt: Date(),
                lastAccessedAt: Date(),
                size: Int64(encodedData.count),
                ttl: defaultTTL
            )
            cacheMetadata.addEntry(entry)
            cacheMetadata.save()
            
            AppLogger.debug("Saved to cache: \(cacheKey)")
            
            // Check cache size
            Task {
                await enforceCacheSizeLimit()
            }
        } catch {
            AppLogger.error("Failed to save to cache: \(error)")
            throw RepositoryError.cacheError(error)
        }
    }
    
    func load<T: Codable>(forKey key: String, as type: T.Type) throws -> T? {
        let cacheKey = sanitizeKey(key)
        let fileURL = cacheDirectory.appendingPathComponent(cacheKey)
        
        // Check if file exists
        guard fileManager.fileExists(atPath: fileURL.path) else {
            AppLogger.debug("Cache miss: \(cacheKey)")
            return nil
        }
        
        // Check TTL
        if let entry = cacheMetadata.getEntry(forKey: cacheKey) {
            if entry.isExpired() {
                AppLogger.debug("Cache expired: \(cacheKey)")
                try? remove(forKey: key)
                return nil
            }
            
            // Update last accessed time
            cacheMetadata.updateLastAccessed(forKey: cacheKey)
            cacheMetadata.save()
        }
        
        do {
            let data = try Data(contentsOf: fileURL)
            let decoded = try decoder.decode(T.self, from: data)
            
            AppLogger.debug("Cache hit: \(cacheKey)")
            return decoded
        } catch {
            AppLogger.error("Failed to load from cache: \(error)")
            
            // Remove corrupted cache entry
            try? remove(forKey: key)
            throw RepositoryError.decodingError(error)
        }
    }
    
    func remove(forKey key: String) throws {
        let cacheKey = sanitizeKey(key)
        let fileURL = cacheDirectory.appendingPathComponent(cacheKey)
        
        try? fileManager.removeItem(at: fileURL)
        cacheMetadata.removeEntry(forKey: cacheKey)
        cacheMetadata.save()
        
        AppLogger.debug("Removed from cache: \(cacheKey)")
    }
    
    func clearAll() throws {
        // Remove all files in cache directory
        let contents = try? fileManager.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: nil)
        contents?.forEach { try? fileManager.removeItem(at: $0) }
        
        // Clear metadata
        cacheMetadata.clear()
        cacheMetadata.save()
        
        AppLogger.info("Cache cleared")
    }
    
    func exists(forKey key: String) -> Bool {
        let cacheKey = sanitizeKey(key)
        let fileURL = cacheDirectory.appendingPathComponent(cacheKey)
        return fileManager.fileExists(atPath: fileURL.path)
    }
    
    func getCacheAge(forKey key: String) -> TimeInterval? {
        let cacheKey = sanitizeKey(key)
        guard let entry = cacheMetadata.getEntry(forKey: cacheKey) else {
            return nil
        }
        return Date().timeIntervalSince(entry.createdAt)
    }
    
    // MARK: - Private Methods
    
    /// Sanitize cache key to be filesystem-safe
    private func sanitizeKey(_ key: String) -> String {
        // Replace invalid characters with underscore
        let invalidCharacters = CharacterSet(charactersIn: "/\\:*?\"<>|")
        return key.components(separatedBy: invalidCharacters).joined(separator: "_")
    }
    
    /// Remove expired cache entries
    private func cleanupExpiredCache() async {
        let expiredKeys = cacheMetadata.getExpiredKeys()
        
        for key in expiredKeys {
            try? remove(forKey: key)
        }
        
        if !expiredKeys.isEmpty {
            AppLogger.info("Cleaned up \(expiredKeys.count) expired cache entries")
        }
    }
    
    /// Enforce cache size limit using LRU eviction
    private func enforceCacheSizeLimit() async {
        var totalSize = cacheMetadata.getTotalSize()
        
        guard totalSize > maxCacheSize else { return }
        
        // Get entries sorted by last accessed (LRU)
        let entries = cacheMetadata.getEntriesSortedByLRU()
        var removedCount = 0
        
        for entry in entries {
            if totalSize <= maxCacheSize * 80 / 100 { // Keep at 80% of max
                break
            }
            
            try? remove(forKey: entry.key)
            totalSize -= entry.size
            removedCount += 1
        }
        
        if removedCount > 0 {
            AppLogger.info("Evicted \(removedCount) cache entries (LRU policy)")
        }
    }
    
    /// Get current cache size
    func getCacheSize() -> Int64 {
        return cacheMetadata.getTotalSize()
    }
    
    /// Get cache statistics
    func getCacheStatistics() -> CacheStatistics {
        return CacheStatistics(
            totalEntries: cacheMetadata.entries.count,
            totalSize: cacheMetadata.getTotalSize(),
            maxSize: maxCacheSize,
            oldestEntry: cacheMetadata.getOldestEntry()?.createdAt,
            newestEntry: cacheMetadata.getNewestEntry()?.createdAt
        )
    }
}

// MARK: - Cache Entry

/// Represents a cached item's metadata
private struct CacheEntry: Codable {
    let key: String
    let createdAt: Date
    var lastAccessedAt: Date
    let size: Int64
    let ttl: TimeInterval
    
    func isExpired() -> Bool {
        return Date().timeIntervalSince(createdAt) > ttl
    }
}

// MARK: - Cache Metadata

/// Manages cache metadata (entries, sizes, access times)
private class CacheMetadata: Codable {
    var entries: [String: CacheEntry] = [:]
    
    private static let metadataKey = "cache_metadata"
    
    func addEntry(_ entry: CacheEntry) {
        entries[entry.key] = entry
    }
    
    func getEntry(forKey key: String) -> CacheEntry? {
        return entries[key]
    }
    
    func removeEntry(forKey key: String) {
        entries.removeValue(forKey: key)
    }
    
    func updateLastAccessed(forKey key: String) {
        entries[key]?.lastAccessedAt = Date()
    }
    
    func getTotalSize() -> Int64 {
        return entries.values.reduce(0) { $0 + $1.size }
    }
    
    func getExpiredKeys() -> [String] {
        return entries.values.filter { $0.isExpired() }.map { $0.key }
    }
    
    func getEntriesSortedByLRU() -> [CacheEntry] {
        return entries.values.sorted { $0.lastAccessedAt < $1.lastAccessedAt }
    }
    
    func getOldestEntry() -> CacheEntry? {
        return entries.values.min { $0.createdAt < $1.createdAt }
    }
    
    func getNewestEntry() -> CacheEntry? {
        return entries.values.max { $0.createdAt < $1.createdAt }
    }
    
    func clear() {
        entries.removeAll()
    }
    
    // MARK: - Persistence
    
    func save() {
        if let data = try? JSONEncoder().encode(self) {
            UserDefaults.standard.set(data, forKey: Self.metadataKey)
        }
    }
    
    static func load() -> CacheMetadata? {
        guard let data = UserDefaults.standard.data(forKey: metadataKey),
              let metadata = try? JSONDecoder().decode(CacheMetadata.self, from: data) else {
            return nil
        }
        return metadata
    }
}

// MARK: - Cache Statistics

/// Cache statistics for monitoring
struct CacheStatistics {
    let totalEntries: Int
    let totalSize: Int64
    let maxSize: Int64
    let oldestEntry: Date?
    let newestEntry: Date?
    
    var usagePercentage: Double {
        return Double(totalSize) / Double(maxSize) * 100
    }
    
    var formattedSize: String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        return formatter.string(fromByteCount: totalSize)
    }
    
    var formattedMaxSize: String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        return formatter.string(fromByteCount: maxSize)
    }
}

