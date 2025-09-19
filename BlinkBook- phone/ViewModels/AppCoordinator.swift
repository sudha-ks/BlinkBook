//
//  AppCoordinator.swift
//  BlinkBook
//
//  Created by Sudha on 10/09/25.
//

import Foundation
import Combine
import UIKit

/// Main app coordinator that manages navigation and state between different screens
class AppCoordinator: ObservableObject {
    
    // MARK: - Published Properties
    @Published var currentScreen: AppScreen = .camera
    @Published var capturedImage: UIImage?
    @Published var extractedData: ExtractedData?
    @Published var businessCard: BusinessCard?
    
    // MARK: - History Manager
    @Published var historyManager = ContactHistoryManager()
    
    // MARK: - Private Properties
    private let cameraViewModel: CameraViewModel
    private let ocrViewModel: OCRViewModel
    private let contactViewModel: ContactViewModel
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    init() {
        self.cameraViewModel = CameraViewModel()
        self.ocrViewModel = OCRViewModel()
        self.contactViewModel = ContactViewModel()
        
        setupBindings()
    }
    
    // MARK: - Public Methods
    
    /// Navigates to the specified screen
    /// - Parameter screen: The screen to navigate to
    func navigateTo(_ screen: AppScreen) {
        currentScreen = screen
    }
    
    /// Handles image capture from camera
    /// - Parameter image: The captured image
    func handleImageCapture(_ image: UIImage) {
        print("📸 Handling new image capture - clearing previous state")
        
        // Clear any previous state first
        extractedData = nil
        businessCard = nil
        ocrViewModel.resetExtractedData()
        
        // Set new image and navigate
        capturedImage = image
        navigateTo(.processing)
        
        // Start OCR processing with fresh state
        ocrViewModel.processImage(image)
    }
    
    /// Handles OCR completion
    /// - Parameter extractedData: The extracted data from OCR
    func handleOCRCompletion(_ extractedData: ExtractedData) {
        self.extractedData = extractedData
        navigateTo(.review)
    }
    
    /// Handles contact saving
    /// - Parameter businessCard: The business card to save
    func handleContactSaving(_ businessCard: BusinessCard) {
        self.businessCard = businessCard
        contactViewModel.saveContact(businessCard)
    }
    
    /// Adds a contact to history
    /// - Parameters:
    ///   - businessCard: The business card to add
    ///   - wasSuccessful: Whether the save was successful
    func addToHistory(_ businessCard: BusinessCard, wasSuccessful: Bool = true) {
        historyManager.addToHistory(businessCard, wasSuccessful: wasSuccessful)
    }
    
    /// Resets the app to the camera screen
    func resetToCamera() {
        print("🔄 Resetting app to camera - clearing all state")
        
        // Reset screen first
        currentScreen = .camera
        
        // Clear coordinator state
        capturedImage = nil
        extractedData = nil
        businessCard = nil
        
        // Reset all view models
        cameraViewModel.resetCapturedImage()
        cameraViewModel.clearError()
        
        ocrViewModel.resetExtractedData()
        ocrViewModel.clearError()
        
        contactViewModel.clearMessages()
        
        print("✅ App state reset complete")
    }
    
    /// Gets the camera view model
    var cameraVM: CameraViewModel {
        return cameraViewModel
    }
    
    /// Gets the OCR view model
    var ocrVM: OCRViewModel {
        return ocrViewModel
    }
    
    /// Gets the contact view model
    var contactVM: ContactViewModel {
        return contactViewModel
    }
    
    // MARK: - Private Methods
    
    /// Sets up bindings between view models
    private func setupBindings() {
        // Bind camera image capture to OCR processing
        cameraViewModel.$capturedImage
            .compactMap { $0 }
            .sink { [weak self] image in
                print("📸 Coordinator received new captured image")
                self?.handleImageCapture(image)
            }
            .store(in: &cancellables)
        
        // Bind OCR completion to navigation
        ocrViewModel.$extractedData
            .compactMap { $0 }
            .sink { [weak self] extractedData in
                self?.handleOCRCompletion(extractedData)
            }
            .store(in: &cancellables)
        
        // Bind contact saving success to navigation
        contactViewModel.$successMessage
            .compactMap { $0 }
            .sink { [weak self] _ in
                // Add to history on successful save
                if let businessCard = self?.businessCard {
                    self?.addToHistory(businessCard, wasSuccessful: true)
                }
                
                // Navigate to success screen
                self?.navigateTo(.success)
            }
            .store(in: &cancellables)
        
        // Bind contact saving failure to history
        contactViewModel.$errorMessage
            .compactMap { $0 }
            .sink { [weak self] _ in
                // Add to history on failed save
                if let businessCard = self?.businessCard {
                    self?.addToHistory(businessCard, wasSuccessful: false)
                }
            }
            .store(in: &cancellables)
    }
}

// MARK: - App Screen Enum

/// Represents the different screens in the app
enum AppScreen {
    case camera
    case processing
    case review
    case success
    case history
}
