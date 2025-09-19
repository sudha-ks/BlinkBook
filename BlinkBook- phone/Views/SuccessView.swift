//
//  SuccessView.swift
//  BlinkBook
//
//  Created by Sudha on 10/09/25.
//

import SwiftUI
import UIKit

struct SuccessView: View {
    @EnvironmentObject var contactViewModel: ContactViewModel
    @EnvironmentObject var coordinator: AppCoordinator
    
    var body: some View {
        VStack(spacing: Constants.DesignSystem.Spacing.large) {
            Spacer()
            
            // Success animation
            VStack(spacing: Constants.DesignSystem.Spacing.medium) {
                // Success icon with animation
                SuccessAnimationView()
                
                Text("Contact Saved!")
                    .font(Constants.DesignSystem.Typography.title)
                    .foregroundColor(Constants.DesignSystem.Colors.text)
                
                if let businessCard = coordinator.businessCard {
                    Text("\(businessCard.fullName) from \(businessCard.company) has been saved to your contacts.")
                        .font(Constants.DesignSystem.Typography.body)
                        .foregroundColor(Constants.DesignSystem.Colors.secondaryText)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, Constants.DesignSystem.Spacing.large)
                } else {
                    Text("The business card information has been successfully saved to your contacts.")
                        .font(Constants.DesignSystem.Typography.body)
                        .foregroundColor(Constants.DesignSystem.Colors.secondaryText)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, Constants.DesignSystem.Spacing.large)
                }
            }
            
            Spacer()
            
            // Action buttons
            VStack(spacing: Constants.DesignSystem.Spacing.medium) {
                // Scan another button
                Button(action: scanAnother) {
                    HStack {
                        Image(systemName: "camera.fill")
                        Text("Scan Another Card")
                    }
                    .font(Constants.DesignSystem.Typography.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Constants.DesignSystem.Colors.primary)
                    .cornerRadius(Constants.DesignSystem.CornerRadius.medium)
                }
                
                // View contacts button
                Button(action: viewContacts) {
                    HStack {
                        Image(systemName: "person.2.fill")
                        Text("View Contacts")
                    }
                    .font(Constants.DesignSystem.Typography.headline)
                    .foregroundColor(Constants.DesignSystem.Colors.primary)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: Constants.DesignSystem.CornerRadius.medium)
                            .stroke(Constants.DesignSystem.Colors.primary, lineWidth: 2)
                    )
                }
            }
            .padding(.horizontal, Constants.DesignSystem.Spacing.large)
            .padding(.bottom, Constants.DesignSystem.Spacing.large)
        }
        .onAppear {
            // Auto-navigate back to camera after a delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                scanAnother()
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func scanAnother() {
        print("🔄 Scanning another card - resetting to camera")
        coordinator.resetToCamera()
    }
    
    private func viewContacts() {
        // Open the Contacts app
        if let url = URL(string: "contacts://") {
            UIApplication.shared.open(url)
        }
    }
}

// MARK: - Success Animation View

struct SuccessAnimationView: View {
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            // Background circle
            Circle()
                .fill(Constants.DesignSystem.Colors.success.opacity(0.2))
                .frame(width: 120, height: 120)
                .scaleEffect(isAnimating ? 1.2 : 1.0)
                .animation(
                    Animation.easeInOut(duration: 0.6)
                        .repeatForever(autoreverses: true),
                    value: isAnimating
                )
            
            // Success checkmark
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(Constants.DesignSystem.Colors.success)
                .scaleEffect(isAnimating ? 1.1 : 1.0)
                .animation(
                    Animation.easeInOut(duration: 0.8)
                        .repeatForever(autoreverses: true),
                    value: isAnimating
                )
        }
        .onAppear {
            isAnimating = true
        }
    }
}

#Preview {
    SuccessView()
        .environmentObject(ContactViewModel())
        .environmentObject(AppCoordinator())
}
