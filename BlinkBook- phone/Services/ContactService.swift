//
//  ContactService.swift
//  BlinkBook
//
//  Created by Sudha on 10/09/25.
//

import Foundation
import Contacts
import Combine

/// Protocol for contact service to enable dependency injection and testing
protocol ContactServiceProtocol {
    func requestPermission() -> AnyPublisher<Bool, ContactError>
    func saveContact(_ businessCard: BusinessCard) -> AnyPublisher<Bool, ContactError>
    func checkPermissionStatus() -> ContactPermissionStatus
}

/// Service responsible for managing contacts and saving business card data
class ContactService: ContactServiceProtocol {
    
    // MARK: - Properties
    private let contactStore = CNContactStore()
    
    // MARK: - Public Methods
    
    /// Requests permission to access contacts
    /// - Returns: A publisher that emits true if permission is granted, false otherwise
    func requestPermission() -> AnyPublisher<Bool, ContactError> {
        return Future<Bool, ContactError> { [weak self] promise in
            self?.contactStore.requestAccess(for: .contacts) { granted, error in
                if let error = error {
                    promise(.failure(.permissionDenied))
                } else {
                    promise(.success(granted))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    /// Saves a business card as a contact
    /// - Parameter businessCard: The business card data to save
    /// - Returns: A publisher that emits true if saved successfully, false otherwise
    func saveContact(_ businessCard: BusinessCard) -> AnyPublisher<Bool, ContactError> {
        return Future<Bool, ContactError> { [weak self] promise in
            guard let self = self else {
                promise(.failure(.unknown))
                return
            }
            
            // Check permission first
            guard self.checkPermissionStatus() == .authorized else {
                promise(.failure(.permissionDenied))
                return
            }
            
            // Create contact
            let contact = self.createContact(from: businessCard)
            
            // Save contact
            let saveRequest = CNSaveRequest()
            saveRequest.add(contact, toContainerWithIdentifier: nil)
            
            do {
                try self.contactStore.execute(saveRequest)
                print("✅ Contact saved successfully: \(businessCard.fullName)")
                promise(.success(true))
            } catch {
                print("❌ Contact save failed: \(error.localizedDescription)")
                print("Contact details: Name=\(businessCard.fullName), Company=\(businessCard.company), Phone=\(businessCard.phoneNumber)")
                promise(.failure(.saveFailed))
            }
        }
        .eraseToAnyPublisher()
    }
    
    /// Checks the current permission status for contacts
    /// - Returns: The current permission status
    func checkPermissionStatus() -> ContactPermissionStatus {
        let status = CNContactStore.authorizationStatus(for: .contacts)
        
        switch status {
        case .authorized:
            return .authorized
        case .denied, .restricted:
            return .denied
        case .notDetermined:
            return .notDetermined
        @unknown default:
            return .notDetermined
        }
    }
    
    // MARK: - Private Methods
    
    /// Creates a CNContact from a BusinessCard
    private func createContact(from businessCard: BusinessCard) -> CNMutableContact {
        let contact = CNMutableContact()
        
        // Set name
        let nameComponents = businessCard.fullName.components(separatedBy: " ")
        if nameComponents.count >= 2 {
            contact.givenName = nameComponents[0]
            contact.familyName = nameComponents.dropFirst().joined(separator: " ")
        } else {
            contact.givenName = businessCard.fullName
        }
        
        // Set organization
        contact.organizationName = businessCard.company
        
        // Set job title
        if let jobTitle = businessCard.jobTitle {
            contact.jobTitle = jobTitle
        }
        
        // Set phone number
        if !businessCard.phoneNumber.isEmpty {
            let phoneNumber = CNPhoneNumber(stringValue: businessCard.phoneNumber)
            let phoneLabel = CNLabeledValue(label: CNLabelWork, value: phoneNumber)
            contact.phoneNumbers = [phoneLabel]
        }
        
        // Set email
        if let email = businessCard.email {
            let emailLabel = CNLabeledValue(label: CNLabelWork, value: email as NSString)
            contact.emailAddresses = [emailLabel]
        }
        
        // Set address
        if let address = businessCard.address {
            let addressLabel = CNLabeledValue(label: CNLabelWork, value: createPostalAddress(from: address))
            contact.postalAddresses = [addressLabel]
        }
        
        // Set website
        if let website = businessCard.website {
            let websiteLabel = CNLabeledValue(label: CNLabelWork, value: website as NSString)
            contact.urlAddresses = [websiteLabel]
        }
        
        // Set notes
        if let notes = businessCard.notes {
            contact.note = notes
        }
        
        return contact
    }
    
    /// Creates a CNPostalAddress from a string address
    private func createPostalAddress(from addressString: String) -> CNPostalAddress {
        let postalAddress = CNMutablePostalAddress()
        postalAddress.street = addressString
        return postalAddress
    }
}

// MARK: - Supporting Types

/// Contact permission status
enum ContactPermissionStatus {
    case authorized
    case denied
    case notDetermined
}

/// Contact-related errors
enum ContactError: LocalizedError {
    case permissionDenied
    case saveFailed
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .permissionDenied:
            return Constants.ErrorMessages.contactsPermissionDenied
        case .saveFailed:
            return Constants.ErrorMessages.saveContactFailed
        case .unknown:
            return "An unknown error occurred while saving the contact."
        }
    }
}
