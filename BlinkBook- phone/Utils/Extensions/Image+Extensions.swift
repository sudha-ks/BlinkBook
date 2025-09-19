//
//  Image+Extensions.swift
//  BlinkBook
//
//  Created by Sudha on 10/09/25.
//

import UIKit
import Vision

extension UIImage {
    
    /// Resizes the image to the specified size while maintaining aspect ratio
    func resized(to size: CGSize) -> UIImage? {
        let aspectRatio = self.size.width / self.size.height
        var newSize = size
        
        if size.width / size.height > aspectRatio {
            newSize.width = size.height * aspectRatio
        } else {
            newSize.height = size.width / aspectRatio
        }
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        defer { UIGraphicsEndImageContext() }
        
        self.draw(in: CGRect(origin: .zero, size: newSize))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    /// Resizes the image to fit within the specified maximum size
    func resizedToFit(maxSize: CGSize) -> UIImage? {
        let aspectRatio = self.size.width / self.size.height
        var newSize = maxSize
        
        if maxSize.width / maxSize.height > aspectRatio {
            newSize.width = maxSize.height * aspectRatio
        } else {
            newSize.height = maxSize.width / aspectRatio
        }
        
        return self.resized(to: newSize)
    }
    
    /// Converts the image to JPEG data with specified compression quality
    func toJPEGData(compressionQuality: CGFloat = Constants.Camera.compressionQuality) -> Data? {
        return self.jpegData(compressionQuality: compressionQuality)
    }
    
    /// Converts the image to PNG data
    func toPNGData() -> Data? {
        return self.pngData()
    }
    
    /// Crops the image to the specified rectangle
    func cropped(to rect: CGRect) -> UIImage? {
        guard let cgImage = self.cgImage?.cropping(to: rect) else { return nil }
        return UIImage(cgImage: cgImage, scale: self.scale, orientation: self.imageOrientation)
    }
    
    /// Rotates the image by the specified angle
    func rotated(by angle: CGFloat) -> UIImage? {
        let radians = angle * .pi / 180
        let rotatedSize = CGRect(origin: .zero, size: self.size)
            .applying(CGAffineTransform(rotationAngle: radians))
            .integral.size
        
        UIGraphicsBeginImageContextWithOptions(rotatedSize, false, self.scale)
        defer { UIGraphicsEndImageContext() }
        
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        
        context.translateBy(x: rotatedSize.width / 2, y: rotatedSize.height / 2)
        context.rotate(by: radians)
        context.scaleBy(x: 1.0, y: -1.0)
        
        let rect = CGRect(x: -self.size.width / 2, y: -self.size.height / 2, 
                         width: self.size.width, height: self.size.height)
        context.draw(self.cgImage!, in: rect)
        
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    /// Fixes the orientation of the image
    func fixedOrientation() -> UIImage? {
        if self.imageOrientation == .up {
            return self
        }
        
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        defer { UIGraphicsEndImageContext() }
        
        self.draw(in: CGRect(origin: .zero, size: self.size))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    /// Detects text in the image using Vision framework
    func detectText(completion: @escaping (Result<[String], Error>) -> Void) {
        guard let cgImage = self.cgImage else {
            completion(.failure(OCRError.invalidImage))
            return
        }
        
        let request = VNRecognizeTextRequest { request, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let observations = request.results as? [VNRecognizedTextObservation] else {
                completion(.success([]))
                return
            }
            
            let recognizedStrings = observations.compactMap { observation in
                observation.topCandidates(1).first?.string
            }
            
            completion(.success(recognizedStrings))
        }
        
        request.recognitionLevel = .accurate
        request.recognitionLanguages = Constants.OCR.supportedLanguages
        
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform([request])
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    /// Detects text with confidence scores
    func detectTextWithConfidence(completion: @escaping (Result<[(String, Double)], Error>) -> Void) {
        guard let cgImage = self.cgImage else {
            completion(.failure(OCRError.invalidImage))
            return
        }
        
        let request = VNRecognizeTextRequest { request, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let observations = request.results as? [VNRecognizedTextObservation] else {
                completion(.success([]))
                return
            }
            
            let recognizedTextWithConfidence = observations.compactMap { observation -> (String, Double)? in
                guard let topCandidate = observation.topCandidates(1).first else { return nil }
                return (topCandidate.string, Double(topCandidate.confidence))
            }
            
            completion(.success(recognizedTextWithConfidence))
        }
        
        request.recognitionLevel = .accurate
        request.recognitionLanguages = Constants.OCR.supportedLanguages
        
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform([request])
            } catch {
                completion(.failure(error))
            }
        }
    }
}

// MARK: - OCRError Definition

enum OCRError: LocalizedError {
    case invalidImage
    case noTextDetected
    case processingFailed
    case unsupportedImageFormat
    
    var errorDescription: String? {
        switch self {
        case .invalidImage:
            return Constants.ErrorMessages.invalidImage
        case .noTextDetected:
            return Constants.ErrorMessages.noTextDetected
        case .processingFailed:
            return Constants.ErrorMessages.processingFailed
        case .unsupportedImageFormat:
            return "Unsupported image format. Please use JPEG or PNG images."
        }
    }
}
