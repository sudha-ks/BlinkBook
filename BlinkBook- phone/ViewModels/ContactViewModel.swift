//
//  ContactViewModel.swift
//  BlinkBook
//
//  Created by Sudha on 10/09/25.
//

import Foundation
import Combine

/// ViewModel responsible for contact management and saving
class ContactViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var permissionStatus: ContactPermissionStatus = .notDetermined
    @Published var isSaving = false
    @Published var errorMessage: String?
    @Published var successMessage: String?
    
    // MARK: - Private Properties
    private let contactService: ContactServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    init(contactService: ContactServiceProtocol = ContactService()) {
        self.contactService = contactService
        checkPermissionStatus()
    }
    
    // MARK: - Public Methods
    
    /// Checks the current contacts permission status
    func checkPermissionStatus() {
        permissionStatus = contactService.checkPermissionStatus()
    }
    
    /// Requests permission to access contacts
    func requestPermission() {
        contactService.requestPermission()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure = completion {
                        self?.errorMessage = Constants.ErrorMessages.contactsPermissionDenied
                    }
                },
                receiveValue: { [weak self] granted in
                    self?.permissionStatus = granted ? .authorized : .denied
                }
            )
            .store(in: &cancellables)
    }
    
    /// Requests permission and then saves the contact if granted
    private func requestPermissionAndThenSave(_ businessCard: BusinessCard) {
        contactService.requestPermission()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure = completion {
                        self?.errorMessage = Constants.ErrorMessages.contactsPermissionDenied
                    }
                },
                receiveValue: { [weak self] granted in
                    self?.permissionStatus = granted ? .authorized : .denied
                    if granted {
                        print("✅ Contact permission granted, now saving contact...")
                        // Now save the contact
                        self?.saveContact(businessCard)
                    } else {
                        print("❌ Contact permission denied by user")
                        self?.errorMessage = Constants.ErrorMessages.contactsPermissionDenied
                    }
                }
            )
            .store(in: &cancellables)
    }
    
    /// Saves a business card as a contact
    /// - Parameter businessCard: The business card data to save
    func saveContact(_ businessCard: BusinessCard) {
        guard !isSaving else { return }
        
        // Check permission status first
        let permissionStatus = contactService.checkPermissionStatus()
        print("📱 Contact permission status: \(permissionStatus)")
        
        if permissionStatus != .authorized {
            print("❌ Contact permission not authorized, requesting permission...")
            requestPermissionAndThenSave(businessCard)
            return
        }
        
        // Validate business card data
        guard businessCard.isValid else {
            print("❌ Invalid business card data: \(businessCard.validationErrors)")
            errorMessage = "Invalid contact data: \(businessCard.validationErrors.joined(separator: ", "))"
            return
        }
        
        print("💾 Attempting to save contact: \(businessCard.fullName)")
        isSaving = true
        errorMessage = nil
        successMessage = nil
        
        contactService.saveContact(businessCard)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isSaving = false
                    
                    if case .failure(let error) = completion {
                        print("❌ Contact save completion error: \(error.localizedDescription)")
                        self?.errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { [weak self] success in
                    self?.isSaving = false
                    if success {
                        print("✅ Contact saved successfully!")
                        self?.successMessage = Constants.SuccessMessages.contactSaved
                    } else {
                        print("❌ Contact save returned false")
                        self?.errorMessage = Constants.ErrorMessages.saveContactFailed
                    }
                }
            )
            .store(in: &cancellables)
    }
    
    /// Saves extracted data as a contact
    /// - Parameter extractedData: The extracted data to save
    /// - Parameter imageData: Optional image data to include
    func saveExtractedData(_ extractedData: ExtractedData, imageData: Data? = nil) {
        let businessCard = extractedData.toBusinessCard(imageData: imageData)
        saveContact(businessCard)
    }
    
    /// Clears any error messages
    func clearError() {
        errorMessage = nil
    }
    
    /// Clears any success messages
    func clearSuccessMessage() {
        successMessage = nil
    }
    
    /// Clears all messages
    func clearMessages() {
        errorMessage = nil
        successMessage = nil
    }
}
