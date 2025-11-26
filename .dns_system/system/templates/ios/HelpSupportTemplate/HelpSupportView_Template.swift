//
//  HelpSupportView.swift
//  [APP_NAME]
//
//  TEMPLATE: Based on VisaPro's Production-Ready Implementation
//  TODO: Customize help content for your app
//

import SwiftUI

struct HelpSupportView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    @State private var expandedSections: Set<String> = []
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Hero Section
                    heroSection
                    
                    // Quick Actions Grid
                    quickActionsGrid
                    
                    // Help Sections
                    ForEach(filteredSections, id: \.title) { section in
                        HelpSection(
                            section: section,
                            isExpanded: expandedSections.contains(section.title),
                            onToggle: { toggleSection(section.title) }
                        )
                        .padding(.horizontal)
                    }
                    
                    // Footer with Legal Links
                    footerSection
                }
                .padding(.vertical)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Help & Support")
            .navigationBarTitleDisplayMode(.large)
            .searchable(text: $searchText, prompt: "Search for help...")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    // MARK: - Hero Section
    
    private var heroSection: some View {
        VStack(spacing: 16) {
            Image(systemName: "lifepreserver.fill")
                .font(.system(size: 50))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.blue, .cyan],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            Text("How can we help you?")
                .font(.system(size: 24, weight: .bold))
            
            Text("Find answers, get support, or learn how to use [APP_NAME]")
                .font(.system(size: 15))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
        .padding(.vertical, 20)
        .frame(maxWidth: .infinity)
        .background(
            LinearGradient(
                colors: [Color(.systemBackground), Color(.secondarySystemBackground)],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.gray.opacity(0.1), lineWidth: 1)
        )
        .padding(.horizontal)
    }
    
    // MARK: - Quick Actions Grid
    
    private var quickActionsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
            QuickActionCard(icon: "play.circle.fill", title: "Getting Started", color: .blue) { }
            QuickActionCard(icon: "questionmark.circle.fill", title: "FAQ", color: .green) { }
            QuickActionCard(icon: "wrench.and.screwdriver.fill", title: "Troubleshooting", color: .orange) { }
        }
        .padding(.horizontal)
    }
    
    // MARK: - Footer Section
    
    private var footerSection: some View {
        VStack(spacing: 12) {
            Divider().padding(.horizontal)
            
            VStack(spacing: 8) {
                // TODO: Replace with your document viewer
                Button("Terms of Service") {
                    // Open terms
                }
                .font(.system(size: 14))
                .foregroundColor(.blue)
                
                Button("Privacy Policy") {
                    // Open privacy
                }
                .font(.system(size: 14))
                .foregroundColor(.blue)
            }
            
            VStack(spacing: 6) {
                Text("Version [APP_VERSION]")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text("Made with ❤️")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .padding(.top, 8)
        }
        .padding(.vertical, 20)
    }
    
    // MARK: - Helper Methods
    
    private var filteredSections: [HelpSectionData] {
        if searchText.isEmpty {
            return helpSections
        }
        return helpSections.filter { section in
            section.title.localizedCaseInsensitiveContains(searchText) ||
            section.items.contains { $0.question.localizedCaseInsensitiveContains(searchText) || $0.answer.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    private func toggleSection(_ title: String) {
        withAnimation(.spring(response: 0.3)) {
            if expandedSections.contains(title) {
                expandedSections.remove(title)
            } else {
                expandedSections.insert(title)
            }
        }
    }
    
    // MARK: - Help Content (TODO: CUSTOMIZE FOR YOUR APP)
    
    private var helpSections: [HelpSectionData] {
        [
            HelpSectionData(
                title: "Getting Started",
                icon: "play.circle.fill",
                color: .blue,
                items: [
                    HelpItem(
                        question: "How do I get started?",
                        answer: "TODO: Add your app-specific getting started guide."
                    )
                ]
            ),
            
            HelpSectionData(
                title: "FAQ",
                icon: "questionmark.circle.fill",
                color: .green,
                items: [
                    HelpItem(
                        question: "Is [APP_NAME] free?",
                        answer: "TODO: Answer pricing questions."
                    )
                ]
            ),
            
            HelpSectionData(
                title: "Troubleshooting",
                icon: "wrench.and.screwdriver.fill",
                color: .orange,
                items: [
                    HelpItem(
                        question: "The app is not loading",
                        answer: "TODO: Add troubleshooting steps."
                    )
                ]
            )
        ]
    }
}

// MARK: - Supporting Views

struct QuickActionCard: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.15))
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: icon)
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundStyle(color)
                }
                
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.gray.opacity(0.15), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.05), radius: 4, y: 2)
        }
        .buttonStyle(.plain)
    }
}

struct HelpSection: View {
    let section: HelpSectionData
    let isExpanded: Bool
    let onToggle: () -> Void
    
    var body: some View {
        Section {
            ForEach(section.items) { item in
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "questionmark.circle.fill")
                            .font(.system(size: 16))
                            .foregroundStyle(section.color)
                        
                        Text(item.question)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.primary)
                    }
                    
                    Text(item.answer)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.vertical, 8)
            }
        } header: {
            HStack {
                Image(systemName: section.icon)
                    .foregroundStyle(section.color)
                Text(section.title)
            }
        }
    }
}

// MARK: - Data Models

struct HelpSectionData {
    let title: String
    let icon: String
    let color: Color
    let items: [HelpItem]
}

struct HelpItem: Identifiable {
    let id = UUID()
    let question: String
    let answer: String
}

