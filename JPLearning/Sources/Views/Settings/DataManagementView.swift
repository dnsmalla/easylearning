//
//  DataManagementView.swift
//  JLearn
//
//  View for managing learning data downloads and updates from GitHub
//

import SwiftUI

struct DataManagementView: View {
    @StateObject private var remoteService = RemoteDataService.shared
    @StateObject private var learningService = LearningDataService.shared
    
    @State private var availableUpdates: [LearningLevel: String]?
    @State private var isCheckingUpdates = false
    @State private var showClearCacheAlert = false
    @State private var downloadSizes: [LearningLevel: Int] = [:]
    @State private var showSuccessMessage = false
    @State private var successMessage = ""
    
    var body: some View {
        List {
            // Status Section
            Section {
                HStack {
                    Image(systemName: remoteService.isDownloading ? "arrow.down.circle.fill" : "checkmark.circle.fill")
                        .foregroundColor(remoteService.isDownloading ? .blue : .green)
                    
                    Text(remoteService.isDownloading ? "Downloading..." : "Data Up-to-date")
                        .font(AppTheme.Typography.body)
                    
                    Spacer()
                    
                    if remoteService.isDownloading {
                        ProgressView(value: remoteService.downloadProgress)
                            .frame(width: 60)
                    }
                }
            } header: {
                Text("Status")
            }
            
            // Import/Sync Section
            Section {
                // TODO: Add DataDiagnosticsView.swift to Xcode project target first
                // Then uncomment this:
                // NavigationLink(destination: DataDiagnosticsView()) {
                //     HStack {
                //         Image(systemName: "stethoscope")
                //         Text("Data Diagnostics")
                //     }
                // }
                
                Button {
                    Task {
                        await checkForUpdates()
                    }
                } label: {
                    HStack {
                        Image(systemName: "arrow.clockwise.icloud")
                            .foregroundColor(AppTheme.brandPrimary)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Sync from GitHub")
                                .font(AppTheme.Typography.body)
                                .fontWeight(.medium)
                            Text("Check for new learning content")
                                .font(AppTheme.Typography.caption)
                                .foregroundColor(AppTheme.mutedText)
                        }
                        Spacer()
                        if isCheckingUpdates {
                            ProgressView()
                        }
                    }
                }
                .disabled(isCheckingUpdates || remoteService.isDownloading)
                
                if let updates = availableUpdates, !updates.isEmpty {
                    ForEach(updates.sorted(by: { $0.key.rawValue < $1.key.rawValue }), id: \.key) { level, version in
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("\(level.rawValue) - Update Available")
                                    .font(AppTheme.Typography.body)
                                    .fontWeight(.medium)
                                Text("Version \(version)")
                                    .font(AppTheme.Typography.caption)
                                    .foregroundColor(AppTheme.mutedText)
                                
                                if let size = downloadSizes[level] {
                                    Text(formatBytes(size))
                                        .font(AppTheme.Typography.caption)
                                        .foregroundColor(AppTheme.brandSecondary)
                                }
                            }
                            
                            Spacer()
                            
                            Button {
                                Task {
                                    await downloadUpdate(for: level)
                                }
                            } label: {
                                HStack(spacing: 4) {
                                    Image(systemName: "arrow.down.circle.fill")
                                    Text("Import")
                                }
                                .font(AppTheme.Typography.caption)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(AppTheme.brandPrimary)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                            }
                            .disabled(remoteService.isDownloading)
                        }
                    }
                } else if availableUpdates != nil {
                    HStack {
                        Image(systemName: "checkmark.circle")
                            .foregroundColor(.green)
                        Text("All data is up-to-date")
                            .font(AppTheme.Typography.body)
                    }
                }
            } header: {
                Text("Import Data from GitHub")
            } footer: {
                Text("Checks GitHub for updated JSON files (flashcards, grammar, practice questions, lessons, exercises, reading passages) and imports them to your local storage")
                    .font(AppTheme.Typography.caption)
            }
            
            // Bulk Actions Section
            Section {
                Button {
                    Task {
                        await downloadAllLevels()
                    }
                } label: {
                    HStack {
                        Image(systemName: "arrow.down.circle")
                            .foregroundColor(AppTheme.brandPrimary)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Import All Levels")
                                .font(AppTheme.Typography.body)
                                .fontWeight(.medium)
                            Text("Download N5-N1 data for offline use")
                                .font(AppTheme.Typography.caption)
                                .foregroundColor(AppTheme.mutedText)
                        }
                        Spacer()
                    }
                }
                .disabled(remoteService.isDownloading)
                
                Button {
                    Task {
                        await forceImportAll()
                    }
                } label: {
                    HStack {
                        Image(systemName: "arrow.clockwise.icloud.fill")
                            .foregroundColor(.orange)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Force Re-Import All")
                                .font(AppTheme.Typography.body)
                                .fontWeight(.medium)
                            Text("Ignore version, download fresh data")
                                .font(AppTheme.Typography.caption)
                                .foregroundColor(AppTheme.mutedText)
                        }
                        Spacer()
                    }
                }
                .disabled(remoteService.isDownloading)
            } header: {
                Text("Bulk Import")
            } footer: {
                Text("Import all JLPT levels at once or force re-import to overwrite existing data")
                    .font(AppTheme.Typography.caption)
            }
            
            // Cache Management
            Section {
                Button(role: .destructive) {
                    showClearCacheAlert = true
                } label: {
                    HStack {
                        Image(systemName: "trash")
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Clear Downloaded Data")
                                .font(AppTheme.Typography.body)
                                .fontWeight(.medium)
                            Text("Delete local cache, re-download on next use")
                                .font(AppTheme.Typography.caption)
                                .foregroundColor(AppTheme.mutedText)
                        }
                        Spacer()
                    }
                }
                .disabled(remoteService.isDownloading)
            } header: {
                Text("Local Storage")
            } footer: {
                Text("Clears all downloaded data. The app will re-download on next use or use bundled sample data.")
                    .font(AppTheme.Typography.caption)
            }
            
            // Info Section
            Section {
                InfoRow(title: "Data Source", value: "GitHub Repository")
                InfoRow(title: "Schema Version", value: "1.0")
                InfoRow(title: "Auto-Sync", value: "Every 30 days")
                InfoRow(title: "Network", value: "Wi-Fi preferred")
                
                // Add link to schema documentation
                Button {
                    // Show schema documentation or open in browser
                    if let url = URL(string: "https://github.com/yourusername/auto_swift_jlearn/blob/main/auto_app_data%20generation/APP_DATA_SCHEMA.txt") {
                        UIApplication.shared.open(url)
                    }
                } label: {
                    HStack {
                        Image(systemName: "doc.text")
                            .foregroundColor(AppTheme.brandPrimary)
                        Text("View Data Schema")
                            .font(AppTheme.Typography.body)
                        Spacer()
                        Image(systemName: "arrow.up.right.square")
                            .font(.caption)
                            .foregroundColor(AppTheme.mutedText)
                    }
                }
            } header: {
                Text("Information")
            } footer: {
                Text("Data schema defines the structure of all learning content")
                    .font(AppTheme.Typography.caption)
            }
        }
        .navigationTitle("Data Management")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Clear Cache", isPresented: $showClearCacheAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Clear", role: .destructive) {
                remoteService.clearCache()
            }
        } message: {
            Text("This will delete all downloaded learning data. You can re-download it anytime.")
        }
        .alert("Success", isPresented: $showSuccessMessage) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(successMessage)
        }
        .task {
            // Load download sizes
            for level in LearningLevel.allCases {
                if let size = await remoteService.getDownloadSize(for: level) {
                    downloadSizes[level] = size
                }
            }
        }
    }
    
    // MARK: - Actions
    
    private func checkForUpdates() async {
        isCheckingUpdates = true
        defer { isCheckingUpdates = false }
        
        availableUpdates = await remoteService.checkForUpdates()
        
        if availableUpdates == nil || availableUpdates!.isEmpty {
            successMessage = "All data is up-to-date!"
            showSuccessMessage = true
        }
    }
    
    private func downloadUpdate(for level: LearningLevel) async {
        do {
            _ = try await remoteService.forceRefresh(for: level)
            
            // Reload data in learning service
            await learningService.loadLearningData()
            
            // Remove from available updates
            availableUpdates?[level] = nil
            
            successMessage = "\(level.rawValue) data updated successfully!"
            showSuccessMessage = true
            
            // Haptics.success()
        } catch {
            AppLogger.error("Failed to download update: \(error)")
            // ToastManager.shared.show(message: "Download failed: \(error.localizedDescription)", type: .error)
        }
    }
    
    private func downloadAllLevels() async {
        for level in LearningLevel.allCases {
            do {
                _ = try await remoteService.forceRefresh(for: level)
            } catch {
                AppLogger.error("Failed to download \(level.rawValue): \(error)")
            }
        }
        
        await learningService.loadLearningData()
        
        successMessage = "All levels downloaded successfully!"
        showSuccessMessage = true
        Haptics.success()
    }
    
    private func forceImportAll() async {
        // Clear cache first to ensure fresh download
        remoteService.clearCache()
        
        // Download all levels
        for level in LearningLevel.allCases {
            do {
                _ = try await remoteService.forceRefresh(for: level)
            } catch {
                AppLogger.error("Failed to force import \(level.rawValue): \(error)")
            }
        }
        
        // Reload data
        await learningService.loadLearningData()
        
        successMessage = "All data re-imported successfully from GitHub!"
        showSuccessMessage = true
        Haptics.success()
    }
    
    private func formatBytes(_ bytes: Int) -> String {
        let kb = Double(bytes) / 1024
        let mb = kb / 1024
        
        if mb >= 1 {
            return String(format: "%.1f MB", mb)
        } else {
            return String(format: "%.0f KB", kb)
        }
    }
}

// MARK: - Supporting Views

private struct InfoRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(AppTheme.Typography.body)
            Spacer()
            Text(value)
                .font(AppTheme.Typography.body)
                .foregroundColor(AppTheme.mutedText)
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        DataManagementView()
    }
}

