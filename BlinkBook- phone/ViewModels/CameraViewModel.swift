//
//  CameraViewModel.swift
//  BlinkBook
//
//  Created by Sudha on 10/09/25.
//

import Foundation
import AVFoundation
import Combine
import UIKit

/// ViewModel responsible for camera functionality and photo capture
class CameraViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var captureSession: AVCaptureSession?
    @Published var isSessionRunning = false
    @Published var isCapturing = false
    @Published var permissionStatus: CameraPermissionStatus = .notDetermined
    @Published var errorMessage: String?
    @Published var capturedImage: UIImage?
    
    // MARK: - Private Properties
    private let cameraService: CameraServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    init(cameraService: CameraServiceProtocol = CameraService()) {
        self.cameraService = cameraService
        checkPermissionStatus()
    }
    
    // MARK: - Public Methods
    
    /// Checks the current camera permission status
    func checkPermissionStatus() {
        permissionStatus = cameraService.checkPermissionStatus()
    }
    
    /// Requests camera permission
    func requestPermission() {
        cameraService.requestPermission()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure = completion {
                        self?.errorMessage = Constants.ErrorMessages.cameraPermissionDenied
                    }
                },
                receiveValue: { [weak self] granted in
                    self?.permissionStatus = granted ? .authorized : .denied
                    if granted {
                        self?.startSession()
                    }
                }
            )
            .store(in: &cancellables)
    }
    
    /// Starts the camera session
    func startSession() {
        guard permissionStatus == .authorized else {
            requestPermission()
            return
        }
        
        cameraService.startSession()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        print("❌ Camera start session failed: \(error)")
                        self?.errorMessage = error.localizedDescription
                        self?.isSessionRunning = false
                    }
                },
                receiveValue: { [weak self] session in
                    print("✅ Camera session received in ViewModel")
                    self?.captureSession = session
                    self?.isSessionRunning = session.isRunning
                    print("📱 Session running: \(session.isRunning), inputs: \(session.inputs.count), outputs: \(session.outputs.count)")
                }
            )
            .store(in: &cancellables)
    }
    
    /// Stops the camera session
    func stopSession() {
        cameraService.stopSession()
        isSessionRunning = false
        captureSession = nil
    }
    
    /// Captures a photo from the current camera session
    func capturePhoto() {
        print("📸 Capture photo button tapped")
        
        guard isSessionRunning else {
            print("❌ Cannot capture: session not running")
            errorMessage = "Camera session is not running"
            return
        }
        
        guard !isCapturing else {
            print("❌ Cannot capture: already capturing")
            return
        }
        
        print("📸 Starting photo capture...")
        isCapturing = true
        
        cameraService.capturePhoto()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    print("📸 Capture completion received")
                    self?.isCapturing = false
                    if case .failure(let error) = completion {
                        print("❌ Capture failed: \(error.localizedDescription)")
                        self?.errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { [weak self] image in
                    print("✅ Photo captured successfully! Image size: \(image.size)")
                    self?.capturedImage = image
                    self?.isCapturing = false
                }
            )
            .store(in: &cancellables)
    }
    
    /// Clears any error messages
    func clearError() {
        errorMessage = nil
    }
    
    /// Resets the captured image
    func resetCapturedImage() {
        print("📷 Resetting captured image")
        capturedImage = nil
        isCapturing = false
    }
    
    // MARK: - Deinitialization
    
    deinit {
        stopSession()
        cancellables.removeAll()
    }
}
