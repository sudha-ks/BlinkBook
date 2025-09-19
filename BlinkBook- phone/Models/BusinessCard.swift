//
//  BusinessCard.swift
//  BlinkBook
//
//  Created by Sudha on 10/09/25.
//

import Foundation
import UIKit

/// Represents a business card with extracted contact information
struct BusinessCard: Codable, Identifiable {
    let id = UUID()
    var fullName: String
    var company: String
    var phoneNumber: String
    var email: String?
    var jobTitle: String?
    var address: String?
    var website: String?
    var notes: String?
    let dateCreated: Date
    let imageData: Data?
    
    /// Confidence scores for extracted data (0.0 to 1.0)
    var confidenceScores: ConfidenceScores
    
    init(
        fullName: String = "",
        company: String = "",
        phoneNumber: String = "",
        email: String? = nil,
        jobTitle: String? = nil,
        address: String? = nil,
        website: String? = nil,
        notes: String? = nil,
        imageData: Data? = nil,
        confidenceScores: ConfidenceScores = ConfidenceScores()
    ) {
        self.fullName = fullName
        self.company = company
        self.phoneNumber = phoneNumber
        self.email = email
        self.jobTitle = jobTitle
        self.address = address
        self.website = website
        self.notes = notes
        self.dateCreated = Date()
        self.imageData = imageData
        self.confidenceScores = confidenceScores
    }
}

/// Confidence scores for extracted data fields
struct ConfidenceScores: Codable {
    var fullName: Double = 0.0
    var company: Double = 0.0
    var phoneNumber: Double = 0.0
    var email: Double = 0.0
    var jobTitle: Double = 0.0
    var address: Double = 0.0
    var website: Double = 0.0
    
    /// Returns true if any field has low confidence (< 0.7)
    var hasLowConfidence: Bool {
        return fullName < 0.7 || company < 0.7 || phoneNumber < 0.7
    }
    
    /// Returns the overall confidence score
    var overallConfidence: Double {
        let scores = [fullName, company, phoneNumber, email, jobTitle, address, website]
        let validScores = scores.filter { $0 > 0 }
        return validScores.isEmpty ? 0.0 : validScores.reduce(0, +) / Double(validScores.count)
    }
}

/// Extracted data from OCR processing
struct ExtractedData: Codable {
    var fullName: String
    var company: String
    var phoneNumber: String
    var email: String?
    var jobTitle: String?
    var address: String?
    var website: String?
    var rawText: String
    var confidenceScores: ConfidenceScores
    
    init(
        fullName: String = "",
        company: String = "",
        phoneNumber: String = "",
        email: String? = nil,
        jobTitle: String? = nil,
        address: String? = nil,
        website: String? = nil,
        rawText: String = "",
        confidenceScores: ConfidenceScores = ConfidenceScores()
    ) {
        self.fullName = fullName
        self.company = company
        self.phoneNumber = phoneNumber
        self.email = email
        self.jobTitle = jobTitle
        self.address = address
        self.website = website
        self.rawText = rawText
        self.confidenceScores = confidenceScores
    }
    
    /// Converts ExtractedData to BusinessCard
    func toBusinessCard(imageData: Data? = nil) -> BusinessCard {
        return BusinessCard(
            fullName: fullName,
            company: company,
            phoneNumber: phoneNumber,
            email: email,
            jobTitle: jobTitle,
            address: address,
            website: website,
            imageData: imageData,
            confidenceScores: confidenceScores
        )
    }
}

// MARK: - Validation Extensions

extension BusinessCard {
    /// Validates if the business card has minimum required information
    var isValid: Bool {
        return !fullName.isEmpty && !company.isEmpty && !phoneNumber.isEmpty
    }
    
    /// Returns validation errors for missing required fields
    var validationErrors: [String] {
        var errors: [String] = []
        
        if fullName.isEmpty {
            errors.append("Full name is required")
        }
        
        if company.isEmpty {
            errors.append("Company name is required")
        }
        
        if phoneNumber.isEmpty {
            errors.append("Phone number is required")
        }
        
        return errors
    }
}

extension ExtractedData {
    /// Validates if the extracted data has minimum required information
    var isValid: Bool {
        return !fullName.isEmpty && !company.isEmpty && !phoneNumber.isEmpty
    }
    
    /// Returns validation errors for missing required fields
    var validationErrors: [String] {
        var errors: [String] = []
        
        if fullName.isEmpty {
            errors.append("Full name is required")
        }
        
        if company.isEmpty {
            errors.append("Company name is required")
        }
        
        if phoneNumber.isEmpty {
            errors.append("Phone number is required")
        }
        
        return errors
    }
}
