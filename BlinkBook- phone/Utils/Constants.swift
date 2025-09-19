//
//  Constants.swift
//  BlinkBook
//
//  Created by Sudha on 10/09/25.
//

import Foundation
import SwiftUI

/// Application-wide constants and configuration
struct Constants {
    
    // MARK: - App Information
    struct App {
        static let name = "BlinkBook"
        static let version = "1.0.0"
        static let bundleIdentifier = "com.funprojects.BlinkBook"
    }
    
    // MARK: - Design System
    struct DesignSystem {
        
        // Colors
        struct Colors {
            static let primary = Color.blue
            static let primaryDark = Color.blue.opacity(0.8)
            static let secondary = Color.gray
            static let secondaryLight = Color.gray.opacity(0.3)
            static let success = Color.green
            static let error = Color.red
            static let warning = Color.orange
            static let background = Color(.systemBackground)
            static let secondaryBackground = Color(.secondarySystemBackground)
            static let text = Color(.label)
            static let secondaryText = Color(.secondaryLabel)
        }
        
        // Typography
        struct Typography {
            static let largeTitle = Font.largeTitle
            static let title = Font.title
            static let title2 = Font.title2
            static let title3 = Font.title3
            static let headline = Font.headline
            static let body = Font.body
            static let callout = Font.callout
            static let subheadline = Font.subheadline
            static let footnote = Font.footnote
            static let caption = Font.caption
            static let caption2 = Font.caption2
        }
        
        // Spacing
        struct Spacing {
            static let extraSmall: CGFloat = 4
            static let small: CGFloat = 8
            static let medium: CGFloat = 16
            static let large: CGFloat = 24
            static let extraLarge: CGFloat = 32
            static let huge: CGFloat = 48
        }
        
        // Corner Radius
        struct CornerRadius {
            static let small: CGFloat = 8
            static let medium: CGFloat = 12
            static let large: CGFloat = 16
            static let extraLarge: CGFloat = 20
        }
        
        // Shadows
        struct Shadow {
            static let small = Color.black.opacity(0.1)
            static let medium = Color.black.opacity(0.15)
            static let large = Color.black.opacity(0.2)
        }
    }
    
    // MARK: - Camera Configuration
    struct Camera {
        static let maxImageSize: CGFloat = 1024
        static let compressionQuality: CGFloat = 0.8
        static let focusPoint = CGPoint(x: 0.5, y: 0.5)
        static let exposurePoint = CGPoint(x: 0.5, y: 0.5)
    }
    
    // MARK: - OCR Configuration
    struct OCR {
        static let minConfidenceThreshold: Double = 0.7
        static let maxProcessingTime: TimeInterval = 10.0
        static let supportedLanguages = ["en"]
    }
    
    // MARK: - Animation Durations
    struct Animation {
        static let short: Double = 0.2
        static let medium: Double = 0.3
        static let long: Double = 0.5
        static let spring = SwiftUI.Animation.easeInOut(duration: 0.3)
    }
    
    // MARK: - User Defaults Keys
    struct UserDefaultsKeys {
        static let hasRequestedCameraPermission = "hasRequestedCameraPermission"
        static let hasRequestedContactsPermission = "hasRequestedContactsPermission"
        static let lastScanDate = "lastScanDate"
        static let totalScansCount = "totalScansCount"
    }
    
    // MARK: - Error Messages
    struct ErrorMessages {
        static let cameraPermissionDenied = "Camera access is required to scan business cards. Please enable camera access in Settings."
        static let contactsPermissionDenied = "Contacts access is required to save business card information. Please enable contacts access in Settings."
        static let noTextDetected = "No text could be detected in the image. Please try again with better lighting or positioning."
        static let processingFailed = "Image processing failed. Please try again."
        static let saveContactFailed = "Failed to save contact. Please try again."
        static let invalidImage = "Invalid image. Please try again."
        static let networkError = "Network error. Please check your connection and try again."
    }
    
    // MARK: - Success Messages
    struct SuccessMessages {
        static let contactSaved = "Contact saved successfully!"
        static let imageProcessed = "Image processed successfully"
    }
    
    // MARK: - Validation Rules
    struct Validation {
        static let minNameLength = 2
        static let maxNameLength = 100
        static let minCompanyLength = 2
        static let maxCompanyLength = 100
        static let phoneNumberPattern = #"^[\+]?[1-9][\d]{0,15}$"#
        static let emailPattern = #"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
    }
}

// MARK: - Extensions for Constants

extension Constants.DesignSystem.Colors {
    /// Returns a color with the specified opacity
    static func withOpacity(_ color: Color, _ opacity: Double) -> Color {
        return color.opacity(opacity)
    }
}

extension Constants.DesignSystem.Typography {
    /// Returns a font with the specified weight
    static func withWeight(_ font: Font, _ weight: Font.Weight) -> Font {
        return font.weight(weight)
    }
}
