//
//  String+Extensions.swift
//  BlinkBook
//
//  Created by Sudha on 10/09/25.
//

import Foundation

extension String {
    
    /// Removes all whitespace and newlines from the string
    var trimmed: String {
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    /// Returns true if the string is a valid email address
    var isValidEmail: Bool {
        let emailRegex = Constants.Validation.emailPattern
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: self)
    }
    
    /// Returns true if the string is a valid phone number
    var isValidPhoneNumber: Bool {
        let phoneRegex = Constants.Validation.phoneNumberPattern
        let phonePredicate = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
        return phonePredicate.evaluate(with: self)
    }
    
    /// Formats a phone number for display
    var formattedPhoneNumber: String {
        let digits = self.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        
        if digits.count == 10 {
            return String(format: "(%@) %@-%@", 
                         String(digits.prefix(3)),
                         String(digits.dropFirst(3).prefix(3)),
                         String(digits.suffix(4)))
        } else if digits.count == 11 && digits.hasPrefix("1") {
            let withoutCountryCode = String(digits.dropFirst())
            return String(format: "+1 (%@) %@-%@",
                         String(withoutCountryCode.prefix(3)),
                         String(withoutCountryCode.dropFirst(3).prefix(3)),
                         String(withoutCountryCode.suffix(4)))
        }
        
        return self
    }
    
    /// Extracts phone number from text
    static func extractPhoneNumber(from text: String) -> String? {
        let phoneRegex = #"[\+]?[1-9][\d\s\-\(\)]{7,15}"#
        let regex = try? NSRegularExpression(pattern: phoneRegex)
        let range = NSRange(location: 0, length: text.utf16.count)
        
        if let match = regex?.firstMatch(in: text, options: [], range: range) {
            let phoneNumber = (text as NSString).substring(with: match.range)
            return phoneNumber.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        }
        
        return nil
    }
    
    /// Extracts email address from text
    static func extractEmail(from text: String) -> String? {
        let emailRegex = #"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}"#
        let regex = try? NSRegularExpression(pattern: emailRegex)
        let range = NSRange(location: 0, length: text.utf16.count)
        
        if let match = regex?.firstMatch(in: text, options: [], range: range) {
            return (text as NSString).substring(with: match.range)
        }
        
        return nil
    }
    
    /// Extracts website URL from text
    static func extractWebsite(from text: String) -> String? {
        let websiteRegex = #"(https?:\/\/)?(www\.)?[a-zA-Z0-9-]+\.[a-zA-Z]{2,}(\/[^\s]*)?"#
        let regex = try? NSRegularExpression(pattern: websiteRegex)
        let range = NSRange(location: 0, length: text.utf16.count)
        
        if let match = regex?.firstMatch(in: text, options: [], range: range) {
            return (text as NSString).substring(with: match.range)
        }
        
        return nil
    }
    
    /// Capitalizes the first letter of each word
    var capitalizedWords: String {
        return self.capitalized
    }
    
    /// Returns true if the string contains only letters and spaces
    var isAlphabetic: Bool {
        return self.range(of: "^[a-zA-Z\\s]+$", options: .regularExpression) != nil
    }
    
    /// Returns true if the string is empty or contains only whitespace
    var isEmptyOrWhitespace: Bool {
        return self.trimmed.isEmpty
    }
}
