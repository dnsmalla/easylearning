//
//  AppLogger.swift
//  JLearn
//
//  Centralized logging utility
//

import Foundation
import os.log

struct AppLogger {
    
    private static let subsystem = Bundle.main.bundleIdentifier ?? "com.company.jlearn"
    
    private static let logger = Logger(subsystem: subsystem, category: "General")
    
    // MARK: - General Logging
    
    static func log(_ message: String, level: OSLogType = .default) {
        logger.log(level: level, "\(message)")
    }
    
    static func debug(_ message: String) {
        #if DEBUG
        logger.debug("\(message)")
        #endif
    }
    
    static func info(_ message: String) {
        logger.info("\(message)")
    }
    
    static func warning(_ message: String) {
        logger.warning("\(message)")
    }
    
    static func error(_ message: String, error: Error? = nil) {
        if let error = error {
            logger.error("\(message): \(error.localizedDescription)")
        } else {
            logger.error("\(message)")
        }
    }
    
    // MARK: - Performance Logging
    
    static func measurePerformance<T>(
        _ operation: String,
        block: () throws -> T
    ) rethrows -> T {
        let startTime = CFAbsoluteTimeGetCurrent()
        let result = try block()
        let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
        info("\(operation) took \(String(format: "%.3f", timeElapsed))s")
        return result
    }
    
    static func measurePerformanceAsync<T>(
        _ operation: String,
        block: () async throws -> T
    ) async rethrows -> T {
        let startTime = CFAbsoluteTimeGetCurrent()
        let result = try await block()
        let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
        info("\(operation) took \(String(format: "%.3f", timeElapsed))s")
        return result
    }
}

