//
//  ContactHistory.swift
//  BlinkBook
//
//  Created by Sudha on 10/09/25.
//

import Foundation

/// Represents a saved contact entry in history
struct ContactHistoryEntry: Codable, Identifiable {
    let id = UUID()
    let businessCard: BusinessCard
    let savedDate: Date
    let wasSuccessful: Bool
    
    init(businessCard: BusinessCard, savedDate: Date = Date(), wasSuccessful: Bool = true) {
        self.businessCard = businessCard
        self.savedDate = savedDate
        self.wasSuccessful = wasSuccessful
    }
}

/// Manages contact history storage and retrieval
class ContactHistoryManager: ObservableObject {
    
    // MARK: - Published Properties
    @Published var history: [ContactHistoryEntry] = []
    
    // MARK: - Private Properties
    private let userDefaults = UserDefaults.standard
    private let historyKey = "BlinkBookContactHistory"
    private let maxHistoryItems = 100 // Limit history to prevent storage bloat
    
    // MARK: - Initialization
    
    init() {
        loadHistory()
    }
    
    // MARK: - Public Methods
    
    /// Adds a contact to history
    /// - Parameters:
    ///   - businessCard: The business card that was saved
    ///   - wasSuccessful: Whether the save was successful
    func addToHistory(_ businessCard: BusinessCard, wasSuccessful: Bool = true) {
        let entry = ContactHistoryEntry(
            businessCard: businessCard,
            savedDate: Date(),
            wasSuccessful: wasSuccessful
        )
        
        history.insert(entry, at: 0) // Add to beginning for chronological order
        
        // Limit history size
        if history.count > maxHistoryItems {
            history = Array(history.prefix(maxHistoryItems))
        }
        
        saveHistory()
        
        print("📚 Added contact to history: \(businessCard.fullName)")
    }
    
    /// Clears all history
    func clearHistory() {
        history.removeAll()
        saveHistory()
        print("🗑️ Contact history cleared")
    }
    
    /// Gets successful contacts count
    var successfulContactsCount: Int {
        return history.filter { $0.wasSuccessful }.count
    }
    
    /// Gets failed contacts count
    var failedContactsCount: Int {
        return history.filter { !$0.wasSuccessful }.count
    }
    
    /// Gets contacts saved today
    var contactsSavedToday: Int {
        let calendar = Calendar.current
        let today = Date()
        
        return history.filter { entry in
            calendar.isDate(entry.savedDate, inSameDayAs: today) && entry.wasSuccessful
        }.count
    }
    
    /// Gets contacts saved this week
    var contactsSavedThisWeek: Int {
        let calendar = Calendar.current
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        
        return history.filter { entry in
            entry.savedDate >= weekAgo && entry.wasSuccessful
        }.count
    }
    
    // MARK: - Private Methods
    
    /// Loads history from UserDefaults
    private func loadHistory() {
        guard let data = userDefaults.data(forKey: historyKey) else {
            print("📚 No contact history found")
            return
        }
        
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            history = try decoder.decode([ContactHistoryEntry].self, from: data)
            print("📚 Loaded \(history.count) contact history entries")
        } catch {
            print("❌ Failed to load contact history: \(error)")
            history = []
        }
    }
    
    /// Saves history to UserDefaults
    private func saveHistory() {
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(history)
            userDefaults.set(data, forKey: historyKey)
            print("💾 Contact history saved")
        } catch {
            print("❌ Failed to save contact history: \(error)")
        }
    }
}
