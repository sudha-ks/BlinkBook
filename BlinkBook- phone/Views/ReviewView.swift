//
//  ReviewView.swift
//  BlinkBook
//
//  Created by Sudha on 10/09/25.
//

import SwiftUI

struct ReviewView: View {
    @EnvironmentObject var ocrViewModel: OCRViewModel
    @EnvironmentObject var contactViewModel: ContactViewModel
    @EnvironmentObject var coordinator: AppCoordinator
    
    @State private var editedData: ExtractedData?
    @State private var showingSaveAlert = false
    @State private var showingErrorAlert = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: Constants.DesignSystem.Spacing.large) {
                    // Header
                    VStack(spacing: Constants.DesignSystem.Spacing.small) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(Constants.DesignSystem.Colors.success)
                        
                        Text("Review Extracted Data")
                            .font(Constants.DesignSystem.Typography.title2)
                            .foregroundColor(Constants.DesignSystem.Colors.text)
                        
                        Text("Please verify and edit the information below")
                            .font(Constants.DesignSystem.Typography.body)
                            .foregroundColor(Constants.DesignSystem.Colors.secondaryText)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, Constants.DesignSystem.Spacing.large)
                    
                    // Form fields
                    if let data = editedData ?? ocrViewModel.extractedData {
                        VStack(spacing: Constants.DesignSystem.Spacing.medium) {
                            // Full Name
                            FormFieldView(
                                title: "Full Name",
                                text: Binding(
                                    get: { data.fullName },
                                    set: { updateField(.fullName, value: $0) }
                                ),
                                isRequired: true,
                                confidence: data.confidenceScores.fullName
                            )
                            
                            // Company
                            FormFieldView(
                                title: "Company",
                                text: Binding(
                                    get: { data.company },
                                    set: { updateField(.company, value: $0) }
                                ),
                                isRequired: true,
                                confidence: data.confidenceScores.company
                            )
                            
                            // Phone Number
                            FormFieldView(
                                title: "Phone Number",
                                text: Binding(
                                    get: { data.phoneNumber },
                                    set: { updateField(.phoneNumber, value: $0) }
                                ),
                                isRequired: true,
                                confidence: data.confidenceScores.phoneNumber
                            )
                            
                            // Email (optional)
                            FormFieldView(
                                title: "Email",
                                text: Binding(
                                    get: { data.email ?? "" },
                                    set: { updateField(.email, value: $0.isEmpty ? nil : $0) }
                                ),
                                isRequired: false,
                                confidence: data.confidenceScores.email
                            )
                            
                            // Job Title (optional)
                            FormFieldView(
                                title: "Job Title",
                                text: Binding(
                                    get: { data.jobTitle ?? "" },
                                    set: { updateField(.jobTitle, value: $0.isEmpty ? nil : $0) }
                                ),
                                isRequired: false,
                                confidence: data.confidenceScores.jobTitle
                            )
                        }
                        .padding(.horizontal, Constants.DesignSystem.Spacing.medium)
                    }
                    
                    // Action buttons
                    VStack(spacing: Constants.DesignSystem.Spacing.medium) {
                        // Save button
                        Button(action: saveContact) {
                            HStack {
                                if contactViewModel.isSaving {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(0.8)
                                } else {
                                    Image(systemName: "person.crop.circle.badge.plus")
                                }
                                
                                Text(contactViewModel.isSaving ? "Saving..." : "Save Contact")
                            }
                            .font(Constants.DesignSystem.Typography.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Constants.DesignSystem.Colors.primary)
                            .cornerRadius(Constants.DesignSystem.CornerRadius.medium)
                        }
                        .disabled(contactViewModel.isSaving || !isValidData)
                        
                        // Cancel button
                        Button(action: cancelReview) {
                            Text("Cancel")
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
                    .padding(.horizontal, Constants.DesignSystem.Spacing.medium)
                    .padding(.bottom, Constants.DesignSystem.Spacing.large)
                }
            }
            .navigationBarHidden(true)
        }
        .onAppear {
            print("📝 ReviewView appeared")
            
            // Always refresh edited data from current OCR result
            if let data = ocrViewModel.extractedData {
                print("📝 Loading fresh extracted data: \(data.fullName)")
                editedData = data
            } else {
                print("⚠️ No extracted data available in OCR view model")
                editedData = nil
            }
            
            // Check contacts permission status
            contactViewModel.checkPermissionStatus()
        }
        .onDisappear {
            print("📝 ReviewView disappeared - clearing edited data")
            editedData = nil
        }
        .alert("Save Contact", isPresented: $showingSaveAlert) {
            Button("Save") {
                performSave()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to save this contact to your phone?")
        }
        .alert("Error", isPresented: $showingErrorAlert) {
            Button("OK") {}
        } message: {
            Text(contactViewModel.errorMessage ?? "An error occurred while saving the contact.")
        }
        .onChange(of: contactViewModel.errorMessage) { errorMessage in
            if errorMessage != nil {
                showingErrorAlert = true
            }
        }
        .onChange(of: contactViewModel.successMessage) { successMessage in
            if successMessage != nil {
                // Navigate back to camera after success
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    coordinator.resetToCamera()
                }
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func updateField(_ field: DataField, value: Any) {
        guard var data = editedData else { return }
        
        switch field {
        case .fullName:
            data.fullName = value as? String ?? ""
        case .company:
            data.company = value as? String ?? ""
        case .phoneNumber:
            data.phoneNumber = value as? String ?? ""
        case .email:
            data.email = value as? String
        case .jobTitle:
            data.jobTitle = value as? String
        }
        
        editedData = data
    }
    
    private var isValidData: Bool {
        guard let data = editedData else { return false }
        return !data.fullName.isEmpty && !data.company.isEmpty && !data.phoneNumber.isEmpty
    }
    
    private func saveContact() {
        showingSaveAlert = true
    }
    
    private func performSave() {
        guard let data = editedData else { return }
        
        let businessCard = data.toBusinessCard(imageData: coordinator.capturedImage?.toJPEGData())
        coordinator.handleContactSaving(businessCard)
    }
    
    private func cancelReview() {
        coordinator.resetToCamera()
    }
}

// MARK: - Data Field Enum

private enum DataField {
    case fullName
    case company
    case phoneNumber
    case email
    case jobTitle
}

// MARK: - Form Field View

struct FormFieldView: View {
    let title: String
    @Binding var text: String
    let isRequired: Bool
    let confidence: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: Constants.DesignSystem.Spacing.small) {
            HStack {
                Text(title)
                    .font(Constants.DesignSystem.Typography.headline)
                    .foregroundColor(Constants.DesignSystem.Colors.text)
                
                if isRequired {
                    Text("*")
                        .foregroundColor(Constants.DesignSystem.Colors.error)
                }
                
                Spacer()
                
                // Confidence indicator
                ConfidenceIndicatorView(confidence: confidence)
            }
            
            TextField("Enter \(title.lowercased())", text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .font(Constants.DesignSystem.Typography.body)
        }
    }
}

// MARK: - Confidence Indicator View

struct ConfidenceIndicatorView: View {
    let confidence: Double
    
    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(confidenceColor)
                .frame(width: 8, height: 8)
            
            Text("\(Int(confidence * 100))%")
                .font(Constants.DesignSystem.Typography.caption)
                .foregroundColor(confidenceColor)
        }
    }
    
    private var confidenceColor: Color {
        if confidence >= 0.8 {
            return Constants.DesignSystem.Colors.success
        } else if confidence >= 0.6 {
            return Constants.DesignSystem.Colors.warning
        } else {
            return Constants.DesignSystem.Colors.error
        }
    }
}

#Preview {
    ReviewView()
        .environmentObject(OCRViewModel())
        .environmentObject(ContactViewModel())
        .environmentObject(AppCoordinator())
}
