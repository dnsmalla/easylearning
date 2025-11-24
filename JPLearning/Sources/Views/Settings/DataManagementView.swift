//
//  DataManagementView.swift
//  JLearn
//
//  View for managing data exports/imports and cache
//

import SwiftUI
import UniformTypeIdentifiers

struct DataManagementView: View {
    @StateObject private var dataService = DataManagementService.shared
    @StateObject private var remoteService = RemoteDataService.shared
    @EnvironmentObject var learningDataService: LearningDataService
    
    @State private var showExportSuccess = false
    @State private var showImportPicker = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var exportedFileURL: URL?
    @State private var showShareSheet = false
    @State private var availableUpdates: [LearningLevel: String]?
    @State private var isCheckingUpdates = false
    
    var body: some View {
        List {
            // Export Section
            Section {
                Button {
                    exportData()
                } label: {
                    HStack {
                        Image(systemName: "square.and.arrow.up")
                            .foregroundColor(AppTheme.brandPrimary)
                        
                        VStack(alignment: .leading) {
                            Text("Export Progress")
                                .font(AppTheme.Typography.body)
                            Text("Save your learning data as backup")
                                .font(AppTheme.Typography.caption)
                                .foregroundColor(AppTheme.mutedText)
                        }
                        
                        Spacer()
                        
                        if dataService.isExporting {
                            ProgressView()
                        }
                    }
                }
                .disabled(dataService.isExporting)
            } header: {
                Text("Backup")
            } footer: {
                Text("Export your progress, achievements, and statistics to a JSON file.")
            }
            
            // Import Section
            Section {
                Button {
                    showImportPicker = true
                } label: {
                    HStack {
                        Image(systemName: "square.and.arrow.down")
                            .foregroundColor(.blue)
                        
                        VStack(alignment: .leading) {
                            Text("Import Progress")
                                .font(AppTheme.Typography.body)
                            Text("Restore from backup file")
                                .font(AppTheme.Typography.caption)
                                .foregroundColor(AppTheme.mutedText)
                        }
                        
                        Spacer()
                        
                        if dataService.isImporting {
                            ProgressView()
                        }
                    }
                }
                .disabled(dataService.isImporting)
            } header: {
                Text("Restore")
            } footer: {
                Text("Import previously exported data. This will override your current progress.")
            }
            
            // GitHub Updates Section
            Section {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Learning Data")
                            .font(AppTheme.Typography.body)
                        Text("Current: \(learningDataService.currentLevel.rawValue)")
                            .font(AppTheme.Typography.caption)
                            .foregroundColor(AppTheme.mutedText)
                    }
                    
                    Spacer()
                    
                    if isCheckingUpdates {
                        ProgressView()
                    }
                }
                
                Button {
                    checkForUpdates()
                } label: {
                    HStack {
                        Image(systemName: "arrow.triangle.2.circlepath")
                            .foregroundColor(.green)
                        Text("Check for Updates")
                        
                        Spacer()
                        
                        if let updates = availableUpdates, !updates.isEmpty {
                            Text("\(updates.count) available")
                                .font(AppTheme.Typography.caption)
                                .foregroundColor(.green)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.green.opacity(0.1))
                                .clipShape(Capsule())
                        }
                    }
                }
                .disabled(isCheckingUpdates)
                
                if let updates = availableUpdates, !updates.isEmpty {
                    ForEach(Array(updates.keys), id: \.self) { level in
                        Button {
                            downloadUpdate(for: level)
                        } label: {
                            HStack {
                                Image(systemName: "arrow.down.circle")
                                Text("\(level.rawValue) - v\(updates[level] ?? "")")
                                Spacer()
                                if remoteService.isDownloading {
                                    ProgressView()
                                }
                            }
                        }
                        .disabled(remoteService.isDownloading)
                    }
                }
            } header: {
                Text("Remote Data")
            } footer: {
                Text("Download updated learning content from GitHub repository.")
            }
            
            // Cache Management
            Section {
                Button(role: .destructive) {
                    clearCache()
                } label: {
                    HStack {
                        Image(systemName: "trash")
                        Text("Clear Cache")
                    }
                }
            } header: {
                Text("Storage")
            } footer: {
                Text("Clear cached data and force reload from source files.")
            }
        }
        .navigationTitle("Data Management")
        .alert("Success", isPresented: $showExportSuccess) {
            Button("Share", action: { showShareSheet = true })
            Button("OK", role: .cancel) {}
        } message: {
            Text("Your data has been exported successfully.")
        }
        .alert("Error", isPresented: $showError) {
            Button("OK") {}
        } message: {
            Text(errorMessage)
        }
        .fileImporter(
            isPresented: $showImportPicker,
            allowedContentTypes: [UTType.json],
            allowsMultipleSelection: false
        ) { result in
            handleImport(result)
        }
        .sheet(isPresented: $showShareSheet) {
            if let url = exportedFileURL {
                ShareSheet(items: [url])
            }
        }
    }
    
    // MARK: - Actions
    
    private func exportData() {
        if let url = dataService.exportUserData() {
            exportedFileURL = url
            showExportSuccess = true
            Haptics.success()
        } else {
            errorMessage = dataService.exportMessage
            showError = true
            Haptics.error()
        }
    }
    
    private func handleImport(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let url = urls.first else { return }
            
            if dataService.importUserData(from: url) {
                // Reload learning data
                Task {
                    await learningDataService.loadLearningData()
                }
                Haptics.success()
            } else {
                errorMessage = dataService.exportMessage
                showError = true
                Haptics.error()
            }
            
        case .failure(let error):
            errorMessage = error.localizedDescription
            showError = true
            Haptics.error()
        }
    }
    
    private func checkForUpdates() {
        isCheckingUpdates = true
        
        Task {
            do {
                availableUpdates = await remoteService.checkForUpdates()
                isCheckingUpdates = false
                
                if availableUpdates == nil || availableUpdates!.isEmpty {
                    // Check console logs for detailed error information
                    errorMessage = "All data is up-to-date!\n\nNote: The app uses bundled data that is already included. Remote downloads are optional.\n\nIf you see network errors in the console, this is normal for offline use."
                    showError = true
                }
            } catch {
                isCheckingUpdates = false
                errorMessage = "Could not check for updates.\n\nError: \(error.localizedDescription)\n\nNote: The app works fine with bundled data. Remote updates are optional."
                AppLogger.error("❌ [DATA MANAGEMENT] Check updates error: \(error)")
                showError = true
            }
        }
    }
    
    private func downloadUpdate(for level: LearningLevel) {
        Task {
            do {
                let _ = try await remoteService.forceRefresh(for: level)
                
                // Reload if it's the current level
                if level == learningDataService.currentLevel {
                    await learningDataService.loadLearningData()
                }
                
                Haptics.success()
                
                // Refresh update list
                checkForUpdates()
            } catch {
                errorMessage = error.localizedDescription
                showError = true
                Haptics.error()
            }
        }
    }
    
    private func clearCache() {
        remoteService.clearCache()
        Haptics.success()
    }
}

// MARK: - Share Sheet
// Note: ShareSheet is defined in WebSearchView.swift and reused here
