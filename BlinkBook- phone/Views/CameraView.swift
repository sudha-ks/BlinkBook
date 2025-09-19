//
//  CameraView.swift
//  BlinkBook
//
//  Created by Sudha on 10/09/25.
//

import SwiftUI
import AVFoundation
import UIKit

struct CameraView: View {
    @EnvironmentObject var cameraViewModel: CameraViewModel
    @EnvironmentObject var coordinator: AppCoordinator
    @State private var showingPermissionAlert = false
    
    var body: some View {
        ZStack {
            // Camera preview
            if cameraViewModel.permissionStatus == .authorized {
                CameraPreviewView(session: cameraViewModel.captureSession)
                    .ignoresSafeArea()
                
                // Business card detection overlay
                BusinessCardOverlayView()
                
                // Top controls
                VStack {
                    HStack {
                        Spacer()
                        
                        // History button
                        Button(action: {
                            coordinator.navigateTo(.history)
                        }) {
                            Image(systemName: "clock.arrow.circlepath")
                                .font(.title2)
                                .foregroundColor(.white)
                                .frame(width: 44, height: 44)
                                .background(Color.black.opacity(0.5))
                                .clipShape(Circle())
                        }
                        .padding(.top, 60)
                        .padding(.trailing, 20)
                    }
                    
                    Spacer()
                    
                    // Camera controls
                    CameraControlsView(
                        isCapturing: cameraViewModel.isCapturing,
                        onCapture: {
                            cameraViewModel.capturePhoto()
                        }
                    )
                    .padding(.bottom, 50)
                }
            } else {
                // Permission request view
                PermissionRequestView(
                    permissionStatus: cameraViewModel.permissionStatus,
                    onRequestPermission: {
                        cameraViewModel.requestPermission()
                    }
                )
            }
            
            // Error overlay
            if let errorMessage = cameraViewModel.errorMessage {
                ErrorOverlayView(
                    message: errorMessage,
                    onDismiss: {
                        cameraViewModel.clearError()
                    }
                )
            }
        }
        .onAppear {
            if cameraViewModel.permissionStatus == .authorized {
                cameraViewModel.startSession()
            } else {
                cameraViewModel.checkPermissionStatus()
                if cameraViewModel.permissionStatus == .notDetermined {
                    cameraViewModel.requestPermission()
                }
            }
        }
        .onDisappear {
            cameraViewModel.stopSession()
        }
    }
}

// MARK: - Camera Preview View

struct CameraPreviewView: UIViewRepresentable {
    let session: AVCaptureSession?
    
    func makeUIView(context: Context) -> CameraPreviewUIView {
        let view = CameraPreviewUIView()
        view.backgroundColor = .black
        return view
    }
    
    func updateUIView(_ uiView: CameraPreviewUIView, context: Context) {
        if let session = session, uiView.previewLayer.session != session {
            uiView.previewLayer.session = session
        }
    }
}

class CameraPreviewUIView: UIView {
    override class var layerClass: AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }
    
    var previewLayer: AVCaptureVideoPreviewLayer {
        return layer as! AVCaptureVideoPreviewLayer
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        previewLayer.frame = bounds
        previewLayer.videoGravity = .resizeAspectFill
    }
}

// MARK: - Business Card Overlay View

struct BusinessCardOverlayView: View {
    var body: some View {
        ZStack {
            // Semi-transparent overlay
            Color.black.opacity(0.3)
                .ignoresSafeArea()
            
            // Business card frame
            RoundedRectangle(cornerRadius: Constants.DesignSystem.CornerRadius.medium)
                .stroke(Constants.DesignSystem.Colors.primary, lineWidth: 3)
                .frame(width: 280, height: 180)
                .overlay(
                    VStack {
                        Text("Position business card here")
                            .font(Constants.DesignSystem.Typography.caption)
                            .foregroundColor(.white)
                            .padding(.top, 8)
                        Spacer()
                    }
                )
        }
    }
}

// MARK: - Camera Controls View

struct CameraControlsView: View {
    let isCapturing: Bool
    let onCapture: () -> Void
    
    var body: some View {
        HStack(spacing: Constants.DesignSystem.Spacing.large) {
            // Gallery button (placeholder)
            Button(action: {}) {
                Image(systemName: "photo.on.rectangle")
                    .font(.title2)
                    .foregroundColor(.white)
                    .frame(width: 50, height: 50)
                    .background(Color.black.opacity(0.5))
                    .clipShape(Circle())
            }
            
            // Capture button
            Button(action: {
                print("🔘 Capture button tapped in UI")
                onCapture()
            }) {
                ZStack {
                    Circle()
                        .fill(isCapturing ? Color.gray : Color.white)
                        .frame(width: 80, height: 80)
                    
                    Circle()
                        .stroke(Color.black, lineWidth: 3)
                        .frame(width: 70, height: 70)
                    
                    if isCapturing {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .black))
                            .scaleEffect(0.8)
                    } else {
                        Circle()
                            .fill(Color.black)
                            .frame(width: 20, height: 20)
                    }
                }
            }
            .disabled(isCapturing)
            .scaleEffect(isCapturing ? 0.9 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: isCapturing)
            
            // Flash button (placeholder)
            Button(action: {}) {
                Image(systemName: "bolt.slash")
                    .font(.title2)
                    .foregroundColor(.white)
                    .frame(width: 50, height: 50)
                    .background(Color.black.opacity(0.5))
                    .clipShape(Circle())
            }
        }
    }
}

// MARK: - Permission Request View

struct PermissionRequestView: View {
    let permissionStatus: CameraPermissionStatus
    let onRequestPermission: () -> Void
    
    var body: some View {
        VStack(spacing: Constants.DesignSystem.Spacing.large) {
            Image(systemName: "camera.fill")
                .font(.system(size: 80))
                .foregroundColor(Constants.DesignSystem.Colors.primary)
            
            Text("Camera Access Required")
                .font(Constants.DesignSystem.Typography.title)
                .foregroundColor(Constants.DesignSystem.Colors.text)
            
            Text("BlinkBook needs camera access to scan business cards. Please enable camera access in Settings.")
                .font(Constants.DesignSystem.Typography.body)
                .foregroundColor(Constants.DesignSystem.Colors.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, Constants.DesignSystem.Spacing.large)
            
            Button(action: onRequestPermission) {
                Text("Enable Camera Access")
                    .font(Constants.DesignSystem.Typography.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Constants.DesignSystem.Colors.primary)
                    .cornerRadius(Constants.DesignSystem.CornerRadius.medium)
            }
            .padding(.horizontal, Constants.DesignSystem.Spacing.large)
        }
    }
}

// MARK: - Error Overlay View

struct ErrorOverlayView: View {
    let message: String
    let onDismiss: () -> Void
    
    var body: some View {
        VStack {
            Spacer()
            
            HStack {
                VStack(alignment: .leading, spacing: Constants.DesignSystem.Spacing.small) {
                    Text("Error")
                        .font(Constants.DesignSystem.Typography.headline)
                        .foregroundColor(.white)
                    
                    Text(message)
                        .font(Constants.DesignSystem.Typography.body)
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                Button(action: onDismiss) {
                    Image(systemName: "xmark")
                        .font(.title2)
                        .foregroundColor(.white)
                }
            }
            .padding()
            .background(Color.red.opacity(0.9))
            .cornerRadius(Constants.DesignSystem.CornerRadius.medium)
            .padding(.horizontal, Constants.DesignSystem.Spacing.medium)
        }
    }
}

#Preview {
    CameraView()
        .environmentObject(CameraViewModel())
}
