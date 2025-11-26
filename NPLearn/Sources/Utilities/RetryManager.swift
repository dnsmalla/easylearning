//
//  RetryManager.swift
//  NPLearn
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
        
        fatalError("Should not reach here")
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
        
        fatalError("Should not reach here")
    }
}

