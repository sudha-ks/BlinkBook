//
//  OCRService.swift
//  BlinkBook
//
//  Created by Sudha on 10/09/25.
//

import Foundation
import Vision
import UIKit
import Combine

/// Protocol for OCR service to enable dependency injection and testing
protocol OCRServiceProtocol {
    func processImage(_ image: UIImage) -> AnyPublisher<ExtractedData, OCRError>
}

/// Service responsible for OCR text extraction from business card images
class OCRService: OCRServiceProtocol {
    
    // MARK: - Properties
    private let textRecognitionQueue = DispatchQueue(label: "com.blinkbook.ocr", qos: .userInitiated)
    
    // MARK: - Public Methods
    
    /// Processes a business card image and extracts contact information
    /// - Parameter image: The captured business card image
    /// - Returns: A publisher that emits extracted data or an error
    func processImage(_ image: UIImage) -> AnyPublisher<ExtractedData, OCRError> {
        return Future<ExtractedData, OCRError> { [weak self] promise in
            self?.textRecognitionQueue.async {
                self?.performTextRecognition(on: image, completion: promise)
            }
        }
        .eraseToAnyPublisher()
    }
    
    // MARK: - Private Methods
    
    /// Performs text recognition on the image
    private func performTextRecognition(on image: UIImage, completion: @escaping (Result<ExtractedData, OCRError>) -> Void) {
        guard let cgImage = image.cgImage else {
            completion(.failure(.invalidImage))
            return
        }
        
        let request = VNRecognizeTextRequest { [weak self] request, error in
            if let error = error {
                completion(.failure(.processingFailed))
                return
            }
            
            guard let observations = request.results as? [VNRecognizedTextObservation] else {
                completion(.failure(.noTextDetected))
                return
            }
            
            let extractedData = self?.extractContactData(from: observations) ?? ExtractedData()
            
            if extractedData.rawText.isEmpty {
                completion(.failure(.noTextDetected))
            } else {
                completion(.success(extractedData))
            }
        }
        
        // Configure the request for better accuracy
        request.recognitionLevel = .accurate
        request.recognitionLanguages = Constants.OCR.supportedLanguages
        request.usesLanguageCorrection = true
        
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        
        do {
            try handler.perform([request])
        } catch {
            completion(.failure(.processingFailed))
        }
    }
    
    /// Extracts contact data from text observations
    private func extractContactData(from observations: [VNRecognizedTextObservation]) -> ExtractedData {
        var allText: [String] = []
        var textWithConfidence: [(String, Double)] = []
        
        // Collect all recognized text with confidence scores
        for observation in observations {
            if let topCandidate = observation.topCandidates(1).first {
                let text = topCandidate.string
                let confidence = Double(topCandidate.confidence)
                allText.append(text)
                textWithConfidence.append((text, confidence))
            }
        }
        
        let rawText = allText.joined(separator: " ")
        
        // Extract specific information
        let fullName = extractFullName(from: textWithConfidence)
        let company = extractCompany(from: textWithConfidence)
        let phoneNumber = extractPhoneNumber(from: textWithConfidence)
        let email = extractEmail(from: textWithConfidence)
        let jobTitle = extractJobTitle(from: textWithConfidence)
        let address = extractAddress(from: textWithConfidence)
        let website = extractWebsite(from: textWithConfidence)
        
        // Calculate confidence scores
        let confidenceScores = ConfidenceScores(
            fullName: getConfidenceForText(fullName, in: textWithConfidence),
            company: getConfidenceForText(company, in: textWithConfidence),
            phoneNumber: getConfidenceForText(phoneNumber, in: textWithConfidence),
            email: getConfidenceForText(email ?? "", in: textWithConfidence),
            jobTitle: getConfidenceForText(jobTitle ?? "", in: textWithConfidence),
            address: getConfidenceForText(address ?? "", in: textWithConfidence),
            website: getConfidenceForText(website ?? "", in: textWithConfidence)
        )
        
        return ExtractedData(
            fullName: fullName,
            company: company,
            phoneNumber: phoneNumber,
            email: email,
            jobTitle: jobTitle,
            address: address,
            website: website,
            rawText: rawText,
            confidenceScores: confidenceScores
        )
    }
    
    /// Extracts full name from recognized text
    private func extractFullName(from textWithConfidence: [(String, Double)]) -> String {
        // Look for text that appears to be a person's name
        // Typically appears at the top of business cards
        let namePatterns = [
            "^[A-Z][a-z]+ [A-Z][a-z]+$", // First Last
            "^[A-Z][a-z]+ [A-Z]\\. [A-Z][a-z]+$", // First M. Last
            "^[A-Z][a-z]+ [A-Z][a-z]+ [A-Z][a-z]+$" // First Middle Last
        ]
        
        for (text, _) in textWithConfidence {
            for pattern in namePatterns {
                if text.range(of: pattern, options: .regularExpression) != nil {
                    return text.trimmed
                }
            }
        }
        
        // Fallback: return the first line that looks like a name
        for (text, _) in textWithConfidence {
            if text.isAlphabetic && text.components(separatedBy: " ").count >= 2 {
                return text.trimmed
            }
        }
        
        return ""
    }
    
    /// Extracts company name from recognized text
    private func extractCompany(from textWithConfidence: [(String, Double)]) -> String {
        // Look for company indicators
        let companyIndicators = ["Inc", "LLC", "Corp", "Ltd", "Company", "Co", "Group", "Associates"]
        
        for (text, _) in textWithConfidence {
            let upperText = text.uppercased()
            for indicator in companyIndicators {
                if upperText.contains(indicator) {
                    return text.trimmed
                }
            }
        }
        
        // Fallback: return text that looks like a company name
        for (text, _) in textWithConfidence {
            if text.count > 3 && text.count < 50 && !text.contains("@") && !text.contains("www") {
                return text.trimmed
            }
        }
        
        return ""
    }
    
    /// Extracts phone number from recognized text
    private func extractPhoneNumber(from textWithConfidence: [(String, Double)]) -> String {
        for (text, _) in textWithConfidence {
            if let phoneNumber = String.extractPhoneNumber(from: text) {
                return phoneNumber
            }
        }
        return ""
    }
    
    /// Extracts email address from recognized text
    private func extractEmail(from textWithConfidence: [(String, Double)]) -> String? {
        for (text, _) in textWithConfidence {
            if let email = String.extractEmail(from: text) {
                return email
            }
        }
        return nil
    }
    
    /// Extracts job title from recognized text
    private func extractJobTitle(from textWithConfidence: [(String, Double)]) -> String? {
        let titleIndicators = ["Manager", "Director", "President", "CEO", "CTO", "CFO", "VP", "Senior", "Lead", "Head", "Chief"]
        
        for (text, _) in textWithConfidence {
            let upperText = text.uppercased()
            for indicator in titleIndicators {
                if upperText.contains(indicator) {
                    return text.trimmed
                }
            }
        }
        
        return nil
    }
    
    /// Extracts address from recognized text
    private func extractAddress(from textWithConfidence: [(String, Double)]) -> String? {
        // Look for address patterns (street numbers, common address words)
        let addressIndicators = ["Street", "St", "Avenue", "Ave", "Road", "Rd", "Drive", "Dr", "Lane", "Ln", "Boulevard", "Blvd"]
        
        for (text, _) in textWithConfidence {
            let upperText = text.uppercased()
            for indicator in addressIndicators {
                if upperText.contains(indicator) {
                    return text.trimmed
                }
            }
        }
        
        return nil
    }
    
    /// Extracts website from recognized text
    private func extractWebsite(from textWithConfidence: [(String, Double)]) -> String? {
        for (text, _) in textWithConfidence {
            if let website = String.extractWebsite(from: text) {
                return website
            }
        }
        return nil
    }
    
    /// Gets confidence score for a specific text
    private func getConfidenceForText(_ text: String, in textWithConfidence: [(String, Double)]) -> Double {
        guard !text.isEmpty else { return 0.0 }
        
        for (recognizedText, confidence) in textWithConfidence {
            if recognizedText.contains(text) || text.contains(recognizedText) {
                return confidence
            }
        }
        
        return 0.5 // Default confidence if not found
    }
}
