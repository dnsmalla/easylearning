//
//  RetryManager.swift
//  JLearn
//
//  Automatic retry mechanism for failed operations
//

import Foundation

struct RetryManager {
    
    /// Retry an async operation with exponential backoff
    static func retry<T>(
        maxAttempts: Int = 3,
        initialDelay: TimeInterval = 1.0,
        multiplier: Double = 2.0,
        operation: @escaping () async throws -> T
    ) async throws -> T {
        var currentAttempt = 0
        var currentDelay = initialDelay
        
        while currentAttempt < maxAttempts {
            do {
                return try await operation()
            } catch {
                currentAttempt += 1
                
                if currentAttempt >= maxAttempts {
                    throw error
                }
                
                AppLogger.warning("Attempt \(currentAttempt) failed, retrying in \(currentDelay)s...")
                
                try await Task.sleep(nanoseconds: UInt64(currentDelay * 1_000_000_000))
                currentDelay *= multiplier
            }
        }
        
        // This should never be reached due to the while loop logic
        // But we throw an error instead of crashing in production
        throw NSError(domain: "RetryManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Retry operation failed after \(maxAttempts) attempts"])
    }
    
    /// Retry a sync operation
    static func retry<T>(
        maxAttempts: Int = 3,
        initialDelay: TimeInterval = 1.0,
        multiplier: Double = 2.0,
        operation: @escaping () throws -> T
    ) throws -> T {
        var currentAttempt = 0
        var currentDelay = initialDelay
        
        while currentAttempt < maxAttempts {
            do {
                return try operation()
            } catch {
                currentAttempt += 1
                
                if currentAttempt >= maxAttempts {
                    throw error
                }
                
                AppLogger.warning("Attempt \(currentAttempt) failed, retrying in \(currentDelay)s...")
                
                Thread.sleep(forTimeInterval: currentDelay)
                currentDelay *= multiplier
            }
        }
        
        // This should never be reached due to the while loop logic
        // But we throw the last error instead of crashing in production
        throw NSError(domain: "RetryManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Retry operation failed after \(maxAttempts) attempts"])
    }
}

