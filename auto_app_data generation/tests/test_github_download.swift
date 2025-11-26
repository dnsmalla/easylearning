#!/usr/bin/env swift

import Foundation

// ═══════════════════════════════════════════════════════════════
// Swift Test for GitHub Data URLs
// ═══════════════════════════════════════════════════════════════
// Tests downloading and parsing JSON from GitHub
// Run: swift test_github_download.swift
// ═══════════════════════════════════════════════════════════════

// Configuration - UPDATE THESE FOR YOUR PROJECT
let githubUsername = "dnsmalla"
let githubRepoName = "easylearning"
let dataFolder = "jpleanrning"

// Construct URLs
let baseURL = "https://raw.githubusercontent.com/\(githubUsername)/\(githubRepoName)/main/\(dataFolder)"

let testURLs = [
    "\(baseURL)/manifest.json",
    "\(baseURL)/vocabulary.json",
    "\(baseURL)/japanese_learning_data_n5_jisho.json"
]

print("╔══════════════════════════════════════════════════════════════╗")
print("║   Swift Test: GitHub Data Download                          ║")
print("╚══════════════════════════════════════════════════════════════╝")
print("")
print("Repository: \(githubUsername)/\(githubRepoName)")
print("Base URL: \(baseURL)")
print("")

// Test result tracking
var successCount = 0
var failCount = 0

// Semaphore for synchronous testing
let semaphore = DispatchSemaphore(value: 0)
var testsRemaining = testURLs.count

// Test each URL
for urlString in testURLs {
    guard let url = URL(string: urlString) else {
        print("❌ Invalid URL: \(urlString)")
        failCount += 1
        testsRemaining -= 1
        if testsRemaining == 0 { semaphore.signal() }
        continue
    }
    
    let task = URLSession.shared.dataTask(with: url) { data, response, error in
        let fileName = url.lastPathComponent
        
        if let error = error {
            print("❌ \(fileName): \(error.localizedDescription)")
            failCount += 1
        } else if let httpResponse = response as? HTTPURLResponse {
            if httpResponse.statusCode == 200 {
                if let data = data {
                    let sizeKB = Double(data.count) / 1024.0
                    print(String(format: "✅ \(fileName): HTTP %d (%.2f KB)", httpResponse.statusCode, sizeKB))
                    
                    // Try to parse as JSON
                    do {
                        let json = try JSONSerialization.jsonObject(with: data, options: [])
                        print("   ✓ Valid JSON")
                        
                        // For manifest, show version
                        if fileName == "manifest.json", let dict = json as? [String: Any] {
                            if let version = dict["version"] {
                                print("   ✓ Version: \(version)")
                            }
                        }
                    } catch {
                        print("   ⚠️  JSON parsing failed: \(error.localizedDescription)")
                    }
                    
                    successCount += 1
                } else {
                    print("❌ \(fileName): No data received")
                    failCount += 1
                }
            } else {
                print("❌ \(fileName): HTTP \(httpResponse.statusCode)")
                failCount += 1
            }
        }
        
        testsRemaining -= 1
        if testsRemaining == 0 {
            semaphore.signal()
        }
    }
    
    task.resume()
}

// Wait for all tests to complete
_ = semaphore.wait(timeout: .now() + 30)

// Summary
print("")
print("═══════════════════════════════════════════════════════════")
print("Summary:")
print("═══════════════════════════════════════════════════════════")
print("Total tests: \(testURLs.count)")
print("✅ Successful: \(successCount)")
print("❌ Failed: \(failCount)")
print("")

if failCount == 0 {
    print("✅ All tests passed!")
    print("")
    print("Your app can successfully download data from GitHub.")
    exit(0)
} else {
    print("❌ Some tests failed")
    print("")
    print("Check:")
    print("  1. Repository is PUBLIC")
    print("  2. Files exist in the \(dataFolder)/ folder")
    print("  3. File names are correct")
    print("  4. Network connection is working")
    exit(1)
}

