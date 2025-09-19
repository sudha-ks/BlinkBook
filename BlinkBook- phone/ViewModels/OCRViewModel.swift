//
//  OCRViewModel.swift
//  BlinkBook
//
//  Created by Sudha on 10/09/25.
//

import Foundation
import UIKit
import Combine

/// ViewModel responsible for OCR text extraction and processing
class OCRViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var extractedData: ExtractedData?
    @Published var isProcessing = false
    @Published var errorMessage: String?
    @Published var processingProgress: Double = 0.0
    
    // MARK: - Private Properties
    private let ocrService: OCRServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    init(ocrService: OCRServiceProtocol = OCRService()) {
        self.ocrService = ocrService
    }
    
    // MARK: - Public Methods
    
    /// Processes an image to extract business card information
    /// - Parameter image: The image to process
    func processImage(_ image: UIImage) {
        print("🔍 Starting OCR processing for new image")
        
        guard !isProcessing else { 
            print("❌ OCR already processing, ignoring new request")
            return 
        }
        
        // Reset all state before processing
        resetExtractedData()
        
        isProcessing = true
        processingProgress = 0.0
        errorMessage = nil
        extractedData = nil
        
        // Cancel any existing subscriptions
        cancellables.removeAll()
        
        // Simulate progress updates
        startProgressSimulation()
        
        print("🔍 Calling OCR service...")
        ocrService.processImage(image)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    print("🔍 OCR processing completed")
                    self?.isProcessing = false
                    self?.processingProgress = 1.0
                    
                    if case .failure(let error) = completion {
                        print("❌ OCR processing failed: \(error)")
                        self?.errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { [weak self] extractedData in
                    print("✅ OCR processing successful: \(extractedData.fullName)")
                    self?.extractedData = extractedData
                    self?.isProcessing = false
                    self?.processingProgress = 1.0
                }
            )
            .store(in: &cancellables)
    }
    
    /// Updates the extracted data with user modifications
    /// - Parameter data: The modified extracted data
    func updateExtractedData(_ data: ExtractedData) {
        extractedData = data
    }
    
    /// Validates the current extracted data
    /// - Returns: True if the data is valid, false otherwise
    func validateExtractedData() -> Bool {
        return extractedData?.isValid ?? false
    }
    
    /// Gets validation errors for the current extracted data
    /// - Returns: Array of validation error messages
    func getValidationErrors() -> [String] {
        return extractedData?.validationErrors ?? []
    }
    
    /// Clears any error messages
    func clearError() {
        errorMessage = nil
    }
    
    /// Resets the extracted data
    func resetExtractedData() {
        extractedData = nil
        errorMessage = nil
        processingProgress = 0.0
    }
    
    // MARK: - Private Methods
    
    /// Simulates progress updates during OCR processing
    private func startProgressSimulation() {
        let timer = Timer.publish(every: 0.1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self, self.isProcessing else { return }
                
                if self.processingProgress < 0.9 {
                    self.processingProgress += 0.05
                }
            }
        
        // Store the timer to prevent it from being deallocated
        cancellables.insert(timer)
    }
}
