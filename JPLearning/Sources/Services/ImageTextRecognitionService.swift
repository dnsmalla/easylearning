//
//  ImageTextRecognitionService.swift
//  JLearn
//
//  Extracts Japanese text from camera or photo input using Vision.
//

import Foundation
import UIKit
@preconcurrency import Vision

@MainActor
final class ImageTextRecognitionService: ObservableObject {
    
    static let shared = ImageTextRecognitionService()
    
    private init() {}
    
    /// Recognize text (Japanese + English) from a UIImage.
    func recognizeText(from image: UIImage) async throws -> String {
        guard let cgImage = image.cgImage else {
            throw AppError.unknown("Invalid image")
        }
        
        return try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<String, Error>) in
            let request = VNRecognizeTextRequest { (request: VNRequest, error: Error?) in
                if let error = error {
                    continuation.resume(throwing: AppError.network("Text recognition failed: \(error.localizedDescription)"))
                    return
                }
                
                guard let observations = request.results as? [VNRecognizedTextObservation] else {
                    continuation.resume(returning: "")
                    return
                }
                
                let recognizedStrings: [String] = observations.compactMap { observation in
                    observation.topCandidates(1).first?.string
                }
                
                continuation.resume(returning: recognizedStrings.joined(separator: "\n"))
            }
            
            request.recognitionLanguages = ["ja", "en"]
            request.usesLanguageCorrection = true
            
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    try handler.perform([request])
                } catch {
                    continuation.resume(throwing: AppError.network("Text recognition failed: \(error.localizedDescription)"))
                }
            }
        }
    }
}



