//
//  NetworkMonitor.swift
//  NPLearn
//
//  Network connectivity monitoring
//

import Foundation
import Network
import SwiftUI

@MainActor
final class NetworkMonitor: ObservableObject {
    
    static let shared = NetworkMonitor()
    
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")
    
    @Published var isConnected = true
    @Published var connectionType: ConnectionType = .unknown
    
    enum ConnectionType {
        case wifi
        case cellular
        case ethernet
        case unknown
    }
    
    private init() {
        startMonitoring()
    }
    
    private func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            Task { @MainActor [weak self] in
                self?.isConnected = path.status == .satisfied
                self?.updateConnectionType(path)
            }
        }
        monitor.start(queue: queue)
    }
    
    private func updateConnectionType(_ path: NWPath) {
        if path.usesInterfaceType(.wifi) {
            connectionType = .wifi
        } else if path.usesInterfaceType(.cellular) {
            connectionType = .cellular
        } else if path.usesInterfaceType(.wiredEthernet) {
            connectionType = .ethernet
        } else {
            connectionType = .unknown
        }
    }
    
    static func hasInternetConnection() async -> Bool {
        return await MainActor.run {
            shared.isConnected
        }
    }
    
    deinit {
        monitor.cancel()
    }
}

// MARK: - View Extension for Network Monitoring

extension View {
    func monitorNetwork() -> some View {
        self.environmentObject(NetworkMonitor.shared)
    }
}

