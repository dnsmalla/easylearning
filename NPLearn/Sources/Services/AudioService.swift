//
//  AudioService.swift
//  NPLearn
//
//  Audio playback and Text-to-Speech service
//

import Foundation
import AVFoundation

// MARK: - Audio Service

@MainActor
final class AudioService: ObservableObject {
    
    static let shared = AudioService()
    
    @Published var isPlaying = false
    @Published var isSpeaking = false
    
    private var audioPlayer: AVAudioPlayer?
    private let speechSynthesizer = AVSpeechSynthesizer()
    
    nonisolated private init() {}
    
    // MARK: - Audio Playback
    
    func playAudio(from url: String) async throws {
        guard let audioURL = URL(string: url) else {
            throw AppError.validation("Invalid audio URL")
        }
        
        do {
            let data = try Data(contentsOf: audioURL)
            audioPlayer = try AVAudioPlayer(data: data)
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
            isPlaying = true
            
            // Wait for audio to finish
            while audioPlayer?.isPlaying == true {
                try await Task.sleep(nanoseconds: 100_000_000)
            }
            
            isPlaying = false
        } catch {
            isPlaying = false
            throw AppError.unknown("Failed to play audio: \(error.localizedDescription)")
        }
    }
    
    func stopAudio() {
        audioPlayer?.stop()
        isPlaying = false
    }
    
    // MARK: - Text-to-Speech
    
    func speak(text: String, language: String = "ne-NP") async {
        isSpeaking = true
        
        // Try to get the preferred voice, fallback to available alternatives
        var voice: AVSpeechSynthesisVoice?
        
        // Try Nepali first
        voice = AVSpeechSynthesisVoice(language: "ne-NP")
        
        // Fallback chain: Nepali -> Hindi -> English
        if voice == nil {
            AppLogger.warning("Nepali voice not available, trying Hindi")
            voice = AVSpeechSynthesisVoice(language: "hi-IN")
        }
        
        if voice == nil {
            AppLogger.warning("Hindi voice not available, using English")
            voice = AVSpeechSynthesisVoice(language: "en-US")
        }
        
        // Single utterance - slow and clear
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = voice
        utterance.rate = 0.2  // Very slow for learning
        utterance.pitchMultiplier = 1.0
        utterance.volume = 1.0
        utterance.preUtteranceDelay = 0.1  // Short pause before speaking
        utterance.postUtteranceDelay = 0.2  // Pause after speaking
        
        speechSynthesizer.speak(utterance)
        
        // Wait for utterance to finish
        while speechSynthesizer.isSpeaking {
            await Task.yield()
            try? await Task.sleep(nanoseconds: 100_000_000)
        }
        
        isSpeaking = false
    }
    
    func stopSpeaking() {
        speechSynthesizer.stopSpeaking(at: .immediate)
        isSpeaking = false
    }
    
    // MARK: - Voice Availability Check
    
    func checkAvailableVoices() -> [String] {
        let allVoices = AVSpeechSynthesisVoice.speechVoices()
        let languages = Set(allVoices.map { $0.language })
        AppLogger.info("Available voice languages: \(languages.sorted().joined(separator: ", "))")
        return Array(languages)
    }
    
    // MARK: - Audio Session
    
    func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            AppLogger.error("Failed to setup audio session", error: error)
        }
    }
}

