//
//  KanaPracticeView.swift
//  JLearn
//
//  Hiragana and Katakana practice screen
//

import SwiftUI

struct KanaPracticeView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Tab Selection
                Picker("Kana Type", selection: $selectedTab) {
                    Text("Hiragana").tag(0)
                    Text("Katakana").tag(1)
                }
                .pickerStyle(.segmented)
                .padding()
                .background(Color.white)
                
                // Content
                TabView(selection: $selectedTab) {
                    HiraganaView()
                        .tag(0)
                    
                    KatakanaView()
                        .tag(1)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            }
            .background(AppTheme.background)
            .navigationTitle("Kana Practice")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - Hiragana View

struct HiraganaView: View {
    let hiraganaCharacters = [
        ["あ", "い", "う", "え", "お"],
        ["か", "き", "く", "け", "こ"],
        ["さ", "し", "す", "せ", "そ"],
        ["た", "ち", "つ", "て", "と"],
        ["な", "に", "ぬ", "ね", "の"],
        ["は", "ひ", "ふ", "へ", "ほ"],
        ["ま", "み", "む", "め", "も"],
        ["や", "", "ゆ", "", "よ"],
        ["ら", "り", "る", "れ", "ろ"],
        ["わ", "", "", "", "を"],
        ["ん", "", "", "", ""]
    ]
    
    let romanji = [
        ["a", "i", "u", "e", "o"],
        ["ka", "ki", "ku", "ke", "ko"],
        ["sa", "shi", "su", "se", "so"],
        ["ta", "chi", "tsu", "te", "to"],
        ["na", "ni", "nu", "ne", "no"],
        ["ha", "hi", "fu", "he", "ho"],
        ["ma", "mi", "mu", "me", "mo"],
        ["ya", "", "yu", "", "yo"],
        ["ra", "ri", "ru", "re", "ro"],
        ["wa", "", "", "", "wo"],
        ["n", "", "", "", ""]
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Text("Hiragana Characters")
                    .font(AppTheme.Typography.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                ForEach(Array(hiraganaCharacters.enumerated()), id: \.offset) { rowIndex, rowChars in
                    HStack(spacing: 8) {
                        ForEach(Array(rowChars.enumerated()), id: \.offset) { colIndex, char in
                            if !char.isEmpty {
                                KanaCard(
                                    character: char,
                                    romanji: romanji[rowIndex][colIndex],
                                    color: AppTheme.brandPrimary
                                )
                            } else {
                                Color.clear
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 60)
                            }
                        }
                    }
                }
            }
            .padding()
        }
    }
}

// MARK: - Katakana View

struct KatakanaView: View {
    let katakanaCharacters = [
        ["ア", "イ", "ウ", "エ", "オ"],
        ["カ", "キ", "ク", "ケ", "コ"],
        ["サ", "シ", "ス", "セ", "ソ"],
        ["タ", "チ", "ツ", "テ", "ト"],
        ["ナ", "ニ", "ヌ", "ネ", "ノ"],
        ["ハ", "ヒ", "フ", "ヘ", "ホ"],
        ["マ", "ミ", "ム", "メ", "モ"],
        ["ヤ", "", "ユ", "", "ヨ"],
        ["ラ", "リ", "ル", "レ", "ロ"],
        ["ワ", "", "", "", "ヲ"],
        ["ン", "", "", "", ""]
    ]
    
    let romanji = [
        ["a", "i", "u", "e", "o"],
        ["ka", "ki", "ku", "ke", "ko"],
        ["sa", "shi", "su", "se", "so"],
        ["ta", "chi", "tsu", "te", "to"],
        ["na", "ni", "nu", "ne", "no"],
        ["ha", "hi", "fu", "he", "ho"],
        ["ma", "mi", "mu", "me", "mo"],
        ["ya", "", "yu", "", "yo"],
        ["ra", "ri", "ru", "re", "ro"],
        ["wa", "", "", "", "wo"],
        ["n", "", "", "", ""]
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Text("Katakana Characters")
                    .font(AppTheme.Typography.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                ForEach(Array(katakanaCharacters.enumerated()), id: \.offset) { rowIndex, rowChars in
                    HStack(spacing: 8) {
                        ForEach(Array(rowChars.enumerated()), id: \.offset) { colIndex, char in
                            if !char.isEmpty {
                                KanaCard(
                                    character: char,
                                    romanji: romanji[rowIndex][colIndex],
                                    color: AppTheme.brandPrimary
                                )
                            } else {
                                Color.clear
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 60)
                            }
                        }
                    }
                }
            }
            .padding()
        }
    }
}

// MARK: - Kana Card

struct KanaCard: View {
    let character: String
    let romanji: String
    let color: Color
    @State private var showRomanji = false
    @StateObject private var audioService = AudioService.shared
    
    var body: some View {
        Button {
            showRomanji.toggle()
            Haptics.selection()
            
            // Speak the character
            Task {
                do {
                    try await audioService.speak(character)
                } catch {
                    print("Failed to speak: \(error)")
                }
            }
        } label: {
            VStack(spacing: 8) {
                Text(character)
                    .font(AppTheme.Typography.largeTitle)
                    .foregroundColor(.primary)
                
                if showRomanji {
                    Text(romanji)
                        .font(AppTheme.Typography.caption)
                        .foregroundColor(AppTheme.mutedText)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 80)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Layout.smallCornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.Layout.smallCornerRadius)
                    .stroke(color.opacity(0.3), lineWidth: 1)
            )
        }
    }
}
