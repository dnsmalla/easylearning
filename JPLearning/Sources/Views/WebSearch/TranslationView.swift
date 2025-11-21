//
//  TranslationView.swift
//  JLearn
//
//  Camera, Photo, and Text Translation features
//

import SwiftUI

struct TranslationView: View {
    @StateObject private var translationService = TextTranslationService.shared
    @StateObject private var imageRecognitionService = ImageTextRecognitionService.shared
    @StateObject private var audioService = AudioService.shared
    
    @State private var inputText = ""
    @State private var translatedText = ""
    @State private var furiganaText = ""
    @State private var isTranslating = false
    @State private var showImagePicker = false
    @State private var showCamera = false
    @State private var selectedImage: UIImage?
    @State private var recognizedText = ""
    @State private var targetLanguage = "en"
    @State private var isPlayingAudio = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("Camera / Photo / Text Translation")
                        .font(AppTheme.Typography.title2)
                        .foregroundColor(.primary)
                    
                    Text("Translate Japanese text using camera, photos, or paste")
                        .font(AppTheme.Typography.body)
                        .foregroundColor(AppTheme.mutedText)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                // Text Input Area
                VStack(alignment: .leading, spacing: 12) {
                    TextEditor(text: $inputText)
                        .frame(minHeight: 150)
                        .padding()
                        .background(AppTheme.secondaryBackground)
                        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Layout.cornerRadius))
                        .overlay(
                            RoundedRectangle(cornerRadius: AppTheme.Layout.cornerRadius)
                                .stroke(AppTheme.separator, lineWidth: 1)
                        )
                        .overlay(
                            Group {
                                if inputText.isEmpty {
                                    Text("Paste or capture Japanese text to translate...")
                                        .foregroundColor(AppTheme.mutedText)
                                        .padding()
                                        .allowsHitTesting(false)
                                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                                }
                            }
                        )
                    
                    // Action Buttons
                    HStack(spacing: 12) {
                        // Paste Button
                        Button {
                            pasteText()
                        } label: {
                            VStack(spacing: 8) {
                                Image(systemName: "doc.on.clipboard")
                                    .font(.system(size: 24))
                                Text("Paste")
                                    .font(AppTheme.Typography.caption)
                            }
                            .foregroundColor(AppTheme.brandPrimary)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(AppTheme.brandPrimary.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Layout.cornerRadius))
                        }
                        
                        // Photo Button
                        Button {
                            showImagePicker = true
                        } label: {
                            VStack(spacing: 8) {
                                Image(systemName: "photo")
                                    .font(.system(size: 24))
                                Text("Photo")
                                    .font(AppTheme.Typography.caption)
                            }
                            .foregroundColor(AppTheme.brandPrimary)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(AppTheme.brandPrimary.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Layout.cornerRadius))
                        }
                        
                        // Camera Button
                        Button {
                            showCamera = true
                        } label: {
                            VStack(spacing: 8) {
                                Image(systemName: "camera")
                                    .font(.system(size: 24))
                                Text("Camera")
                                    .font(AppTheme.Typography.caption)
                            }
                            .foregroundColor(AppTheme.brandPrimary)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(AppTheme.brandPrimary.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Layout.cornerRadius))
                        }
                    }
                }
                
                // Language Selection
                HStack {
                    Text("Japanese →")
                        .font(AppTheme.Typography.body)
                        .foregroundColor(.primary)
                    
                    Menu {
                        Button("English") { targetLanguage = "en" }
                        Button("Spanish") { targetLanguage = "es" }
                        Button("French") { targetLanguage = "fr" }
                        Button("German") { targetLanguage = "de" }
                        Button("Chinese") { targetLanguage = "zh" }
                        Button("Korean") { targetLanguage = "ko" }
                    } label: {
                        HStack {
                            Text(languageName(for: targetLanguage))
                                .font(AppTheme.Typography.body)
                            Image(systemName: "chevron.down")
                                .font(.system(size: 12))
                        }
                        .foregroundColor(AppTheme.brandPrimary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(AppTheme.brandPrimary.opacity(0.1))
                        .clipShape(Capsule())
                    }
                    
                    Spacer()
                    
                    // Translate Button
                    Button {
                        translateText()
                    } label: {
                        HStack(spacing: 8) {
                            if isTranslating {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.8)
                            } else {
                                Text("Translate")
                                    .font(AppTheme.Typography.headline)
                            }
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(AppTheme.brandPrimary)
                        .clipShape(Capsule())
                    }
                    .disabled(inputText.isEmpty || isTranslating)
                }
                
                // Translation Result with Furigana and Audio
                if !translatedText.isEmpty {
                    VStack(spacing: 16) {
                        // Raw Japanese with Furigana Window
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Raw Japanese")
                                    .font(AppTheme.Typography.headline)
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                // Speaker Button
                                Button {
                                    playAudio()
                                } label: {
                                    HStack(spacing: 6) {
                                        Image(systemName: isPlayingAudio ? "speaker.wave.3.fill" : "speaker.wave.2.fill")
                                            .font(.system(size: 18))
                                        Text("Play")
                                            .font(AppTheme.Typography.caption)
                                    }
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(AppTheme.brandSecondary)
                                    .clipShape(Capsule())
                                }
                                .disabled(isPlayingAudio)
                            }
                            
                            // Furigana Display
                            if !furiganaText.isEmpty {
                                FuriganaTextView(furiganaText: furiganaText)
                                    .padding()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(AppTheme.brandPrimary.opacity(0.05))
                                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.Layout.cornerRadius))
                            } else {
                                // Plain Japanese text if no furigana available
                                Text(inputText)
                                    .font(.system(size: 24))
                                    .foregroundColor(.primary)
                                    .padding()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(AppTheme.brandPrimary.opacity(0.05))
                                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.Layout.cornerRadius))
                            }
                        }
                        .padding()
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Layout.cornerRadius))
                        .shadow(
                            color: AppTheme.Shadows.elevation2.color,
                            radius: AppTheme.Shadows.elevation2.radius,
                            y: AppTheme.Shadows.elevation2.y
                        )
                        
                        // Translation Window
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Translation")
                                    .font(AppTheme.Typography.headline)
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                Button {
                                    copyTranslation()
                                } label: {
                                    HStack(spacing: 4) {
                                        Image(systemName: "doc.on.doc")
                                        Text("Copy")
                                    }
                                    .font(AppTheme.Typography.caption)
                                    .foregroundColor(AppTheme.brandPrimary)
                                }
                            }
                            
                            Text(translatedText)
                                .font(AppTheme.Typography.body)
                                .foregroundColor(.primary)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(AppTheme.success.opacity(0.1))
                                .clipShape(RoundedRectangle(cornerRadius: AppTheme.Layout.cornerRadius))
                        }
                        .padding()
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Layout.cornerRadius))
                        .shadow(
                            color: AppTheme.Shadows.elevation2.color,
                            radius: AppTheme.Shadows.elevation2.radius,
                            y: AppTheme.Shadows.elevation2.y
                        )
                    }
                }
                
                // Recognized Text (from image)
                if !recognizedText.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Recognized Text")
                            .font(AppTheme.Typography.headline)
                            .foregroundColor(.primary)
                        
                        Text(recognizedText)
                            .font(AppTheme.Typography.body)
                            .foregroundColor(.primary)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(AppTheme.brandPrimary.opacity(0.05))
                            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Layout.cornerRadius))
                        
                        Button {
                            inputText = recognizedText
                            recognizedText = ""
                        } label: {
                            Text("Use This Text")
                                .font(AppTheme.Typography.subheadline)
                                .foregroundColor(AppTheme.brandPrimary)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(AppTheme.brandPrimary.opacity(0.1))
                                .clipShape(RoundedRectangle(cornerRadius: AppTheme.Layout.cornerRadius))
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.Layout.cornerRadius))
                    .shadow(
                        color: AppTheme.Shadows.elevation2.color,
                        radius: AppTheme.Shadows.elevation2.radius,
                        y: AppTheme.Shadows.elevation2.y
                    )
                }
                
                // Info Card
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 8) {
                        Image(systemName: "info.circle.fill")
                            .foregroundColor(AppTheme.brandSecondary)
                        Text("How to Use")
                            .font(AppTheme.Typography.headline)
                            .foregroundColor(.primary)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        InfoRow(icon: "camera.fill", text: "Take a photo of Japanese text")
                        InfoRow(icon: "photo.fill", text: "Select from your photo library")
                        InfoRow(icon: "doc.on.clipboard.fill", text: "Paste Japanese text directly")
                    }
                }
                .padding()
                .background(AppTheme.brandSecondary.opacity(0.05))
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.Layout.cornerRadius))
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.Layout.cornerRadius)
                        .stroke(AppTheme.brandSecondary.opacity(0.2), lineWidth: 1)
                )
            }
            .padding()
        }
        .background(AppTheme.background)
        .navigationTitle("Translation")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showImagePicker) {
            TranslationImagePicker(selectedImage: $selectedImage, sourceType: .photoLibrary)
        }
        .sheet(isPresented: $showCamera) {
            TranslationImagePicker(selectedImage: $selectedImage, sourceType: .camera)
        }
        .onChange(of: selectedImage) { newImage in
            if let image = newImage {
                recognizeTextFromImage(image)
            }
        }
        .onAppear {
            AnalyticsService.shared.trackScreen("Translation", screenClass: "TranslationView")
        }
    }
    
    // MARK: - Helper Methods
    
    private func pasteText() {
        if let clipboardText = UIPasteboard.general.string {
            inputText = clipboardText
            Haptics.selection()
        }
    }
    
    private func translateText() {
        guard !inputText.isEmpty else { return }
        
        isTranslating = true
        furiganaText = ""
        translatedText = ""
        
        Task {
            do {
                // Get furigana for Japanese text
                let ruby = try await TranslatorService.shared.translateToFurigana(inputText)
                let segments = TranslatorService.shared.parseRubyText(ruby)
                let furiganaString = segments.map { segment in
                    if let reading = segment.reading {
                        return "\(segment.word)[\(reading)]"
                    } else {
                        return segment.word
                    }
                }.joined(separator: "")
                
                // Get translation
                let result = try await translationService.translate(
                    text: inputText,
                    to: TranslationLanguage(rawValue: targetLanguage) ?? .english
                )
                
                await MainActor.run {
                    self.furiganaText = furiganaString
                    self.translatedText = result
                    self.isTranslating = false
                    Haptics.success()
                }
            } catch {
                await MainActor.run {
                    self.translatedText = "Translation failed. Please try again."
                    self.isTranslating = false
                    Haptics.error()
                }
            }
        }
    }
    
    private func playAudio() {
        guard !inputText.isEmpty else { return }
        
        isPlayingAudio = true
        
        Task {
            do {
                try await audioService.speak(inputText, language: "ja-JP")
                await MainActor.run {
                    isPlayingAudio = false
                }
            } catch {
                await MainActor.run {
                    isPlayingAudio = false
                }
            }
        }
    }
    
    private func recognizeTextFromImage(_ image: UIImage) {
        Task {
            do {
                let text = try await imageRecognitionService.recognizeText(from: image)
                
                await MainActor.run {
                    recognizedText = text
                    Haptics.success()
                }
            } catch {
                await MainActor.run {
                    recognizedText = "Could not recognize text from image."
                    Haptics.error()
                }
            }
        }
    }
    
    private func copyTranslation() {
        UIPasteboard.general.string = translatedText
        Haptics.success()
        ToastManager.shared.showSuccess("Copied to clipboard")
    }
    
    private func languageName(for code: String) -> String {
        switch code {
        case "en": return "English"
        case "es": return "Spanish"
        case "fr": return "French"
        case "de": return "German"
        case "zh": return "Chinese"
        case "ko": return "Korean"
        default: return "English"
        }
    }
}

// MARK: - Info Row

private struct InfoRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(AppTheme.brandSecondary)
                .frame(width: 24)
            
            Text(text)
                .font(AppTheme.Typography.body)
                .foregroundColor(.primary)
        }
    }
}

// MARK: - Furigana Text View

struct FuriganaTextView: View {
    let furiganaText: String
    
    var body: some View {
        let segments = parseFuriganaText(furiganaText)
        
        FlowLayout(spacing: 4) {
            ForEach(Array(segments.enumerated()), id: \.offset) { index, segment in
                VStack(spacing: 2) {
                    if let furigana = segment.furigana {
                        // Furigana (reading) on top
                        Text(furigana)
                            .font(.system(size: 12))
                            .foregroundColor(AppTheme.brandSecondary)
                    } else {
                        // Empty space to maintain alignment
                        Text(" ")
                            .font(.system(size: 12))
                            .opacity(0)
                    }
                    
                    // Kanji or text below
                    Text(segment.kanji)
                        .font(.system(size: 24, weight: .medium))
                        .foregroundColor(.primary)
                }
            }
        }
    }
    
    private func parseFuriganaText(_ text: String) -> [(kanji: String, furigana: String?)] {
        var result: [(kanji: String, furigana: String?)] = []
        let currentText = text
        
        // Pattern: kanji[furigana]
        let pattern = "([^\\[]+)\\[([^\\]]+)\\]"
        let regex = try? NSRegularExpression(pattern: pattern)
        
        var lastEnd = 0
        if let regex = regex {
            let matches = regex.matches(in: currentText, range: NSRange(currentText.startIndex..., in: currentText))
            
            for match in matches {
                // Add text before this match (if any)
                if match.range.location > lastEnd {
                    let beforeRange = NSRange(location: lastEnd, length: match.range.location - lastEnd)
                    if let range = Range(beforeRange, in: currentText) {
                        let plainText = String(currentText[range])
                        if !plainText.isEmpty {
                            result.append((kanji: plainText, furigana: nil))
                        }
                    }
                }
                
                // Add kanji with furigana
                if let kanjiRange = Range(match.range(at: 1), in: currentText),
                   let furiganaRange = Range(match.range(at: 2), in: currentText) {
                    let kanji = String(currentText[kanjiRange])
                    let furigana = String(currentText[furiganaRange])
                    result.append((kanji: kanji, furigana: furigana))
                }
                
                lastEnd = match.range.location + match.range.length
            }
        }
        
        // Add remaining text
        if lastEnd < currentText.count {
            let remainingRange = NSRange(location: lastEnd, length: currentText.count - lastEnd)
            if let range = Range(remainingRange, in: currentText) {
                let remainingText = String(currentText[range])
                if !remainingText.isEmpty {
                    result.append((kanji: remainingText, furigana: nil))
                }
            }
        }
        
        return result.isEmpty ? [(kanji: text, furigana: nil)] : result
    }
}

// MARK: - Translation Image Picker

struct TranslationImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.dismiss) var dismiss
    let sourceType: UIImagePickerController.SourceType
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: TranslationImagePicker
        
        init(_ parent: TranslationImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image
            }
            parent.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        TranslationView()
    }
}


