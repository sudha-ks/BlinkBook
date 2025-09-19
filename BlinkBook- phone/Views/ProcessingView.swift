//
//  ProcessingView.swift
//  BlinkBook
//
//  Created by Sudha on 10/09/25.
//

import SwiftUI

struct ProcessingView: View {
    @EnvironmentObject var ocrViewModel: OCRViewModel
    
    var body: some View {
        VStack(spacing: Constants.DesignSystem.Spacing.large) {
            Spacer()
            
            // Processing animation
            VStack(spacing: Constants.DesignSystem.Spacing.medium) {
                // Animated scanning icon
                ScanningAnimationView()
                
                Text("Processing Business Card")
                    .font(Constants.DesignSystem.Typography.title2)
                    .foregroundColor(Constants.DesignSystem.Colors.text)
                
                Text("Extracting contact information...")
                    .font(Constants.DesignSystem.Typography.body)
                    .foregroundColor(Constants.DesignSystem.Colors.secondaryText)
                
                // Progress bar
                ProgressView(value: ocrViewModel.processingProgress)
                    .progressViewStyle(LinearProgressViewStyle(tint: Constants.DesignSystem.Colors.primary))
                    .frame(width: 200)
            }
            
            Spacer()
            
            // Error handling
            if let errorMessage = ocrViewModel.errorMessage {
                ErrorView(
                    message: errorMessage,
                    onRetry: {
                        // Retry logic would go here
                        ocrViewModel.clearError()
                    }
                )
            }
        }
        .padding(Constants.DesignSystem.Spacing.large)
    }
}

// MARK: - Scanning Animation View

struct ScanningAnimationView: View {
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            // Background circle
            Circle()
                .stroke(Constants.DesignSystem.Colors.primary.opacity(0.3), lineWidth: 4)
                .frame(width: 120, height: 120)
            
            // Scanning line
            Rectangle()
                .fill(Constants.DesignSystem.Colors.primary)
                .frame(width: 100, height: 3)
                .offset(y: isAnimating ? 50 : -50)
                .animation(
                    Animation.easeInOut(duration: 1.5)
                        .repeatForever(autoreverses: true),
                    value: isAnimating
                )
            
            // Center icon
            Image(systemName: "doc.text.viewfinder")
                .font(.system(size: 40))
                .foregroundColor(Constants.DesignSystem.Colors.primary)
        }
        .onAppear {
            isAnimating = true
        }
    }
}

// MARK: - Error View

struct ErrorView: View {
    let message: String
    let onRetry: () -> Void
    
    var body: some View {
        VStack(spacing: Constants.DesignSystem.Spacing.medium) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundColor(Constants.DesignSystem.Colors.error)
            
            Text("Processing Failed")
                .font(Constants.DesignSystem.Typography.headline)
                .foregroundColor(Constants.DesignSystem.Colors.text)
            
            Text(message)
                .font(Constants.DesignSystem.Typography.body)
                .foregroundColor(Constants.DesignSystem.Colors.secondaryText)
                .multilineTextAlignment(.center)
            
            Button(action: onRetry) {
                Text("Try Again")
                    .font(Constants.DesignSystem.Typography.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Constants.DesignSystem.Colors.primary)
                    .cornerRadius(Constants.DesignSystem.CornerRadius.medium)
            }
        }
        .padding(Constants.DesignSystem.Spacing.large)
        .background(Constants.DesignSystem.Colors.secondaryBackground)
        .cornerRadius(Constants.DesignSystem.CornerRadius.large)
        .padding(.horizontal, Constants.DesignSystem.Spacing.medium)
    }
}

#Preview {
    ProcessingView()
        .environmentObject(OCRViewModel())
}
