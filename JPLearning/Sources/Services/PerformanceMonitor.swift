//
//  PerformanceMonitor.swift
//  JLearn
//
//  Performance monitoring and optimization tools
//  Tracks app performance metrics, memory usage, and bottlenecks
//

import Foundation
import os.log
import SwiftUI

// MARK: - Performance Monitor

/// Monitors app performance and provides metrics
@MainActor
final class PerformanceMonitor: ObservableObject {
    
    // MARK: - Singleton
    
    static let shared = PerformanceMonitor()
    
    // MARK: - Properties
    
    @Published private(set) var metrics: PerformanceMetrics
    @Published private(set) var isMonitoring: Bool = false
    
    private var monitoringTimer: Timer?
    private let metricsQueue = DispatchQueue(label: "com.jlearn.performance", qos: .utility)
    
    // MARK: - Initialization
    
    private init() {
        self.metrics = PerformanceMetrics()
        
        #if DEBUG
        startMonitoring()
        #endif
    }
    
    // MARK: - Monitoring Control
    
    /// Start performance monitoring
    func startMonitoring() {
        guard !isMonitoring else { return }
        
        isMonitoring = true
        
        // Update metrics every 5 seconds
        monitoringTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                await self?.updateMetrics()
            }
        }
        
        AppLogger.info("Performance monitoring started")
    }
    
    /// Stop performance monitoring
    func stopMonitoring() {
        isMonitoring = false
        monitoringTimer?.invalidate()
        monitoringTimer = nil
        
        AppLogger.info("Performance monitoring stopped")
    }
    
    // MARK: - Metrics Collection
    
    /// Update performance metrics
    private func updateMetrics() async {
        let memoryUsage = getMemoryUsage()
        let cpuUsage = getCPUUsage()
        
        metrics.memoryUsageMB = memoryUsage
        metrics.cpuUsagePercentage = cpuUsage
        metrics.lastUpdated = Date()
        
        // Check for performance issues
        checkPerformanceIssues()
    }
    
    /// Get current memory usage in MB
    private func getMemoryUsage() -> Double {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size)/4
        
        let kerr: kern_return_t = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_,
                         task_flavor_t(MACH_TASK_BASIC_INFO),
                         $0,
                         &count)
            }
        }
        
        if kerr == KERN_SUCCESS {
            let usedBytes = Double(info.resident_size)
            let usedMB = usedBytes / (1024 * 1024)
            return usedMB
        }
        
        return 0
    }
    
    /// Get current CPU usage percentage
    private func getCPUUsage() -> Double {
        var totalUsageOfCPU: Double = 0.0
        var threadsList: thread_act_array_t?
        var threadsCount = mach_msg_type_number_t(0)
        
        let threadsResult = withUnsafeMutablePointer(to: &threadsList) {
            task_threads(mach_task_self_, $0, &threadsCount)
        }
        
        if threadsResult == KERN_SUCCESS, let threadsList = threadsList {
            for index in 0..<threadsCount {
                var threadInfo = thread_basic_info()
                var threadInfoCount = mach_msg_type_number_t(THREAD_INFO_MAX)
                
                let infoResult = withUnsafeMutablePointer(to: &threadInfo) {
                    $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                        thread_info(threadsList[Int(index)],
                                  thread_flavor_t(THREAD_BASIC_INFO),
                                  $0,
                                  &threadInfoCount)
                    }
                }
                
                guard infoResult == KERN_SUCCESS else { continue }
                
                let threadBasicInfo = threadInfo
                if threadBasicInfo.flags != TH_FLAGS_IDLE {
                    totalUsageOfCPU += Double(threadBasicInfo.cpu_usage) / Double(TH_USAGE_SCALE) * 100.0
                }
            }
            
            vm_deallocate(mach_task_self_, vm_address_t(bitPattern: threadsList), vm_size_t(Int(threadsCount) * MemoryLayout<thread_t>.stride))
        }
        
        return totalUsageOfCPU
    }
    
    // MARK: - Performance Issues Detection
    
    /// Check for performance issues and log warnings
    private func checkPerformanceIssues() {
        // Check memory usage
        if metrics.memoryUsageMB > 150 {
            AppLogger.debug("⚠️ High memory usage: \(String(format: "%.1f", metrics.memoryUsageMB)) MB")
        }
        
        // Check CPU usage
        if metrics.cpuUsagePercentage > 80 {
            AppLogger.debug("⚠️ High CPU usage: \(String(format: "%.1f", metrics.cpuUsagePercentage))%")
        }
    }
    
    // MARK: - Operation Timing
    
    /// Measure execution time of an operation
    func measure<T>(
        operation: String,
        threshold: TimeInterval = 0.5,
        execute: () throws -> T
    ) rethrows -> T {
        let startTime = CFAbsoluteTimeGetCurrent()
        let result = try execute()
        let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
        
        recordOperationTime(operation: operation, duration: timeElapsed)
        
        if timeElapsed > threshold {
            AppLogger.debug("⏱️ Slow operation: \(operation) took \(String(format: "%.3f", timeElapsed))s")
        }
        
        return result
    }
    
    /// Measure execution time of an async operation
    func measureAsync<T>(
        operation: String,
        threshold: TimeInterval = 0.5,
        execute: () async throws -> T
    ) async rethrows -> T {
        let startTime = CFAbsoluteTimeGetCurrent()
        let result = try await execute()
        let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
        
        await MainActor.run {
            recordOperationTime(operation: operation, duration: timeElapsed)
        }
        
        if timeElapsed > threshold {
            AppLogger.debug("⏱️ Slow async operation: \(operation) took \(String(format: "%.3f", timeElapsed))s")
        }
        
        return result
    }
    
    private func recordOperationTime(operation: String, duration: TimeInterval) {
        var operations = metrics.slowOperations
        operations[operation] = duration
        
        // Keep only top 20 slowest operations
        if operations.count > 20 {
            let sortedOps = operations.sorted { $0.value > $1.value }
            let top20 = sortedOps.prefix(20).map { ($0.key, $0.value) }
            operations = Dictionary(uniqueKeysWithValues: top20)
        }
        
        metrics.slowOperations = operations
    }
    
    // MARK: - Report Generation
    
    /// Generate performance report
    func generateReport() -> PerformanceReport {
        return PerformanceReport(
            memoryUsage: metrics.memoryUsageMB,
            cpuUsage: metrics.cpuUsagePercentage,
            slowOperations: metrics.slowOperations,
            timestamp: Date()
        )
    }
    
    /// Print performance summary to console
    func printSummary() {
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("📊 PERFORMANCE SUMMARY")
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("Memory Usage: \(String(format: "%.1f", metrics.memoryUsageMB)) MB")
        print("CPU Usage: \(String(format: "%.1f", metrics.cpuUsagePercentage))%")
        print("")
        
        if !metrics.slowOperations.isEmpty {
            print("Slow Operations:")
            let sorted = metrics.slowOperations.sorted { $0.value > $1.value }.prefix(10)
            for (operation, duration) in sorted {
                print("  • \(operation): \(String(format: "%.3f", duration))s")
            }
        }
        
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    }
}

// MARK: - Performance Metrics

/// Structure to hold performance metrics
struct PerformanceMetrics {
    var memoryUsageMB: Double = 0
    var cpuUsagePercentage: Double = 0
    var slowOperations: [String: TimeInterval] = [:]
    var lastUpdated: Date = Date()
}

// MARK: - Performance Report

/// Detailed performance report
struct PerformanceReport {
    let memoryUsage: Double
    let cpuUsage: Double
    let slowOperations: [String: TimeInterval]
    let timestamp: Date
    
    var formattedMemory: String {
        return String(format: "%.1f MB", memoryUsage)
    }
    
    var formattedCPU: String {
        return String(format: "%.1f%%", cpuUsage)
    }
    
    var topSlowOperations: [(String, TimeInterval)] {
        return slowOperations.sorted { $0.value > $1.value }.prefix(5).map { ($0.key, $0.value) }
    }
}

// MARK: - View Modifier for Performance Tracking

struct PerformanceTrackingModifier: ViewModifier {
    let viewName: String
    @State private var appearTime: Date?
    
    func body(content: Content) -> some View {
        content
            .onAppear {
                appearTime = Date()
            }
            .onDisappear {
                if let startTime = appearTime {
                    let duration = Date().timeIntervalSince(startTime)
                    AppLogger.debug("View '\(viewName)' displayed for \(String(format: "%.2f", duration))s")
                }
            }
    }
}

extension View {
    /// Track how long a view is displayed
    func trackViewPerformance(viewName: String) -> some View {
        self.modifier(PerformanceTrackingModifier(viewName: viewName))
    }
}

