//
//  HistoryView.swift
//  BlinkBook
//
//  Created by Sudha on 10/09/25.
//

import SwiftUI

struct HistoryView: View {
    @EnvironmentObject var coordinator: AppCoordinator
    @StateObject private var historyManager = ContactHistoryManager()
    @State private var showingClearAlert = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Statistics header
                StatisticsHeaderView(historyManager: historyManager)
                
                // History list
                if historyManager.history.isEmpty {
                    EmptyHistoryView()
                } else {
                    List {
                        ForEach(historyManager.history) { entry in
                            ContactHistoryRow(entry: entry)
                        }
                    }
                    .listStyle(PlainListStyle())
                }
                
                Spacer()
                
                // Action buttons
                VStack(spacing: Constants.DesignSystem.Spacing.medium) {
                    // Back to camera button
                    Button(action: {
                        coordinator.resetToCamera()
                    }) {
                        HStack {
                            Image(systemName: "camera.fill")
                            Text("Back to Scanner")
                        }
                        .font(Constants.DesignSystem.Typography.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Constants.DesignSystem.Colors.primary)
                        .cornerRadius(Constants.DesignSystem.CornerRadius.medium)
                    }
                    
                    // Clear history button
                    if !historyManager.history.isEmpty {
                        Button(action: {
                            showingClearAlert = true
                        }) {
                            Text("Clear History")
                                .font(Constants.DesignSystem.Typography.callout)
                                .foregroundColor(Constants.DesignSystem.Colors.error)
                        }
                    }
                }
                .padding(.horizontal, Constants.DesignSystem.Spacing.medium)
                .padding(.bottom, Constants.DesignSystem.Spacing.large)
            }
            .navigationTitle("Contact History")
            .navigationBarTitleDisplayMode(.large)
        }
        .alert("Clear History", isPresented: $showingClearAlert) {
            Button("Clear", role: .destructive) {
                historyManager.clearHistory()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to clear all contact history? This action cannot be undone.")
        }
        .environmentObject(historyManager)
    }
}

// MARK: - Statistics Header View

struct StatisticsHeaderView: View {
    let historyManager: ContactHistoryManager
    
    var body: some View {
        VStack(spacing: Constants.DesignSystem.Spacing.medium) {
            HStack(spacing: Constants.DesignSystem.Spacing.large) {
                StatCard(
                    title: "Total Saved",
                    value: "\(historyManager.successfulContactsCount)",
                    color: Constants.DesignSystem.Colors.success
                )
                
                StatCard(
                    title: "This Week",
                    value: "\(historyManager.contactsSavedThisWeek)",
                    color: Constants.DesignSystem.Colors.primary
                )
                
                StatCard(
                    title: "Today",
                    value: "\(historyManager.contactsSavedToday)",
                    color: Constants.DesignSystem.Colors.warning
                )
            }
        }
        .padding(Constants.DesignSystem.Spacing.medium)
        .background(Constants.DesignSystem.Colors.secondaryBackground)
    }
}

// MARK: - Stat Card

struct StatCard: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: Constants.DesignSystem.Spacing.small) {
            Text(value)
                .font(Constants.DesignSystem.Typography.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(title)
                .font(Constants.DesignSystem.Typography.caption)
                .foregroundColor(Constants.DesignSystem.Colors.secondaryText)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Constants.DesignSystem.Colors.background)
        .cornerRadius(Constants.DesignSystem.CornerRadius.medium)
    }
}

// MARK: - Contact History Row

struct ContactHistoryRow: View {
    let entry: ContactHistoryEntry
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: Constants.DesignSystem.Spacing.small) {
                Text(entry.businessCard.fullName)
                    .font(Constants.DesignSystem.Typography.headline)
                    .foregroundColor(Constants.DesignSystem.Colors.text)
                
                Text(entry.businessCard.company)
                    .font(Constants.DesignSystem.Typography.body)
                    .foregroundColor(Constants.DesignSystem.Colors.secondaryText)
                
                Text(entry.businessCard.phoneNumber)
                    .font(Constants.DesignSystem.Typography.caption)
                    .foregroundColor(Constants.DesignSystem.Colors.secondaryText)
                
                Text(formatDate(entry.savedDate))
                    .font(Constants.DesignSystem.Typography.caption2)
                    .foregroundColor(Constants.DesignSystem.Colors.secondaryText)
            }
            
            Spacer()
            
            // Status indicator
            Image(systemName: entry.wasSuccessful ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundColor(entry.wasSuccessful ? Constants.DesignSystem.Colors.success : Constants.DesignSystem.Colors.error)
                .font(.title2)
        }
        .padding(.vertical, Constants.DesignSystem.Spacing.small)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - Empty History View

struct EmptyHistoryView: View {
    var body: some View {
        VStack(spacing: Constants.DesignSystem.Spacing.large) {
            Spacer()
            
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 80))
                .foregroundColor(Constants.DesignSystem.Colors.secondaryText)
            
            Text("No Contacts Scanned Yet")
                .font(Constants.DesignSystem.Typography.title2)
                .foregroundColor(Constants.DesignSystem.Colors.text)
            
            Text("Start scanning business cards to see your history here.")
                .font(Constants.DesignSystem.Typography.body)
                .foregroundColor(Constants.DesignSystem.Colors.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, Constants.DesignSystem.Spacing.large)
            
            Spacer()
        }
    }
}

#Preview {
    HistoryView()
        .environmentObject(AppCoordinator())
}
