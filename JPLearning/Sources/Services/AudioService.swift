//
//  AudioService.swift
//  JLearn
//
//  Audio playback and Text-to-Speech service
//

import Foundation
import AVFoundation
import Speech

// MARK: - Audio Service

@MainActor
final class AudioService: NSObject, ObservableObject {
    
    static let shared = AudioService()
    
    @Published var isPlaying = false
    @Published var isRecording = false
    @Published var recognizedText = ""
    
    private var audioPlayer: AVAudioPlayer?
    private var audioEngine: AVAudioEngine?
    private var speechRecognizer: SFSpeechRecognizer?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let synthesizer = AVSpeechSynthesizer()
    
    override nonisolated init() {
        super.init()
        Task { @MainActor in
            setupAudio()
        }
    }
    
    private func setupAudio() {
        // Setup speech recognizer for Japanese
        speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "ja-JP"))
        
        // Setup audio session
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
            try audioSession.setActive(true)
        } catch {
            print("Failed to setup audio session: \(error)")
        }
    }
    
    // MARK: - Text-to-Speech
    
    func speak(_ text: String, language: String = "ja-JP", rate: Float = 0.5) async throws {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: language)
        utterance.rate = rate
        
        await MainActor.run {
            isPlaying = true
            synthesizer.speak(utterance)
        }
        
        // Wait for speech to finish
        await withCheckedContinuation { continuation in
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(text.count) * 0.1) {
                continuation.resume()
            }
        }
        
        await MainActor.run {
            isPlaying = false
        }
    }
    
    func stopSpeaking() {
        synthesizer.stopSpeaking(at: .immediate)
        isPlaying = false
    }
    
    // MARK: - Audio Playback
    
    func playAudio(from url: URL) async throws {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.prepareToPlay()
            
            await MainActor.run {
                isPlaying = true
                audioPlayer?.play()
            }
            
            // Wait for audio to finish
            let duration = audioPlayer?.duration ?? 0
            try await Task.sleep(nanoseconds: UInt64(duration * 1_000_000_000))
            
            await MainActor.run {
                isPlaying = false
            }
        } catch {
            await MainActor.run {
                isPlaying = false
            }
            throw AppError.unknown("Failed to play audio: \(error.localizedDescription)")
        }
    }
    
    func playAudio(from urlString: String) async throws {
        guard let url = URL(string: urlString) else {
            throw AppError.validation("Invalid audio URL")
        }
        
        // Download audio if it's a remote URL
        if urlString.hasPrefix("http") {
            let (data, _) = try await URLSession.shared.data(from: url)
            let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("temp_audio.mp3")
            try data.write(to: tempURL)
            try await playAudio(from: tempURL)
        } else {
            try await playAudio(from: url)
        }
    }
    
    func stopAudio() {
        audioPlayer?.stop()
        isPlaying = false
    }
    
    // MARK: - Speech Recognition
    
    func requestSpeechRecognitionPermission() async -> Bool {
        return await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                continuation.resume(returning: status == .authorized)
            }
        }
    }
    
    func startRecording() async throws {
        // Cancel previous task if exists
        recognitionTask?.cancel()
        recognitionTask = nil
        
        // Check permission
        let hasPermission = await requestSpeechRecognitionPermission()
        guard hasPermission else {
            throw AppError.validation("Speech recognition permission denied")
        }
        
        // Setup audio engine
        audioEngine = AVAudioEngine()
        guard let audioEngine = audioEngine else {
            throw AppError.unknown("Failed to create audio engine")
        }
        
        let inputNode = audioEngine.inputNode
        
        // Create recognition request
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else {
            throw AppError.unknown("Failed to create recognition request")
        }
        
        recognitionRequest.shouldReportPartialResults = true
        
        // Start recognition task
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            guard let self = self else { return }
            
            Task { @MainActor in
                if let result = result {
                    self.recognizedText = result.bestTranscription.formattedString
                }
                
                if error != nil || result?.isFinal == true {
                    audioEngine.stop()
                    inputNode.removeTap(onBus: 0)
                    self.recognitionRequest = nil
                    self.recognitionTask = nil
                    self.isRecording = false
                }
            }
        }
        
        // Configure audio format
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            recognitionRequest.append(buffer)
        }
        
        audioEngine.prepare()
        try audioEngine.start()
        
        await MainActor.run {
            isRecording = true
            recognizedText = ""
        }
    }
    
    func stopRecording() {
        audioEngine?.stop()
        audioEngine?.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        isRecording = false
    }
    
    // MARK: - Available Voices
    
    func availableVoices(for language: String = "ja") -> [AVSpeechSynthesisVoice] {
        return AVSpeechSynthesisVoice.speechVoices().filter { voice in
            voice.language.hasPrefix(language)
        }
    }
}

